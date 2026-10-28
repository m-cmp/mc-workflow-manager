#!/usr/bin/env groovy
// Run from the repository root: groovy script/test-multi-csp-k8s-pipeline.groovy
// Executes the seeded pipelines locally; no Jenkins or cloud requests are made.
import groovy.json.JsonOutput
import groovy.json.JsonSlurperClassic
import org.codehaus.groovy.control.CompilerConfiguration

class PipelineFailure extends RuntimeException {
    PipelineFailure(Object message) { super(message.toString()) }
}

abstract class PipelineHarness extends Script {
    Map responses = [:]
    Map nodeGroupReply = [code: 200, body: [:]]
    Map files = [:]
    List calls = []

    def pipeline(Closure body) { body() }
    def stages(Closure body) { body() }
    def stage(String name, Closure body) { body() }
    def steps(Closure body) { body() }
    def script(Closure body) { body() }
    def agent(Object value) { }
    def echo(Object value) { }
    def sleep(Map options) { }
    def error(Object message) { throw new PipelineFailure(message) }
    def writeFile(Map options) { files[options.file.toString()] = options.text.toString() }

    Object assertSerializable(Object snapshot) {
        new ObjectOutputStream(new ByteArrayOutputStream()).withCloseable { it.writeObject(snapshot) }
        snapshot
    }

    String sh(Map options) {
        def request = options.script.toString() =~ /-X (GET|POST) "([^"]+)"/
        assert request.find(): "Unexpected shell command: ${options.script}"
        def call = [method: request.group(1), url: request.group(2)]
        def data = options.script.toString() =~ /-d @([^\s]+)/
        if (data.find()) {
            call.payload = new JsonSlurperClassic().parseText(files[data.group(1)])
        }
        calls << call
        Map response
        if (call.url.endsWith("/tumblebug/ns/default") && call.method == "GET") {
            response = [code: 200, body: [name: "default"]]
        } else if (call.url.contains("/k8sClusterDynamic") && call.method == "POST") {
            response = [code: 200, body: [status: "Creating"]]
        } else if (call.url.endsWith("/k8sNodeGroupDynamic") && call.method == "POST") {
            response = nodeGroupReply
        } else if (call.url.contains("/k8sCluster/") && call.method == "GET") {
            def clusterId = call.url.split("/k8sCluster/")[1].split(/[?\/]/)[0]
            def queue = responses[clusterId.tokenize("-").last()]
            assert queue: "No response prepared for ${call.url}"
            response = queue.size() > 1 ? queue.remove(0) : queue[0]
        } else {
            throw new AssertionError("Unexpected request: ${call}")
        }
        call.response = response
        def body = response.body instanceof String ? response.body : JsonOutput.toJson(response.body)
        return "${body}- Http_Status_code:${response.code}"
    }
}

