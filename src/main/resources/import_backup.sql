-- Step 1: Insert into oss_type
INSERT INTO oss_type (oss_type_idx, oss_type_name, oss_type_desc) VALUES (1, 'JENKINS', 'init');

-- Step 2: Insert into oss
INSERT INTO oss (oss_idx, oss_type_idx, oss_name, oss_desc, oss_url, oss_username, oss_password) VALUES (1, 1, 'SampleOss', 'Sample Description', 'http://sample.com', 'root', null);

-- Step 3: Insert into workflow_stage_type (assuming this table exists and 1 is valid)
-- 1, 'SPIDER INFO CHECK'
-- 2, 'INFRASTRUCTURE NS CREATE'
-- 3, 'INFRASTRUCTURE VM CREATE'
-- 4, 'INFRASTRUCTURE VM DELETE'
-- 5, 'INFRASTRUCTURE MCI RUNNING STATUS'
-- 6, 'INFRASTRUCTURE K8S CREATE'
-- 7, 'INFRASTRUCTURE K8S DELETE'
-- 8, 'INFRASTRUCTURE PMK RUNNING STATUS'
-- 9, 'RUN JENKINS JOB'
-- 10, 'VM ACCESS INFO'
-- 11, 'ACCESS VM AND SH(MCI VM)'
-- 12, WAIT FOR VM TO BE READY
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (1, 'SPIDER INFO CHECK', 'SPIDER INFO CHECK');
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (2, 'INFRASTRUCTURE NS CREATE', 'INFRASTRUCTURE NS CREATE');
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (2, 'INFRASTRUCTURE NS CREATE', 'INFRASTRUCTURE NS RUNNING STATUS');
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (3, 'INFRASTRUCTURE VM CREATE', 'INFRASTRUCTURE VM CREATE');
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (4, 'INFRASTRUCTURE VM DELETE', 'INFRASTRUCTURE VM DELETE');
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (5, 'INFRASTRUCTURE MCI RUNNING STATUS', 'INFRASTRUCTURE MCI RUNNING STATUS');
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (6, 'INFRASTRUCTURE PMK CREATE', 'INFRASTRUCTURE PMK CREATE');
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (7, 'INFRASTRUCTURE PMK DELETE', 'INFRASTRUCTURE PMK DELETE');
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (8, 'INFRASTRUCTURE PMK RUNNING STATUS', 'INFRASTRUCTURE PMK RUNNING STATUS');

INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (9, 'RUN JENKINS JOB', 'RUN JENKINS JOB');

INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (10, 'VM ACCESS INFO', 'VM ACCESS INFO');
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (11, 'ACCESS VM AND SH(MCI VM)', 'ACCESS VM AND SH(MCI VM)');
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (12, 'WAIT FOR VM TO BE READY', 'WAIT FOR VM TO BE READY');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Step 4: Insert into workflow_stage
-- 1. Spider Info Check
-- 2. Infrastructure NS Create
-- 3. Infrastructure NS Running Status
-- 4. Infrastructure VM Create
-- 5. Infrastructure VM Delete
-- 6. Infrastructure MCI Running Status
-- 7. Infrastructure PMK Create
-- 8. Infrastructure PMK Delete
-- 9. Infrastructure PMK Running Status
-- 10. Run Jenkins Job
-- 11. VM GET Access Info
-- 12. ACCESS VM AND SH(MCI VM)
-- 13. WAIT FOR VM TO BE READY
-- INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (1, 1, 1, 'Spider Info Check', 'Spider Info Check', '');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (1, 1, 1, 'Spider Info Check', 'Spider Info Check', '
    stage(''Spider Info Check'') {
      steps {
        echo ''>>>>> STAGE: Spider Info Check''
        echo TUMBLEBUG
        echo MCI

        script {
            // Calling a GET API using curl
            def response = sh(script: ''curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/tumblebug/config --user "${USER}:${USERPASS}"'', returnStdout: true).trim()

            if (response.indexOf(''Http_Status_code:200'') > 0 ) {
                echo "GET API call successful."
                response = response.replace(''- Http_Status_code:200'', '''')
                echo JsonOutput.prettyPrint(response)
            } else {
                error "GET API call failed with status code: ${response}"
            }
        }
      }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (2, 2, 1, 'Infrastructure NS Create', 'Infrastructure NS Create', '
    stage(''Infrastructure NS Create'') {
        steps {
            echo ''>>>>> STAGE: Infrastructure NS Create''
            script {
                def get_namespace_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}"""
                def exist_ns_response = sh(script: """curl -w ''- Http_Status_code:%{http_code}'' ''${get_namespace_url}'' --user ''${USER}:${USERPASS}''""", returnStdout: true).trim()

                if (exist_ns_response.indexOf(''Http_Status_code:200'') > 0 ) {
                    echo """Exist ''${NAMESPACE}'' namespace!"""
                } else {
                    // create namespace
                    def create_ns_response = sh(script: """curl -w ''- Http_Status_code:%{http_code}'' -X ''POST'' ''${TUMBLEBUG}/tumblebug/ns'' -H ''accept: application/json'' -H ''Content-Type: application/json'' -d ''{ "description": "Workflow create namespace", "name": "${NAMESPACE}"}'' --user ''${USER}:${USERPASS}''""", returnStdout: true).trim()

                    echo """${create_ns_response}"""
                    if (create_ns_response.indexOf(''Http_Status_code:200'') > 0 ) {
                        echo """create Namespace ${NAMESPCE}"""
                    } else {
                        error """GET API call failed with status code: ''${response}''"""
                    }
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (3, 3, 1, 'Infrastructure NS Running Status', 'Infrastructure NS Running Status', '
    stage(''Infrastructure NS Running Status'') {
        steps {
            echo ''>>>>> STAGE: Infrastructure MCI Running Status''
            script {
                def tb_vm_status_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}"""
                def response = sh(script:  """curl -w ''- Http_Status_code:%{http_code}'' ${tb_vm_status_url} --user ''${USER}:${USERPASS}''""", returnStdout: true).trim()

                if (response.indexOf(''Http_Status_code:200'') > 0 ) {
                    echo "GET API call successful."
                    response = response.replace(''- Http_Status_code:200'', '''')
                    echo JsonOutput.prettyPrint(response)
                  } else {
                    error "GET API call failed with status code: ${response}"
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (4, 4, 1, 'Infrastructure VM Create', 'Infrastructure VM Create', '
    stage(''Infrastructure VM Create'') {
        steps {
            echo ''>>>>> STAGE: Infrastructure VM Create''
            script {
                echo """shtest6-1"""
                // def payload = """{ "name": "${MCI}", "vm": [ { "commonImage": "${COMMON_IMAGE}", "commonSpec": "${COMMON_SPEC}" } ]}"""
                def payload = """{ "name": "${MCI}", "vm": [ { "name":"vm01", "commonImage": "${COMMON_IMAGE}", "commonSpec": "${COMMON_SPEC}" } ]}"""

                def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/mciDynamic"""
                def call = """curl -X ''POST'' ''${tb_vm_url}'' -H ''accept: application/json'' -H ''Content-Type: application/json'' -d ''${payload}'' --user ''${USER}:${USERPASS}''"""
                def response = sh(script: """ ${call} """, returnStdout: true).trim()
                echo """shtest6-2"""
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (5, 5, 1, 'Infrastructure VM Delete', 'Infrastructure VM Delete', '
    stage(''Infrastructure MCI Terminate'') {
      steps {
        echo ''>>>>> STAGE: Infrastructure MCI Terminate''
        script {
          echo "MCI Terminate Start."
          def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/mci/${MCI}?option=terminate"""
          sh(script: """curl -X DELETE --user ${USER}:${USERPASS} "${tb_vm_url}" -H ''accept: application/json'' """, returnStdout: true)
          echo "MCI Terminate successful."
        }
      }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (6, 6, 1, 'Infrastructure MCI Running Status', 'Infrastructure Running Status', '
    stage(''Infrastructure MCI Running Status'') {
        steps {
            echo ''>>>>> STAGE: Infrastructure MCI Running Status''
            script {
                def tb_vm_status_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/mci/${MCI}?option=status"""
                def response = sh(script: """curl -w ''- Http_Status_code:%{http_code}'' ''${tb_vm_status_url}'' --user ''${USER}:${USERPASS}'' -H ''accept: application/json''""", returnStdout: true).trim()

                if (response.indexOf(''Http_Status_code:200'') > 0 ) {
                    echo "GET API call successful."
                    response = response.replace(''- Http_Status_code:200'', '''')
                    echo JsonOutput.prettyPrint(response)
                  } else {
                    error "GET API call failed with status code: ${response}"
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (7, 7, 1, 'Infrastructure PMK Create', 'Infrastructure PMK Create', '
    stage(''Infrastructure PMK Create'') {
        steps {
            echo ''>>>>> STAGE: Infrastructure PMK Create''
            script {
                def payload = """{ "connectionName": "alibaba-ap-northeast-2", "cspResourceId": "required when option is register", "description": "My K8sCluster", "k8sNodeGroupList": [ { "desiredNodeSize": "1", "imageId": "image-01", "maxNodeSize": "3", "minNodeSize": "1", "name": "ng-01", "onAutoScaling": "true", "rootDiskSize": "40", "rootDiskType": "cloud_essd", "specId": "spec-01", "sshKeyId": "sshkey-01" } ], "name": "k8scluster-01", "securityGroupIds": [ "sg-01" ], "subnetIds": [ "subnet-01" ], "vNetId": "vpc-01", "version": "1.30.1-aliyun.1" }"""
                def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8scluster?option=register"""
                def call = """curl -X ''POST'' --user ''${USER}:${USERPASS}'' ''${tb_vm_url}'' -H ''accept: application/json'' -H ''Content-Type: application/json'' -d ''${payload}''"""
                def response = sh(script: """ ${call} """, returnStdout: true).trim()
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (8, 8, 1, 'Infrastructure PMK Delete', 'Infrastructure PMK Delete', '
    stage(''Infrastructure PMK Delete'') {
        steps {
            echo ''>>>>> STAGE: Infrastructure PMK Delete''
            script {
                def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8scluster/${CLUSTER}?option=force"""
                def call = """curl -X DELETE --user ${USER}:${USERPASS} "${tb_vm_url}" -H accept: "application/json" """
                sh(script: """ ${call} """, returnStdout: true)
                echo "VM deletion successful."
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (9, 9, 1, 'Infrastructure PMK Running Status', 'Infrastructure PMK Running Status', '
    stage(''Infrastructure PMK Running Status'') {
        steps {
            echo ''>>>>> STAGE: Infrastructure PMK Running Status''
            script {
                def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8scluster/${CLUSTER}?option=status"""
                def response = sh(script: """curl -w ''- Http_Status_code:%{http_code}'' ''${tb_vm_url}'' --user ''${USER}:${USERPASS}'' -H ''accept: application/json''""", returnStdout: true).trim()
                if (response.indexOf(''Http_Status_code:200'') > 0 ) {
                    echo "GET API call successful."
                    response = response.replace(''- Http_Status_code:200'', '''')
                    echo JsonOutput.prettyPrint(response)
                } else {
                    error "GET API call failed with status code: ${response}"
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (10, 10, 1, 'Run Jenkins Job', 'Run Jenkins Job', '
        stage (''run jenkins job'') {
            steps {

            }
        }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (11, 11, 1, 'VM GET Access Info', 'VM GET Access Info', '
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/mci/${MCI}?option=accessinfo --user "default:default" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/mci/${MCI}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${USER}:${USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${MCI}.pem", text: pemkey)
                        sh "chmod 600 ${MCI}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (12, 12, 1, 'ACCESS VM AND SH(MCI VM)', 'ACCESS VM AND SH(MCI VM)', '
        stage(''ACCESS VM AND SH(MCI VM)'') {
            steps {
                echo ''>>>>>STAGE: ACCESS VM AND SH(MCI VM)''

            }
        }
');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (13, 13, 1, 'WAIT FOR VM TO BE READY', 'WAIT FOR VM TO BE READY', '
        stage(''Wait for VM to be ready'') {
            steps {
                echo ''>>>>>STAGE: Wait for VM to be ready''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            retry(30) { // 최대 30번 재시도
                                sleep 10 // 10초 대기
                                timeout(time: 5, unit: ''MINUTES'') { // 5분 타임아웃
                                    sh """
                                        ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${MCI}.pem cb-user@${cleanIp} ''echo "VM is ready"''
                                    """
                                }
                            }
                        }
                    }
                }
            }
        }');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Step 5: Insert into workflow
-- 1. vm-mariadb-nginx-all-in-one
-- 2. k8s-mariadb-nginx-all-in-one
-- 3. create-ns
-- 4. create-mci
-- 5. delete-mci
-- 6. create-pmk
-- 7. delete-pmk
-- 8. install-nginx
-- 9. install-mariadb
-- INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (1, 'create vm', 'test', 1, '');
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (1, 'vm-mariadb-nginx-all-in-one', 'test', 1, '
pipeline {
    agent any
    stages {
        //=============================================================================================
        // stage template - Run Jenkins Job
        //=============================================================================================
        stage (''create-ns'') {
            steps {
                build job: ''create-ns'',
                parameters: [
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS),
                ]
            }
        }

        //=============================================================================================
        // stage template - Run Jenkins Job
        //=============================================================================================
        stage (''create-mci'') {
            steps {
                build job: ''create-mci'',
                parameters: [
                    string(name: ''MCI'', value: MCI),
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS),
                    string(name: ''COMMON_IMAGE'', value: COMMON_IMAGE),
                    string(name: ''COMMON_SPEC'', value: COMMON_SPEC),
                ]
            }
        }

        //=============================================================================================
        // stage template - Run Jenkins Job
        //=============================================================================================
        stage (''install-nginx'') {
            steps {
                build job: ''install-nginx'',
                parameters: [
                    string(name: ''MCI'', value: MCI),
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS)
                ]
            }
        }

        //=============================================================================================
        // stage template - Run Jenkins Job
        //=============================================================================================
        stage (''install-mariadb'') {
            steps {
                build job: ''install-mariadb'',
                parameters: [
                    string(name: ''MCI'', value: MCI),
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS)
                ]
            }
        }
    }
}');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (2, 'k8s-mariadb-nginx-all-in-one', 'test', 1, '
pipeline {
    agent any
    stages {
        //=============================================================================================
        // stage template - Run Jenkins Job
        //=============================================================================================
        stage (''create-ns'') {
            steps {
                build job: ''create-ns'',
                parameters: [
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS),
                ]
            }
        }' ||
                                                                                                                                            '
        //=============================================================================================
        // stage template - Run Jenkins Job
        //=============================================================================================
        stage (''create-pmk'') {
            steps {
                build job: ''create-pmk'',
                parameters: [
                    string(name: ''CLUSTER'', value: CLUSTER),
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS)
                ]
            }
        }

        //=============================================================================================
        // stage template - Run Jenkins Job
        //=============================================================================================
        stage (''install-nginx'') {
            steps {
                build job: ''install-nginx'',
                parameters: [
                    string(name: ''MCI'', value: MCI),
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS)
                ]
            }
        }

        //=============================================================================================
        // stage template - Run Jenkins Job
        //=============================================================================================
        stage (''install-mariadb'') {
            steps {
                build job: ''install-mariadb'',
                parameters: [
                    string(name: ''MCI'', value: MCI),
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS)
                ]
            }
        }
    }
}');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (3, 'create-ns', 'test', 1, '
import groovy.json.JsonOutput
import groovy.json.JsonSlurper
import groovy.json.JsonSlurperClassic

pipeline {
  agent any
  stages {
    stage(''Spider Info Check'') {
      steps {
        echo ''>>>>> STAGE: Spider Info Check''
        echo TUMBLEBUG

        script {
            def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/tumblebug/config --user ''${USER}:${USERPASS}''""", returnStdout: true).trim()

            if (response.indexOf(''Http_Status_code:200'') > 0 ) {
                echo "GET API call successful."
                response = response.replace(''- Http_Status_code:200'', '''')
                echo JsonOutput.prettyPrint(response)
            } else {
                error "GET API call failed with status code: ${response}"
            }
        }
      }
    }
    stage(''Infrastructure NS Create'') {
        steps {
            echo ''>>>>> STAGE: Infrastructure NS Create''
            script {
                def get_namespace_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}"""
                def exist_ns_response = sh(script: """curl -w ''- Http_Status_code:%{http_code}'' ''${get_namespace_url}'' --user ''${USER}:${USERPASS}''""", returnStdout: true).trim()

                if (exist_ns_response.indexOf(''Http_Status_code:200'') > 0 ) {
                    echo """Exist ''${NAMESPACE}'' namespace!"""
                } else {
                    // create namespace
                    def create_ns_response = sh(script: """curl -w ''- Http_Status_code:%{http_code}'' -X ''POST'' ''${TUMBLEBUG}/tumblebug/ns'' -H ''accept: application/json'' -H ''Content-Type: application/json'' -d ''{ "description": "Workflow create namespace", "name": "${NAMESPACE}"}'' --user ''${USER}:${USERPASS}''""", returnStdout: true).trim()

                    echo """${create_ns_response}"""
                    if (create_ns_response.indexOf(''Http_Status_code:200'') > 0 ) {
                        echo """create Namespace ${NAMESPCE}"""
                    } else {
                        error """GET API call failed with status code: ''${response}''"""
                    }
                }
            }
        }
    }
    stage(''Infrastructure MCI Running Status'') {
        steps {
            echo ''>>>>> STAGE: Infrastructure MCI Running Status''
            script {
                def tb_vm_status_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}"""
                def response = sh(script:  """curl -w ''- Http_Status_code:%{http_code}'' ${tb_vm_status_url} --user ''${USER}:${USERPASS}''""", returnStdout: true).trim()

                if (response.indexOf(''Http_Status_code:200'') > 0 ) {
                    echo "GET API call successful."
                    response = response.replace(''- Http_Status_code:200'', '''')
                    echo JsonOutput.prettyPrint(response)
                  } else {
                    error "GET API call failed with status code: ${response}"
                }
            }
        }
    }
  }
}');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (4, 'create-mci', 'test', 1, '
import groovy.json.JsonOutput
import groovy.json.JsonSlurper
import groovy.json.JsonSlurperClassic

pipeline {
  agent any
  stages {
    stage(''Spider Info Check'') {
      steps {
        echo ''>>>>> STAGE: Spider Info Check''
        echo TUMBLEBUG
        echo MCI

        script {
            // Calling a GET API using curl
            def response = sh(script: ''curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/tumblebug/config --user "${USER}:${USERPASS}"'', returnStdout: true).trim()

            if (response.indexOf(''Http_Status_code:200'') > 0 ) {
                echo "GET API call successful."
                response = response.replace(''- Http_Status_code:200'', '''')
                echo JsonOutput.prettyPrint(response)
            } else {
                error "GET API call failed with status code: ${response}"
            }
        }
      }
    }
    stage(''Infrastructure VM Create'') {
        steps {
            echo ''>>>>> STAGE: Infrastructure VM Create''
            script {
                echo """shtest6-1"""
                // def payload = """{ "name": "${MCI}", "vm": [ { "commonImage": "${COMMON_IMAGE}", "commonSpec": "${COMMON_SPEC}" } ]}"""
                def payload = """{ "name": "${MCI}", "vm": [ { "name":"vm01", "commonImage": "${COMMON_IMAGE}", "commonSpec": "${COMMON_SPEC}" } ]}"""

                def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/mciDynamic"""
                def call = """curl -X ''POST'' ''${tb_vm_url}'' -H ''accept: application/json'' -H ''Content-Type: application/json'' -d ''${payload}'' --user ''${USER}:${USERPASS}''"""
                def response = sh(script: """ ${call} """, returnStdout: true).trim()
                echo """shtest6-2"""
            }
        }
    }
    stage(''Infrastructure MCI Running Status'') {
        steps {
            echo ''>>>>> STAGE: Infrastructure MCI Running Status''
            script {
                def tb_vm_status_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/mci/${MCI}?option=status"""
                def response = sh(script: """curl -w ''- Http_Status_code:%{http_code}'' ''${tb_vm_status_url}'' --user ''${USER}:${USERPASS}'' -H ''accept: application/json''""", returnStdout: true).trim()

                if (response.indexOf(''Http_Status_code:200'') > 0 ) {
                    echo "GET API call successful."
                    response = response.replace(''- Http_Status_code:200'', '''')
                    echo JsonOutput.prettyPrint(response)
                  } else {
                    error "GET API call failed with status code: ${response}"
                }
            }
        }
    }
  }
}');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (5, 'delete-mci', 'test', 1, '
import groovy.json.JsonOutput
import groovy.json.JsonSlurper
import groovy.json.JsonSlurperClassic
import groovy.json.JsonSlurper

pipeline {
  agent any

  stages {
    stage(''Spider Info Check'') {
      steps {
        echo ''>>>>> STAGE: Spider Info Check''
        script {
          def response = sh(script: ''curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/tumblebug/config --user "${USER}:${USERPASS}"'', returnStdout: true).trim()
          if (response.indexOf(''Http_Status_code:200'') > 0 ) {
            echo "GET API call successful."
            response = response.replace(''- Http_Status_code:200'', '''')
            echo JsonOutput.prettyPrint(response)
          } else {
            error "GET API call failed with status code: ${response}"
          }
        }
      }
    }
    stage(''Infrastructure MCI Terminate'') {
      steps {
        echo ''>>>>> STAGE: Infrastructure MCI Terminate''
        script {
          echo "MCI Terminate Start."
          def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/mci/${MCI}?option=terminate"""
          sh(script: """curl -X DELETE --user ${USER}:${USERPASS} "${tb_vm_url}" -H ''accept: application/json'' """, returnStdout: true)
          echo "MCI Terminate successful."
        }
      }
    }
    stage(''Infrastructure MCI Running Status'') {
      steps {
        echo ''>>>>> STAGE: Infrastructure MCI Running Status''
        script {
          def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/mci/${MCI}?option=status"""
          def response = sh(script: """curl -w ''- Http_Status_code:%{http_code}'' ''${tb_vm_url}'' --user ''${USER}:${USERPASS}'' -H ''accept: application/json''""", returnStdout: true).trim()
          if (response.indexOf(''Http_Status_code:200'') > 0 ) {
            echo "GET API call successful."
            response = response.replace(''- Http_Status_code:200'', '''')
            echo JsonOutput.prettyPrint(response)
          } else {
            // error "GET API call failed with status code: ${response}"
            echo "Is Not Exist MCI!"
          }
        }
      }
    }
  }
}');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (6, 'create-pmk', 'test', 1, '
import groovy.json.JsonOutput
import groovy.json.JsonSlurper
import groovy.json.JsonSlurperClassic
import groovy.json.JsonSlurper

pipeline {
  agent any
  stages {
    stage(''Spider Info Check'') {
      steps {
        echo ''>>>>> STAGE: Spider Info Check''
        script {
          def response = sh(script: ''curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/tumblebug/config --user "${USER}:${USERPASS}"'', returnStdout: true).trim()
          if (response.indexOf(''Http_Status_code:200'') > 0 ) {
            echo "GET API call successful."
            response = response.replace(''- Http_Status_code:200'', '''')
            echo JsonOutput.prettyPrint(response)
          } else {
            error "GET API call failed with status code: ${response}"
          }
        }
      }
    }
    stage(''Infrastructure K8S Create'') {
      steps {
        echo ''>>>>> STAGE: Infrastructure K8S Create''
        script {
            def payload = """{ "connectionName": "alibaba-ap-northeast-2", "cspResourceId": "required when option is register", "description": "My K8sCluster", "k8sNodeGroupList": [ { "desiredNodeSize": "1", "imageId": "image-01", "maxNodeSize": "3", "minNodeSize": "1", "name": "ng-01", "onAutoScaling": "true", "rootDiskSize": "40", "rootDiskType": "cloud_essd", "specId": "spec-01", "sshKeyId": "sshkey-01" } ], "name": "k8scluster-01", "securityGroupIds": [ "sg-01" ], "subnetIds": [ "subnet-01" ], "vNetId": "vpc-01", "version": "1.30.1-aliyun.1" }"""
            def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8scluster?option=register"""
            def call = """curl -X ''POST'' --user ''${USER}:${USERPASS}'' ''${tb_vm_url}'' -H ''accept: application/json'' -H ''Content-Type: application/json'' -d ''${payload}''"""
            def response = sh(script: """ ${call} """, returnStdout: true).trim()
        }
      }
    }
    stage(''Infrastructure PMK Running Status'') {
      steps {
        echo ''>>>>> STAGE: Infrastructure PMK Running Status''
        script {
          def tb_vm_status_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8scluster/${CLUSTER}?option=status"""
          def response = sh(script: """curl -w ''- Http_Status_code:%{http_code}'' ''${tb_vm_status_url}'' --user ''${USER}:${USERPASS}'' -H ''accept: application/json''""", returnStdout: true).trim()

          if (response.indexOf(''Http_Status_code:200'') > 0 ) {
            echo "GET API call successful."
            response = response.replace(''- Http_Status_code:200'', '''')
            echo JsonOutput.prettyPrint(response)
          } else {
            error "GET API call failed with status code: ${response}"
          }
        }
      }
    }
  }
}');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (7, 'delete-pmk', 'test', 1, '
import groovy.json.JsonOutput
import groovy.json.JsonSlurper
import groovy.json.JsonSlurperClassic
import groovy.json.JsonSlurper

pipeline {
  agent any

  stages {
    stage(''Spider Info Check'') {
      steps {
        echo ''>>>>> STAGE: Spider Info Check''
        script {
          def response = sh(script: ''curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/tumblebug/config --user "${USER}:${USERPASS}"'', returnStdout: true).trim()
          if (response.indexOf(''Http_Status_code:200'') > 0 ) {
            echo "GET API call successful."
            response = response.replace(''- Http_Status_code:200'', '''')
            echo JsonOutput.prettyPrint(response)
          } else {
            error "GET API call failed with status code: ${response}"
          }
        }
      }
    }

    stage(''Infrastructure K8S Delete'') {
      steps {
        echo ''>>>>> STAGE: Infrastructure VM Delete''
        script {
          def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8scluster/${CLUSTER}?option=force"""
          def call = """curl -X DELETE --user ${USER}:${USERPASS} "${tb_vm_url}" -H accept: "application/json" """
          sh(script: """ ${call} """, returnStdout: true)
          echo "VM deletion successful."
        }
      }
    }

    stage(''Infrastructure PMK Running Status'') {
      steps {
        echo ''>>>>> STAGE: Infrastructure PMK Running Status''
        script {
          def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8scluster/${CLUSTER}?option=status"""
          def response = sh(script: """curl -w ''- Http_Status_code:%{http_code}'' ''${tb_vm_url}'' --user ''${USER}:${USERPASS}'' -H ''accept: application/json''""", returnStdout: true).trim()
          if (response.indexOf(''Http_Status_code:200'') > 0 ) {
            echo "GET API call successful."
            response = response.replace(''- Http_Status_code:200'', '''')
            echo JsonOutput.prettyPrint(response)
          } else {
            error "GET API call failed with status code: ${response}"
          }
        }
      }
    }
  }
}');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (8, 'install-nginx', 'test', 1, 'import groovy.json.JsonSlurper

def getSSHKey(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findResult { it.key == ''MciSubGroupAccessInfo'' ?
        it.value.findResult { it.MciVmAccessInfo?.findResult { it.privateKey } } : null
    } ?: ''''
}

def getPublicInfoList(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findAll { it.key == ''MciSubGroupAccessInfo'' }
        .collectMany { it.value.MciVmAccessInfo*.publicIP }
}

//Global variable
def callData = ''''
def infoObj = ''''
def unsupportedOsCount = 0 // Counter for unsupported OS (global for the entire pipeline)

pipeline {
    agent any

    stages {

        //=============================================================================================
        // stage template - VM ACCESS INFO
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/tumblebug/ns/ns01/mci/${MCI}?option=accessinfo --user "default:default" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/mci/${MCI}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${USER}:${USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${MCI}.pem", text: pemkey)
                        sh "chmod 600 ${MCI}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }

        stage(''Wait for VM to be ready'') {
            steps {
                echo ''>>>>>STAGE: Wait for VM to be ready''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            retry(30) { // 최대 30번 재시도
                                sleep 10 // 10초 대기
                                timeout(time: 5, unit: ''MINUTES'') { // 5분 타임아웃
                                    sh """
                                        ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${MCI}.pem cb-user@${cleanIp} ''echo "VM is ready"''
                                    """
                                }
                            }
                        }
                    }
                }
            }
        }

        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCI VM)
        //=============================================================================================
         stage(''Set nginx'') {
            steps {
                echo ''>>>>>STAGE: Set nginx''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>Installing Nginx on VM : ${cleanIp}"
                            sh """
                                ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${MCI}.pem cb-user@${cleanIp} ''
                                #!/bin/bash

                                echo ==========================================================================

                                # Determine OS name
                                os=\$(uname)

                                # Check release
                                if [ "\$os" = "Linux" ]; then
                                    echo "This is a Linux machine"

                                    if [[ -f /etc/redhat-release ]]; then
                                        pkg_manager=yum
                                    elif [[ -f /etc/debian_version ]]; then
                                        pkg_manager=apt
                                    fi

                                    if [ \$pkg_manager = "yum" ]; then
                                        echo "Using yum"
                                        sudo yum update -y
                                        sudo yum install nginx -y
                                    elif [ \$pkg_manager = "apt" ]; then
                                        echo "Using apt"
                                        sudo apt-get update && sudo apt-get upgrade -y
                                        sudo apt install nginx -y
                                    fi

                                elif [ "\$os" = "Darwin" ]; then
                                    echo "This is a Mac Machine. Not supported"
                                    exit 1
                                else
                                    echo "Unsupported OS"
                                    exit 1
                                fi

                                echo "Nginx installed!"
                                ''
                            """
                        }
                    }
                }
            }
         }
    }
}
');
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (9, 'install-mariadb', 'test', 1, '
import groovy.json.JsonSlurper

def getSSHKey(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findResult { it.key == ''MciSubGroupAccessInfo'' ?
        it.value.findResult { it.MciVmAccessInfo?.findResult { it.privateKey } } : null
    } ?: ''''
}

def getPublicInfoList(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findAll { it.key == ''MciSubGroupAccessInfo'' }
        .collectMany { it.value.MciVmAccessInfo*.publicIP }
}

//Global variable
def callData = ''''
def infoObj = ''''

pipeline {
    agent any

    stages {
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/mci/${MCI}?option=accessinfo --user "default:default" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/mci/${MCI}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${USER}:${USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${MCI}.pem", text: pemkey)
                        sh "chmod 600 ${MCI}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }

        stage(''Wait for VM to be ready'') {
            steps {
                echo ''>>>>>STAGE: Wait for VM to be ready''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    publicIPs.each { ip ->
                        def cleanIp = ip.toString().replaceAll(/[\[\]]/, '''')
                        retry(30) { // 최대 30번 재시도
                            sleep 10 // 10초 대기
                            timeout(time: 5, unit: ''MINUTES'') { // 5분 타임아웃
                                sh """
                                    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${MCI}.pem cb-user@${cleanIp} ''echo "VM is ready"''
                                """
                            }
                        }
                    }
                }
            }
        }

        stage(''Set MariaDB'') {
            steps {
                echo ''>>>>>STAGE: Set MariaDB''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    publicIPs.each { ip ->
                        def cleanIp = ip.toString().replaceAll(/[\[\]]/, '''')
                        println ">>Installing MariaDB on VM : ${cleanIp}"
                        sh """
                            ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${MCI}.pem cb-user@${cleanIp} ''
                            #!/bin/bash

                            # Determine OS name
                            os=\$(uname)

                            # chk release
                            if [ "\$os" = "Linux" ]; then
                              echo "This is a Linux machine"

                              if [[ -f /etc/redhat-release ]]; then
                                pkg_manager=yum
                                sudo yum update -y
                                sudo yum install mariadb-server mariadb-client -y
                              elif [[ -f /etc/debian_version ]]; then
                                pkg_manager=apt
                                sudo apt-get update && sudo apt-get upgrade -y
                                sudo apt-get install mariadb-server mariadb-client -y
                              else
                                echo "Unsupported Linux distribution"
                                exit 1
                              fi

                            elif [ "\$os" = "Darwin" ]; then
                              echo "This is a Mac Machine. not supported"
                              exit 1
                            else
                              echo "Unsupported OS"
                              exit 1
                            fi

                            echo "MariaDB installed!"
                            ''
                        """
                    }
                }
            }
        }
    }
}');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Step 6: Insert into workflow_param
-- 1. vm-mariadb-nginx-all-in-one
-- 2. k8s-mariadb-nginx-all-in-one
-- 3. create-ns
-- 4. create-mci
-- 5. delete-mci
-- 6. create-pmk
-- 7. delete-pmk
-- 8. install-nginx
-- 9. install-mariadb
-- INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (1, 1, 'MCI', '', 'N');
-- Workflow : vm-mariadb-nginx-all-in-one
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (1, 1, 'MCI', 'mci01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (2, 1, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (3, 1, 'TUMBLEBUG', 'http://tb-url:1323', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (4, 1, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (5, 1, 'USERPASS', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (6, 1, 'COMMON_IMAGE', 'aws+ap-northeast-2+ubuntu22.04', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (7, 1, 'COMMON_SPEC', 'aws+ap-northeast-2+t2.small', 'N');

-- Workflow : k8s-mariadb-nginx-all-in-one
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (8, 2, 'CLUSTER', 'pmk01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (9, 2, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (10, 2, 'TUMBLEBUG', 'http://tb-url:1323', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (11, 2, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (12, 2, 'USERPASS', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (13, 2, 'COMMON_IMAGE', 'aws+ap-northeast-2+ubuntu22.04', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (14, 2, 'COMMON_SPEC', 'aws+ap-northeast-2+t2.small', 'N');

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : create-ns
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (15, 3, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (16, 3, 'TUMBLEBUG', 'http://tb-url:1323', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (17, 3, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (18, 3, 'USERPASS', 'default', 'N');

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : create-mci
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (19, 4, 'MCI', 'mci01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (20, 4, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (21, 4, 'TUMBLEBUG', 'http://tb-url:1323', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (22, 4, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (23, 4, 'USERPASS', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (24, 4, 'COMMON_IMAGE', 'aws+ap-northeast-2+ubuntu22.04', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (25, 4, 'COMMON_SPEC', 'aws+ap-northeast-2+t2.small', 'N');

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : delete-mci
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (26, 5, 'MCI', 'mci01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (27, 5, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (28, 5, 'TUMBLEBUG', 'http://tb-url:1323', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (29, 5, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (30, 5, 'USERPASS', 'default', 'N');

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : create-pmk
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (31, 6, 'CLUSTER', 'pmk01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (32, 6, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (33, 6, 'TUMBLEBUG', 'http://tb-url:1323', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (34, 6, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (35, 6, 'USERPASS', 'default', 'N');

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : delete-pmk
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (36, 7, 'CLUSTER', 'pmk01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (37, 7, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (38, 7, 'TUMBLEBUG', 'http://tb-url:1323', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (39, 7, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (40, 7, 'USERPASS', 'default', 'N');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : install-nginx
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (41, 8, 'MCI', 'mci01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (42, 8, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (43, 8, 'TUMBLEBUG', 'http://tb-url:1323', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (44, 8, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (45, 8, 'USERPASS', 'default', 'N');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : install-mariadb
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (46, 9, 'MCI', 'mci01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (47, 9, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (48, 9, 'TUMBLEBUG', 'http://tb-url:1323', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (49, 9, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (50, 9, 'USERPASS', 'default', 'N');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Step 7: Insert into workflow_stage_mapping
-- 1. vm-mariadb-nginx-all-in-one
-- 2. k8s-mariadb-nginx-all-in-one
-- 3. create-ns
-- 4. create-mci
-- 5. delete-mci
-- 6. create-pmk
-- 7. delete-pmk
-- 8. install-nginx
-- 9. install-mariadb
-- INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (1, 1, 1, null, '');
-- Workflow : vm-mariadb-nginx-all-in-one
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (1, 1, 1, null, '
pipeline {
    agent any
    stages {');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (2, 1, 2, 10, '
        //=============================================================================================
        // stage template - Run Jenkins Job
        //=============================================================================================
        stage (''create-ns'') {
            steps {
                build job: ''create-ns'',
                parameters: [
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS),
                ]
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (3, 1, 3, 10, '
        //=============================================================================================
        // stage template - Run Jenkins Job
        //=============================================================================================
        stage (''create-mci'') {
            steps {
                build job: ''create-mci'',
                parameters: [
                    string(name: ''MCI'', value: MCI),
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS),
                    string(name: ''COMMON_IMAGE'', value: COMMON_IMAGE),
                    string(name: ''COMMON_SPEC'', value: COMMON_SPEC),
                ]
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (4, 1, 4, 10, '
        //=============================================================================================
        // stage template - Run Jenkins Job
        //=============================================================================================
        stage (''install-nginx'') {
            steps {
                build job: ''install-nginx'',
                parameters: [
                    string(name: ''MCI'', value: MCI),
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS)
                ]
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (5, 1, 5, 10, '
        //=============================================================================================
        // stage template - Run Jenkins Job
        //=============================================================================================
        stage (''install-mariadb'') {
            steps {
                build job: ''install-mariadb'',
                parameters: [
                    string(name: ''MCI'', value: MCI),
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS)
                ]
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (6, 1, 6, null, '
    }
}');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Workflow : k8s-mariadb-nginx-all-in-one
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (7, 2, 1, null, '
pipeline {
    agent any
    stages {');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (8, 2, 2, 10, '
        //=============================================================================================
        // stage template - Run Jenkins Job
        //=============================================================================================
        stage (''create-ns'') {
            steps {
                build job: ''create-ns'',
                parameters: [
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS),
                ]
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (9, 2, 3, 10, '
        //=============================================================================================
        // stage template - Run Jenkins Job
        //=============================================================================================
        stage (''create-pmk'') {
            steps {
                build job: ''create-pmk'',
                parameters: [
                    string(name: ''CLUSTER'', value: CLUSTER),
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS),
                    string(name: ''COMMON_IMAGE'', value: COMMON_IMAGE),
                    string(name: ''COMMON_SPEC'', value: COMMON_SPEC),
                ]
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (10, 2, 4, 10, '
        //=============================================================================================
        // stage template - Run Jenkins Job
        //=============================================================================================
        stage (''install-nginx'') {
            steps {
                build job: ''install-nginx'',
                parameters: [
                    string(name: ''MCI'', value: MCI),
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS)
                ]
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (11, 2, 5, 10, '
        //=============================================================================================
        // stage template - Run Jenkins Job
        //=============================================================================================
        stage (''install-mariadb'') {
            steps {
                build job: ''install-mariadb'',
                parameters: [
                    string(name: ''MCI'', value: MCI),
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS)
                ]
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (12, 2, 6, null, '
    }
}');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : create-ns
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (13, 3, 1, null, '
import groovy.json.JsonOutput
import groovy.json.JsonSlurper
import groovy.json.JsonSlurperClassic

pipeline {
  agent any
  stages {');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (14, 3, 2, 1, '
    stage(''Spider Info Check'') {
      steps {
        echo ''>>>>> STAGE: Spider Info Check''
        script {
            def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/tumblebug/config --user ''${USER}:${USERPASS}''""", returnStdout: true).trim()

            if (response.indexOf(''Http_Status_code:200'') > 0 ) {
                echo "GET API call successful."
                response = response.replace(''- Http_Status_code:200'', '''')
                echo JsonOutput.prettyPrint(response)
            } else {
                error "GET API call failed with status code: ${response}"
            }
        }
      }
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (15, 3, 3, 2, '
    stage(''Infrastructure NS Create'') {
        steps {
            echo ''>>>>> STAGE: Infrastructure NS Create''
            script {
                def get_namespace_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}"""
                def exist_ns_response = sh(script: """curl -w ''- Http_Status_code:%{http_code}'' ''${get_namespace_url}'' --user ''${USER}:${USERPASS}''""", returnStdout: true).trim()

                if (exist_ns_response.indexOf(''Http_Status_code:200'') > 0 ) {
                    echo """Exist ''${NAMESPACE}'' namespace!"""
                } else {
                    // create namespace
                    def create_ns_response = sh(script: """curl -w ''- Http_Status_code:%{http_code}'' -X ''POST'' ''${TUMBLEBUG}/tumblebug/ns'' -H ''accept: application/json'' -H ''Content-Type: application/json'' -d ''{ "description": "Workflow create namespace", "name": "${NAMESPACE}"}'' --user ''${USER}:${USERPASS}''""", returnStdout: true).trim()

                    echo """${create_ns_response}"""
                    if (create_ns_response.indexOf(''Http_Status_code:200'') > 0 ) {
                        echo """create Namespace ${NAMESPCE}"""
                    } else {
                        error """GET API call failed with status code: ''${response}''"""
                    }
                }
            }
        }
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (16, 3, 4, 3, '
    stage(''Infrastructure NS Running Status'') {
        steps {
            echo ''>>>>> STAGE: Infrastructure MCI Running Status''
            script {
                def tb_vm_status_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}"""
                def response = sh(script:  """curl -w ''- Http_Status_code:%{http_code}'' ${tb_vm_status_url} --user ''${USER}:${USERPASS}''""", returnStdout: true).trim()

                if (response.indexOf(''Http_Status_code:200'') > 0 ) {
                    echo "GET API call successful."
                    response = response.replace(''- Http_Status_code:200'', '''')
                    echo JsonOutput.prettyPrint(response)
                  } else {
                    error "GET API call failed with status code: ${response}"
                }
            }
        }
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (17, 3, 5, null, '
  }
}');


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : create-mci
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (18, 4, 1, null, '
import groovy.json.JsonOutput
import groovy.json.JsonSlurper
import groovy.json.JsonSlurperClassic

pipeline {
  agent any
  stages {');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (19, 4, 2, 1, '
    stage(''Spider Info Check'') {
      steps {
        echo ''>>>>> STAGE: Spider Info Check''
        script {
            // Calling a GET API using curl
            def response = sh(script: ''curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/tumblebug/config --user "${USER}:${USERPASS}"'', returnStdout: true).trim()

            if (response.indexOf(''Http_Status_code:200'') > 0 ) {
                echo "GET API call successful."
                response = response.replace(''- Http_Status_code:200'', '''')
                echo JsonOutput.prettyPrint(response)
            } else {
                error "GET API call failed with status code: ${response}"
            }
        }
      }
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (20, 4, 3, 4, '
    stage(''Infrastructure VM Create'') {
        steps {
            echo ''>>>>> STAGE: Infrastructure VM Create''
            script {
                echo """shtest6-1"""
                // def payload = """{ "name": "${MCI}", "vm": [ { "commonImage": "${COMMON_IMAGE}", "commonSpec": "${COMMON_SPEC}" } ]}"""
                def payload = """{ "name": "${MCI}", "vm": [ { "name":"vm01", "commonImage": "${COMMON_IMAGE}", "commonSpec": "${COMMON_SPEC}" } ]}"""

                def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/mciDynamic"""
                def call = """curl -X ''POST'' ''${tb_vm_url}'' -H ''accept: application/json'' -H ''Content-Type: application/json'' -d ''${payload}'' --user ''${USER}:${USERPASS}''"""
                def response = sh(script: """ ${call} """, returnStdout: true).trim()
                echo """shtest6-2"""
            }
        }
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (21, 4, 4, 6, '
    stage(''Infrastructure MCI Running Status'') {
        steps {
            echo ''>>>>> STAGE: Infrastructure MCI Running Status''
            script {
                def tb_vm_status_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/mci/${MCI}?option=status"""
                def response = sh(script: """curl -w ''- Http_Status_code:%{http_code}'' ''${tb_vm_status_url}'' --user ''${USER}:${USERPASS}'' -H ''accept: application/json''""", returnStdout: true).trim()

                if (response.indexOf(''Http_Status_code:200'') > 0 ) {
                    echo "GET API call successful."
                    response = response.replace(''- Http_Status_code:200'', '''')
                    echo JsonOutput.prettyPrint(response)
                  } else {
                    error "GET API call failed with status code: ${response}"
                }
            }
        }
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (22, 4, 5, null, '
  }
}');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : delete-mci
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (23, 5, 1, null, '
import groovy.json.JsonOutput
import groovy.json.JsonSlurper
import groovy.json.JsonSlurperClassic
import groovy.json.JsonSlurper

pipeline {
  agent any
  stages {');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (24, 5, 2, 1, '
    stage(''Spider Info Check'') {
      steps {
        echo ''>>>>> STAGE: Spider Info Check''
        script {
          def response = sh(script: ''curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/tumblebug/config --user "${USER}:${USERPASS}"'', returnStdout: true).trim()
          if (response.indexOf(''Http_Status_code:200'') > 0 ) {
            echo "GET API call successful."
            response = response.replace(''- Http_Status_code:200'', '''')
            echo JsonOutput.prettyPrint(response)
          } else {
            error "GET API call failed with status code: ${response}"
          }
        }
      }
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (25, 5, 3, 5, '
    stage(''Infrastructure MCI Terminate'') {
      steps {
        echo ''>>>>> STAGE: Infrastructure MCI Terminate''
        script {
          echo "MCI Terminate Start."
          def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/mci/${MCI}?option=terminate"""
          sh(script: """curl -X DELETE --user ${USER}:${USERPASS} "${tb_vm_url}" -H ''accept: application/json'' """, returnStdout: true)
          echo "MCI Terminate successful."
        }
      }
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (26, 5, 4, 6, '
    stage(''Infrastructure MCI Running Status'') {
      steps {
        echo ''>>>>> STAGE: Infrastructure MCI Running Status''
        script {
          def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/mci/${MCI}?option=status"""
          def response = sh(script: """curl -w ''- Http_Status_code:%{http_code}'' ''${tb_vm_url}'' --user ''${USER}:${USERPASS}'' -H ''accept: application/json''""", returnStdout: true).trim()
          if (response.indexOf(''Http_Status_code:200'') > 0 ) {
            echo "GET API call successful."
            response = response.replace(''- Http_Status_code:200'', '''')
            echo JsonOutput.prettyPrint(response)
          } else {
            // error "GET API call failed with status code: ${response}"
            echo "Is Not Exist MCI!"
          }
        }
      }
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (27, 5, 5, null, '
  }
}');
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : create-pmk
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (28, 6, 1, null, '
import groovy.json.JsonOutput
import groovy.json.JsonSlurper
import groovy.json.JsonSlurperClassic
import groovy.json.JsonSlurper

pipeline {
  agent any
  stages {');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (29, 6, 2, 1, '
    stage(''Spider Info Check'') {
      steps {
        echo ''>>>>> STAGE: Spider Info Check''
        script {
          def response = sh(script: ''curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/tumblebug/config --user "${USER}:${USERPASS}"'', returnStdout: true).trim()
          if (response.indexOf(''Http_Status_code:200'') > 0 ) {
            echo "GET API call successful."
            response = response.replace(''- Http_Status_code:200'', '''')
            echo JsonOutput.prettyPrint(response)
          } else {
            error "GET API call failed with status code: ${response}"
          }
        }
      }
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (30, 6, 3, 7, '
    stage(''Infrastructure K8S Create'') {
      steps {
        echo ''>>>>> STAGE: Infrastructure K8S Create''
        script {
            def payload = """{ "connectionName": "alibaba-ap-northeast-2", "cspResourceId": "required when option is register", "description": "My K8sCluster", "k8sNodeGroupList": [ { "desiredNodeSize": "1", "imageId": "image-01", "maxNodeSize": "3", "minNodeSize": "1", "name": "ng-01", "onAutoScaling": "true", "rootDiskSize": "40", "rootDiskType": "cloud_essd", "specId": "spec-01", "sshKeyId": "sshkey-01" } ], "name": "k8scluster-01", "securityGroupIds": [ "sg-01" ], "subnetIds": [ "subnet-01" ], "vNetId": "vpc-01", "version": "1.30.1-aliyun.1" }"""
            def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8scluster?option=register"""
            def call = """curl -X ''POST'' --user ''${USER}:${USERPASS}'' ''${tb_vm_url}'' -H ''accept: application/json'' -H ''Content-Type: application/json'' -d ''${payload}''"""
            def response = sh(script: """ ${call} """, returnStdout: true).trim()
        }
      }
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (31, 6, 4, 9, '
    stage(''Infrastructure PMK Running Status'') {
      steps {
        echo ''>>>>> STAGE: Infrastructure PMK Running Status''
        script {
          def tb_vm_status_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8scluster/${CLUSTER}?option=status"""
          def response = sh(script: """curl -w ''- Http_Status_code:%{http_code}'' ''${tb_vm_status_url}'' --user ''${USER}:${USERPASS}'' -H ''accept: application/json''""", returnStdout: true).trim()

          if (response.indexOf(''Http_Status_code:200'') > 0 ) {
            echo "GET API call successful."
            response = response.replace(''- Http_Status_code:200'', '''')
            echo JsonOutput.prettyPrint(response)
          } else {
            error "GET API call failed with status code: ${response}"
          }
        }
      }
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (32, 6, 5, null, '
  }
}');
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : delete-pmk
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (33, 7, 1, null, '
import groovy.json.JsonOutput
import groovy.json.JsonSlurper
import groovy.json.JsonSlurperClassic
import groovy.json.JsonSlurper

pipeline {
  agent any
  stages {');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (34, 7, 2, 1, '
    stage(''Spider Info Check'') {
      steps {
        echo ''>>>>> STAGE: Spider Info Check''
        script {
          def response = sh(script: ''curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/tumblebug/config --user "${USER}:${USERPASS}"'', returnStdout: true).trim()
          if (response.indexOf(''Http_Status_code:200'') > 0 ) {
            echo "GET API call successful."
            response = response.replace(''- Http_Status_code:200'', '''')
            echo JsonOutput.prettyPrint(response)
          } else {
            error "GET API call failed with status code: ${response}"
          }
        }
      }
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (35, 7, 3, 8, '
    stage(''Infrastructure PMK Delete'') {
      steps {
        echo ''>>>>> STAGE: Infrastructure PMK Delete''
        script {
          def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8scluster/${CLUSTER}?option=force"""
          def call = """curl -X DELETE --user ${USER}:${USERPASS} "${tb_vm_url}" -H accept: "application/json" """
          sh(script: """ ${call} """, returnStdout: true)
          echo "VM deletion successful."
        }
      }
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (36, 7, 4, 9, '
    stage(''Infrastructure PMK Running Status'') {
      steps {
        echo ''>>>>> STAGE: Infrastructure PMK Running Status''
        script {
          def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8scluster/${CLUSTER}?option=status"""
          def response = sh(script: """curl -w ''- Http_Status_code:%{http_code}'' ''${tb_vm_url}'' --user ''${USER}:${USERPASS}'' -H ''accept: application/json''""", returnStdout: true).trim()
          if (response.indexOf(''Http_Status_code:200'') > 0 ) {
            echo "GET API call successful."
            response = response.replace(''- Http_Status_code:200'', '''')
            echo JsonOutput.prettyPrint(response)
          } else {
            error "GET API call failed with status code: ${response}"
          }
        }
      }
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (37, 7, 5, null, '
  }
}');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : install-nginx
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (38, 8, 1, null, '
import groovy.json.JsonSlurper

def getSSHKey(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findResult { it.key == ''MciSubGroupAccessInfo'' ?
        it.value.findResult { it.MciVmAccessInfo?.findResult { it.privateKey } } : null
    } ?: ''''
}

def getPublicInfoList(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findAll { it.key == ''MciSubGroupAccessInfo'' }
        .collectMany { it.value.MciVmAccessInfo*.publicIP }
}

//Global variable
def callData = ''''
def infoObj = ''''
def unsupportedOsCount = 0 // Counter for unsupported OS (global for the entire pipeline)

pipeline {
    agent any
    stages {');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (39, 8, 2, 11, '
        //=============================================================================================
        // stage template - VM ACCESS INFO
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/tumblebug/ns/ns01/mci/${MCI}?option=accessinfo --user "default:default" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/mci/${MCI}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${USER}:${USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${MCI}.pem", text: pemkey)
                        sh "chmod 600 ${MCI}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (40, 8, 3, 13, '
        stage(''Wait for VM to be ready'') {
            steps {
                echo ''>>>>>STAGE: Wait for VM to be ready''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            retry(30) { // 최대 30번 재시도
                                sleep 10 // 10초 대기
                                timeout(time: 5, unit: ''MINUTES'') { // 5분 타임아웃
                                    sh """
                                        ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${MCI}.pem cb-user@${cleanIp} ''echo "VM is ready"''
                                    """
                                }
                            }
                        }
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (41, 8, 4, 12, '
        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCI VM)
        //=============================================================================================
         stage(''Set nginx'') {
            steps {
                echo ''>>>>>STAGE: Set nginx''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>Installing Nginx on VM : ${cleanIp}"
                            sh """
                                ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${MCI}.pem cb-user@${cleanIp} ''
                                #!/bin/bash

                                echo ==========================================================================

                                # Determine OS name
                                os=\$(uname)

                                # Check release
                                if [ "\$os" = "Linux" ]; then
                                    echo "This is a Linux machine"

                                    if [[ -f /etc/redhat-release ]]; then
                                        pkg_manager=yum
                                    elif [[ -f /etc/debian_version ]]; then
                                        pkg_manager=apt
                                    fi

                                    if [ \$pkg_manager = "yum" ]; then
                                        echo "Using yum"
                                        sudo yum update -y
                                        sudo yum install nginx -y
                                    elif [ \$pkg_manager = "apt" ]; then
                                        echo "Using apt"
                                        sudo apt-get update && sudo apt-get upgrade -y
                                        sudo apt install nginx -y
                                    fi

                                elif [ "\$os" = "Darwin" ]; then
                                    echo "This is a Mac Machine. Not supported"
                                    exit 1
                                else
                                    echo "Unsupported OS"
                                    exit 1
                                fi

                                echo "Nginx installed!"
                                ''
                            """
                        }
                    }
                }
            }
         }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (42, 8, 5, null, '
    }
}');


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : install-mariadb
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (43, 9, 1, null, '
import groovy.json.JsonSlurper

def getSSHKey(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findResult { it.key == ''MciSubGroupAccessInfo'' ?
        it.value.findResult { it.MciVmAccessInfo?.findResult { it.privateKey } } : null
    } ?: ''''
}

def getPublicInfoList(jsonInput) {
    def json = new JsonSlurper().parseText(jsonInput)
    return json.findAll { it.key == ''MciSubGroupAccessInfo'' }
        .collectMany { it.value.MciVmAccessInfo*.publicIP }
}' ||
                                                                                                                               '
//Global variable
def callData = ''''
def infoObj = ''''
pipeline {
    agent any
    stages {');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (44, 9, 2, 11, '
        //=============================================================================================
        // stage template - VM ACCESS INFO
        // need two functions : getSSHKey(jsonInput), getPublicInfoList(jsonInput)
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/mci/${MCI}?option=accessinfo --user "default:default" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/mci/${MCI}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${USER}:${USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${MCI}.pem", text: pemkey)
                        sh "chmod 600 ${MCI}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (45, 9, 3, 13, '
        stage(''Wait for VM to be ready'') {
            steps {
                echo ''>>>>>STAGE: Wait for VM to be ready''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    publicIPs.each { ip ->
                        def cleanIp = ip.toString().replaceAll(/[\[\]]/, '''')
                        retry(30) { // 최대 30번 재시도
                            sleep 10 // 10초 대기
                            timeout(time: 5, unit: ''MINUTES'') { // 5분 타임아웃
                                sh """
                                    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${MCI}.pem cb-user@${cleanIp} ''echo "VM is ready"''
                                """
                            }
                        }
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (46, 9, 4, 12, '
        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCI VM)
        //=============================================================================================
               stage(''Set MariaDB'') {
            steps {
                echo ''>>>>>STAGE: Set MariaDB''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    publicIPs.each { ip ->
                        def cleanIp = ip.toString().replaceAll(/[\[\]]/, '''')
                        println ">>Installing MariaDB on VM : ${cleanIp}"
                        sh """
                            ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${MCI}.pem cb-user@${cleanIp} ''
                            #!/bin/bash

                            # Determine OS name
                            os=\$(uname)

                            # chk release
                            if [ "\$os" = "Linux" ]; then
                              echo "This is a Linux machine"

                              if [[ -f /etc/redhat-release ]]; then
                                pkg_manager=yum
                                sudo yum update -y
                                sudo yum install mariadb-server mariadb-client -y
                              elif [[ -f /etc/debian_version ]]; then
                                pkg_manager=apt
                                sudo apt-get update && sudo apt-get upgrade -y
                                sudo apt-get install mariadb-server mariadb-client -y
                              else
                                echo "Unsupported Linux distribution"
                                exit 1
                              fi

                            elif [ "\$os" = "Darwin" ]; then
                              echo "This is a Mac Machine. not supported"
                              exit 1
                            else
                              echo "Unsupported OS"
                              exit 1
                            fi

                            echo "MariaDB installed!"
                            ''
                        """
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (47, 9, 5, null, '
    }
}
');