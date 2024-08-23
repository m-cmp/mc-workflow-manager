-- Step 1: Insert into oss_type
INSERT INTO oss_type (oss_type_idx, oss_type_name, oss_type_desc) VALUES (1, 'JENKINS', 'init');

-- Step 2: Insert into oss
INSERT INTO oss (oss_idx, oss_type_idx, oss_name, oss_desc, oss_url, oss_username, oss_password) VALUES (1, 1, 'SampleOss', 'Sample Description', 'http://sample.com', 'root', null);

-- Step 3: Insert into workflow_stage_type (assuming this table exists and 1 is valid)
-- Note: No specific values provided for WorkflowStageType. Adjust as necessary.
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (1, 'WORKFLOW BASE TEMPLATE', 'workflow base template');
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (2, 'VM ACCESS INFO', 'vm access info');
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (3, 'ACCESS VM AND SH', 'ACCESS VM AND SH');
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (4, 'K8S COMMAND''S UTIL', 'k8s command''s util');
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (5, 'SPIDER INFO CHECK', 'spider info check');
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (6, 'MCIS(VM)', 'MCIS(VM)');
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (7, 'REDIS INSTALL(tar)', 'redis install(tar)');
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (8, 'NEXUS PUT', 'NEXUS PUT');
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (9, 'JENKINS RUN', 'JENKINS RUN');


