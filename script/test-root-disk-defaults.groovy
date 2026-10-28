#!/usr/bin/env groovy
// Run from the repository root: groovy script/test-root-disk-defaults.groovy
// Executes seeded request generation with mocked Jenkins steps, without cloud calls.
import groovy.json.JsonSlurperClassic
import org.codehaus.groovy.control.CompilerConfiguration

class RequestCaptured extends RuntimeException { }

abstract class DiskPipelineHarness extends Script {
    Map files = [:]
    Map capturedRequest

    def pipeline(Closure body) { body() }
    def stages(Closure body) { body() }
    def stage(String name, Closure body) { body() }
    def steps(Closure body) { body() }
    def script(Closure body) { body() }
    def agent(Object value) { }
    def echo(Object value) { }
    def sleep(Map value) { }
    def error(Object value) { throw new IllegalStateException(value.toString()) }
    def writeFile(Map value) { files[value.file.toString()] = value.text.toString() }

    String sh(Map options) {
        String command = options.script.toString()
        if (command.contains('-X POST')) {
            def data = command =~ /-d @([^\s]+)/
            assert data.find(): "Unexpected POST: ${command}"
            capturedRequest = new JsonSlurperClassic().parseText(files[data.group(1)])
            throw new RequestCaptured()
        }
        assert command.contains('-X GET'): "Unexpected command: ${command}"
        return command.contains('/k8sCluster/')
            ? '{}- Http_Status_code:404'
            : '{}- Http_Status_code:200'
    }
}

def sql = new File(args ? args[0] : 'src/main/resources/import.sql').getText('UTF-8')
def literalAfter = { matcher ->
    assert matcher.find(): 'Missing SQL seed'
    def literal = sql.substring(matcher.end()) =~ /(?s)^((?:[^']++|'')*+)'/
    assert literal.find(): 'Unterminated SQL literal'
    literal.group(1).replace("''", "'")
}
def sources = [:]
[17, 26, 31, 50, 51].each { id ->
    sources["stage${id}".toString()] = literalAfter(sql =~ /(?m)^INSERT INTO workflow_stage [^\n]* VALUES \(${id},[^\n]*, '/)
}
[102, 104].each { id ->
    sources["workflow${id}".toString()] = literalAfter(sql =~ /(?m)^MERGE INTO workflow [^\n]* VALUES \(${id},[^\n]*, '/)
}
def defaults = [
    TUMBLEBUG: 'http://tumblebug.test', NAMESPACE: 'default',
    INFRA_ID: 'vm-test', K8S_CLUSTER_ID: 'k8s-test', REGION: 'ap-seoul',
    K8S_NODEGROUP_NAME: 'ng1', SPEC_ID: 'tencent+ap-seoul+S8.LARGE8',
    IMAGE_ID: 'test-image', K8S_VERSION: '1.34.1'
]
def compiledPipelines = [:]
def run = { String source, Map overrides ->
    if (!compiledPipelines[source]) {
        def config = new CompilerConfiguration(scriptBaseClass: DiskPipelineHarness.name)
        compiledPipelines[source] = new GroovyShell(this.class.classLoader, new Binding(), config).parse(source).getClass()
    }
    def pipeline = compiledPipelines[source].getDeclaredConstructor().newInstance()
    pipeline.setBinding(new Binding([params: defaults + overrides, any: 'any']))
    try {
        pipeline.run()
        assert false: 'Pipeline never generated a creation request'
    } catch (RequestCaptured expected) {
        assert pipeline.capturedRequest
    }
    pipeline.capturedRequest
}
int checks = 0
sources.each { variant, source ->
    boolean multi = variant in ['stage50', 'stage51', 'workflow102', 'workflow104']
    ['tencent', 'alibaba', 'aws', 'gcp', 'azure', 'ibm', 'ncp', 'nhn'].each { csp ->
        String key = csp.toUpperCase()
        def providerParams = [CSP: csp, PROVIDER: csp, CSP_LIST: csp,
            ("${key}_SPEC_ID".toString()): "${csp}-spec".toString(),
            ("${key}_IMAGE_ID".toString()): 'test-image']
        [null, '', '   ', 'default', ' DeFaUlT ', 'custom-disk-type'].each { diskType ->
            def payload = run(source, providerParams + [ROOT_DISK_TYPE: diskType])
            def node = payload.nodeGroups ? payload.nodeGroups[0] : payload
            String requestedType = diskType?.trim() ?: 'default'
            String expectedType = requestedType.equalsIgnoreCase('default')
                ? ([tencent: 'CLOUD_BSSD', alibaba: 'cloud_essd'][csp] ?: requestedType)
                : requestedType
            assert node.rootDiskType == expectedType: "${variant}/${csp}/${diskType}: ${node}"
            checks++
        }
        if (!multi) {
            def payload = run(source, providerParams + [CSP: key, PROVIDER: key, ROOT_DISK_TYPE: 'default'])
            def node = payload.nodeGroups ? payload.nodeGroups[0] : payload
            assert node.rootDiskType == ([tencent: 'CLOUD_BSSD', alibaba: 'cloud_essd'][csp] ?: 'default')
            checks++
        }
    }
    if (!multi) {
        ['tencent', 'alibaba'].each { csp ->
            def payload = run(source, [SPEC_ID: "${csp}+region+spec".toString(), ROOT_DISK_TYPE: 'default'])
            def node = payload.nodeGroups ? payload.nodeGroups[0] : payload
            assert node.rootDiskType == [tencent: 'CLOUD_BSSD', alibaba: 'cloud_essd'][csp]
            checks++
        }
    }
    println "PASS ${variant}: default/empty/custom disk types and provider isolation"
}
['stage50', 'workflow102'].each { variant ->
    def params = [CSP_LIST: 'alibaba,tencent,aws,gcp', ROOT_DISK_TYPE: 'default']
    ['ALIBABA', 'TENCENT', 'AWS', 'GCP'].each { key ->
        params["${key}_SPEC_ID".toString()] = 'test-spec'
        params["${key}_IMAGE_ID".toString()] = 'test-image'
    }
    assert run(sources[variant], params).nodeGroups*.rootDiskType == ['cloud_essd', 'CLOUD_BSSD', 'default', 'default']
    checks++
}
println "Passed ${checks} disk-default request checks across both reusable and stored pipelines."