def sql = new File(args ? args[0] : "src/main/resources/import.sql").getText("UTF-8")
def extractLiteral = { String marker ->
    int start = sql.indexOf(marker)
    assert start >= 0: "Missing SQL seed: ${marker}"
    // SQL escapes apostrophes by doubling them; preserve Groovy backslashes verbatim.
    def literal = sql.substring(start + marker.length()) =~ /(?s)^((?:[^']++|'')*+)'/
    assert literal.find(): "Unterminated SQL literal: ${marker}"
    literal.group(1).replace("''", "'")
}
def sources = [
    stage51: extractLiteral("VALUES (51, 18, 9, 'multi-csp-k8s-cluster-deploy', 'Deploy K8s clusters across 8 CSPs', '"),
    workflow104: extractLiteral("VALUES (104, 'multi-csp-k8s-cluster-deploy', 'For Deployment', 1, '")
]
def defaults = [
    TUMBLEBUG: "http://tumblebug.test", NAMESPACE: "default", CSP_LIST: "aws",
    SPEC_ID: "generic-spec", IMAGE_ID: "generic-image", REGION: "generic-region",
    K8S_STATUS_MAX_ATTEMPTS: "4", K8S_STATUS_INTERVAL_SECONDS: "1"
]
def reply = { body, int code = 200 -> [code: code, body: body] }
def group = { String csp, int count = 1, String status = "Active" ->
    [name: "ng${csp}", status: status, k8sNodes: (0..<count).collect { [cspResourceId: "node-${it}"] }]
}
def cluster = { List groups = [], String status = "Active" ->
    [status: status, k8sNodeGroupList: groups]
}
def run = { String source, Map overrides, Map responses, Map postReply = reply([:]) ->
    def config = new CompilerConfiguration(scriptBaseClass: PipelineHarness.name)
    def shell = new GroovyShell(this.class.classLoader, new Binding([params: defaults + overrides, any: "any"]), config)
    // Check snapshots before the next Jenkins step could persist the pipeline.
    def checkedSource = source.replace("clusterInfo = parseClusterResponse(statusResponse)",
        "clusterInfo = assertSerializable(parseClusterResponse(statusResponse))")
    def pipeline = shell.parse(checkedSource)
    pipeline.setResponses(responses.collectEntries { csp, queue -> [(csp): new ArrayList(queue)] })
    pipeline.setNodeGroupReply(postReply)
    pipeline.run()
    pipeline
}
def additions = { pipeline -> pipeline.calls.findAll { it.method == "POST" && it.url.endsWith("/k8sNodeGroupDynamic") } }
def mustFail = { Closure body ->
    boolean failed = false
    try { body() } catch (PipelineFailure expected) { failed = true }
    assert failed: "Pipeline incorrectly succeeded"
}

int scenarios = 0
sources.each { variant, source ->
    def verify = { String description, Closure body ->
        body()
        scenarios++
        println "PASS ${variant}: ${description}"
    }
    verify("all three providers create groups after the control plane is active") {
        def overrides = [CSP_LIST: "alibaba,aws,tencent", K8S_DESIRED_NODE_SIZE: "3", K8S_MIN_NODE_SIZE: "2", K8S_MAX_NODE_SIZE: "5", ROOT_DISK_SIZE: "80"]
        def responses = [:]
        ["alibaba", "aws", "tencent"].each { csp ->
            overrides["${csp.toUpperCase()}_SPEC_ID".toString()] = "${csp}-spec".toString()
            overrides["${csp.toUpperCase()}_IMAGE_ID".toString()] = "${csp}-image".toString()
            overrides["${csp.toUpperCase()}_REGION".toString()] = "${csp}-region".toString()
            responses[csp] = [reply(cluster([group(csp, 3)], "Updating")), reply(cluster()), reply(cluster([group(csp, 3)]))]
        }
        def pipeline = run(source, overrides, responses)
        assert additions(pipeline).size() == 3
        additions(pipeline).each { call ->
            def csp = call.url.split("/k8sCluster/")[1].split("/")[0].tokenize("-").last()
            def expectedDiskType = [alibaba: "cloud_essd", tencent: "CLOUD_BSSD"][csp] ?: "default"
            assert call.payload == [name: "ng${csp}".toString(), specId: "${csp}-spec".toString(), imageId: "${csp}-image".toString(), rootDiskType: expectedDiskType, rootDiskSize: 80, desiredNodeSize: 3, minNodeSize: 2, maxNodeSize: 5]
            def before = pipeline.calls.take(pipeline.calls.indexOf(call))
            assert before.any { it.method == "POST" && it.url.contains("/k8sClusterDynamic") && it.payload.label.csp == csp }
            def gets = before.findAll { it.method == "GET" && it.url.contains("/k8sCluster/multi-csp-k8s-${csp}?") }
            assert gets.size() == 2
            assert gets.last().response.body.status == "Active"
        }
    }
    verify("explicit disk type and provider image default are preserved") {
        def pipeline = run(source, [CSP_LIST: "tencent", IMAGE_ID: "", ROOT_DISK_TYPE: "CLOUD_SSD"], [tencent: [reply(cluster()), reply(cluster([group("tencent")]))]])
        assert additions(pipeline).first().payload.rootDiskType == "CLOUD_SSD"
        assert !additions(pipeline).first().payload.containsKey("imageId")
    }
    verify("existing expected groups are reused for all three providers") {
        ["alibaba", "aws", "tencent"].each { csp ->
            def pipeline = run(source, [CSP_LIST: csp], [(csp): [reply(cluster([group(csp)]))]])
            assert additions(pipeline).isEmpty()
        }
    }
    verify("group must become Active and reach the requested worker count") {
        def pipeline = run(source, [K8S_DESIRED_NODE_SIZE: "3"], [aws: [reply(cluster()), reply(cluster([group("aws", 3, "Creating")])), reply(cluster([group("aws", 1)])), reply(cluster([group("aws", 3)]))]])
        assert additions(pipeline).size() == 1
        assert pipeline.calls.count { it.method == "GET" && it.url.contains("/k8sCluster/") } == 4
    }
    verify("the other five providers never receive an extra node group POST") {
        ["azure", "gcp", "ibm", "ncp", "nhn"].each { csp ->
            def pipeline = run(source, [CSP_LIST: csp], [(csp): [reply(cluster([group(csp)]))]])
            assert additions(pipeline).isEmpty()
        }
    }
    verify("failed group POST is fatal even when its message contains already") {
        mustFail { run(source, [:], [aws: [reply(cluster())]], reply([message: "dependency already unavailable"], 500)) }
    }
    verify("empty worker lists and non-Active groups time out") {
        [group("aws", 0), group("aws", 1, "Creating")].each { nodeGroup ->
            mustFail { run(source, [:], [aws: [reply(cluster()), reply(cluster([nodeGroup]))]]) }
        }
    }
    verify("HTTP errors during cluster or group polling cannot succeed") {
        mustFail { run(source, [:], [aws: [reply([message: "unavailable"], 503)]]) }
        mustFail { run(source, [:], [aws: [reply(cluster()), reply([message: "unavailable"], 503)]]) }
    }
}
println "Passed ${scenarios} pipeline regression scenarios across both SQL seeds."