-- Step 4: Insert into workflow_stage
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (1, 1, 1, 'workflow base', 'workflow base', 'import groovy.json.JsonSlurper

def getSSHKey(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findResult { it.key == ''McisSubGroupAccessInfo'' ?
        it.value.findResult { it.McisVmAccessInfo?.findResult { it.privateKey } } : null
    } ?: ''''
}

def getPublicInfoList(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findAll { it.key == ''McisSubGroupAccessInfo'' }
        .collectMany { it.value.McisVmAccessInfo*.publicIP }
}


//Global variable
def callData = ''''
def infoObj = ''''

pipeline {
    agent any

    environment {
        ENV_VAL = "env-value-sample"
    }

    stages {


        // INTO STAGE TEMPLATE


    }
}');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (2, 2, 1, 'VM GET Access Info', 'VM GET Access Info', 'stage(''VM GET Access Info'') {
    steps {
        echo ''>>>>>STAGE: VM GET Access Info''
        script {
            def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/${env.NAMESPACE}/mcis/${env.MCIS_NAME}?option=accessinfo --user "${env.USERNAME}:${env.USERPASS}" """, returnStdout: true).trim()
            if (response.contains(''Http_Status_code:200'')) {
                echo "GET API call successful."
                callData = response.replace(''- Http_Status_code:200'', '''')
                echo(callData)
            } else {
                error "GET API call failed with status code: ${response}"
            }

            def tb_sw_url = "${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/ns01/mcis/${env.MCIS_NAME}?option=accessinfo&accessInfoOption=showSshKey"
            def response2 = sh(script: """curl -X ''GET'' --user ''${env.USERNAME}:${env.USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
            def pemkey = getSSHKey(response2)
            if (pemkey) {
                writeFile(file: "${env.MCIS_NAME}.pem", text: pemkey)
                sh "chmod 400 ${env.MCIS_NAME}.pem"
            } else {
                error "SSH Key retrieval failed."
            }
        }
    }
}');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (3, 3, 1, 'ACCESS VM AND SH(MCIS VM)', 'ACCESS VM AND SH(MCIS VM)', 'stage(''ACCESS VM AND SH'') {
    steps {
        echo ''>>>>>STAGE: ACCESS VM AND SH''
        script {
            def publicIPs = getPublicInfoList(callData)
            echo publicIPs.toString()
            publicIPs[0].each{ ip-> echo "ip view : " + ip }
            publicIPs.each { ip ->
                ip.each { inip ->
                    def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                    println ">>test SSH to MCIS VMs : ${cleanIp}"
                    sh """
                        ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${env.MCIS_NAME}.pem cb-user@${cleanIp} ''

                        # INSERT YOUR SHELL COMMAND

                        ''
                    """
                }
            }
        }
    }
}');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (4, 3, 2, 'ACCESS VM AND SH(direct SSH)', 'ACCESS VM AND SH(direct SSH)', 'stage(''ACCESS VM AND SH'') {
    steps {
        echo ''>>>>>STAGE: ACCESS VM AND SH''
        sh """
            ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $USERNAME@111.111.111.111 ''

            # INSERT YOUR SHELL COMMAND

            ''
        """
    }
}');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (5, 4, 1, 'k8s command''s util(jenkins plugin : docker)', 'k8s command''s util(jenkins plugin : docker)', 'stage(''test k8s/helm'') {
    agent {
        docker {
            // kubectl, helm, iam-authenticator, eksctl, kubeseal, etc...
            image ''alpine/k8s:1.28.13'' # any tag(version)
        }
    }
    steps {
        sh ''''''
        cat > /apps/config << EOF '''''' + $YOUR_KUBECONFIG + ''''''EOF

        # ex : GET NAMESPACE(USING YOUR CONFIG)
        kubectl get ns --kubeconfig=/apps/config

        # ex : HELM HELP
        helm --help
        ''''''
    }
}');




INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (6, 4, 2, 'k8s command''s util(no plug in, only docker.sock mount)', 'k8s command''s util(no plug in, only docker.sock mount)', 'stage(''test k8s/helm'') {
    agent {
        docker {
            // kubectl, helm, iam-authenticator, eksctl, kubeseal, etc...
            image ''alpine/k8s:1.28.13'' # any tag(version)
        }
    }
    steps {
        sh ''''''
        cat > config << EOF '''''' + $YOUR_KUBECONFIG + ''''''EOF

        # docker k8s-tool running check
        export isRun=$(docker ps --format "table {{.Status}} | {{.Names}}" | grep k8s-tools)
        if [ ! -z "$isRun" ];then
            echo "The k8s-tools is already running. Terminate k8s-tools"
            docker stop k8s-tools && docker rm -f k8s-tools
        else
            echo "k8s-tools is not running."
        fi

        # docker run k8s-tool
        docker run -d --rm --name k8s-tools alpine/k8s:1.28.13 sleep 10m
        docker cp config k8s-tools:/

        # ex : get ns using your kubeconfig
        docker exec -i k8s-tools kubectl get ns --kubeconfig=/config

        # ex : helm command with your kubeconfig and install nginx sample
        helm install my-release oci://registry-1.docker.io/bitnamicharts/nginx --kubeconfig=/config

        # stop to command ends
        docker stop k8s-tools
        ''''''
    }
}');

INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (7, 5, 1, 'spider info check', 'spider info check', 'stage(''Spider Info Check'') {
    steps {
        echo ''>>>>>STAGE: Spider Info Check''
        // TUMBLEBUG_URI sample : http://111.111.111.111:1323/tumblebug
        script {
            // Calling a GET API using curl
            def response = sh(script: ''curl -w "- Http_Status_code:%{http_code}" '' + $TUMBLEBUG_URI + ''/config --user "''+ $USER + '':''+ $USER_PASSWORD + ''"'', returnStdout: true).trim()
            if (response.indexOf(''Http_Status_code:200'') > 0 ) {
                echo "GET API call successful."
                response = response.replace(''- Http_Status_code:200'', '''');
                def prettyJSON = JsonOutput.prettyPrint(response)
                echo("${prettyJSON}")
            } else {
                error "GET API call failed with status code: ${response}"
            }
        }
    }
}');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (8, 6, 1, 'Infrastructure Delete', 'Infrastructure Delete', 'stage(''Infrastructure Delete''){
    steps {
        echo ''>>>>>>STAGE: Infrastructure Delete''
        script {
            def tb_sw_url = ''http://TUMBLEBUG_URL_OR_IP:PORT/tumblebug/ns''
            def call = """ curl -X ''DELETE'' --user ''$USER:$USER_PASSWORD'' ''${tb_sw_url}/$NAMESPACE/mcis/$MCIS?option=terminate''  -H ''accept: application/json''"""
            def postResponse = sh(script: """ ${call} """, returnStdout: true).trim()
        }
    }
}');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (9, 6, 2, 'Infrastructure Create', 'Infrastructure Create', 'stage(''Infrastructure Create''){
    steps {
        echo ''>>>>>>STAGE: Infrastructure Create''
        script {
            def payload = ''''''{ "description": "$DESCRIPTION", "installMonAgent": "yes", "label": "$LABEL", "name": "$MCIS", "vm": [ { "commonImage": "Ubuntu22.04", "commonSpec": "aws+ap-northeast-2+t2.small", "description": "mapui", "label": "DynamicVM", "rootDiskType": "default", "rootDiskSize": "default", "subGroupSize": "$VM_NUMBER", "name": "g1" } ] }''''''
            def tb_sw_url = ''http://TUMBLEBUG_URL_OR_IP:PORT/tumblebug/ns/ns01/mcisDynamic''
            def call = """ curl -X ''POST'' --user ''default:default'' ''${tb_sw_url}''  -H ''accept: application/json'' -H ''Content-Type: application/json''  -d ''${payload}'' """
            def postResponse = sh(script: """ ${call} """, returnStdout: true).trim()
        }
    }
}');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (10, 6, 3, 'Infrastructure Running Status', 'Infrastructure Running Status', 'stage(''Infrastructure Running Status'') {
    steps {
        echo ''>>>>>STAGE: Infrastructure Running Status''

        script {
            def tb_sw_url = ''http://TUMBLEBUG_URL_OR_IP:PORT/tumblebug/ns/ns01/mcis?option=status''
            def response = sh(script: """ curl -w ''- Http_Status_code:%{http_code}'' ''${tb_sw_url}'' --user ''default:default'' -H ''accept: application/json'' """, returnStdout: true).trim()
            if (response.indexOf(''Http_Status_code:200'') > 0 ) {
                echo "GET API call successful."
                response = response.replace(''- Http_Status_code:200'', '''');
                def prettyJSON = JsonOutput.prettyPrint(response)
                echo("${prettyJSON}")
            } else {
                error "GET API call failed with status code: ${response}"
            }
        }
    }
}');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (11, 7, 1, 'redis install vm servers', 'redis install vm servers', 'stage(''redis install vm servers.'') {
    steps {
        echo ''>>>>>STAGE: redis install vm servers.''

        script {
            // Calling a GET API using curl
            def aval = getPublicInfoList(callData)
            aval.each{
                println ">>INSTALL: Server IP : $it"
                sh """
                    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i """ + env.MCIS_NAME + """.pem cb-user@${it} ''
                    sudo apt-get update -y -qq
                    sudo apt-get install -y make
                    sudo apt install gcc -y
                    mkdir -p /home/cb-user/redis
                    curl -o /home/cb-user/redis/redis-7.0.15.tar.gz https://download.redis.io/releases/redis-7.0.15.tar.gz
                    cd /home/cb-user/redis
                    tar -zxf /home/cb-user/redis/redis-7.0.15.tar.gz -C /home/cb-user/redis
                    cd /home/cb-user/redis/redis-7.0.15
                    sudo apt install gcc
                    sudo apt install redis-tools
                    make distclean
                    make
                    #sed -i ''s/daemonize no/daemonize yes/g'' /home/cb-user/redis/redis-7.0.15/redis.conf
                    /home/cb-user/redis/redis-7.0.15/src/redis-server --daemonize yes --requirepass """ + env.REDIS_PASS +  """
                    #redis-cli -h 127.0.0.1
                    #auth """ + env.REDIS_PASS + """
                    #shutdown
                    ''
                """
            }
        }
    }
}');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (12, 8, 1, 'Put Nexus', 'Put Nexus', 'stage(''Put Nexus''){
    steps {
        echo ''>>>>>>STAGE: Put Nexus''

        script {
            echo "test tar to NEXUS"
            sh """
            curl -o """ + "${FILENAME}" + """ """ + "${FROM_LOCATION}" + """
            curl -v -u """ + env.USER + """:""" + env.USER_PASSWORD + """ --upload-file """ + "${FILENAME}" + """ """ + "${TO_LOCATION}" + """
            """
        }
    }
}');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (13, 9, 1, 'run jenkins job', 'run jenkins job', 'stage (''jenkins job'') {
    steps {
        build job: ''$your-jenkins-job-name'',
        parameters: [
            string(name: ''PARAM_NAME'', value: ''YOUR_VALUE''),
            string(name: ''PARAM_NAME2'', value: ''YOUR_VALUE2'')
        ]
    }
}');





-- Step 5: Insert into workflow
INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (1, 'nginx', 'test', 1, 'import groovy.json.JsonSlurper

def getSSHKey(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findResult { it.key == ''McisSubGroupAccessInfo'' ?
        it.value.findResult { it.McisVmAccessInfo?.findResult { it.privateKey } } : null
    } ?: ''''
}

def getPublicInfoList(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findAll { it.key == ''McisSubGroupAccessInfo'' }
        .collectMany { it.value.McisVmAccessInfo*.publicIP }
}


//Global variable
def callData = ''''
def infoObj = ''''

pipeline {
    agent any

    environment {
        MCIS = "$mcis"
    }

    stages {


        //=============================================================================================
        // stage template - VM ACCESS INFO
        // need two functions : getSSHKey(jsonInput), getPublicInfoList(jsonInput)
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/${env.NAMESPACE}/mcis/${env.MCIS_NAME}?option=accessinfo --user "${env.USERNAME}:${env.USERPASS}" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/ns01/mcis/${env.MCIS_NAME}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${env.USERNAME}:${env.USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${env.MCIS_NAME}.pem", text: pemkey)
                        sh "chmod 400 ${env.MCIS_NAME}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }


        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCIS VM)
        //=============================================================================================
        stage(''ACCESS VM AND SH'') {
            steps {
                echo ''>>>>>STAGE: ACCESS VM AND SH''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCIS VMs : ${cleanIp}"
                            sh """
                                ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${env.MCIS_NAME}.pem cb-user@${cleanIp} ''
                                sudo apt-get update && sudo apt-get upgrade -y
                                sudo apt-get install nginx -y
                                ''
                            """
                        }
                    }
                }
            }
        }


    }
}');
INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (2, 'tomcat', 'test', 1, 'import groovy.json.JsonSlurper

def getSSHKey(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findResult { it.key == ''McisSubGroupAccessInfo'' ?
        it.value.findResult { it.McisVmAccessInfo?.findResult { it.privateKey } } : null
    } ?: ''''
}

def getPublicInfoList(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findAll { it.key == ''McisSubGroupAccessInfo'' }
        .collectMany { it.value.McisVmAccessInfo*.publicIP }
}


//Global variable
def callData = ''''
def infoObj = ''''

pipeline {
    agent any

    environment {
        MCIS = "$mcis"
    }

    stages {


        //=============================================================================================
        // stage template - VM ACCESS INFO
        // need two functions : getSSHKey(jsonInput), getPublicInfoList(jsonInput)
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/${env.NAMESPACE}/mcis/${env.MCIS_NAME}?option=accessinfo --user "${env.USERNAME}:${env.USERPASS}" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/ns01/mcis/${env.MCIS_NAME}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${env.USERNAME}:${env.USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${env.MCIS_NAME}.pem", text: pemkey)
                        sh "chmod 400 ${env.MCIS_NAME}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }


        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCIS VM)
        //=============================================================================================
        stage(''ACCESS VM AND SH'') {
            steps {
                echo ''>>>>>STAGE: ACCESS VM AND SH''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCIS VMs : ${cleanIp}"
                            sh """
                                ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${env.MCIS_NAME}.pem cb-user@${cleanIp} ''
                                sudo apt-get update && sudo apt-get upgrade -y
                                sudo apt-get install nginx -y
                                ''
                            """
                        }
                    }
                }
            }
        }


    }
}');
INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (3, 'mariaDB', 'test', 1, 'import groovy.json.JsonSlurper

def getSSHKey(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findResult { it.key == ''McisSubGroupAccessInfo'' ?
        it.value.findResult { it.McisVmAccessInfo?.findResult { it.privateKey } } : null
    } ?: ''''
}

def getPublicInfoList(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findAll { it.key == ''McisSubGroupAccessInfo'' }
        .collectMany { it.value.McisVmAccessInfo*.publicIP }
}


//Global variable
def callData = ''''
def infoObj = ''''

pipeline {
    agent any

    environment {
        MCIS = "$mcis"
    }

    stages {


        //=============================================================================================
        // stage template - VM ACCESS INFO
        // need two functions : getSSHKey(jsonInput), getPublicInfoList(jsonInput)
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/${env.NAMESPACE}/mcis/${env.MCIS_NAME}?option=accessinfo --user "${env.USERNAME}:${env.USERPASS}" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/ns01/mcis/${env.MCIS_NAME}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${env.USERNAME}:${env.USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${env.MCIS_NAME}.pem", text: pemkey)
                        sh "chmod 400 ${env.MCIS_NAME}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }


        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCIS VM)
        //=============================================================================================
        stage(''ACCESS VM AND SH'') {
            steps {
                echo ''>>>>>STAGE: ACCESS VM AND SH''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCIS VMs : ${cleanIp}"
                            sh """
                                ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${env.MCIS_NAME}.pem cb-user@${cleanIp} ''
                                sudo apt-get update && sudo apt-get upgrade -y
                                sudo apt-get install nginx -y
                                ''
                            """
                        }
                    }
                }
            }
        }


    }
}');
INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (4, 'redis', 'test', 1, 'import groovy.json.JsonSlurper

def getSSHKey(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findResult { it.key == ''McisSubGroupAccessInfo'' ?
        it.value.findResult { it.McisVmAccessInfo?.findResult { it.privateKey } } : null
    } ?: ''''
}

def getPublicInfoList(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findAll { it.key == ''McisSubGroupAccessInfo'' }
        .collectMany { it.value.McisVmAccessInfo*.publicIP }
}


//Global variable
def callData = ''''
def infoObj = ''''

pipeline {
    agent any

    environment {
        MCIS = "$mcis"
    }

    stages {


        //=============================================================================================
        // stage template - VM ACCESS INFO
        // need two functions : getSSHKey(jsonInput), getPublicInfoList(jsonInput)
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/${env.NAMESPACE}/mcis/${env.MCIS_NAME}?option=accessinfo --user "${env.USERNAME}:${env.USERPASS}" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/ns01/mcis/${env.MCIS_NAME}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${env.USERNAME}:${env.USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${env.MCIS_NAME}.pem", text: pemkey)
                        sh "chmod 400 ${env.MCIS_NAME}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }


        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCIS VM)
        //=============================================================================================
        stage(''ACCESS VM AND SH'') {
            steps {
                echo ''>>>>>STAGE: ACCESS VM AND SH''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCIS VMs : ${cleanIp}"
                            sh """
                                ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${env.MCIS_NAME}.pem cb-user@${cleanIp} ''
                                sudo apt-get update && sudo apt-get upgrade -y
                                sudo apt-get install nginx -y
                                ''
                            """
                        }
                    }
                }
            }
        }


    }
}');
INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (5, 'prometheus', 'test', 1, 'import groovy.json.JsonSlurper

def getSSHKey(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findResult { it.key == ''McisSubGroupAccessInfo'' ?
        it.value.findResult { it.McisVmAccessInfo?.findResult { it.privateKey } } : null
    } ?: ''''
}

def getPublicInfoList(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findAll { it.key == ''McisSubGroupAccessInfo'' }
        .collectMany { it.value.McisVmAccessInfo*.publicIP }
}


//Global variable
def callData = ''''
def infoObj = ''''

pipeline {
    agent any

    environment {
        MCIS = "$mcis"
    }

    stages {


        //=============================================================================================
        // stage template - VM ACCESS INFO
        // need two functions : getSSHKey(jsonInput), getPublicInfoList(jsonInput)
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/${env.NAMESPACE}/mcis/${env.MCIS_NAME}?option=accessinfo --user "${env.USERNAME}:${env.USERPASS}" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/ns01/mcis/${env.MCIS_NAME}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${env.USERNAME}:${env.USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${env.MCIS_NAME}.pem", text: pemkey)
                        sh "chmod 400 ${env.MCIS_NAME}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }


        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCIS VM)
        //=============================================================================================
        stage(''ACCESS VM AND SH'') {
            steps {
                echo ''>>>>>STAGE: ACCESS VM AND SH''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCIS VMs : ${cleanIp}"
                            sh """
                                ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${env.MCIS_NAME}.pem cb-user@${cleanIp} ''
                                sudo apt-get update && sudo apt-get upgrade -y
                                sudo apt-get install nginx -y
                                ''
                            """
                        }
                    }
                }
            }
        }


    }
}');
INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (6, 'grafana', 'test', 1, 'import groovy.json.JsonSlurper

def getSSHKey(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findResult { it.key == ''McisSubGroupAccessInfo'' ?
        it.value.findResult { it.McisVmAccessInfo?.findResult { it.privateKey } } : null
    } ?: ''''
}

def getPublicInfoList(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findAll { it.key == ''McisSubGroupAccessInfo'' }
        .collectMany { it.value.McisVmAccessInfo*.publicIP }
}


//Global variable
def callData = ''''
def infoObj = ''''

pipeline {
    agent any

    environment {
        MCIS = "$mcis"
    }

    stages {


        //=============================================================================================
        // stage template - VM ACCESS INFO
        // need two functions : getSSHKey(jsonInput), getPublicInfoList(jsonInput)
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/${env.NAMESPACE}/mcis/${env.MCIS_NAME}?option=accessinfo --user "${env.USERNAME}:${env.USERPASS}" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/ns01/mcis/${env.MCIS_NAME}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${env.USERNAME}:${env.USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${env.MCIS_NAME}.pem", text: pemkey)
                        sh "chmod 400 ${env.MCIS_NAME}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }


        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCIS VM)
        //=============================================================================================
        stage(''ACCESS VM AND SH'') {
            steps {
                echo ''>>>>>STAGE: ACCESS VM AND SH''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCIS VMs : ${cleanIp}"
                            sh """
                                ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${env.MCIS_NAME}.pem cb-user@${cleanIp} ''
                                sudo apt-get update && sudo apt-get upgrade -y
                                sudo apt-get install nginx -y
                                ''
                            """
                        }
                    }
                }
            }
        }


    }
}');
INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (7, 'test1', 'test', 1, 'import groovy.json.JsonSlurper

def getSSHKey(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findResult { it.key == ''McisSubGroupAccessInfo'' ?
        it.value.findResult { it.McisVmAccessInfo?.findResult { it.privateKey } } : null
    } ?: ''''
}

def getPublicInfoList(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findAll { it.key == ''McisSubGroupAccessInfo'' }
        .collectMany { it.value.McisVmAccessInfo*.publicIP }
}


//Global variable
def callData = ''''
def infoObj = ''''

pipeline {
    agent any

    environment {
        MCIS = "$mcis"
    }

    stages {


        //=============================================================================================
        // stage template - VM ACCESS INFO
        // need two functions : getSSHKey(jsonInput), getPublicInfoList(jsonInput)
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/${env.NAMESPACE}/mcis/${env.MCIS_NAME}?option=accessinfo --user "${env.USERNAME}:${env.USERPASS}" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/ns01/mcis/${env.MCIS_NAME}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${env.USERNAME}:${env.USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${env.MCIS_NAME}.pem", text: pemkey)
                        sh "chmod 400 ${env.MCIS_NAME}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }


        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCIS VM)
        //=============================================================================================
        stage(''ACCESS VM AND SH'') {
            steps {
                echo ''>>>>>STAGE: ACCESS VM AND SH''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCIS VMs : ${cleanIp}"
                            sh """
                                ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${env.MCIS_NAME}.pem cb-user@${cleanIp} ''
                                sudo apt-get update && sudo apt-get upgrade -y
                                sudo apt-get install nginx -y
                                ''
                            """
                        }
                    }
                }
            }
        }


    }
}');
INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (8, 'test2', 'test', 1, 'import groovy.json.JsonSlurper

def getSSHKey(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findResult { it.key == ''McisSubGroupAccessInfo'' ?
        it.value.findResult { it.McisVmAccessInfo?.findResult { it.privateKey } } : null
    } ?: ''''
}

def getPublicInfoList(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findAll { it.key == ''McisSubGroupAccessInfo'' }
        .collectMany { it.value.McisVmAccessInfo*.publicIP }
}


//Global variable
def callData = ''''
def infoObj = ''''

pipeline {
    agent any

    environment {
        MCIS = "$mcis"
    }

    stages {


        //=============================================================================================
        // stage template - VM ACCESS INFO
        // need two functions : getSSHKey(jsonInput), getPublicInfoList(jsonInput)
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/${env.NAMESPACE}/mcis/${env.MCIS_NAME}?option=accessinfo --user "${env.USERNAME}:${env.USERPASS}" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/ns01/mcis/${env.MCIS_NAME}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${env.USERNAME}:${env.USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${env.MCIS_NAME}.pem", text: pemkey)
                        sh "chmod 400 ${env.MCIS_NAME}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }


        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCIS VM)
        //=============================================================================================
        stage(''ACCESS VM AND SH'') {
            steps {
                echo ''>>>>>STAGE: ACCESS VM AND SH''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCIS VMs : ${cleanIp}"
                            sh """
                                ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${env.MCIS_NAME}.pem cb-user@${cleanIp} ''
                                sudo apt-get update && sudo apt-get upgrade -y
                                sudo apt-get install nginx -y
                                ''
                            """
                        }
                    }
                }
            }
        }


    }
}');
INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (9, 'test3', 'test', 1, 'import groovy.json.JsonSlurper

def getSSHKey(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findResult { it.key == ''McisSubGroupAccessInfo'' ?
        it.value.findResult { it.McisVmAccessInfo?.findResult { it.privateKey } } : null
    } ?: ''''
}

def getPublicInfoList(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findAll { it.key == ''McisSubGroupAccessInfo'' }
        .collectMany { it.value.McisVmAccessInfo*.publicIP }
}


//Global variable
def callData = ''''
def infoObj = ''''

pipeline {
    agent any

    environment {
        MCIS = "$mcis"
    }

    stages {


        //=============================================================================================
        // stage template - VM ACCESS INFO
        // need two functions : getSSHKey(jsonInput), getPublicInfoList(jsonInput)
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/${env.NAMESPACE}/mcis/${env.MCIS_NAME}?option=accessinfo --user "${env.USERNAME}:${env.USERPASS}" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/ns01/mcis/${env.MCIS_NAME}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${env.USERNAME}:${env.USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${env.MCIS_NAME}.pem", text: pemkey)
                        sh "chmod 400 ${env.MCIS_NAME}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }


        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCIS VM)
        //=============================================================================================
        stage(''ACCESS VM AND SH'') {
            steps {
                echo ''>>>>>STAGE: ACCESS VM AND SH''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCIS VMs : ${cleanIp}"
                            sh """
                                ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${env.MCIS_NAME}.pem cb-user@${cleanIp} ''
                                sudo apt-get update && sudo apt-get upgrade -y
                                sudo apt-get install nginx -y
                                ''
                            """
                        }
                    }
                }
            }
        }


    }
}');
INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (10, 'test4', 'test', 1, 'import groovy.json.JsonSlurper

def getSSHKey(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findResult { it.key == ''McisSubGroupAccessInfo'' ?
        it.value.findResult { it.McisVmAccessInfo?.findResult { it.privateKey } } : null
    } ?: ''''
}

def getPublicInfoList(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findAll { it.key == ''McisSubGroupAccessInfo'' }
        .collectMany { it.value.McisVmAccessInfo*.publicIP }
}


//Global variable
def callData = ''''
def infoObj = ''''

pipeline {
    agent any

    environment {
        MCIS = "$mcis"
    }

    stages {


        //=============================================================================================
        // stage template - VM ACCESS INFO
        // need two functions : getSSHKey(jsonInput), getPublicInfoList(jsonInput)
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/${env.NAMESPACE}/mcis/${env.MCIS_NAME}?option=accessinfo --user "${env.USERNAME}:${env.USERPASS}" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/ns01/mcis/${env.MCIS_NAME}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${env.USERNAME}:${env.USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${env.MCIS_NAME}.pem", text: pemkey)
                        sh "chmod 400 ${env.MCIS_NAME}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }


        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCIS VM)
        //=============================================================================================
        stage(''ACCESS VM AND SH'') {
            steps {
                echo ''>>>>>STAGE: ACCESS VM AND SH''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCIS VMs : ${cleanIp}"
                            sh """
                                ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${env.MCIS_NAME}.pem cb-user@${cleanIp} ''
                                sudo apt-get update && sudo apt-get upgrade -y
                                sudo apt-get install nginx -y
                                ''
                            """
                        }
                    }
                }
            }
        }


    }
}');









-- Step 6: Insert into workflow_param
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (1, 1, 'MCIS', '', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (2, 2, 'MCIS', '', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (3, 3, 'MCIS', '', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (4, 4, 'MCIS', '', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (5, 5, 'MCIS', '', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (6, 6, 'MCIS', '', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (7, 7, 'MCIS', '', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (8, 8, 'MCIS', '', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (9, 9, 'MCIS', '', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (10, 10, 'MCIS', '', 'N');









-- Step 7: Insert into workflow_stage_mapping
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (1, 1, 1, null, 'import groovy.json.JsonSlurper

def getSSHKey(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findResult { it.key == ''McisSubGroupAccessInfo'' ?
        it.value.findResult { it.McisVmAccessInfo?.findResult { it.privateKey } } : null
    } ?: ''''
}

def getPublicInfoList(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findAll { it.key == ''McisSubGroupAccessInfo'' }
        .collectMany { it.value.McisVmAccessInfo*.publicIP }
}


//Global variable
def callData = ''''
def infoObj = ''''

pipeline {
    agent any

    environment {
        MCIS = "$mcis"
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (2, 1, 2, 2, '        //=============================================================================================
        // stage template - VM ACCESS INFO
        // need two functions : getSSHKey(jsonInput), getPublicInfoList(jsonInput)
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/${env.NAMESPACE}/mcis/${env.MCIS_NAME}?option=accessinfo --user "${env.USERNAME}:${env.USERPASS}" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/ns01/mcis/${env.MCIS_NAME}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${env.USERNAME}:${env.USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${env.MCIS_NAME}.pem", text: pemkey)
                        sh "chmod 400 ${env.MCIS_NAME}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (3, 1, 3, 3, '        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCIS VM)
        //=============================================================================================
        stage(''ACCESS VM AND SH'') {
            steps {
                echo ''>>>>>STAGE: ACCESS VM AND SH''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCIS VMs : ${cleanIp}"
                            sh """
                                ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${env.MCIS_NAME}.pem cb-user@${cleanIp} ''
                                sudo apt-get update && sudo apt-get upgrade -y
                                sudo apt-get install nginx -y
                                ''
                            """
                        }
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (4, 1, 4, null, '  }
}
');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (5, 2, 1, null, 'import groovy.json.JsonSlurper

def getSSHKey(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findResult { it.key == ''McisSubGroupAccessInfo'' ?
        it.value.findResult { it.McisVmAccessInfo?.findResult { it.privateKey } } : null
    } ?: ''''
}

def getPublicInfoList(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findAll { it.key == ''McisSubGroupAccessInfo'' }
        .collectMany { it.value.McisVmAccessInfo*.publicIP }
}


//Global variable
def callData = ''''
def infoObj = ''''

pipeline {
    agent any

    environment {
        MCIS = "$mcis"
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (6, 2, 2, 2, '        //=============================================================================================
        // stage template - VM ACCESS INFO
        // need two functions : getSSHKey(jsonInput), getPublicInfoList(jsonInput)
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/${env.NAMESPACE}/mcis/${env.MCIS_NAME}?option=accessinfo --user "${env.USERNAME}:${env.USERPASS}" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/ns01/mcis/${env.MCIS_NAME}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${env.USERNAME}:${env.USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${env.MCIS_NAME}.pem", text: pemkey)
                        sh "chmod 400 ${env.MCIS_NAME}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (7, 2, 3, 3, '        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCIS VM)
        //=============================================================================================
        stage(''ACCESS VM AND SH'') {
            steps {
                echo ''>>>>>STAGE: ACCESS VM AND SH''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCIS VMs : ${cleanIp}"
                            sh """
                                ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${env.MCIS_NAME}.pem cb-user@${cleanIp} ''
                                sudo apt-get update && sudo apt-get upgrade -y
                                sudo apt-get install nginx -y
                                ''
                            """
                        }
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (8, 2, 4, null, '  }
}
');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------


INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (9, 3, 1, null, 'import groovy.json.JsonSlurper

def getSSHKey(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findResult { it.key == ''McisSubGroupAccessInfo'' ?
        it.value.findResult { it.McisVmAccessInfo?.findResult { it.privateKey } } : null
    } ?: ''''
}

def getPublicInfoList(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findAll { it.key == ''McisSubGroupAccessInfo'' }
        .collectMany { it.value.McisVmAccessInfo*.publicIP }
}


//Global variable
def callData = ''''
def infoObj = ''''

pipeline {
    agent any

    environment {
        MCIS = "$mcis"
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (10, 3, 2, 2, '        //=============================================================================================
        // stage template - VM ACCESS INFO
        // need two functions : getSSHKey(jsonInput), getPublicInfoList(jsonInput)
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/${env.NAMESPACE}/mcis/${env.MCIS_NAME}?option=accessinfo --user "${env.USERNAME}:${env.USERPASS}" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/ns01/mcis/${env.MCIS_NAME}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${env.USERNAME}:${env.USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${env.MCIS_NAME}.pem", text: pemkey)
                        sh "chmod 400 ${env.MCIS_NAME}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (11, 3, 3, 3, '        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCIS VM)
        //=============================================================================================
        stage(''ACCESS VM AND SH'') {
            steps {
                echo ''>>>>>STAGE: ACCESS VM AND SH''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCIS VMs : ${cleanIp}"
                            sh """
                                ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${env.MCIS_NAME}.pem cb-user@${cleanIp} ''
                                sudo apt-get update && sudo apt-get upgrade -y
                                sudo apt-get install nginx -y
                                ''
                            """
                        }
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (12, 3, 4, null, '  }
}
');


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (13, 4, 1, null, 'import groovy.json.JsonSlurper

def getSSHKey(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findResult { it.key == ''McisSubGroupAccessInfo'' ?
        it.value.findResult { it.McisVmAccessInfo?.findResult { it.privateKey } } : null
    } ?: ''''
}

def getPublicInfoList(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findAll { it.key == ''McisSubGroupAccessInfo'' }
        .collectMany { it.value.McisVmAccessInfo*.publicIP }
}


//Global variable
def callData = ''''
def infoObj = ''''

pipeline {
    agent any

    environment {
        MCIS = "$mcis"
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (14, 4, 2, 2, '        //=============================================================================================
        // stage template - VM ACCESS INFO
        // need two functions : getSSHKey(jsonInput), getPublicInfoList(jsonInput)
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/${env.NAMESPACE}/mcis/${env.MCIS_NAME}?option=accessinfo --user "${env.USERNAME}:${env.USERPASS}" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/ns01/mcis/${env.MCIS_NAME}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${env.USERNAME}:${env.USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${env.MCIS_NAME}.pem", text: pemkey)
                        sh "chmod 400 ${env.MCIS_NAME}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (15, 4, 3, 3, '        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCIS VM)
        //=============================================================================================
        stage(''ACCESS VM AND SH'') {
            steps {
                echo ''>>>>>STAGE: ACCESS VM AND SH''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCIS VMs : ${cleanIp}"
                            sh """
                                ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${env.MCIS_NAME}.pem cb-user@${cleanIp} ''
                                sudo apt-get update && sudo apt-get upgrade -y
                                sudo apt-get install nginx -y
                                ''
                            """
                        }
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (16, 4, 4, null, '  }
}
');


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (17, 5, 1, null, 'import groovy.json.JsonSlurper

def getSSHKey(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findResult { it.key == ''McisSubGroupAccessInfo'' ?
        it.value.findResult { it.McisVmAccessInfo?.findResult { it.privateKey } } : null
    } ?: ''''
}

def getPublicInfoList(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findAll { it.key == ''McisSubGroupAccessInfo'' }
        .collectMany { it.value.McisVmAccessInfo*.publicIP }
}


//Global variable
def callData = ''''
def infoObj = ''''

pipeline {
    agent any

    environment {
        MCIS = "$mcis"
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (18, 5, 2, 2, '        //=============================================================================================
        // stage template - VM ACCESS INFO
        // need two functions : getSSHKey(jsonInput), getPublicInfoList(jsonInput)
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/${env.NAMESPACE}/mcis/${env.MCIS_NAME}?option=accessinfo --user "${env.USERNAME}:${env.USERPASS}" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/ns01/mcis/${env.MCIS_NAME}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${env.USERNAME}:${env.USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${env.MCIS_NAME}.pem", text: pemkey)
                        sh "chmod 400 ${env.MCIS_NAME}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (19, 5, 3, 3, '        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCIS VM)
        //=============================================================================================
        stage(''ACCESS VM AND SH'') {
            steps {
                echo ''>>>>>STAGE: ACCESS VM AND SH''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCIS VMs : ${cleanIp}"
                            sh """
                                ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${env.MCIS_NAME}.pem cb-user@${cleanIp} ''
                                sudo apt-get update && sudo apt-get upgrade -y
                                sudo apt-get install nginx -y
                                ''
                            """
                        }
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (20, 5, 4, null, '  }
}
');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (21, 6, 1, null, 'import groovy.json.JsonSlurper

def getSSHKey(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findResult { it.key == ''McisSubGroupAccessInfo'' ?
        it.value.findResult { it.McisVmAccessInfo?.findResult { it.privateKey } } : null
    } ?: ''''
}

def getPublicInfoList(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findAll { it.key == ''McisSubGroupAccessInfo'' }
        .collectMany { it.value.McisVmAccessInfo*.publicIP }
}


//Global variable
def callData = ''''
def infoObj = ''''

pipeline {
    agent any

    environment {
        MCIS = "$mcis"
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (22, 6, 2, 2, '        //=============================================================================================
        // stage template - VM ACCESS INFO
        // need two functions : getSSHKey(jsonInput), getPublicInfoList(jsonInput)
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/${env.NAMESPACE}/mcis/${env.MCIS_NAME}?option=accessinfo --user "${env.USERNAME}:${env.USERPASS}" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/ns01/mcis/${env.MCIS_NAME}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${env.USERNAME}:${env.USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${env.MCIS_NAME}.pem", text: pemkey)
                        sh "chmod 400 ${env.MCIS_NAME}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (27, 6, 3, 3, '        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCIS VM)
        //=============================================================================================
        stage(''ACCESS VM AND SH'') {
            steps {
                echo ''>>>>>STAGE: ACCESS VM AND SH''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCIS VMs : ${cleanIp}"
                            sh """
                                ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${env.MCIS_NAME}.pem cb-user@${cleanIp} ''
                                sudo apt-get update && sudo apt-get upgrade -y
                                sudo apt-get install nginx -y
                                ''
                            """
                        }
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (28, 6, 4, null, '  }
}
');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (29, 7, 1, null, 'import groovy.json.JsonSlurper

def getSSHKey(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findResult { it.key == ''McisSubGroupAccessInfo'' ?
        it.value.findResult { it.McisVmAccessInfo?.findResult { it.privateKey } } : null
    } ?: ''''
}

def getPublicInfoList(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findAll { it.key == ''McisSubGroupAccessInfo'' }
        .collectMany { it.value.McisVmAccessInfo*.publicIP }
}


//Global variable
def callData = ''''
def infoObj = ''''

pipeline {
    agent any

    environment {
        MCIS = "$mcis"
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (30, 7, 2, 2, '        //=============================================================================================
        // stage template - VM ACCESS INFO
        // need two functions : getSSHKey(jsonInput), getPublicInfoList(jsonInput)
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/${env.NAMESPACE}/mcis/${env.MCIS_NAME}?option=accessinfo --user "${env.USERNAME}:${env.USERPASS}" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/ns01/mcis/${env.MCIS_NAME}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${env.USERNAME}:${env.USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${env.MCIS_NAME}.pem", text: pemkey)
                        sh "chmod 400 ${env.MCIS_NAME}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (31, 7, 3, 3, '        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCIS VM)
        //=============================================================================================
        stage(''ACCESS VM AND SH'') {
            steps {
                echo ''>>>>>STAGE: ACCESS VM AND SH''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCIS VMs : ${cleanIp}"
                            sh """
                                ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${env.MCIS_NAME}.pem cb-user@${cleanIp} ''
                                sudo apt-get update && sudo apt-get upgrade -y
                                sudo apt-get install nginx -y
                                ''
                            """
                        }
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (38, 7, 4, null, '  }
}
');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (39, 8, 1, null, 'import groovy.json.JsonSlurper

def getSSHKey(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findResult { it.key == ''McisSubGroupAccessInfo'' ?
        it.value.findResult { it.McisVmAccessInfo?.findResult { it.privateKey } } : null
    } ?: ''''
}

def getPublicInfoList(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findAll { it.key == ''McisSubGroupAccessInfo'' }
        .collectMany { it.value.McisVmAccessInfo*.publicIP }
}


//Global variable
def callData = ''''
def infoObj = ''''

pipeline {
    agent any

    environment {
        MCIS = "$mcis"
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (40, 8, 2, 2, '        //=============================================================================================
        // stage template - VM ACCESS INFO
        // need two functions : getSSHKey(jsonInput), getPublicInfoList(jsonInput)
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/${env.NAMESPACE}/mcis/${env.MCIS_NAME}?option=accessinfo --user "${env.USERNAME}:${env.USERPASS}" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/ns01/mcis/${env.MCIS_NAME}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${env.USERNAME}:${env.USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${env.MCIS_NAME}.pem", text: pemkey)
                        sh "chmod 400 ${env.MCIS_NAME}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (41, 8, 3, 3, '        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCIS VM)
        //=============================================================================================
        stage(''ACCESS VM AND SH'') {
            steps {
                echo ''>>>>>STAGE: ACCESS VM AND SH''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCIS VMs : ${cleanIp}"
                            sh """
                                ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${env.MCIS_NAME}.pem cb-user@${cleanIp} ''
                                sudo apt-get update && sudo apt-get upgrade -y
                                sudo apt-get install nginx -y
                                ''
                            """
                        }
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (42, 8, 4, null, '  }
}
');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (43, 9, 1, null, 'import groovy.json.JsonSlurper

def getSSHKey(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findResult { it.key == ''McisSubGroupAccessInfo'' ?
        it.value.findResult { it.McisVmAccessInfo?.findResult { it.privateKey } } : null
    } ?: ''''
}

def getPublicInfoList(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findAll { it.key == ''McisSubGroupAccessInfo'' }
        .collectMany { it.value.McisVmAccessInfo*.publicIP }
}


//Global variable
def callData = ''''
def infoObj = ''''

pipeline {
    agent any

    environment {
        MCIS = "$mcis"
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (44, 9, 2, 2, '        //=============================================================================================
        // stage template - VM ACCESS INFO
        // need two functions : getSSHKey(jsonInput), getPublicInfoList(jsonInput)
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/${env.NAMESPACE}/mcis/${env.MCIS_NAME}?option=accessinfo --user "${env.USERNAME}:${env.USERPASS}" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/ns01/mcis/${env.MCIS_NAME}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${env.USERNAME}:${env.USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${env.MCIS_NAME}.pem", text: pemkey)
                        sh "chmod 400 ${env.MCIS_NAME}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (45, 9, 3, 3, '        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCIS VM)
        //=============================================================================================
        stage(''ACCESS VM AND SH'') {
            steps {
                echo ''>>>>>STAGE: ACCESS VM AND SH''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCIS VMs : ${cleanIp}"
                            sh """
                                ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${env.MCIS_NAME}.pem cb-user@${cleanIp} ''
                                sudo apt-get update && sudo apt-get upgrade -y
                                sudo apt-get install nginx -y
                                ''
                            """
                        }
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (46, 9, 4, null, '  }
}
');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (47, 10, 1, null, 'import groovy.json.JsonSlurper

def getSSHKey(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findResult { it.key == ''McisSubGroupAccessInfo'' ?
        it.value.findResult { it.McisVmAccessInfo?.findResult { it.privateKey } } : null
    } ?: ''''
}

def getPublicInfoList(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findAll { it.key == ''McisSubGroupAccessInfo'' }
        .collectMany { it.value.McisVmAccessInfo*.publicIP }
}


//Global variable
def callData = ''''
def infoObj = ''''

pipeline {
    agent any

    environment {
        MCIS = "$mcis"
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (48, 10, 2, 2, '        //=============================================================================================
        // stage template - VM ACCESS INFO
        // need two functions : getSSHKey(jsonInput), getPublicInfoList(jsonInput)
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/${env.NAMESPACE}/mcis/${env.MCIS_NAME}?option=accessinfo --user "${env.USERNAME}:${env.USERPASS}" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${env.CB_TUMBLEBUG_SWAGGER_URI}/ns/ns01/mcis/${env.MCIS_NAME}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${env.USERNAME}:${env.USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${env.MCIS_NAME}.pem", text: pemkey)
                        sh "chmod 400 ${env.MCIS_NAME}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (49, 10, 3, 3, '        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCIS VM)
        //=============================================================================================
        stage(''ACCESS VM AND SH'') {
            steps {
                echo ''>>>>>STAGE: ACCESS VM AND SH''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCIS VMs : ${cleanIp}"
                            sh """
                                ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${env.MCIS_NAME}.pem cb-user@${cleanIp} ''
                                sudo apt-get update && sudo apt-get upgrade -y
                                sudo apt-get install nginx -y
                                ''
                            """
                        }
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (50, 10, 4, null, '  }
}
');