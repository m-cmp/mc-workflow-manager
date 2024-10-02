-- Step 1: Insert into oss_type
INSERT INTO oss_type (oss_type_idx, oss_type_name, oss_type_desc) VALUES (1, 'JENKINS', 'init');

-- Step 2: Insert into oss
INSERT INTO oss (oss_idx, oss_type_idx, oss_name, oss_desc, oss_url, oss_username, oss_password) VALUES (1, 1, 'SampleOss', 'Sample Description', 'http://sample.com', 'root', null);

-- Step 3: Insert into workflow_stage_type (assuming this table exists and 1 is valid)
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (1, 'SPIDER INFO CHECK', 'SPIDER INFO CHECK');
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (2, 'INFRASTRUCTURE VM CREATE', 'INFRASTRUCTURE VM CREATE');
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (3, 'INFRASTRUCTURE VM DELETE', 'INFRASTRUCTURE VM DELETE');
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (4, 'INFRASTRUCTURE MCI RUNNING STATUS', 'INFRASTRUCTURE MCI RUNNING STATUS');
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (5, 'INFRASTRUCTURE K8S CREATE', 'INFRASTRUCTURE K8S CREATE');
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (6, 'INFRASTRUCTURE K8S DELETE', 'INFRASTRUCTURE K8S DELETE');
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (7, 'INFRASTRUCTURE PMK RUNNING STATUS', 'INFRASTRUCTURE PMK RUNNING STATUS');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (8, 'START', 'START');
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (9, 'RUN JENKINS JOB', 'RUN JENKINS JOB');
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (10, 'END', 'END');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (11, 'VM ACCESS INFO', 'VM ACCESS INFO');
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (12, 'ACCESS VM AND SH(MCI VM)', 'ACCESS VM AND SH(MCI VM)');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Step 4: Insert into workflow_stage
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (2, 2, 1, 'Infrastructure VM Create', 'Infrastructure VM Create', '
    stage(''Infrastructure VM Create'') {
        steps {
            echo ''>>>>> STAGE: Infrastructure VM Create''
            script {

                def createInfraVmActionMethod = { ->
                    def payload = """{ "name": "${MCI}", "vm": [ { "commonImage": "${COMMON_IMAGE}", "commonSpec": "${COMMON_SPEC}" } ]}"""
                    def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/mciDynamic"""
                    def call = """curl -X ''POST'' --user ''${USER}:${USERPASS}'' ''${tb_vm_url}'' -H ''accept: application/json'' -H ''Content-Type: application/json'' -d ''${payload}''"""
                    def response = sh(script: """ ${call} """, returnStdout: true).trim()
                }

                def get_namespace_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}"""
                def exist_ns_response = sh(script: """curl -w ''- Http_Status_code:%{http_code}'' ''${get_namespace_url}'' --user ''${USER}:${USERPASS}''""", returnStdout: true).trim()

                def exist_ns_flag = "false"
                echo """''${exist_ns_response}''"""

                if (exist_ns_response.indexOf(''Http_Status_code:200'') > 0 ) {
                    echo """Exist ''${NAMESPACE}'' namespace!"""
                    createInfraVmActionMethod()
                } else {
                    // create namespace
                    def create_ns_response = sh(script: """curl -X ''POST'' ''${TUMBLEBUG}/tumblebug/ns'' -H ''accept: application/json'' -H ''Content-Type: application/json'' -d ''{ "description": "Workflow create namespace", "name": "${NAMESPACE}"}'' --user ''${USER}:${USERPASS}''""", returnStdout: true).trim()

                    echo """''${create_ns_response}''"""
                    if (create_ns_response.indexOf(''Http_Status_code:200'') > 0 ) {
                        createInfraVmActionMethod()
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (3, 3, 1, 'Infrastructure VM Delete', 'Infrastructure VM Delete', '
    stage(''Infrastructure VM Delete'') {
        steps {
            echo ''>>>>> STAGE: Infrastructure VM Delete''
            script {
                def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/mci/${MCI}?option=force"""
                def call = """curl -X DELETE --user ${USER}:${USERPASS} "${tb_vm_url}" -H accept: "application/json" """
                sh(script: """ ${call} """, returnStdout: true)
                echo "VM deletion successful."
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (4, 4, 1, 'Infrastructure MCI Running Status', 'Infrastructure Running Status', '
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (5, 5, 1, 'Infrastructure K8S Create', 'Infrastructure K8S Create', '
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (6, 6, 1, 'Infrastructure K8S Delete', 'Infrastructure K8S Delete', '
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
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (7, 7, 1, 'Infrastructure PMK Running Status', 'Infrastructure PMK Running Status', '
    stage(''Infrastructure PMK Running Status'') {
        steps {
            echo ''>>>>> STAGE: Infrastructure PMK Running Status''
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

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (8, 8, 1, 'Start', 'Start', '
        stage(''Start'') {
            steps {
                echo ''Hello''
            }
        }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (9, 9, 1, 'Run Jenkins Job', 'Run Jenkins Job', '
        stage (''run jenkins job'') {
            steps {

            }
        }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (10, 10, 1, 'End', 'End', '
        stage(''End'') {
            steps {
                echo ''Job completed''
            }
        }
    }
');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (11, 11, 1, 'VM GET Access Info', 'VM GET Access Info', '
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/ns/ns01/mci/${MCI}?option=accessinfo --user "default:default" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${TUMBLEBUG}/ns/${NAMESPACE}/mci/${MCI}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${USER}:${USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${MCI}.pem", text: pemkey)
                        sh "chmod 400 ${MCI}.pem"
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

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Step 5: Insert into workflow
-- INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (1, 'create vm', 'test', 1, '');
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (1, 'vm-mariadb-nginx-all-in-one', 'test', 1, '
pipeline {
    agent any
    stages {
        stage(''Start'') {
            steps {
                echo ''Hello''
            }
        }

        //=============================================================================================
        // stage template - create-mci
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
                    string(name: ''DISK'', value: DISK),
                ]
            }
        }

        //=============================================================================================
        // stage template - run jenkins job
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
        // stage template - run jenkins job
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

        //=============================================================================================
        // stage template - run jenkins job
        //=============================================================================================
        stage (''mariadb-set-password'') {
            steps {
                build job: ''mariadb-set-password'',
                parameters: [
                    string(name: ''MCI'', value: MCI),
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS),
                    string(name: ''SCHEMA'', value: SCHEMA),
                    string(name: ''DBUSER'', value: DBUSER),
                    string(name: ''DBPASS'', value: DBPASS)
                ]
            }
        }

        //=============================================================================================
        // stage template - run jenkins job
        //=============================================================================================
        stage (''set-nginx'') {
            steps {
                build job: ''set-nginx'',
                parameters: [
                    string(name: ''MCI'', value: MCI),
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS)
                ]
            }
        }


        stage(''End'') {
            steps {
                echo ''Job completed''
            }
        }
    }
}');

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (2, 'k8s-mariadb-nginx-all-in-one', 'test', 1, '
pipeline {
    agent any
    stages {
        stage(''Start'') {
            steps {
                echo ''Hello''
            }
        }
        //=============================================================================================
        // stage template - create-pmk
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
        // stage template - run jenkins job
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
        // stage template - run jenkins job
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

        //=============================================================================================
        // stage template - run jenkins job
        //=============================================================================================
        stage (''mariadb-set-password'') {
            steps {
                build job: ''mariadb-set-password'',
                parameters: [
                    string(name: ''MCI'', value: MCI),
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS),
                    string(name: ''SCHEMA'', value: SCHEMA),
                    string(name: ''DBUSER'', value: DBUSER),
                    string(name: ''DBPASS'', value: DBPASS)
                ]
            }
        }

        //=============================================================================================
        // stage template - run jenkins job
        //=============================================================================================
        stage (''set-nginx'') {
            steps {
                build job: ''set-nginx'',
                parameters: [
                    string(name: ''MCI'', value: MCI),
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS)
                ]
            }
        }


        stage(''End'') {
            steps {
                echo ''Job completed''
            }
        }
    }
}');
INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (3, 'create-mci', 'test', 1, '
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

                def createInfraVmActionMethod = { ->
                    def payload = """{ "name": "${MCI}", "vm": [ { "commonImage": "${COMMON_IMAGE}", "commonSpec": "${COMMON_SPEC}" } ]}"""
                    def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/mciDynamic"""
                    def call = """curl -X ''POST'' --user ''${USER}:${USERPASS}'' ''${tb_vm_url}'' -H ''accept: application/json'' -H ''Content-Type: application/json'' -d ''${payload}''"""
                    def response = sh(script: """ ${call} """, returnStdout: true).trim()
                }

                def get_namespace_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}"""
                def exist_ns_response = sh(script: """curl -w ''- Http_Status_code:%{http_code}'' ''${get_namespace_url}'' --user ''${USER}:${USERPASS}''""", returnStdout: true).trim()

                def exist_ns_flag = "false"
                echo """''${exist_ns_response}''"""

                if (exist_ns_response.indexOf(''Http_Status_code:200'') > 0 ) {
                    echo """Exist ''${NAMESPACE}'' namespace!"""
                    createInfraVmActionMethod()
                } else {
                    // create namespace
                    def create_ns_response = sh(script: """curl -X ''POST'' ''${TUMBLEBUG}/tumblebug/ns'' -H ''accept: application/json'' -H ''Content-Type: application/json'' -d ''{ "description": "Workflow create namespace", "name": "${NAMESPACE}"}'' --user ''${USER}:${USERPASS}''""", returnStdout: true).trim()

                    echo """''${create_ns_response}''"""
                    if (create_ns_response.indexOf(''Http_Status_code:200'') > 0 ) {
                        createInfraVmActionMethod()
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }
                }
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

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (4, 'delete-mci', 'test', 1, '
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
    stage(''Infrastructure VM Delete'') {
      steps {
        echo ''>>>>> STAGE: Infrastructure VM Delete''
        script {
          def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/mci/${MCI}?option=force"""
          def call = """curl -X DELETE --user ${USER}:${USERPASS} "${tb_vm_url}" -H accept: "application/json" """
          sh(script: """ ${call} """, returnStdout: true)
          echo "VM deletion successful."
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
            error "GET API call failed with status code: ${response}"
          }
        }
      }
    }
  }
}');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (5, 'create-pmk', 'test', 1, '
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

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (6, 'delete-pmk', 'test', 1, '
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

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (7, 'wordpress-all-in-one', 'test', 1, '
pipeline {
    agent any
    stages {
        stage(''Start'') {
            steps {
                echo ''Hello''
            }
        }

        //=============================================================================================
        // stage template - run jenkins job
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
        // stage template - run jenkins job
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

        //=============================================================================================
        // stage template - run jenkins job
        //=============================================================================================
        stage (''mariadb-set-password'') {
            steps {
                build job: ''mariadb-set-password'',
                parameters: [
                    string(name: ''MCI'', value: MCI),
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS),
                    string(name: ''SCHEMA'', value: SCHEMA),
                    string(name: ''DBUSER'', value: DBUSER),
                    string(name: ''DBPASS'', value: DBPASS)
                ]
            }
        }

        //=============================================================================================
        // stage template - run jenkins job
        //=============================================================================================
        stage (''php-install'') {
            steps {
                build job: ''php-install'',
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
        // stage template - run jenkins job
        //=============================================================================================
        stage (''set-nginx'') {
            steps {
                build job: ''set-nginx'',
                parameters: [
                    string(name: ''MCI'', value: MCI),
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS)
                ]
            }
        }


        stage(''End'') {
            steps {
                echo ''Job completed''
            }
        }
    }
}');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (8, 'install-nginx', 'test', 1, '
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

        //=============================================================================================
        // stage template - VM ACCESS INFO
        // need two functions : getSSHKey(jsonInput), getPublicInfoList(jsonInput)
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/ns/ns01/mci/${MCI}?option=accessinfo --user "default:default" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${TUMBLEBUG}/ns/${NAMESPACE}/mci/${MCI}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${USER}:${USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${MCI}.pem", text: pemkey)
                        sh "chmod 400 ${MCI}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }


        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCI VM)
        //=============================================================================================
        stage(''set nginx'') {
            steps {
                echo ''>>>>>STAGE: set nginx''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCI VMs : ${cleanIp}"
                            sh """

ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${MCI}.pem cb-user@${cleanIp} ''
#!/bin/bash

echo ==========================================================================

# Determine OS name
os=\$(uname)

# chk release
if [ "\$os" = "Linux" ]; then

  echo "This is a Linux machine"

  if [[ -f /etc/redhat-release ]]; then
    pkg_manager=yum
  elif [[ -f /etc/debian_version ]]; then
    pkg_manager=apt
  fi

  if [ \$pkg_manager = "yum" ]; then
    echo "yum"
  elif [ \$pkg_manager = "apt" ]; then
    echo "apt"
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt install nginx -y
  fi

elif [ "\$os" = "Darwin" ]; then
  echo "This is a Mac Machine. not supported"
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
}');

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

        //=============================================================================================
        // stage template - VM ACCESS INFO
        // need two functions : getSSHKey(jsonInput), getPublicInfoList(jsonInput)
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/ns/ns01/mci/${MCI}?option=accessinfo --user "default:default" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${TUMBLEBUG}/ns/${NAMESPACE}/mci/${MCI}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${USER}:${USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${MCI}.pem", text: pemkey)
                        sh "chmod 400 ${MCI}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }

        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCI VM)
        //=============================================================================================
        stage(''set mariadb'') {
            steps {
                echo ''>>>>>STAGE: set mariadb''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCI VMs : ${cleanIp}"
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
  elif [[ -f /etc/debian_version ]]; then
    pkg_manager=apt
  fi

  if [ \$pkg_manager = "yum" ]; then
    echo "yum"
  elif [ \$pkg_manager = "apt" ]; then
    echo "apt"
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get install mariadb-server mariadb-client -y
  fi

elif [ "\$os" = "Darwin" ]; then
  echo "This is a Mac Machine. not supported"
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


    }
}');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (10, 'mariadb-set-password', 'test', 1, '
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

        //=============================================================================================
        // stage template - VM ACCESS INFO
        // need two functions : getSSHKey(jsonInput), getPublicInfoList(jsonInput)
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/ns/ns01/mci/${MCI}?option=accessinfo --user "default:default" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${TUMBLEBUG}/ns/${NAMESPACE}/mci/${MCI}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${USER}:${USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${MCI}.pem", text: pemkey)
                        sh "chmod 400 ${MCI}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }

        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCI VM)
        //=============================================================================================
        stage(''mariadb-set-password'') {
            steps {
                echo ''>>>>>STAGE: mariadb-set-password''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCI VMs : ${cleanIp}"
                            sh """
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${MCI}.pem cb-user@${cleanIp} << EOF
    #!/bin/bash
    echo "drop schema if exists ${SCHEMA}; create database ${SCHEMA}; use mysql; create user ''${DBUSER}''@''host'' identified by ''${DBPASS}''; create user ''${DBUSER}''@''localhost'' identified by ''${DBPASS}''; create user ''${DBUSER}''@''%'' identified by ''${DBPASS}''; grant all privileges on ${SCHEMA}.* to ''${DBUSER}''@''localhost'';" | sudo mysql

EOF
                            """
                        }
                    }
                }
            }
        }


    }
}');
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (11, 'php-install', 'test', 1, '
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

        //=============================================================================================
        // stage template - VM ACCESS INFO
        // need two functions : getSSHKey(jsonInput), getPublicInfoList(jsonInput)
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/ns/ns01/mci/${MCI}?option=accessinfo --user "default:default" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${TUMBLEBUG}/ns/${NAMESPACE}/mci/${MCI}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${USER}:${USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${MCI}.pem", text: pemkey)
                        sh "chmod 400 ${MCI}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }

        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCI VM)
        //=============================================================================================
        stage(''php-install'') {
            steps {
                echo ''>>>>>STAGE: php-install''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCI VMs : ${cleanIp}"
                            sh """
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${MCI}.pem cb-user@${cleanIp} ''
# php/wordpress 및 필요요소 설치
sudo add-apt-repository ppa:ondrej/php

sudo apt-get update && sudo apt-get upgrade -y
sudo apt install php8.0-{bcmath,bz2,cgi,cli,common,curl,dba,dev,enchant,fpm,gd,gmp,imap,interbase,intl,ldap,mbstring,mysql,odbc,opcache,pgsql,phpdbg,pspell,readline,snmp,soap,sqlite3,sybase,tidy,xml,xmlrpc,zip,xsl} -y
sudo systemctl enable php8.0-fpm
sudo systemctl start php8.0-fpm

sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xvzf latest.tar.gz
sudo mv wordpress /var/www
sudo chmod -R 755 /var/www/wordpress;
sudo chown -R www-data:www-data /var/www/wordpress/

# 폴더 내용 확인
ls /var/www/wordpress

''
                            """
                        }
                    }
                }
            }
        }


    }
}');
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (12, 'set-nginx', 'test', 1, '
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

        //=============================================================================================
        // stage template - VM ACCESS INFO
        // need two functions : getSSHKey(jsonInput), getPublicInfoList(jsonInput)
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/ns/ns01/mci/${MCI}?option=accessinfo --user "default:default" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${TUMBLEBUG}/ns/${NAMESPACE}/mci/${MCI}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${USER}:${USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${MCI}.pem", text: pemkey)
                        sh "chmod 400 ${MCI}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }

        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCI VM)
        //=============================================================================================
        stage(''set-nginx'') {
            steps {
                echo ''>>>>>STAGE: set-nginx''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCI VMs : ${cleanIp}"
                            sh """
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${MCI}.pem cb-user@${cleanIp} << EOF
# nginx 설정 변경
# index.html 을 index.html index.php로 변경
sudo sed -i "s/index.html index.htm/index.html index.htm index.php/g" /etc/nginx/sites-available/default

# root를 html에서 wordpress로 변경
sudo sed -i "s|root /var/www/html;|root /var/www/wordpress;|g" /etc/nginx/sites-available/default

# php 처리 구문 추가 (중간에 내용이 주석으로 존재함)
sudo sed -i "s|# pass PHP scripts to FastCGI server|location ~ \\.php\$ { include snippets/fastcgi-php.conf; fastcgi_pass unix:/var/run/php/php8.0-fpm.sock; }|g" /etc/nginx/sites-available/default

# nginx 등록 및 restart
sudo systemctl enable nginx
sleep 3s
sudo systemctl restart nginx

echo "Nginx configuration!"

EOF
                            """
                        }
                    }
                }
            }
        }


    }
}');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (13, 'install-grafana', 'test', 1, '
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
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/ns/ns01/mci/${MCI}?option=accessinfo --user "default:default" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${TUMBLEBUG}/ns/${NAMESPACE}/mci/${MCI}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${USER}:${USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${MCI}.pem", text: pemkey)
                        sh "chmod 400 ${MCI}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }


        stage(''install-grafana'') {
            steps {
                echo ''>>>>>STAGE: install-grafana''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCI VMs : ${cleanIp}"
                            sh """
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${MCI}.pem cb-user@${cleanIp} ''
#!/bin/bash

echo ==========================================================================

# Determine OS name
os=\$(uname)

# chk release
if [ "\$os" = "Linux" ]; then

  echo "This is a Linux machine"

  if [[ -f /etc/redhat-release ]]; then
    pkg_manager=yum
  elif [[ -f /etc/debian_version ]]; then
    pkg_manager=apt
  fi

  if [ \$pkg_manager = "yum" ]; then
    echo "yum"
  elif [ \$pkg_manager = "apt" ]; then
    echo "apt"

    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get install -y apt-transport-https
    sudo apt-get install -y software-properties-common wget
    wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
    echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
    sudo apt-get update
    sudo apt-get install grafana

    sudo service grafana-server start

  fi

elif [ "\$os" = "Darwin" ]; then
  echo "This is a Mac Machine. not supported"
else
  echo "Unsupported OS"

  sudo mkdir -p /home/cb-user/prometheus
  cd /home/cb-user/prometheus
  sudo wget https://github.com/prometheus/prometheus/releases/download/v2.45.4/prometheus-2.45.4.linux-amd64.tar.gz
  #curl -o /home/cb-user/grafana/grafana-4.1.2-1486989747.linux-x64.tar.gz https://grafanarel.s3.amazonaws.com/builds/grafana-4.1.2-1486989747.linux-x64.tar.gz
  cd /home/cb-user/prometheus
  sudo tar xvfz prometheus-2.45.4.linux-amd64.tar.gz
  ls -al
  cd prometheus-2.45.4.linux-amd64
  ls -al
  sudo ./prometheus --config.file=prometheus.yml &

  #exit 1
fi

echo "Grafana installed!"


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

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (14, 'install-redis', 'test', 1, '
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
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/ns/ns01/mci/${MCI}?option=accessinfo --user "default:default" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${TUMBLEBUG}/ns/${NAMESPACE}/mci/${MCI}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${USER}:${USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${MCI}.pem", text: pemkey)
                        sh "chmod 400 ${MCI}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }


        stage(''install-redis'') {
            steps {
                echo ''>>>>>STAGE: install-redis''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCI VMs : ${cleanIp}"
                            sh """
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${MCI}.pem cb-user@${cleanIp} ''
#!/bin/bash

echo ==========================================================================

# Determine OS name
os=\$(uname)

# chk release
if [ "\$os" = "Linux" ]; then

  echo "This is a Linux machine"

  if [[ -f /etc/redhat-release ]]; then
    pkg_manager=yum
  elif [[ -f /etc/debian_version ]]; then
    pkg_manager=apt
  fi

  if [ \$pkg_manager = "yum" ]; then
    echo "yum"
  elif [ \$pkg_manager = "apt" ]; then
    echo "apt"

    sudo apt-get update -y -qq
    sudo apt-get install -y make
    sudo apt install gcc -y

    sudo apt install redis-server

    sudo apt install redis-tools -y
    make distclean -y
    make
    #sed -i ''s/daemonize no/daemonize yes/g'' /home/cb-user/redis/redis-7.0.15/redis.conf
    #/home/cb-user/redis/redis-7.0.15/src/redis-server --daemonize yes --requirepass """ + REDISPASS +  """

  fi

elif [ "\$os" = "Darwin" ]; then
  echo "This is a Mac Machine. not supported"
else
  echo "Unsupported OS"

  curl -o /home/cb-user/redis/redis-7.0.15.tar.gz https://download.redis.io/releases/redis-7.0.15.tar.gz
  cd /home/cb-user/redis
  tar -zxf /home/cb-user/redis/redis-7.0.15.tar.gz -C /home/cb-user/redis

  #exit 1
fi

echo "Redis installed!"

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

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (15, 'install-prometheus', 'test', 1, '
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
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/ns/ns01/mci/${MCI}?option=accessinfo --user "default:default" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${TUMBLEBUG}/ns/${NAMESPACE}/mci/${MCI}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${USER}:${USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${MCI}.pem", text: pemkey)
                        sh "chmod 400 ${MCI}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }


        stage(''install prometheus'') {
            steps {
                echo ''>>>>>STAGE: install prometheus''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCI VMs : ${cleanIp}"
                            sh """
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${MCI}.pem cb-user@${cleanIp} ''
#!/bin/bash

echo ==========================================================================

# Determine OS name
os=\$(uname)

# chk release
if [ "\$os" = "Linux" ]; then

  echo "This is a Linux machine"

  if [[ -f /etc/redhat-release ]]; then
    pkg_manager=yum
  elif [[ -f /etc/debian_version ]]; then
    pkg_manager=apt
  fi

  if [ \$pkg_manager = "yum" ]; then
    echo "yum"
  elif [ \$pkg_manager = "apt" ]; then
    echo "apt"

    sudo mkdir -p /home/cb-user/prometheus
    cd /home/cb-user/prometheus
    sudo wget https://github.com/prometheus/prometheus/releases/download/v2.45.4/prometheus-2.45.4.linux-amd64.tar.gz
    cd /home/cb-user/prometheus
    sudo tar xvfz prometheus-2.45.4.linux-amd64.tar.gz
    ls -al
    cd prometheus-2.45.4.linux-amd64
    ls -al
    sudo ./prometheus --config.file=prometheus.yml &

  fi

elif [ "\$os" = "Darwin" ]; then
  echo "This is a Mac Machine. not supported"
else
  echo "Unsupported OS"

  mkdir -p /home/cb-user/prometheus
  cd /home/cb-user/prometheus
  sudo wget https://github.com/prometheus/prometheus/releases/download/v2.45.4/prometheus-2.45.4.linux-amd64.tar.gz
  cd /home/cb-user/prometheus
  tar xvfz prometheus-2.45.4.linux-amd64.tar.gz
  ls -al
  cd prometheus-2.45.4.linux-amd64
  ls -al
  ./prometheus --config.file=prometheus.yml &

  #exit 1
fi

echo "Prometheus installed!"




''
                            """
                        }
                    }
                }
            }
        }


    }
}');
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (16, 'install-tomcat', 'test', 1, '
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
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/ns/ns01/mci/${MCI}?option=accessinfo --user "default:default" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${TUMBLEBUG}/ns/${NAMESPACE}/mci/${MCI}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${USER}:${USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${MCI}.pem", text: pemkey)
                        sh "chmod 400 ${MCI}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }


        stage(''install tomcat'') {
            steps {
                echo ''>>>>>STAGE: install tomcat''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    def TOMCAT_VER
                    def TAR_URL
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCI VMs : ${cleanIp}"
                            sh """
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${MCI}.pem cb-user@${cleanIp} ''
#!/bin/bash

echo ==========================================================================

# Determine OS name
os=\$(uname)

# chk release
if [ "\$os" = "Linux" ]; then

  echo "This is a Linux machine"

  if [[ -f /etc/redhat-release ]]; then
    pkg_manager=yum
  elif [[ -f /etc/debian_version ]]; then
    pkg_manager=apt
  fi

  if [ \$pkg_manager = "yum" ]; then
    echo "yum"
  elif [ \$pkg_manager = "apt" ]; then
    echo "apt"

    sudo apt update
    sudo apt install tomcat9 -y
    sudo service tomcat9 start


  fi

elif [ "\$os" = "Darwin" ]; then
  echo "This is a Mac Machine. not supported"
else
  echo "Unsupported OS"

  mkdir -p /home/cb-user/tomcat
  curl -o /home/cb-user/tomcat/${TOMCAT_VER}.tar.gz ${TAR_URL}
  cd /home/cb-user/tomcat
  tar -zxf /home/cb-user/tomcat/${TOMCAT_VER}.tar.gz -C /home/cb-user/tomcat
  ls /home/cb-user/tomcat/
  ls /home/cb-user/tomcat/${TOMCAT_VER}
  ls /home/cb-user/tomcat/${TOMCAT_VER}/bin
  /home/cb-user/tomcat/${TOMCAT_VER}/bin/startup.sh

  #exit 1
fi

echo "Tomcat installed!"




''
                            """
                        }
                    }
                }
            }
        }
    }
}');
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Step 6: Insert into workflow_param
-- INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (1, 1, 'MCI', '', 'N');
-- Workflow : vm-mariadb-nginx-all-in-one
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (1, 1, 'MCI', 'mcitest-01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (2, 1, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (3, 1, 'TUMBLEBUG', 'http://tb-url:1323', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (4, 1, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (5, 1, 'USERPASS', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (6, 1, 'COMMON_IMAGE', 'aws+ap-northeast-2+ubuntu22.04', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (7, 1, 'COMMON_SPEC', 'aws+ap-northeast-2+t2.small', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (8, 1, 'DISK', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (9, 1, 'SCHEMA', 'wordpress', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (10, 1, 'DBUSER', 'mcmp', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (11, 1, 'DBPASS', 'mcmp1234', 'N');

-- Workflow : k8s-mariadb-nginx-all-in-one
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (12, 2, 'CLUSTER', 'clustertest-01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (13, 2, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (14, 2, 'TUMBLEBUG', 'http://tb-url:1323', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (15, 2, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (16, 2, 'USERPASS', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (17, 2, 'COMMON_IMAGE', 'aws+ap-northeast-2+ubuntu22.04', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (18, 2, 'COMMON_SPEC', 'aws+ap-northeast-2+t2.small', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (19, 2, 'DISK', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (20, 2, 'SCHEMA', 'wordpress', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (21, 2, 'DBUSER', 'mcmp', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (22, 2, 'DBPASS', 'mcmp1234', 'N');

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : create-mci
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (23, 3, 'MCI', 'mcitest-01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (24, 3, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (25, 3, 'TUMBLEBUG', 'http://tb-url:1323', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (26, 3, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (27, 3, 'USERPASS', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (28, 3, 'COMMON_IMAGE', 'aws+ap-northeast-2+ubuntu22.04', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (29, 3, 'COMMON_SPEC', 'aws+ap-northeast-2+t2.small', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (30, 3, 'DISK', 'default', 'N');

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : delete-mci
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (31, 4, 'MCI', 'mcitest-01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (32, 4, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (33, 4, 'TUMBLEBUG', 'http://tb-url:1323', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (34, 4, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (35, 4, 'USERPASS', 'default', 'N');

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : create-pmk
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (36, 5, 'CLUSTER', 'clustertest-01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (37, 5, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (38, 5, 'TUMBLEBUG', 'http://tb-url:1323', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (39, 5, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (40, 5, 'USERPASS', 'default', 'N');

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : delete-pmk
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (41, 6, 'CLUSTER', 'clustertest-01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (42, 6, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (43, 6, 'TUMBLEBUG', 'http://tb-url:1323', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (44, 6, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (45, 6, 'USERPASS', 'default', 'N');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : wordpress-all-in-one
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (46, 7, 'MCI', 'mcitest-01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (47, 7, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (48, 7, 'TUMBLEBUG', 'http://tb-url:1323', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (49, 7, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (50, 7, 'USERPASS', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (51, 7, 'SCHEMA', 'wordpress', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (52, 7, 'DBUSER', 'mcmp', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (53, 7, 'DBPASS', 'mcmp1234', 'N');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : install-nginx
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (54, 8, 'MCI', 'mcitest-01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (55, 8, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (56, 8, 'TUMBLEBUG', 'http://tb-url:1323', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (57, 8, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (58, 8, 'USERPASS', 'default', 'N');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : install-mariadb
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (59, 9, 'MCI', 'mcitest-01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (60, 9, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (61, 9, 'TUMBLEBUG', 'http://tb-url:1323', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (62, 9, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (63, 9, 'USERPASS', 'default', 'N');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : mariadb-set-password
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (64, 10, 'MCI', 'mcitest-01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (65, 10, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (66, 10, 'TUMBLEBUG', 'http://tb-url:1323', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (67, 10, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (68, 10, 'USERPASS', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (69, 10, 'SCHEMA', 'wordpress', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (70, 10, 'DBUSER', 'mcmp', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (71, 10, 'DBPASS', 'mcmp1234', 'N');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : php-install
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (72, 11, 'MCI', 'mcitest-01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (73, 11, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (74, 11, 'TUMBLEBUG', 'http://tb-url:1323', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (75, 11, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (76, 11, 'USERPASS', 'default', 'N');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : set-nginx
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (77, 12, 'MCI', 'mcitest-01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (78, 12, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (79, 12, 'TUMBLEBUG', 'http://tb-url:1323', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (80, 12, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (81, 12, 'USERPASS', 'default', 'N');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : install-grafana
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (82, 13, 'MCI', 'mcitest-01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (83, 13, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (84, 13, 'TUMBLEBUG', 'http://tb-url:1323', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (85, 13, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (86, 13, 'USERPASS', 'default', 'N');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : install-redis
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (87, 14, 'MCI', 'mcitest-01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (88, 14, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (89, 14, 'TUMBLEBUG', 'http://tb-url:1323', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (90, 14, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (91, 14, 'USERPASS', 'default', 'N');
-- INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (52, 9, 'defaultValue', '1234', 'N');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : install-prometheus
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (92, 15, 'MCI', 'mcitest-01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (93, 15, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (94, 15, 'TUMBLEBUG', 'http://tb-url:1323', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (95, 15, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (96, 15, 'USERPASS', 'default', 'N');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : install-tomcat
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (97, 16, 'MCI', 'mcitest-01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (98, 16, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (99, 16, 'TUMBLEBUG', 'http://tb-url:1323', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (100, 16, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (101, 16, 'USERPASS', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (102, 16, 'TOMCAT_VER', '-----', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (103, 16, 'TAR_URL', '-----', 'N');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Step 7: Insert into workflow_stage_mapping
-- INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (1, 1, 1, null, '');
-- Workflow : vm-mariadb-nginx-all-in-one
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (1, 1, 1, null, '
pipeline {
  agent any
  stages {');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (2, 1, 2, 8, '
        stage(''Start'') {
            steps {
                echo ''Hello''
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (3, 1, 3, 9, '
        //=============================================================================================
        // stage template - create-mci
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
                    string(name: ''DISK'', value: DISK)
                ]
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (4, 1, 4, 9, '
        //=============================================================================================
        // stage template - run jenkins job
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (5, 1, 5, 9, '
        //=============================================================================================
        // stage template - run jenkins job
        //=============================================================================================
        stage (''mariadb-set-password'') {
            steps {
                build job: ''mariadb-set-password'',
                parameters: [
                    string(name: ''MCI'', value: MCI),
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS),
                    string(name: ''SCHEMA'', value: SCHEMA),
                    string(name: ''DBUSER'', value: DBUSER),
                    string(name: ''DBPASS'', value: DBPASS)
                ]
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (6, 1, 6, 9, '
        //=============================================================================================
        // stage template - run jenkins job
        //=============================================================================================
        stage (''set-nginx'') {
            steps {
                build job: ''set-nginx'',
                parameters: [
                    string(name: ''MCI'', value: MCI),
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS)
                ]
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (7, 1, 7, 10, '
        stage(''End'') {
            steps {
                echo ''Job completed''
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (8, 1, 8, null, '
  }
}');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Workflow : k8s-mariadb-nginx-all-in-one
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (9, 2, 1, null, '
pipeline {
  agent any
  stages {');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (10, 2, 2, 8, '
        stage(''Start'') {
            steps {
                echo ''Hello''
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (11, 2, 3, 9, '
        //=============================================================================================
        // stage template - create-pmk
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
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (12, 2, 4, 9, '
        //=============================================================================================
        // stage template - run jenkins job
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (13, 2, 5, 9, '
        //=============================================================================================
        // stage template - run jenkins job
        //=============================================================================================
        stage (''mariadb-set-password'') {
            steps {
                build job: ''mariadb-set-password'',
                parameters: [
                    string(name: ''MCI'', value: MCI),
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS),
                    string(name: ''SCHEMA'', value: SCHEMA),
                    string(name: ''DBUSER'', value: DBUSER),
                    string(name: ''DBPASS'', value: DBPASS)
                ]
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (14, 2, 6, 9, '
        //=============================================================================================
        // stage template - run jenkins job
        //=============================================================================================
        stage (''set-nginx'') {
            steps {
                build job: ''set-nginx'',
                parameters: [
                    string(name: ''MCI'', value: MCI),
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS)
                ]
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (15, 2, 7, 10, '
        stage(''End'') {
            steps {
                echo ''Job completed''
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (16, 2, 8, null, '
  }
}');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : create-mci
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (17, 3, 1, null, '
import groovy.json.JsonOutput
import groovy.json.JsonSlurper
import groovy.json.JsonSlurperClassic

pipeline {
  agent any
  stages {');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (18, 3, 2, 1, '
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (19, 3, 3, 2, '
    stage(''Infrastructure VM Create'') {
        steps {
            echo ''>>>>> STAGE: Infrastructure VM Create''
            script {

                def createInfraVmActionMethod = { ->
                    def payload = """{ "name": "${MCI}", "vm": [ { "commonImage": "${COMMON_IMAGE}", "commonSpec": "${COMMON_SPEC}" } ]}"""
                    def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/mciDynamic"""
                    def call = """curl -X ''POST'' --user ''${USER}:${USERPASS}'' ''${tb_vm_url}'' -H ''accept: application/json'' -H ''Content-Type: application/json'' -d ''${payload}''"""
                    def response = sh(script: """ ${call} """, returnStdout: true).trim()
                }

                def get_namespace_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}"""
                def exist_ns_response = sh(script: """curl -w ''- Http_Status_code:%{http_code}'' ''${get_namespace_url}'' --user ''${USER}:${USERPASS}''""", returnStdout: true).trim()

                def exist_ns_flag = "false"
                echo """''${exist_ns_response}''"""

                if (exist_ns_response.indexOf(''Http_Status_code:200'') > 0 ) {
                    echo """Exist ''${NAMESPACE}'' namespace!"""
                    createInfraVmActionMethod()
                } else {
                    // create namespace
                    def create_ns_response = sh(script: """curl -X ''POST'' ''${TUMBLEBUG}/tumblebug/ns'' -H ''accept: application/json'' -H ''Content-Type: application/json'' -d ''{ "description": "Workflow create namespace", "name": "${NAMESPACE}"}'' --user ''${USER}:${USERPASS}''""", returnStdout: true).trim()

                    echo """''${create_ns_response}''"""
                    if (create_ns_response.indexOf(''Http_Status_code:200'') > 0 ) {
                        createInfraVmActionMethod()
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }
                }
            }
        }
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (20, 3, 4, 4, '
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (21, 3, 5, null, '
  }
}');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : delete-mci
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (22, 4, 1, null, '
import groovy.json.JsonOutput
import groovy.json.JsonSlurper
import groovy.json.JsonSlurperClassic
import groovy.json.JsonSlurper

pipeline {
  agent any
  stages {');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (23, 4, 2, 1, '
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (24, 4, 3, 3, '
    stage(''Infrastructure VM Delete'') {
      steps {
        echo ''>>>>> STAGE: Infrastructure VM Delete''
        script {
          def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/mci/${MCI}?option=force"""
          def call = """curl -X DELETE --user ${USER}:${USERPASS} "${tb_vm_url}" -H accept: "application/json" """
          sh(script: """ ${call} """, returnStdout: true)
          echo "VM deletion successful."
        }
      }
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (25, 4, 4, 4, '
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
            error "GET API call failed with status code: ${response}"
          }
        }
      }
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (26, 4, 5, null, '
  }
}');
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : create-pmk
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (27, 5, 1, null, '
import groovy.json.JsonOutput
import groovy.json.JsonSlurper
import groovy.json.JsonSlurperClassic
import groovy.json.JsonSlurper

pipeline {
  agent any
  stages {');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (28, 5, 2, 1, '
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (29, 5, 3, 5, '
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (30, 5, 7, 3, '
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (31, 5, 5, null, '
  }
}');
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : delete-cluster
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (21, 6, 1, null, '
import groovy.json.JsonOutput
import groovy.json.JsonSlurper
import groovy.json.JsonSlurperClassic
import groovy.json.JsonSlurper

pipeline {
  agent any
  stages {');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (22, 6, 2, 1, '
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (23, 6, 3, 6, '
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
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (24, 6, 4, 7, '
    stage(''Infrastructure Running Status'') {
      steps {
        echo ''>>>>> STAGE: Infrastructure Running Status''
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (25, 6, 5, null, '
  }
}');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : wordpress-all-in-one
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (26, 7, 1, null, '
pipeline {
    agent any
    stages {');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (27, 7, 2, 8, '
        stage(''Start'') {
            steps {
                echo ''Hello''
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (28, 7, 3, 9, '
        //=============================================================================================
        // stage template - run jenkins job
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (29, 7, 4, 9, '
        //=============================================================================================
        // stage template - run jenkins job
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (30, 7, 5, 9, '
        //=============================================================================================
        // stage template - run jenkins job
        //=============================================================================================
        stage (''mariadb-set-password'') {
            steps {
                build job: ''mariadb-set-password'',
                parameters: [
                    string(name: ''MCI'', value: MCI),
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS),
                    string(name: ''SCHEMA'', value: SCHEMA),
                    string(name: ''DBUSER'', value: DBUSER),
                    string(name: ''DBPASS'', value: DBPASS)
                ]
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (31, 7, 6, 9, '
        //=============================================================================================
        // stage template - run jenkins job
        //=============================================================================================
        stage (''php-install'') {
            steps {
                build job: ''php-install'',
                parameters: [
                    string(name: ''MCI'', value: MCI),
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS)
                ]
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (32, 7, 7, 9, '
        //=============================================================================================
        // stage template - run jenkins job
        //=============================================================================================
        stage (''set-nginx'') {
            steps {
                build job: ''set-nginx'',
                parameters: [
                    string(name: ''MCI'', value: MCI),
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS)
                ]
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (33, 7, 8, 10, '
        stage(''End'') {
            steps {
                echo ''Job completed''
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (34, 7, 9, null, '
    }
}');



-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : install-nginx
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (35, 8, 1, null, '
import groovy.json.JsonSlurper

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

    stages {');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (36, 8, 2, 11, '
        //=============================================================================================
        // stage template - VM ACCESS INFO
        // need two functions : getSSHKey(jsonInput), getPublicInfoList(jsonInput)
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/ns/ns01/mcis/${MCIS}?option=accessinfo --user "default:default" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${TUMBLEBUG}/ns/${NAMESPACE}/mcis/${MCIS}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${USER}:${USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${MCIS}.pem", text: pemkey)
                        sh "chmod 400 ${MCIS}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (37, 8, 3, 12, '
        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCIS VM)
        //=============================================================================================
        stage(''set nginx'') {
            steps {
                echo ''>>>>>STAGE: set nginx''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCIS VMs : ${cleanIp}"
                            sh """

ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${MCIS}.pem cb-user@${cleanIp} ''
#!/bin/bash

echo ==========================================================================

# Determine OS name
os=\$(uname)

# chk release
if [ "\$os" = "Linux" ]; then

  echo "This is a Linux machine"

  if [[ -f /etc/redhat-release ]]; then
    pkg_manager=yum
  elif [[ -f /etc/debian_version ]]; then
    pkg_manager=apt
  fi

  if [ \$pkg_manager = "yum" ]; then
    echo "yum"
  elif [ \$pkg_manager = "apt" ]; then
    echo "apt"
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt install nginx -y
  fi

elif [ "\$os" = "Darwin" ]; then
  echo "This is a Mac Machine. not supported"
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
');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (38, 8, 4, null, '
    }
}
');


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : install-mariadb
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (39, 9, 1, null, '
import groovy.json.JsonSlurper

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

    stages {
');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (40, 9, 2, 11, '
        //=============================================================================================
        // stage template - VM ACCESS INFO
        // need two functions : getSSHKey(jsonInput), getPublicInfoList(jsonInput)
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/ns/ns01/mcis/${MCIS}?option=accessinfo --user "default:default" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${TUMBLEBUG}/ns/${NAMESPACE}/mcis/${MCIS}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${USER}:${USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${MCIS}.pem", text: pemkey)
                        sh "chmod 400 ${MCIS}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (41, 9, 3, 12, '

        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCIS VM)
        //=============================================================================================
        stage(''install-mariadb'') {
            steps {
                echo ''>>>>>STAGE: install-mariadb''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCIS VMs : ${cleanIp}"
                            sh """
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${MCIS}.pem cb-user@${cleanIp} ''
#!/bin/bash

# Determine OS name
os=\$(uname)

# chk release
if [ "\$os" = "Linux" ]; then

  echo "This is a Linux machine"

  if [[ -f /etc/redhat-release ]]; then
    pkg_manager=yum
  elif [[ -f /etc/debian_version ]]; then
    pkg_manager=apt
  fi

  if [ \$pkg_manager = "yum" ]; then
    echo "yum"
  elif [ \$pkg_manager = "apt" ]; then
    echo "apt"
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get install mariadb-server mariadb-client -y
  fi

elif [ "\$os" = "Darwin" ]; then
  echo "This is a Mac Machine. not supported"
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

    ');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (42, 9, 4, null, '
    }
}
');


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : mariadb-set-password
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (43, 10, 1, null, '
import groovy.json.JsonSlurper

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

    stages {
');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (44, 10, 2, 11, '
        //=============================================================================================
        // stage template - VM ACCESS INFO
        // need two functions : getSSHKey(jsonInput), getPublicInfoList(jsonInput)
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/ns/ns01/mcis/${MCIS}?option=accessinfo --user "default:default" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${TUMBLEBUG}/ns/${NAMESPACE}/mcis/${MCIS}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${USER}:${USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${MCIS}.pem", text: pemkey)
                        sh "chmod 400 ${MCIS}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }
');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (45, 10, 3, 12, '
        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCIS VM)
        //=============================================================================================
        stage(''mariadb-set-password'') {
            steps {
                echo ''>>>>>STAGE: mariadb-set-password''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCIS VMs : ${cleanIp}"
                            sh """
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${MCIS}.pem cb-user@${cleanIp} << EOF
    #!/bin/bash
    echo "drop schema if exists ${SCHEMA}; create database ${SCHEMA}; use mysql; create user ''${DBUSER}''@''host'' identified by ''${DBPASS}''; create user ''${DBUSER}''@''localhost'' identified by ''${DBPASS}''; create user ''${DBUSER}''@''%'' identified by ''${DBPASS}''; grant all privileges on ${SCHEMA}.* to ''${DBUSER}''@''localhost'';" | sudo mysql

EOF
                            """
                        }
                    }
                }
            }
        }
    ');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (46, 10, 4, null, '
    }
}
');


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : php-install
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (47, 11, 1, null, '
import groovy.json.JsonSlurper

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

    stages {
');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (48, 11, 2, 11, '
        //=============================================================================================
        // stage template - VM ACCESS INFO
        // need two functions : getSSHKey(jsonInput), getPublicInfoList(jsonInput)
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/ns/ns01/mcis/${MCIS}?option=accessinfo --user "default:default" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${TUMBLEBUG}/ns/${NAMESPACE}/mcis/${MCIS}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${USER}:${USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${MCIS}.pem", text: pemkey)
                        sh "chmod 400 ${MCIS}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (49, 11, 3, 12, '

        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCIS VM)
        //=============================================================================================
        stage(''php-install'') {
            steps {
                echo ''>>>>>STAGE: php-install''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCIS VMs : ${cleanIp}"
                            sh """
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${MCIS}.pem cb-user@${cleanIp} ''
# php/wordpress 및 필요요소 설치
sudo add-apt-repository ppa:ondrej/php

sudo apt-get update && sudo apt-get upgrade -y
sudo apt install php8.0-{bcmath,bz2,cgi,cli,common,curl,dba,dev,enchant,fpm,gd,gmp,imap,interbase,intl,ldap,mbstring,mysql,odbc,opcache,pgsql,phpdbg,pspell,readline,snmp,soap,sqlite3,sybase,tidy,xml,xmlrpc,zip,xsl} -y
sudo systemctl enable php8.0-fpm
sudo systemctl start php8.0-fpm

sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xvzf latest.tar.gz
sudo mv wordpress /var/www
sudo chmod -R 755 /var/www/wordpress;
sudo chown -R www-data:www-data /var/www/wordpress/

# 폴더 내용 확인
ls /var/www/wordpress

''
                            """
                        }
                    }
                }
            }
        }
    ');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (50, 11, 4, null, '
    }
}');


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : set-nginx
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (51, 12, 1, null, '
import groovy.json.JsonSlurper

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

    stages {
');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (52, 12, 2, 11, '
        //=============================================================================================
        // stage template - VM ACCESS INFO
        // need two functions : getSSHKey(jsonInput), getPublicInfoList(jsonInput)
        //=============================================================================================
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/ns/ns01/mcis/${MCIS}?option=accessinfo --user "default:default" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${TUMBLEBUG}/ns/${NAMESPACE}/mcis/${MCIS}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${USER}:${USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${MCIS}.pem", text: pemkey)
                        sh "chmod 400 ${MCIS}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }
');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (53, 12, 3, 12, '
        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCIS VM)
        //=============================================================================================
        stage(''set-nginx'') {
            steps {
                echo ''>>>>>STAGE: set-nginx''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCIS VMs : ${cleanIp}"
                            sh """
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${MCIS}.pem cb-user@${cleanIp} << EOF
# nginx 설정 변경
# index.html 을 index.html index.php로 변경
sudo sed -i "s/index.html index.htm/index.html index.htm index.php/g" /etc/nginx/sites-available/default

# root를 html에서 wordpress로 변경
sudo sed -i "s|root /var/www/html;|root /var/www/wordpress;|g" /etc/nginx/sites-available/default

# php 처리 구문 추가 (중간에 내용이 주석으로 존재함)
sudo sed -i "s|# pass PHP scripts to FastCGI server|location ~ \\.php\$ { include snippets/fastcgi-php.conf; fastcgi_pass unix:/var/run/php/php8.0-fpm.sock; }|g" /etc/nginx/sites-available/default

# nginx 등록 및 restart
sudo systemctl enable nginx
sleep 3s
sudo systemctl restart nginx

echo "Nginx configuration!"

EOF
                            """
                        }
                    }
                }
            }
        }
    ');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (54, 12, 4, null, '
    }
}
');


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : install-grafana
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (55, 13, 1, null, '
import groovy.json.JsonSlurper

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

    stages {
');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (56, 13, 2, 11, '
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/ns/ns01/mcis/${MCIS}?option=accessinfo --user "default:default" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${TUMBLEBUG}/ns/${NAMESPACE}/mcis/${MCIS}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${USER}:${USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${MCIS}.pem", text: pemkey)
                        sh "chmod 400 ${MCIS}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }
');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (57, 13, 3, 12, '
        stage(''install-grafana'') {
            steps {
                echo ''>>>>>STAGE: install-grafana''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCIS VMs : ${cleanIp}"
                            sh """
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${MCIS}.pem cb-user@${cleanIp} ''
#!/bin/bash

echo ==========================================================================

# Determine OS name
os=\$(uname)

# chk release
if [ "\$os" = "Linux" ]; then

  echo "This is a Linux machine"

  if [[ -f /etc/redhat-release ]]; then
    pkg_manager=yum
  elif [[ -f /etc/debian_version ]]; then
    pkg_manager=apt
  fi

  if [ \$pkg_manager = "yum" ]; then
    echo "yum"
  elif [ \$pkg_manager = "apt" ]; then
    echo "apt"

    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get install -y apt-transport-https
    sudo apt-get install -y software-properties-common wget
    wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
    echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
    sudo apt-get update
    sudo apt-get install grafana

    sudo service grafana-server start

  fi

elif [ "\$os" = "Darwin" ]; then
  echo "This is a Mac Machine. not supported"
else
  echo "Unsupported OS"

  sudo mkdir -p /home/cb-user/prometheus
  cd /home/cb-user/prometheus
  sudo wget https://github.com/prometheus/prometheus/releases/download/v2.45.4/prometheus-2.45.4.linux-amd64.tar.gz
  #curl -o /home/cb-user/grafana/grafana-4.1.2-1486989747.linux-x64.tar.gz https://grafanarel.s3.amazonaws.com/builds/grafana-4.1.2-1486989747.linux-x64.tar.gz
  cd /home/cb-user/prometheus
  sudo tar xvfz prometheus-2.45.4.linux-amd64.tar.gz
  ls -al
  cd prometheus-2.45.4.linux-amd64
  ls -al
  sudo ./prometheus --config.file=prometheus.yml &

  #exit 1
fi

echo "Grafana installed!"


''
                            """
                        }
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (58, 13, 4, null, '
    }
}
');


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : install-redis
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (59, 14, 1, null, '
import groovy.json.JsonSlurper

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

    stages {
');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (60, 14, 2, 11, '
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/ns/ns01/mcis/${MCIS}?option=accessinfo --user "default:default" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${TUMBLEBUG}/ns/${NAMESPACE}/mcis/${MCIS}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${USER}:${USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${MCIS}.pem", text: pemkey)
                        sh "chmod 400 ${MCIS}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }
');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (61, 14, 3, 12, '
        stage(''install-redis'') {
            steps {
                echo ''>>>>>STAGE: install-redis''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCIS VMs : ${cleanIp}"
                            sh """
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${MCIS}.pem cb-user@${cleanIp} ''
#!/bin/bash

echo ==========================================================================

# Determine OS name
os=\$(uname)

# chk release
if [ "\$os" = "Linux" ]; then

  echo "This is a Linux machine"

  if [[ -f /etc/redhat-release ]]; then
    pkg_manager=yum
  elif [[ -f /etc/debian_version ]]; then
    pkg_manager=apt
  fi

  if [ \$pkg_manager = "yum" ]; then
    echo "yum"
  elif [ \$pkg_manager = "apt" ]; then
    echo "apt"

    sudo apt-get update -y -qq
    sudo apt-get install -y make
    sudo apt install gcc -y

    sudo apt install redis-server

    sudo apt install redis-tools -y
    make distclean -y
    make
    #sed -i ''s/daemonize no/daemonize yes/g'' /home/cb-user/redis/redis-7.0.15/redis.conf
    #/home/cb-user/redis/redis-7.0.15/src/redis-server --daemonize yes --requirepass """ + REDISPASS +  """

  fi

elif [ "\$os" = "Darwin" ]; then
  echo "This is a Mac Machine. not supported"
else
  echo "Unsupported OS"

  curl -o /home/cb-user/redis/redis-7.0.15.tar.gz https://download.redis.io/releases/redis-7.0.15.tar.gz
  cd /home/cb-user/redis
  tar -zxf /home/cb-user/redis/redis-7.0.15.tar.gz -C /home/cb-user/redis

  #exit 1
fi

echo "Redis installed!"

''
                            """
                        }
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (62, 14, 4, null, '
    }
}
');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : install-prometheus
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (63, 15, 1, null, '
import groovy.json.JsonSlurper

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

    stages {');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (64, 15, 2, 11, '
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/ns/ns01/mcis/${MCIS}?option=accessinfo --user "default:default" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${TUMBLEBUG}/ns/${NAMESPACE}/mcis/${MCIS}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${USER}:${USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${MCIS}.pem", text: pemkey)
                        sh "chmod 400 ${MCIS}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (65, 15, 3, 12, '
        stage(''install prometheus'') {
            steps {
                echo ''>>>>>STAGE: install prometheus''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCIS VMs : ${cleanIp}"
                            sh """
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${MCIS}.pem cb-user@${cleanIp} ''
#!/bin/bash

echo ==========================================================================

# Determine OS name
os=\$(uname)

# chk release
if [ "\$os" = "Linux" ]; then

  echo "This is a Linux machine"

  if [[ -f /etc/redhat-release ]]; then
    pkg_manager=yum
  elif [[ -f /etc/debian_version ]]; then
    pkg_manager=apt
  fi

  if [ \$pkg_manager = "yum" ]; then
    echo "yum"
  elif [ \$pkg_manager = "apt" ]; then
    echo "apt"

    sudo mkdir -p /home/cb-user/prometheus
    cd /home/cb-user/prometheus
    sudo wget https://github.com/prometheus/prometheus/releases/download/v2.45.4/prometheus-2.45.4.linux-amd64.tar.gz
    cd /home/cb-user/prometheus
    sudo tar xvfz prometheus-2.45.4.linux-amd64.tar.gz
    ls -al
    cd prometheus-2.45.4.linux-amd64
    ls -al
    sudo ./prometheus --config.file=prometheus.yml &

  fi

elif [ "\$os" = "Darwin" ]; then
  echo "This is a Mac Machine. not supported"
else
  echo "Unsupported OS"

  mkdir -p /home/cb-user/prometheus
  cd /home/cb-user/prometheus
  sudo wget https://github.com/prometheus/prometheus/releases/download/v2.45.4/prometheus-2.45.4.linux-amd64.tar.gz
  cd /home/cb-user/prometheus
  tar xvfz prometheus-2.45.4.linux-amd64.tar.gz
  ls -al
  cd prometheus-2.45.4.linux-amd64
  ls -al
  ./prometheus --config.file=prometheus.yml &

  #exit 1
fi

echo "Prometheus installed!"




''
                            """
                        }
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (66, 15, 4, null, '
    }
}');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : install-tomcat
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (67, 16, 1, null, '
import groovy.json.JsonSlurper

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

    stages {');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (68, 16, 2, 11, '
        stage(''VM GET Access Info'') {
            steps {
                echo ''>>>>>STAGE: VM GET Access Info''
                script {
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/ns/ns01/mcis/${MCIS}?option=accessinfo --user "default:default" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${TUMBLEBUG}/ns/${NAMESPACE}/mcis/${MCIS}?option=accessinfo&accessInfoOption=showSshKey"
                    def response2 = sh(script: """curl -X ''GET'' --user ''${USER}:${USERPASS}'' ''${tb_sw_url}'' -H ''accept: application/json'' """, returnStdout: true).trim()
                    def pemkey = getSSHKey(response2)
                    if (pemkey) {
                        writeFile(file: "${MCIS}.pem", text: pemkey)
                        sh "chmod 400 ${MCIS}.pem"
                    } else {
                        error "SSH Key retrieval failed."
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (69, 16, 3, 12, '
        stage(''install tomcat'') {
            steps {
                echo ''>>>>>STAGE: install tomcat''
                script {
                    def publicIPs = getPublicInfoList(callData)
                    def TOMCAT_VER
                    def TAR_URL
                    echo publicIPs.toString()
                    publicIPs[0].each{ ip-> echo "ip view : " + ip }
                    publicIPs.each { ip ->
                        ip.each { inip ->
                            def cleanIp = inip.toString().replaceAll(/[\[\]]/, '''')
                            println ">>test SSH to MCIS VMs : ${cleanIp}"
                            sh """
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${MCIS}.pem cb-user@${cleanIp} ''
#!/bin/bash

echo ==========================================================================

# Determine OS name
os=\$(uname)

# chk release
if [ "\$os" = "Linux" ]; then

  echo "This is a Linux machine"

  if [[ -f /etc/redhat-release ]]; then
    pkg_manager=yum
  elif [[ -f /etc/debian_version ]]; then
    pkg_manager=apt
  fi

  if [ \$pkg_manager = "yum" ]; then
    echo "yum"
  elif [ \$pkg_manager = "apt" ]; then
    echo "apt"

    sudo apt update
    sudo apt install tomcat9 -y
    sudo service tomcat9 start


  fi

elif [ "\$os" = "Darwin" ]; then
  echo "This is a Mac Machine. not supported"
else
  echo "Unsupported OS"

  mkdir -p /home/cb-user/tomcat
  curl -o /home/cb-user/tomcat/${TOMCAT_VER}.tar.gz ${TAR_URL}
  cd /home/cb-user/tomcat
  tar -zxf /home/cb-user/tomcat/${TOMCAT_VER}.tar.gz -C /home/cb-user/tomcat
  ls /home/cb-user/tomcat/
  ls /home/cb-user/tomcat/${TOMCAT_VER}
  ls /home/cb-user/tomcat/${TOMCAT_VER}/bin
  /home/cb-user/tomcat/${TOMCAT_VER}/bin/startup.sh

  #exit 1
fi

echo "Tomcat installed!"




''
                            """
                        }
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (70, 16, 4, null, '
    }
}');