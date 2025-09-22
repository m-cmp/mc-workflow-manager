-- Step 1: Insert into oss_type
INSERT INTO oss_type (oss_type_idx, oss_type_name, oss_type_desc) VALUES (1, 'JENKINS', 'init');

-- Step 2: Insert into oss
INSERT INTO oss (oss_idx, oss_type_idx, oss_name, oss_desc, oss_url, oss_username, oss_password) VALUES (1, 1, 'SampleOss', 'Sample Description', 'http://mc-workflow-manager-jenkins:8080', 'admin', '7TEWaICzct4JsjFGMYtgaA==');

-- Step 3: Insert into workflow_stage_type (assuming this table exists and 1 is valid)
-- 1, 'TUMBLEBUG INFO CHECK', 'TUMBLEBUG INFO CHECK'
-- 2, 'INFRASTRUCTURE NS CREATE', 'INFRASTRUCTURE NS CREATE'
-- 3, 'INFRASTRUCTURE NS RUNNING STATUS', 'INFRASTRUCTURE NS RUNNING STATUS'
-- 4, 'INFRASTRUCTURE MCI CREATE', 'INFRASTRUCTURE MCI CREATE'
-- 5, 'INFRASTRUCTURE MCI DELETE', 'INFRASTRUCTURE MCI DELETE'
-- 6, 'INFRASTRUCTURE MCI RUNNING STATUS', 'INFRASTRUCTURE MCI RUNNING STATUS'
-- 7, 'INFRASTRUCTURE K8S Cluster CREATE', 'INFRASTRUCTURE K8S Cluster CREATE'
-- 8, 'INFRASTRUCTURE K8S Cluster DELETE', 'INFRASTRUCTURE K8S Cluster DELETE'
-- 9, 'INFRASTRUCTURE K8S Cluster RUNNING STATUS', 'INFRASTRUCTURE K8S Cluster RUNNING STATUS'
-- 10, 'RUN JENKINS JOB', 'RUN JENKINS JOB'
-- 11, 'VM ACCESS INFO', 'VM ACCESS INFO'
-- 12, 'ACCESS VM AND SH(MCI VM)', 'ACCESS VM AND SH(MCI VM)'
-- 13, 'WAIT FOR VM TO BE READY', 'WAIT FOR VM TO BE READY'
-- 14, 'K8S PRE-INSTALLATION TASKS', 'K8S PRE-INSTALLATION TASKS'
-- 15, 'K8S ACCESS GET CONFIG INFO', 'K8S ACCESS GET CONFIG INFO'
-- 16, 'K8S ACCESS AND SH(K8S Cluster)', 'K8S ACCESS AND SH(K8S Cluster)'
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES
(1, 'TUMBLEBUG INFO CHECK', 'TUMBLEBUG INFO CHECK'),
(2, 'INFRASTRUCTURE NS CREATE', 'INFRASTRUCTURE NS CREATE'),
(3, 'INFRASTRUCTURE NS RUNNING STATUS', 'INFRASTRUCTURE NS RUNNING STATUS'),

(4, 'INFRASTRUCTURE MCI CREATE', 'INFRASTRUCTURE MCI CREATE'),
(5, 'INFRASTRUCTURE MCI DELETE', 'INFRASTRUCTURE MCI DELETE'),
(6, 'INFRASTRUCTURE MCI RUNNING STATUS', 'INFRASTRUCTURE MCI RUNNING STATUS'),

(7, 'INFRASTRUCTURE K8S Cluster CREATE', 'INFRASTRUCTURE K8S Cluster CREATE'),
(8, 'INFRASTRUCTURE K8S Cluster DELETE', 'INFRASTRUCTURE K8S Cluster DELETE'),
(9, 'INFRASTRUCTURE K8S Cluster RUNNING STATUS', 'INFRASTRUCTURE K8S Cluster RUNNING STATUS'),

(10, 'RUN JENKINS JOB', 'RUN JENKINS JOB'),

(11, 'VM ACCESS INFO', 'VM ACCESS INFO'),
(12, 'ACCESS VM AND SH(MCI VM)', 'ACCESS VM AND SH(MCI VM)'),
(13, 'WAIT FOR VM TO BE READY', 'WAIT FOR VM TO BE READY'),

(14, 'K8S PRE-INSTALLATION TASKS', 'K8S PRE-INSTALLATION TASKS'),
(15, 'K8S ACCESS GET CONFIG INFO', 'K8S ACCESS GET CONFIG INFO'),
(16, 'K8S ACCESS AND SH(K8S Cluster)', 'K8S ACCESS AND SH(K8S Cluster)');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Step 4: Insert into workflow_stage
-- 1. Tumblebug Info Check
-- 2. Infrastructure NS Create
-- 3. Infrastructure NS Running Status
-- 4. Infrastructure MCI Create
-- 5. Infrastructure MCI Delete
-- 6. Infrastructure MCI Running Status
-- 7. Infrastructure K8S Cluster Create
-- 8. Infrastructure K8S Cluster Delete
-- 9. Infrastructure K8S Cluster Running Status
-- 10. Run Jenkins Job
-- 11. VM GET Access Info
-- 12. ACCESS VM AND SH(MCI VM)
-- 13. WAIT FOR VM TO BE READY
-- 14. K8S PRE-INSTALLATION TASKS
-- 15. K8S ACCESS GET CONFIG INFO
-- 16. K8S ACCESS AND SH(K8S Cluster)
-- INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (1, 1, 1, 'Tumblebug Info Check', 'Tumblebug Info Check', '');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (1, 1, 1, 'Tumblebug Info Check', 'Tumblebug Info Check', '
    stage(''Tumblebug Info Check'') {
        steps {
            echo ''>>>>> STAGE: Tumblebug Info Check''
            echo TUMBLEBUG
            echo MCI

            script {
                // Calling a GET API using curl
                def response = sh(script: ''curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/tumblebug/readyz --user "${USER}:${USERPASS}"'', returnStdout: true).trim()

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
                        echo """create Namespace ${NAMESPACE}"""
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
            echo ''>>>>> STAGE: Infrastructure NS Running Status''
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
    stage(''Infrastructure MCI Create'') {
        steps {
            echo ''>>>>> STAGE: Infrastructure MCI Create''
            script {
                def payload = JsonOutput.toJson([
                    name: "${MCI}",
                    subGroups: [
                        [
                            specId: "${SPEC_ID}",
                            imageId: "${IMAGE_ID}",
                            rootDiskType: "${ROOT_DISK_TYPE}",
                            rootDiskSize: "${ROOT_DISK_SIZE}"
                        ]
                    ]
                ])

                def tb_vm_url = "${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/mciDynamic"
                def call = """curl -X POST ''${tb_vm_url}'' \
                  -H ''accept: application/json'' \
                  -H ''Content-Type: application/json'' \
                  -d ''${payload}'' \
                  --user ''${USER}:${USERPASS}''"""
                def response = sh(script: call, returnStdout: true).trim()

                echo JsonOutput.prettyPrint(response)
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (5, 5, 1, 'Infrastructure MCI Delete', 'Infrastructure MCI Delete', '
    stage(''Infrastructure MCI Delete'') {
      steps {
        echo ''>>>>> STAGE: Infrastructure MCI Delete''
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (7, 7, 1, 'Infrastructure K8S Cluster Create', 'Infrastructure K8S Cluster Create', '
    stage(''Infrastructure K8S Cluster Create'') {
        steps {
            echo ''>>>>> STAGE: Infrastructure K8S Cluster Create''
            script {
                def call_tumblebug_exist_k8s_cluster_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}"""
                def tumblebug_exist_k8s_cluster_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X GET ${call_tumblebug_exist_k8s_cluster_url} -H "Content-Type: application/json" --user ${USER}:${USERPASS}""", returnStdout: true).trim()

                if (tumblebug_exist_k8s_cluster_response.indexOf(''Http_Status_code:200'') > 0 ) {
                    echo "Exist cluster!"
                    tumblebug_exist_k8s_cluster_response = tumblebug_exist_k8s_cluster_response.replace(''- Http_Status_code:200'', '''')
                    echo JsonOutput.prettyPrint(tumblebug_exist_k8s_cluster_response)
                } else {
                    def call_tumblebug_create_k8s_cluster_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sClusterDynamic"""
                    def call_tumblebug_create_cluster_payload = """{ \
                            "imageId": "default", \
                            "specId": "aws+ap-northeast-2+t3a.xlarge", \
                            "connectionName": "aws-ap-northeast-2", \
                            "name": "k8scluster01", \
                            "nodeGroupName": "k8sng01" \
                        }"""
                    def tumblebug_create_cluster_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_create_cluster_url} -H "Content-Type: application/json" -d ''${call_tumblebug_create_cluster_payload}'' --user ${USER}:${USERPASS}""", returnStdout: true).trim()

                    if (tumblebug_create_cluster_response.indexOf(''Http_Status_code:200'') > 0 ) {
                        echo """Create cluster >> ${CLUSTER}"""
                        tumblebug_create_cluster_response = tumblebug_create_cluster_response.replace(''- Http_Status_code:200'', '''')
                        echo JsonOutput.prettyPrint(tumblebug_create_cluster_response)
                    } else {
                        error """GET API call failed with status code: ${tumblebug_create_cluster_response}"""
                    }
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (8, 8, 1, 'Infrastructure K8S Cluster Delete', 'Infrastructure K8S Cluster Delete', '
    stage(''Infrastructure K8S Cluster Delete'') {
        steps {
            echo ''>>>>> STAGE: Infrastructure K8S Cluster Delete''
            script {
                def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}"""
                def call = """curl -X DELETE "${tb_vm_url}" -H "accept: application/json" --user ${USER}:${USERPASS} """
                sh(script: """ ${call} """, returnStdout: true)
                echo "K8S Cluster deletion successful."
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (9, 9, 1, 'Infrastructure K8S Cluster Running Status', 'Infrastructure K8S Cluster Running Status', '
    stage(''Infrastructure K8S Cluster Running Status'') {
        steps {
            echo ''>>>>> STAGE: Infrastructure K8S Cluster Running Status''
            script {
                def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}?option=status"""
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
    }');
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (14, 14, 1, 'K8S PRE-INSTALLATION TASKS', 'K8S PRE-INSTALLATION TASKS', '
    stage(''K8S PRE-INSTALLATION TASKS'') {
        steps {
            echo ''>>>>>STAGE: K8S PRE-INSTALLATION TASKS''
            script {
                def call_tumblebug_exist_ns_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}"""
                def tumblebug_exist_ns_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X GET ${call_tumblebug_exist_ns_url} -H "Content-Type: application/json" --user ${USER}:${USERPASS}""", returnStdout: true).trim()

                if (tumblebug_exist_ns_response.indexOf(''Http_Status_code:200'') > 0 ) {
                    echo "Exist Namespace!"
                    tumblebug_exist_ns_response = tumblebug_exist_ns_response.replace(''- Http_Status_code:200'', '''')
                    echo JsonOutput.prettyPrint(tumblebug_exist_ns_response)
                } else {
                    def call_tumblebug_create_ns_url = """${TUMBLEBUG}/tumblebug/ns"""
                    def call_tumblebug_create_ns_payload = """''{ "name": ${NAMESPACE}, "description": "Workflow Created Namespace" }''"""
                    def tumblebug_create_ns_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_create_ns_url} -H "Content-Type: application/json" -d ''${call_tumblebug_create_ns_payload}'' --user ${USER}:${USERPASS}""", returnStdout: true).trim()

                    if (tumblebug_create_ns_response.indexOf(''Http_Status_code:200'') > 0 ) {
                        echo """Create Namespace successful >> ${NAMESPACE}"""
                        tumblebug_create_ns_response = tumblebug_create_ns_response.replace(''- Http_Status_code:200'', '''')
                        echo JsonOutput.prettyPrint(tumblebug_create_ns_response)
                    } else {
                        error """GET API call failed with status code: ${tumblebug_create_ns_response}"""
                    }
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (15, 15, 1, 'K8S ACCESS GET CONFIG INFO', 'K8S ACCESS GET CONFIG INFO', '
    stage(''K8S ACCESS GET CONFIG INFO'') {
        steps {
            script {
                echo ''>>>>>STAGE: GET kubeconfig''
                def json = new JsonSlurper().parseText(kubeinfo)
                kubeconfig = "${json.CspViewK8sClusterDetail.AccessInfo.Kubeconfig}"
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (16, 16, 1, 'K8S ACCESS AND SH(K8S Cluster)', 'K8S ACCESS AND SH(K8S Cluster)', '
    stage(''K8S ACCESS AND SH(K8S Cluster)'') {
            steps {
                sh ''''''

cat > config << EOF
'''''' + kubeconfig + ''''''
EOF

export isRun=$(docker ps --format "table {{.Status}} | {{.Names}}" | grep k8s-tools)
if [ ! -z "$isRun" ];then
    echo "The k8s-tools is already running. Terminate k8s-tools"
	docker stop k8s-tools && docker rm -f k8s-tools
else
	echo "k8s-tools is not running."
fi

docker run -d --rm --name k8s-tools alpine/k8s:1.28.13 sleep 1m
docker cp config k8s-tools:/apps

docker exec -i k8s-tools helm --help


#parameter reference: artifacthub

#nginx: https://artifacthub.io/packages/helm/bitnami/nginx
#helm install {{RELEASENAME}} oci://registry-1.docker.io/bitnamicharts/nginx --kubeconfig=/apps/config

#grafana: https://artifacthub.io/packages/helm/grafana/grafana
#helm repo add grafana https://grafana.github.io/helm-charts
#helm repo update
#helm install {{RELEASENAME}} grafana/grafana

#prometheus: https://artifacthub.io/packages/helm/prometheus-community/prometheus
#helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
#helm repo update
#helm install {{RELEASENAME}} prometheus-community/prometheus

#mariadb: https://artifacthub.io/packages/helm/bitnami/mariadb
#helm install {{RELEASENAME}} oci://registry-1.docker.io/bitnamicharts/mariadb

#redis: https://artifacthub.io/packages/helm/bitnami/redis
#helm install {{RELEASENAME}} oci://registry-1.docker.io/bitnamicharts/redis

#tomcat: https://artifacthub.io/packages/helm/bitnami/tomcat
#helm install {{RELEASENAME}} oci://registry-1.docker.io/bitnamicharts/tomcat



#remove
#helm remove {{RELEASENAME}}


docker stop k8s-tools

''''''

            }
    }');


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Step 5: Insert into workflow
-- 1. vm-mariadb-nginx-all-in-one
-- 2. k8s-mariadb-nginx-all-in-one
-- 3. create-ns
-- 4. create-mci
-- 5. delete-mci
-- 6. k8s pre-installation tasks
-- 7. create-k8s-cluster
-- 8. delete-k8s-cluster
-- 9. mci-nginx-install
-- 10. mci-mariadb-install
-- 11. k8s-nginx-install
-- 12. k8s-mariadb-install
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
                    string(name: ''IMAGE_ID'', value: IMAGE_ID),
                    string(name: ''ROOT_DISK_TYPE'', value: ROOT_DISK_TYPE),
                    string(name: ''ROOT_DISK_SIZE'', value: ROOT_DISK_SIZE),
                    string(name: ''SPEC_ID'', value: SPEC_ID),
                ]
            }
        }

        //=============================================================================================
        // stage template - Run Jenkins Job
        //=============================================================================================
        stage (''mci-nginx-install'') {
            steps {
                build job: ''mci-nginx-install'',
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
        stage (''mci-mariadb-install'') {
            steps {
                build job: ''mci-mariadb-install'',
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
        stage (''create-k8s-cluster'') {
            steps {
                build job: ''create-k8s-cluster'',
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
        stage (''k8s-nginx-install'') {
            steps {
                build job: ''k8s-nginx-install'',
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
        stage (''k8s-mariadb-install'') {
            steps {
                build job: ''k8s-mariadb-install'',
                parameters: [
                    string(name: ''CLUSTER'', value: CLUSTER),
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
    stage(''Tumblebug Info Check'') {
      steps {
        echo ''>>>>> STAGE: Tumblebug Info Check''
        script {
            def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/tumblebug/readyz --user ''${USER}:${USERPASS}''""", returnStdout: true).trim()

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
                        echo """create Namespace ${NAMESPACE}"""
                    } else {
                        error """GET API call failed with status code: ''${response}''"""
                    }
                }
            }
        }
    }
    stage(''Infrastructure NS Running Status'') {
        steps {
            echo ''>>>>> STAGE: Infrastructure NS Running Status''
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
    stage(''Tumblebug Info Check'') {
      steps {
        echo ''>>>>> STAGE: Tumblebug Info Check''
        echo TUMBLEBUG
        echo MCI

        script {
            // Calling a GET API using curl
            def response = sh(script: ''curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/tumblebug/readyz --user "${USER}:${USERPASS}"'', returnStdout: true).trim()

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
    stage(''Infrastructure MCI Create'') {
        steps {
            echo ''>>>>> STAGE: Infrastructure MCI Create''
            script {
                def payload = JsonOutput.toJson([
                    name: "${MCI}",
                    subGroups: [
                        [
                            specId: "${SPEC_ID}",
                            imageId: "${IMAGE_ID}",
                            rootDiskType: "${ROOT_DISK_TYPE}",
                            rootDiskSize: "${ROOT_DISK_SIZE}"
                        ]
                    ]
                ])

                def tb_vm_url = "${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/mciDynamic"
                def call = """curl -X POST ''${tb_vm_url}'' \
                  -H ''accept: application/json'' \
                  -H ''Content-Type: application/json'' \
                  -d ''${payload}'' \
                  --user ''${USER}:${USERPASS}''"""
                def response = sh(script: call, returnStdout: true).trim()

                echo JsonOutput.prettyPrint(response)
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
    stage(''Tumblebug Info Check'') {
      steps {
        echo ''>>>>> STAGE: Tumblebug Info Check''
        script {
          def response = sh(script: ''curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/tumblebug/readyz --user "${USER}:${USERPASS}"'', returnStdout: true).trim()
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
    stage(''Infrastructure MCI Delete'') {
      steps {
        echo ''>>>>> STAGE: Infrastructure MCI Delete''
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

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (6, 'k8s pre-installation tasks', 'test', 1, '
import groovy.json.JsonOutput
import groovy.json.JsonSlurper
import groovy.json.JsonSlurperClassic
import groovy.json.JsonSlurper


pipeline {
  agent any
  stages {
    stage(''Tumblebug Info Check'') {
        steps {
            echo ''>>>>> STAGE: Tumblebug Info Check''
            script {
                def call_tumblebug_status_url = """${TUMBLEBUG}/tumblebug/readyz"""
                def tumblebug_status_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${call_tumblebug_status_url} --user "${USER}:${USERPASS}" """, returnStdout: true).trim()

                if (tumblebug_status_response.indexOf(''Http_Status_code:200'') > 0 ) {
                    echo "GET API call successful."
                    tumblebug_status_response = tumblebug_status_response.replace(''- Http_Status_code:200'', '''')
                    echo JsonOutput.prettyPrint(tumblebug_status_response)
                } else {
                    error "GET API call failed with status code: ${tumblebug_status_response}"
                }
            }
        }
    }
    stage(''K8S PRE-INSTALLATION TASKS(namespace)'') {
        steps {
            echo ''>>>>> STAGE: K8S PRE-INSTALLATION TASKS (namespace)''
            script {
                def call_tumblebug_exist_ns_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}"""
                def tumblebug_exist_ns_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X GET ${call_tumblebug_exist_ns_url} -H "Content-Type: application/json" --user ${USER}:${USERPASS}""", returnStdout: true).trim()

                if (tumblebug_exist_ns_response.indexOf(''Http_Status_code:200'') > 0 ) {
                    echo "Exist Namespace!"
                    tumblebug_exist_ns_response = tumblebug_exist_ns_response.replace(''- Http_Status_code:200'', '''')
                    echo JsonOutput.prettyPrint(tumblebug_exist_ns_response)
                } else {
                    def call_tumblebug_create_ns_url = """${TUMBLEBUG}/tumblebug/ns"""
                    def call_tumblebug_create_ns_payload = """''{ "name": ${NAMESPACE}, "description": "Workflow Created Namespace" }''"""
                    def tumblebug_create_ns_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_create_ns_url} -H "Content-Type: application/json" -d ''${call_tumblebug_create_ns_payload}'' --user ${USER}:${USERPASS}""", returnStdout: true).trim()

                    if (tumblebug_create_ns_response.indexOf(''Http_Status_code:200'') > 0 ) {
                        echo """Create Namespace successful >> ${NAMESPACE}"""
                        tumblebug_create_ns_response = tumblebug_create_ns_response.replace(''- Http_Status_code:200'', '''')
                        echo JsonOutput.prettyPrint(tumblebug_create_ns_response)
                    } else {
                        error """GET API call failed with status code: ${tumblebug_create_ns_response}"""
                    }
                }
            }
        }
    }
    stage(''K8S PRE-INSTALLATION TASKS(spec)'') {
        steps {
            echo ''>>>>> STAGE: K8S PRE-INSTALLATION TASKS (spec)''
            script {
                // m2 / 4core / 8GB
                def call_tumblebug_exist_spec_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/resources/spec/${SPEC_ID}"""
                def tumblebug_exist_spec_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X GET ${call_tumblebug_exist_spec_url} -H "Content-Type: application/json" --user ${USER}:${USERPASS} """, returnStdout: true).trim()

                if (tumblebug_exist_spec_response.indexOf(''Http_Status_code:200'') > 0 ) {
                    echo "Exist Spec!"
                    tumblebug_exist_spec_response = tumblebug_exist_spec_response.replace(''- Http_Status_code:200'', '''')
                    echo JsonOutput.prettyPrint(tumblebug_exist_spec_response)
                } else {
                    def call_tumblebug_regist_spec_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/resources/spec"""
                    def call_tumblebug_regist_spec_payload = """{ \
                        "connectionName": "nhn-kr1", \
                        "name": "${SPEC_ID}", \
                        "cspSpecName": "m2.c4m8", \
                        "num_vCPU": 4, \
                        "mem_GiB": 8, \
                        "storage_GiB": 100, \
                        "description": "NHN Cloud kr1 region m2.c4m8 spec & Workflow registed spec" \
                    }"""
                    def tumblebug_regist_spec_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_regist_spec_url} -H "Content-Type: application/json" -d ''${call_tumblebug_regist_spec_payload}'' --user ${USER}:${USERPASS} """, returnStdout: true).trim()

                    if (tumblebug_regist_spec_response.indexOf(''Http_Status_code:200'') > 0 ) {
                        echo """Create Spec successful >> ${SPEC_ID}"""
                        tumblebug_regist_spec_response = tumblebug_regist_spec_response.replace(''- Http_Status_code:200'', '''')
                        echo JsonOutput.prettyPrint(tumblebug_regist_spec_response)
                    } else if (tumblebug_regist_spec_response.indexOf(''Http_Status_code:201'') > 0 ) {
                        echo """Create Spec successful >> ${SPEC_ID}"""
                        tumblebug_regist_spec_response = tumblebug_regist_spec_response.replace(''- Http_Status_code:201'', '''')
                        echo JsonOutput.prettyPrint(tumblebug_regist_spec_response)
                    } else {
                        error """GET API call failed with status code: ${tumblebug_regist_spec_response}"""
                    }
                }
            }
        }
    }
    stage(''K8S PRE-INSTALLATION TASKS(vNet)'') {
        steps {
            echo ''>>>>> STAGE: K8S PRE-INSTALLATION TASKS(vNet)''
            script {
                def call_tumblebug_exist_vnet_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/resources/vNet/${VNET_ID}"""
                def tumblebug_exist_vnet_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X GET ${call_tumblebug_exist_vnet_url} -H "Content-Type: application/json" --user ${USER}:${USERPASS}""", returnStdout: true).trim()

                if (tumblebug_exist_vnet_response.indexOf(''Http_Status_code:200'') > 0 ) {
                    echo "Exist vNnet!"
                    tumblebug_exist_vnet_response = tumblebug_exist_vnet_response.replace(''- Http_Status_code:200'', '''')
                    echo JsonOutput.prettyPrint(tumblebug_exist_vnet_response)
                } else {
                    def call_tumblebug_create_vnet_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/resources/vNet"""
                    def call_tumblebug_create_vnet_payload = """{ \
                        "cidrBlock": "10.0.0.0/16", \
                        "connectionName": "nhn-kr1", \
                        "description": "${VNET_ID} managed by CB-Tumblebug & Workflow Created vNet, subnet", \
                        "name": "${VNET_ID}", \
                        "subnetInfoList": [ \
                            { \
                                "description": "nhn-subnet managed by CB-Tumblebug", \
                                "ipv4_CIDR": "10.0.1.0/24", \
                                "name": "${SUBNET_ID}", \
                                "zone": "kr-pub-a" \
                            } \
                        ] \
                    }"""
                    def tumblebug_create_vnet_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_create_vnet_url} -H "Content-Type: application/json" -d ''${call_tumblebug_create_vnet_payload}'' --user ${USER}:${USERPASS}""", returnStdout: true).trim()

                    if (tumblebug_create_vnet_response.indexOf(''Http_Status_code:200'') > 0 ) {
                        echo """Create vNet successful >> ${VNET_ID}"""
                        echo """Create subnet successful >> ${SUBNET_ID}"""
                        tumblebug_create_vnet_response = tumblebug_create_vnet_response.replace(''- Http_Status_code:200'', '''')
                        echo JsonOutput.prettyPrint(tumblebug_create_vnet_response)
                    } else if (tumblebug_create_vnet_response.indexOf(''Http_Status_code:201'') > 0 ) {
                        echo """Create vNet successful >> ${VNET_ID}"""
                        echo """Create subnet successful >> ${SUBNET_ID}"""
                        tumblebug_create_vnet_response = tumblebug_create_vnet_response.replace(''- Http_Status_code:201'', '''')
                        echo JsonOutput.prettyPrint(tumblebug_create_vnet_response)
                    } else {
                        error """GET API call failed with status code: ${tumblebug_create_vnet_response}"""
                    }
                }
            }
        }
    }
    stage(''K8S PRE-INSTALLATION TASKS(SecurityGroup)'') {
        steps {
            echo ''>>>>> STAGE: K8S PRE-INSTALLATION TASKS(SecurityGroup)''
            script {
                def call_tumblebug_exist_sg_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/resources/securityGroup/${SG_ID}"""
                def tumblebug_exist_sg_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X GET ${call_tumblebug_exist_sg_url} -H "Content-Type: application/json" --user ${USER}:${USERPASS}""", returnStdout: true).trim()

                if (tumblebug_exist_sg_response.indexOf(''Http_Status_code:200'') > 0 ) {
                    echo "Exist SecurityGroup!"
                    tumblebug_exist_sg_response = tumblebug_exist_sg_response.replace(''- Http_Status_code:200'', '''')
                    echo JsonOutput.prettyPrint(tumblebug_exist_sg_response)
                } else {
                    def call_tumblebug_create_sg_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/resources/securityGroup"""
                    def call_tumblebug_create_sg_payload = """{ \
                        "connectionName": "nhn-kr1", \
                        "name": "${SG_ID}", \
                        "vNetId": "${VNET_ID}", \
                        "description": "Security group for NHN K8s cluster & Workflow Create SecurityGroup", \
                        "firewallRules": [ \
                            { \
                                "Ports": "22", \
                                "Protocol": "tcp", \
                                "Direction": "inbound", \
                                "CIDR": "0.0.0.0/0" \
                            }, \
                            { \
                                "Ports": "6443", \
                                "Protocol": "tcp", \
                                "Direction": "inbound", \
                                "CIDR": "0.0.0.0/0" \
                            } \
                          ] \
                        }"""
                    def tumblebug_create_sg_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_create_sg_url} -H "Content-Type: application/json" -d ''${call_tumblebug_create_sg_payload}'' --user ${USER}:${USERPASS}""", returnStdout: true).trim()

                    if (tumblebug_create_sg_response.indexOf(''Http_Status_code:200'') > 0 ) {
                        echo """Create SecurityGroup successful >> ${SG_ID}"""
                        tumblebug_create_sg_response = tumblebug_create_sg_response.replace(''- Http_Status_code:200'', '''')
                        echo JsonOutput.prettyPrint(tumblebug_create_sg_response)
                    } else if (tumblebug_create_sg_response.indexOf(''Http_Status_code:201'') > 0 ) {
                        echo """Create SecurityGroup successful >> ${SG_ID}"""
                        tumblebug_create_sg_response = tumblebug_create_sg_response.replace(''- Http_Status_code:201'', '''')
                        echo JsonOutput.prettyPrint(tumblebug_create_sg_response)
                    } else {
                        error """GET API call failed with status code: ${tumblebug_create_sg_response}"""
                    }
                }
            }
        }
    }
    stage(''K8S PRE-INSTALLATION TASKS(sshKey)'') {
        steps {
            echo ''>>>>> STAGE: K8S PRE-INSTALLATION TASKS(sshKey)''
            script {
                def call_tumblebug_exist_sshkey_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/resources/sshKey/${SSHKEY_ID}"""
                def tumblebug_exist_sshkey_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X GET ${call_tumblebug_exist_sshkey_url} -H "Content-Type: application/json" --user ${USER}:${USERPASS}""", returnStdout: true).trim()

                if (tumblebug_exist_sshkey_response.indexOf(''Http_Status_code:200'') > 0 ) {
                    echo "Exist SshKey!"
                    tumblebug_exist_sshkey_response = tumblebug_exist_sshkey_response.replace(''- Http_Status_code:200'', '''')
                    echo JsonOutput.prettyPrint(tumblebug_exist_sshkey_response)
                } else {
                    def call_tumblebug_create_sshkey_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/resources/sshKey"""
                    def call_tumblebug_create_sshkey_payload = """{ \
                        "connectionName": "nhn-kr1", \
                        "name": "${SSHKEY_ID}" \
                    }"""
                    def tumblebug_create_sshkey_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_create_sshkey_url} -H "Content-Type: application/json" -d ''${call_tumblebug_create_sshkey_payload}'' --user ${USER}:${USERPASS}""", returnStdout: true).trim()

                    if (tumblebug_create_sshkey_response.indexOf(''Http_Status_code:200'') > 0 ) {
                        echo """Create sshkey >> ${SSHKEY_ID}"""
                        tumblebug_create_sshkey_response = tumblebug_create_sshkey_response.replace(''- Http_Status_code:200'', '''')
                        echo JsonOutput.prettyPrint(tumblebug_create_sshkey_response)
                    } else if (tumblebug_create_sshkey_response.indexOf(''Http_Status_code:201'') > 0 ) {
                        echo """Create sshkey >> ${SSHKEY_ID}"""
                        tumblebug_create_sshkey_response = tumblebug_create_sshkey_response.replace(''- Http_Status_code:201'', '''')
                        echo JsonOutput.prettyPrint(tumblebug_create_sshkey_response)
                    } else {
                        error """GET API call failed with status code: ${tumblebug_create_sshkey_response}"""
                    }
                }
            }
        }
    }
  }
}');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (7, 'create-k8s-cluster', 'test', 1, '
import groovy.json.JsonOutput
import groovy.json.JsonSlurper
import groovy.json.JsonSlurperClassic
import groovy.json.JsonSlurper


pipeline {
  agent any
  stages {
    stage(''Tumblebug Info Check'') {
        steps {
            echo ''>>>>> STAGE: Tumblebug Info Check''
            script {
                def call_tumblebug_status_url = """${TUMBLEBUG}/tumblebug/readyz"""
                def tumblebug_status_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${call_tumblebug_status_url} --user "${USER}:${USERPASS}" """, returnStdout: true).trim()

                if (tumblebug_status_response.indexOf(''Http_Status_code:200'') > 0 ) {
                    echo "GET API call successful."
                    tumblebug_status_response = tumblebug_status_response.replace(''- Http_Status_code:200'', '''')
                    echo JsonOutput.prettyPrint(tumblebug_status_response)
                } else {
                    error "GET API call failed with status code: ${tumblebug_status_response}"
                }
            }
        }
    }
    stage(''Infrastructure K8S Cluster Create'') {
        steps {
            echo ''>>>>> STAGE: Infrastructure K8S Cluster Create''
            script {
                def call_tumblebug_exist_k8s_cluster_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}"""
                def tumblebug_exist_k8s_cluster_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X GET ${call_tumblebug_exist_k8s_cluster_url} -H "Content-Type: application/json" --user ${USER}:${USERPASS}""", returnStdout: true).trim()

                if (tumblebug_exist_k8s_cluster_response.indexOf(''Http_Status_code:200'') > 0 ) {
                    echo "Exist cluster!"
                    tumblebug_exist_k8s_cluster_response = tumblebug_exist_k8s_cluster_response.replace(''- Http_Status_code:200'', '''')
                    echo JsonOutput.prettyPrint(tumblebug_exist_k8s_cluster_response)
                } else {
                    def call_tumblebug_create_cluster_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sClusterDynamic"""

                    // CPS에 따른 클러스터 페이로드 선택
                    def call_tumblebug_create_cluster_payload

                    if (CPS == "azure") {
                        call_tumblebug_create_cluster_payload = """{ \
                            "imageId": "default", \
                            "specId": "azure+koreacentral+standard_b4ms", \
                            "connectionName": "azure-koreacentral", \
                            "name": "k8scluster02", \
                            "nodeGroupName": "k8sng02" \
                        }"""
                    } else if (CPS == "nhn") {
                        call_tumblebug_create_cluster_payload = """{ \
                            "imageId": "efe7f58f-5a32-4905-aa3b-e7839bd191d7", \
                            "specId": "nhn+kr1+m2.c4m8", \
                            "connectionName": "nhn-kr1", \
                            "name": "k8scluster02", \
                            "nodeGroupName": "k8sng02" \
                        }"""
                    } else if (CPS == "gcp") {
                        call_tumblebug_create_cluster_payload = """{ \
                            "imageId": "default", \
                            "specId": "gcp+asia-east1+e2-standard-4", \
                            "connectionName": "gcp-asia-east1", \
                            "name": "k8s03", \
                            "nodeGroupName": "k8sng02", \
                            "version": "1.32.2-gke.1297002" \
                        }"""
                    } else if (CPS == "aws") {
                        call_tumblebug_create_cluster_payload = """{ \
                            "imageId": "default", \
                            "specId": "aws+ap-northeast-2+t3a.xlarge", \
                            "connectionName": "aws-ap-northeast-2", \
                            "name": "k8scluster01", \
                            "nodeGroupName": "k8sng01" \
                        }"""
                    } else {
                        error "Unsupported CPS: ${CPS}. Supported values are: azure, nhn, gcp, aws"
                    }

                    def tumblebug_create_cluster_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_create_cluster_url} -H "Content-Type: application/json" -d ''${call_tumblebug_create_cluster_payload}'' --user ${USER}:${USERPASS}""", returnStdout: true).trim()

                    if (tumblebug_create_cluster_response.indexOf(''Http_Status_code:200'') > 0 ) {
                        echo """Create cluster >> ${CLUSTER}"""
                        tumblebug_create_cluster_response = tumblebug_create_cluster_response.replace(''- Http_Status_code:200'', '''')
                        echo JsonOutput.prettyPrint(tumblebug_create_cluster_response)
                    } else if (tumblebug_create_cluster_response.indexOf(''Http_Status_code:201'') > 0 ) {
                        echo """Create cluster >> ${CLUSTER}"""
                        tumblebug_create_cluster_response = tumblebug_create_cluster_response.replace(''- Http_Status_code:201'', '''')
                        echo JsonOutput.prettyPrint(tumblebug_create_cluster_response)
                    } else {
                        error """GET API call failed with status code: ${tumblebug_create_cluster_response}"""
                    }
                }
            }
        }
    }
    stage(''Infrastructure K8S Cluster Running Status'') {
      steps {
        echo ''>>>>> STAGE: Infrastructure K8S Cluster Running Status''
        script {
          def tb_vm_status_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}?option=status"""
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

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (8, 'delete-k8s-cluster', 'test', 1, '
import groovy.json.JsonOutput
import groovy.json.JsonSlurper
import groovy.json.JsonSlurperClassic
import groovy.json.JsonSlurper

pipeline {
  agent any

  stages {
    stage(''Tumblebug Info Check'') {
      steps {
        echo ''>>>>> STAGE: Tumblebug Info Check''
        script {
          def response = sh(script: ''curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/tumblebug/readyz --user "${USER}:${USERPASS}"'', returnStdout: true).trim()
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

    stage(''Infrastructure K8S Cluster Delete'') {
      steps {
        echo ''>>>>> STAGE: Infrastructure K8S Cluster Delete''
        script {
          def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}"""
          def call = """curl -X DELETE "${tb_vm_url}" -H "accept: application/json" --user ${USER}:${USERPASS}"""
          sh(script: """ ${call} """, returnStdout: true)
          echo "VM deletion successful."
        }
      }
    }

    stage(''Infrastructure K8S Cluster Running Status'') {
      steps {
        echo ''>>>>> STAGE: Infrastructure K8S Cluster Running Status''
        script {
          def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}?option=status"""
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

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (9, 'mci-nginx-install', 'test', 1, '
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

        stage(''WAIT FOR VM TO BE READY'') {
            steps {
                echo ''>>>>>STAGE: WAIT FOR VM TO BE READY''
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
}');
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (10, 'mci-mariadb-install', 'test', 1, '
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
INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (11, 'k8s-nginx-install', 'test', 1, '
import groovy.json.JsonOutput
import groovy.json.JsonSlurper

// JSON 파싱 함수 정의
def parseJson(String jsonString) {
    try {
        def json = new JsonSlurper().parseText(jsonString)
        return json.findAll { it.key == ''CspViewK8sClusterDetail'' }
                .collect { it.value.NodeGroupList.Status }
        return json
    } catch (Exception e) {
        error "Failed to parse JSON: ${e.message}"
    }
}

def kubeinfo = ""
def kubeconfig = ""


pipeline {
    agent any
    stages {
        stage(''Infrastructure K8S Cluster Running Status'') {
            steps {
                echo ''>>>>> STAGE: Infrastructure K8S Cluster Running Status''
                script {
                    for (int attempt = 1; attempt <= 30; attempt++) {

                        def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}?option=status"""
                        kubeinfo = sh(script: """curl -w ''- Http_Status_code:%{http_code}'' ''${tb_vm_url}'' --user ''${USER}:${USERPASS}'' -H ''accept: application/json''""", returnStdout: true).trim()
                        if (kubeinfo.indexOf(''Http_Status_code:200'') > 0 ) {
                            echo "GET API call successful."
                            kubeinfo = kubeinfo.replace(''- Http_Status_code:200'', '''')
                        } else {
                            error "GET API call failed with status code: ${kubeinfo}"
                        }

                        def k8sstatus = parseJson(kubeinfo)

                        if(k8sstatus.flatten().contains(''Active'')) {
                            break
                        }
                        else {
                            echo """${k8sstatus}"""
                            sh ''sleep 60'' // 1분 대기
                        }
                    }
                }
            }
        }

        stage(''K8S ACCESS GET CONFIG INFO'') {
            steps {
                script {
                    echo ''>>>>>STAGE: K8S ACCESS GET CONFIG INFO''
                    def json = new JsonSlurper().parseText(kubeinfo)
                    kubeconfig = "${json.CspViewK8sClusterDetail.AccessInfo.Kubeconfig}"
                }
            }
        }

        stage(''K8S ACCESS AND SH(K8S Cluster)'') {
            steps {
                sh ''''''

cat > config << EOF
'''''' + kubeconfig + ''''''
EOF

export isRun=$(docker ps --format "table {{.Status}} | {{.Names}}" | grep k8s-tools)
if [ ! -z "$isRun" ];then
    echo "The k8s-tools is already running. Terminate k8s-tools"
	docker stop k8s-tools && docker rm -f k8s-tools
else
	echo "k8s-tools is not running."
fi

docker run -d --rm --name k8s-tools alpine/k8s:1.28.13 sleep 1m
docker cp config k8s-tools:/apps

docker exec -i k8s-tools helm --help

docker exec -i k8s-tools helm install test-nginx oci://registry-1.docker.io/bitnamicharts/nginx --kubeconfig=/apps/config

#parameter reference: artifacthub

#nginx: https://artifacthub.io/packages/helm/bitnami/nginx
#helm install {{RELEASENAME}} oci://registry-1.docker.io/bitnamicharts/nginx --kubeconfig=/apps/config

#grafana: https://artifacthub.io/packages/helm/grafana/grafana
#helm repo add grafana https://grafana.github.io/helm-charts
#helm repo update
#helm install {{RELEASENAME}} grafana/grafana

#prometheus: https://artifacthub.io/packages/helm/prometheus-community/prometheus
#helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
#helm repo update
#helm install {{RELEASENAME}} prometheus-community/prometheus

#mariadb: https://artifacthub.io/packages/helm/bitnami/mariadb
#helm install {{RELEASENAME}} oci://registry-1.docker.io/bitnamicharts/mariadb

#redis: https://artifacthub.io/packages/helm/bitnami/redis
#helm install {{RELEASENAME}} oci://registry-1.docker.io/bitnamicharts/redis

#tomcat: https://artifacthub.io/packages/helm/bitnami/tomcat
#helm install {{RELEASENAME}} oci://registry-1.docker.io/bitnamicharts/tomcat

#remove
#helm remove {{RELEASENAME}}

docker stop k8s-tools

''''''
            }
        }
    }
}');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (12, 'k8s-mariadb-install', 'test', 1, '
import groovy.json.JsonOutput
import groovy.json.JsonSlurper

// JSON 파싱 함수 정의
def parseJson(String jsonString) {
    try {
        def json = new JsonSlurper().parseText(jsonString)
        return json.findAll { it.key == ''CspViewK8sClusterDetail'' }
                .collect { it.value.NodeGroupList.Status }
        return json
    } catch (Exception e) {
        error "Failed to parse JSON: ${e.message}"
    }
}

def kubeinfo = ""
def kubeconfig = ""


pipeline {
    agent any
    stages {
        stage(''Infrastructure K8S Cluster Running Status'') {
            steps {
                echo ''>>>>> STAGE: Infrastructure K8S Cluster Running Status''
                script {
                    for (int attempt = 1; attempt <= 30; attempt++) {

                        def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}?option=status"""
                        kubeinfo = sh(script: """curl -w ''- Http_Status_code:%{http_code}'' ''${tb_vm_url}'' --user ''${USER}:${USERPASS}'' -H ''accept: application/json''""", returnStdout: true).trim()
                        if (kubeinfo.indexOf(''Http_Status_code:200'') > 0 ) {
                            echo "GET API call successful."
                            kubeinfo = kubeinfo.replace(''- Http_Status_code:200'', '''')
                        } else {
                            error "GET API call failed with status code: ${kubeinfo}"
                        }

                        def k8sstatus = parseJson(kubeinfo)

                        if(k8sstatus.flatten().contains(''Active'')) {
                            break
                        }
                        else {
                            echo """${k8sstatus}"""
                            sh ''sleep 60'' // 1분 대기
                        }
                    }
                }
            }
        }

        stage(''K8S ACCESS GET CONFIG INFO'') {
            steps {
                script {
                    echo ''>>>>>STAGE: K8S ACCESS GET CONFIG INFO''
                    def json = new JsonSlurper().parseText(kubeinfo)
                    kubeconfig = "${json.CspViewK8sClusterDetail.AccessInfo.Kubeconfig}"
                }
            }
        }

        stage(''K8S ACCESS AND SH(K8S Cluster)'') {
            steps {
                sh ''''''

cat > config << EOF
'''''' + kubeconfig + ''''''
EOF

export isRun=$(docker ps --format "table {{.Status}} | {{.Names}}" | grep k8s-tools)
if [ ! -z "$isRun" ];then
    echo "The k8s-tools is already running. Terminate k8s-tools"
	docker stop k8s-tools && docker rm -f k8s-tools
else
	echo "k8s-tools is not running."
fi

docker run -d --rm --name k8s-tools alpine/k8s:1.28.13 sleep 1m
docker cp config k8s-tools:/apps

docker exec -i k8s-tools helm --help

docker exec -i k8s-tools helm install mariadb-test oci://registry-1.docker.io/bitnamicharts/mariadb --kubeconfig=/apps/config

#parameter reference: artifacthub

#nginx: https://artifacthub.io/packages/helm/bitnami/nginx
#helm install {{RELEASENAME}} oci://registry-1.docker.io/bitnamicharts/nginx --kubeconfig=/apps/config

#grafana: https://artifacthub.io/packages/helm/grafana/grafana
#helm repo add grafana https://grafana.github.io/helm-charts
#helm repo update
#helm install {{RELEASENAME}} grafana/grafana

#prometheus: https://artifacthub.io/packages/helm/prometheus-community/prometheus
#helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
#helm repo update
#helm install {{RELEASENAME}} prometheus-community/prometheus

#mariadb: https://artifacthub.io/packages/helm/bitnami/mariadb
#helm install {{RELEASENAME}} oci://registry-1.docker.io/bitnamicharts/mariadb

#redis: https://artifacthub.io/packages/helm/bitnami/redis
#helm install {{RELEASENAME}} oci://registry-1.docker.io/bitnamicharts/redis

#tomcat: https://artifacthub.io/packages/helm/bitnami/tomcat
#helm install {{RELEASENAME}} oci://registry-1.docker.io/bitnamicharts/tomcat

#remove
#helm remove {{RELEASENAME}}

docker stop k8s-tools

''''''
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
-- 6. k8s pre-installation tasks
-- 7. create-k8s-cluster
-- 8. delete-k8s-cluster
-- 9. mci-nginx-install
-- 10. mci-mariadb-install
-- 11. k8s-nginx-install
-- 12. k8s-mariadb-install
-- INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (1, 1, 'MCI', '', 'N');

-- Workflow : vm-mariadb-nginx-all-in-one
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES
(1, 1, 'MCI', 'mci01', 'N'),
(2, 1, 'NAMESPACE', 'ns01', 'N'),
(3, 1, 'TUMBLEBUG', 'http://mc-infra-manager:1323', 'N'),
(4, 1, 'USER', 'default', 'N'),
(5, 1, 'USERPASS', 'default', 'N'),
(6, 1, 'IMAGE_ID', 'ami-03236529070b4a0a5', 'N'),
(7, 1, 'SPEC_ID', 'aws+ap-northeast-2+t2.small', 'N'),
(8, 1, 'ROOT_DISK_TYPE', '', 'N'),
(9, 1, 'ROOT_DISK_SIZE', '100', 'N');
-- Workflow : k8s-mariadb-nginx-all-in-one
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES
(10, 2, 'CLUSTER', 'k8s01', 'N'),
(11, 2, 'NAMESPACE', 'ns01', 'N'),
(12, 2, 'TUMBLEBUG', 'http://mc-infra-manager:1323', 'N'),
(13, 2, 'USER', 'default', 'N'),
(14, 2, 'USERPASS', 'default', 'N'),
(67, 2, 'CPS', 'azure', 'N');

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : create-ns
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES
(15, 3, 'NAMESPACE', 'ns01', 'N'),
(16, 3, 'TUMBLEBUG', 'http://mc-infra-manager:1323', 'N'),
(17, 3, 'USER', 'default', 'N'),
(18, 3, 'USERPASS', 'default', 'N');

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : create-mci
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES
(19, 4, 'MCI', 'mci01', 'N'),
(20, 4, 'NAMESPACE', 'ns01', 'N'),
(21, 4, 'TUMBLEBUG', 'http://mc-infra-manager:1323', 'N'),
(22, 4, 'USER', 'default', 'N'),
(23, 4, 'USERPASS', 'default', 'N'),
(24, 4, 'IMAGE_ID', 'ami-03236529070b4a0a5', 'N'),
(25, 4, 'SPEC_ID', 'aws+ap-northeast-2+t2.small', 'N'),
(26, 4, 'ROOT_DISK_TYPE', '', 'N'),
(27, 4, 'ROOT_DISK_SIZE', '100', 'N');

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : delete-mci
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES
(28, 5, 'MCI', 'mci01', 'N'),
(29, 5, 'NAMESPACE', 'ns01', 'N'),
(30, 5, 'TUMBLEBUG', 'http://mc-infra-manager:1323', 'N'),
(31, 5, 'USER', 'default', 'N'),
(32, 5, 'USERPASS', 'default', 'N');

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : k8s pre-installation task
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES
(33, 6, 'NAMESPACE', 'ns01', 'N'),
(34, 6, 'TUMBLEBUG', 'http://mc-infra-manager:1323', 'N'),
(35, 6, 'USER', 'default', 'N'),
(36, 6, 'USERPASS', 'default', 'N'),
(75, 6, 'SPEC_ID', 'nhn+kr1+m2-c4m8', 'N'),
(76, 6, 'VNET_ID', 'vNet01', 'N'),
(77, 6, 'SUBNET_ID', 'subnet01', 'N'),
(78, 6, 'SG_ID', 'sg01', 'N'),
(79, 6, 'SSHKEY_ID', 'sshkey01', 'N'),
(80, 6, 'NG_ID', 'ng01', 'N');

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : create-k8s-cluster
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES
(37, 7, 'CLUSTER', 'k8s01', 'N'),
(38, 7, 'NAMESPACE', 'ns01', 'N'),
(39, 7, 'TUMBLEBUG', 'http://mc-infra-manager:1323', 'N'),
(40, 7, 'USER', 'default', 'N'),
(41, 7, 'USERPASS', 'default', 'N'),
(68, 7, 'CPS', 'azure', 'N');

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : delete-k8s-cluster
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES
(42, 8, 'CLUSTER', 'k8s01', 'N'),
(43, 8, 'NAMESPACE', 'ns01', 'N'),
(44, 8, 'TUMBLEBUG', 'http://mc-infra-manager:1323', 'N'),
(45, 8, 'USER', 'default', 'N'),
(46, 8, 'USERPASS', 'default', 'N');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : mci-nginx-install
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES
(47, 9, 'MCI', 'mci01', 'N'),
(48, 9, 'NAMESPACE', 'ns01', 'N'),
(49, 9, 'TUMBLEBUG', 'http://mc-infra-manager:1323', 'N'),
(50, 9, 'USER', 'default', 'N'),
(51, 9, 'USERPASS', 'default', 'N');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : mci-mariadb-install
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES
(52, 10, 'MCI', 'mci01', 'N'),
(53, 10, 'NAMESPACE', 'ns01', 'N'),
(54, 10, 'TUMBLEBUG', 'http://mc-infra-manager:1323', 'N'),
(55, 10, 'USER', 'default', 'N'),
(56, 10, 'USERPASS', 'default', 'N');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : k8s-nginx-install
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES
(57, 11, 'CLUSTER', 'k8s01', 'N'),
(58, 11, 'NAMESPACE', 'ns01', 'N'),
(59, 11, 'TUMBLEBUG', 'http://mc-infra-manager:1323', 'N'),
(60, 11, 'USER', 'default', 'N'),
(61, 11, 'USERPASS', 'default', 'N');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : k8s-mariadb-install
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES
(62, 12, 'CLUSTER', 'k8s01', 'N'),
(63, 12, 'NAMESPACE', 'ns01', 'N'),
(64, 12, 'TUMBLEBUG', 'http://mc-infra-manager:1323', 'N'),
(65, 12, 'USER', 'default', 'N'),
(66, 12, 'USERPASS', 'default', 'N');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Step 7: Insert into workflow_stage_mapping
-- 1. vm-mariadb-nginx-all-in-one
-- 2. k8s-mariadb-nginx-all-in-one
-- 3. create-ns
-- 4. create-mci
-- 5. delete-mci
-- 6. k8s pre-installation tasks
-- 7. create-k8s-cluster
-- 8. delete-k8s-cluster
-- 9. mci-nginx-install
-- 10. mci-mariadb-install
-- 11. k8s-nginx-install
-- 12. k8s-mariadb-install
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
                    string(name: ''SPEC_ID'', value: SPEC_ID),
                ]
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (4, 1, 4, 10, '
        //=============================================================================================
        // stage template - Run Jenkins Job
        //=============================================================================================
        stage (''mci-nginx-install'') {
            steps {
                build job: ''mci-nginx-install'',
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
        stage (''mci-mariadb-install'') {
            steps {
                build job: ''mci-mariadb-install'',
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
        stage (''create-k8s-cluster'') {
            steps {
                build job: ''create-k8s-cluster'',
                parameters: [
                    string(name: ''CLUSTER'', value: CLUSTER),
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS)
                ]
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (9, 2, 3, 10, '
        //=============================================================================================
        // stage template - Run Jenkins Job
        //=============================================================================================
        stage (''k8s-nginx-install'') {
            steps {
                build job: ''k8s-nginx-install'',
                parameters: [
                    string(name: ''CLUSTER'', value: CLUSTER),
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS)
                ]
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (10, 2, 4, 10, '
        //=============================================================================================
        // stage template - Run Jenkins Job
        //=============================================================================================
        stage (''k8s-mariadb-install'') {
            steps {
                build job: ''k8s-mariadb-install'',
                parameters: [
                    string(name: ''CLUSTER'', value: CLUSTER),
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS)
                ]
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (11, 2, 5, null, '
    }
}');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : create-ns
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (12, 3, 1, null, '
import groovy.json.JsonOutput
import groovy.json.JsonSlurper
import groovy.json.JsonSlurperClassic

pipeline {
  agent any
  stages {');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (13, 3, 2, 1, '
    stage(''Tumblebug Info Check'') {
      steps {
        echo ''>>>>> STAGE: Tumblebug Info Check''
        script {
            def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/tumblebug/readyz --user ''${USER}:${USERPASS}''""", returnStdout: true).trim()

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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (14, 3, 3, 2, '
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
                        echo """create Namespace ${NAMESPACE}"""
                    } else {
                        error """GET API call failed with status code: ''${response}''"""
                    }
                }
            }
        }
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (15, 3, 4, 3, '
    stage(''Infrastructure NS Running Status'') {
        steps {
            echo ''>>>>> STAGE: Infrastructure NS Running Status''
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
    stage(''Tumblebug Info Check'') {
      steps {
        echo ''>>>>> STAGE: Tumblebug Info Check''
        script {
            // Calling a GET API using curl
            def response = sh(script: ''curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/tumblebug/readyz --user "${USER}:${USERPASS}"'', returnStdout: true).trim()

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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (20, 4, 3, 2, '
    stage(''Infrastructure MCI Create'') {
        steps {
            echo ''>>>>> STAGE: Infrastructure MCI Create''
            script {
                def payload = JsonOutput.toJson([
                    name: "${MCI}",
                    subGroups: [
                        [
                            specId: "${SPEC_ID}",
                            imageId: "${IMAGE_ID}",
                            rootDiskType: "${ROOT_DISK_TYPE}",
                            rootDiskSize: "${ROOT_DISK_SIZE}"
                        ]
                    ]
                ])

                def tb_vm_url = "${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/mciDynamic"
                def call = """curl -X POST ''${tb_vm_url}'' \
                  -H ''accept: application/json'' \
                  -H ''Content-Type: application/json'' \
                  -d ''${payload}'' \
                  --user ''${USER}:${USERPASS}''"""
                def response = sh(script: call, returnStdout: true).trim()

                echo JsonOutput.prettyPrint(response)
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
    stage(''Tumblebug Info Check'') {
      steps {
        echo ''>>>>> STAGE: Tumblebug Info Check''
        script {
          def response = sh(script: ''curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/tumblebug/readyz --user "${USER}:${USERPASS}"'', returnStdout: true).trim()
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
    stage(''Infrastructure MCI Delete'') {
      steps {
        echo ''>>>>> STAGE: Infrastructure MCI Delete''
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
-- Workflow : k8s pre-installation tasks
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (28, 6, 1, null, '
import groovy.json.JsonOutput
import groovy.json.JsonSlurper
import groovy.json.JsonSlurperClassic
import groovy.json.JsonSlurper

pipeline {
  agent any
  stages {');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (29, 6, 2, 1, '
    stage(''Tumblebug Info Check'') {
        steps {
            echo ''>>>>> STAGE: Tumblebug Info Check''
            script {
                def call_tumblebug_status_url = """${TUMBLEBUG}/tumblebug/readyz"""
                def tumblebug_status_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${call_tumblebug_status_url} --user "${USER}:${USERPASS}" """, returnStdout: true).trim()

                if (tumblebug_status_response.indexOf(''Http_Status_code:200'') > 0 ) {
                    echo "GET API call successful."
                    tumblebug_status_response = tumblebug_status_response.replace(''- Http_Status_code:200'', '''')
                    echo JsonOutput.prettyPrint(tumblebug_status_response)
                } else {
                    error "GET API call failed with status code: ${tumblebug_status_response}"
                }
            }
        }
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (30, 6, 3, 14, '
    stage(''K8S PRE-INSTALLATION TASKS(namespace)'') {
        steps {
            echo ''>>>>> STAGE: K8S PRE-INSTALLATION TASKS (namespace)''
            script {
                def call_tumblebug_exist_ns_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}"""
                def tumblebug_exist_ns_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X GET ${call_tumblebug_exist_ns_url} -H "Content-Type: application/json" --user ${USER}:${USERPASS}""", returnStdout: true).trim()

                if (tumblebug_exist_ns_response.indexOf(''Http_Status_code:200'') > 0 ) {
                    echo "Exist Namespace!"
                    tumblebug_exist_ns_response = tumblebug_exist_ns_response.replace(''- Http_Status_code:200'', '''')
                    echo JsonOutput.prettyPrint(tumblebug_exist_ns_response)
                } else {
                    def call_tumblebug_create_ns_url = """${TUMBLEBUG}/tumblebug/ns"""
                    def call_tumblebug_create_ns_payload = """''{ "name": ${NAMESPACE}, "description": "Workflow Created Namespace" }''"""
                    def tumblebug_create_ns_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_create_ns_url} -H "Content-Type: application/json" -d ''${call_tumblebug_create_ns_payload}'' --user ${USER}:${USERPASS}""", returnStdout: true).trim()

                    if (tumblebug_create_ns_response.indexOf(''Http_Status_code:200'') > 0 ) {
                        echo """Create Namespace successful >> ${NAMESPACE}"""
                        tumblebug_create_ns_response = tumblebug_create_ns_response.replace(''- Http_Status_code:200'', '''')
                        echo JsonOutput.prettyPrint(tumblebug_create_ns_response)
                    } else if (tumblebug_create_ns_response.indexOf(''Http_Status_code:201'') > 0 ) {
                        echo """Create Namespace successful >> ${NAMESPACE}"""
                        tumblebug_create_ns_response = tumblebug_create_ns_response.replace(''- Http_Status_code:201'', '''')
                        echo JsonOutput.prettyPrint(tumblebug_create_ns_response)
                    } else {
                        error """GET API call failed with status code: ${tumblebug_create_ns_response}"""
                    }
                }
            }
        }
    }');

INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (31, 6, 4, 15, '
    stage(''K8S PRE-INSTALLATION TASKS(spec)'') {
        steps {
            echo ''>>>>> STAGE: K8S PRE-INSTALLATION TASKS (spec)''
            script {
                // m2 / 4core / 8GB
                def call_tumblebug_exist_spec_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/resources/spec/${SPEC_ID}"""
                def tumblebug_exist_spec_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X GET ${call_tumblebug_exist_spec_url} -H "Content-Type: application/json" --user ${USER}:${USERPASS} """, returnStdout: true).trim()

                if (tumblebug_exist_spec_response.indexOf(''Http_Status_code:200'') > 0 ) {
                    echo "Exist Spec!"
                    tumblebug_exist_spec_response = tumblebug_exist_spec_response.replace(''- Http_Status_code:200'', '''')
                    echo JsonOutput.prettyPrint(tumblebug_exist_spec_response)
                } else {
                    def call_tumblebug_regist_spec_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/resources/spec"""
                    def call_tumblebug_regist_spec_payload = """{ \
                        "connectionName": "nhn-kr1", \
                        "name": "${SPEC_ID}", \
                        "cspSpecName": "m2.c4m8", \
                        "num_vCPU": 4, \
                        "mem_GiB": 8, \
                        "storage_GiB": 100, \
                        "description": "NHN Cloud kr1 region m2.c4m8 spec & Workflow registed spec" \
                    }"""
                    def tumblebug_regist_spec_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_regist_spec_url} -H "Content-Type: application/json" -d ''${call_tumblebug_regist_spec_payload}'' --user ${USER}:${USERPASS} """, returnStdout: true).trim()

                    if (tumblebug_regist_spec_response.indexOf(''Http_Status_code:200'') > 0 ) {
                        echo """Create Spec successful >> ${SPEC_ID}"""
                        tumblebug_regist_spec_response = tumblebug_regist_spec_response.replace(''- Http_Status_code:200'', '''')
                        echo JsonOutput.prettyPrint(tumblebug_regist_spec_response)
                    } else if (tumblebug_regist_spec_response.indexOf(''Http_Status_code:201'') > 0 ) {
                        echo """Create Spec successful >> ${SPEC_ID}"""
                        tumblebug_regist_spec_response = tumblebug_regist_spec_response.replace(''- Http_Status_code:201'', '''')
                        echo JsonOutput.prettyPrint(tumblebug_regist_spec_response)
                    } else {
                        error """GET API call failed with status code: ${tumblebug_regist_spec_response}"""
                    }
                }
            }
        }
    }');

INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (32, 6, 5, 15, '
    stage(''K8S PRE-INSTALLATION TASKS(vNet)'') {
        steps {
            echo ''>>>>> STAGE: K8S PRE-INSTALLATION TASKS(vNet)''
            script {
                def call_tumblebug_exist_vnet_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/resources/vNet/${VNET_ID}"""
                def tumblebug_exist_vnet_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X GET ${call_tumblebug_exist_vnet_url} -H "Content-Type: application/json" --user ${USER}:${USERPASS}""", returnStdout: true).trim()

                if (tumblebug_exist_vnet_response.indexOf(''Http_Status_code:200'') > 0 ) {
                    echo "Exist vNnet!"
                    tumblebug_exist_vnet_response = tumblebug_exist_vnet_response.replace(''- Http_Status_code:200'', '''')
                    echo JsonOutput.prettyPrint(tumblebug_exist_vnet_response)
                } else {
                    def call_tumblebug_create_vnet_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/resources/vNet"""
                    def call_tumblebug_create_vnet_payload = """{ \
                        "cidrBlock": "10.0.0.0/16", \
                        "connectionName": "nhn-kr1", \
                        "description": "${VNET_ID} managed by CB-Tumblebug & Workflow Created vNet, subnet", \
                        "name": "${VNET_ID}", \
                        "subnetInfoList": [ \
                            { \
                                "description": "nhn-subnet managed by CB-Tumblebug", \
                                "ipv4_CIDR": "10.0.1.0/24", \
                                "name": "${SUBNET_ID}", \
                                "zone": "kr-pub-a" \
                            } \
                        ] \
                    }"""
                    def tumblebug_create_vnet_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_create_vnet_url} -H "Content-Type: application/json" -d ''${call_tumblebug_create_vnet_payload}'' --user ${USER}:${USERPASS}""", returnStdout: true).trim()

                    if (tumblebug_create_vnet_response.indexOf(''Http_Status_code:200'') > 0 ) {
                        echo """Create vNet successful >> ${VNET_ID}"""
                        echo """Create subnet successful >> ${SUBNET_ID}"""
                        tumblebug_create_vnet_response = tumblebug_create_vnet_response.replace(''- Http_Status_code:200'', '''')
                        echo JsonOutput.prettyPrint(tumblebug_create_vnet_response)
                    } else if (tumblebug_create_vnet_response.indexOf(''Http_Status_code:201'') > 0 ) {
                        echo """Create vNet successful >> ${VNET_ID}"""
                        echo """Create subnet successful >> ${SUBNET_ID}"""
                        tumblebug_create_vnet_response = tumblebug_create_vnet_response.replace(''- Http_Status_code:201'', '''')
                        echo JsonOutput.prettyPrint(tumblebug_create_vnet_response)
                    } else {
                        error """GET API call failed with status code: ${tumblebug_create_vnet_response}"""
                    }
                }
            }
        }
    }');

INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (33, 6, 6, 15, '
    stage(''K8S PRE-INSTALLATION TASKS(SecurityGroup)'') {
        steps {
            echo ''>>>>> STAGE: K8S PRE-INSTALLATION TASKS(SecurityGroup)''
            script {
                def call_tumblebug_exist_sg_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/resources/securityGroup/${SG_ID}"""
                def tumblebug_exist_sg_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X GET ${call_tumblebug_exist_sg_url} -H "Content-Type: application/json" --user ${USER}:${USERPASS}""", returnStdout: true).trim()

                if (tumblebug_exist_sg_response.indexOf(''Http_Status_code:200'') > 0 ) {
                    echo "Exist SecurityGroup!"
                    tumblebug_exist_sg_response = tumblebug_exist_sg_response.replace(''- Http_Status_code:200'', '''')
                    echo JsonOutput.prettyPrint(tumblebug_exist_sg_response)
                } else {
                    def call_tumblebug_create_sg_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/resources/securityGroup"""
                    def call_tumblebug_create_sg_payload = """{ \
                        "connectionName": "nhn-kr1", \
                        "name": "${SG_ID}", \
                        "vNetId": "${VNET_ID}", \
                        "description": "Security group for NHN K8s cluster & Workflow Create SecurityGroup", \
                        "firewallRules": [ \
                            { \
                                "Ports": "22", \
                                "Protocol": "tcp", \
                                "Direction": "inbound", \
                                "CIDR": "0.0.0.0/0" \
                            }, \
                            { \
                                "Ports": "6443", \
                                "Protocol": "tcp", \
                                "Direction": "inbound", \
                                "CIDR": "0.0.0.0/0" \
                            } \
                          ] \
                        }"""
                    def tumblebug_create_sg_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_create_sg_url} -H "Content-Type: application/json" -d ''${call_tumblebug_create_sg_payload}'' --user ${USER}:${USERPASS}""", returnStdout: true).trim()

                    if (tumblebug_create_sg_response.indexOf(''Http_Status_code:200'') > 0 ) {
                        echo """Create SecurityGroup successful >> ${SG_ID}"""
                        tumblebug_create_sg_response = tumblebug_create_sg_response.replace(''- Http_Status_code:200'', '''')
                        echo JsonOutput.prettyPrint(tumblebug_create_sg_response)
                    } else if (tumblebug_create_sg_response.indexOf(''Http_Status_code:201'') > 0 ) {
                        echo """Create SecurityGroup successful >> ${SG_ID}"""
                        tumblebug_create_sg_response = tumblebug_create_sg_response.replace(''- Http_Status_code:201'', '''')
                        echo JsonOutput.prettyPrint(tumblebug_create_sg_response)
                    } else {
                        error """GET API call failed with status code: ${tumblebug_create_sg_response}"""
                    }
                }
            }
        }
    }');

INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (34, 6, 7, 14, '
    stage(''K8S PRE-INSTALLATION TASKS(sshKey)'') {
        steps {
            echo ''>>>>> STAGE: K8S PRE-INSTALLATION TASKS(sshKey)''
            script {
                def call_tumblebug_exist_sshkey_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/resources/sshKey/${SSHKEY_ID}"""
                def tumblebug_exist_sshkey_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X GET ${call_tumblebug_exist_sshkey_url} -H "Content-Type: application/json" --user ${USER}:${USERPASS}""", returnStdout: true).trim()

                if (tumblebug_exist_sshkey_response.indexOf(''Http_Status_code:200'') > 0 ) {
                    echo "Exist SshKey!"
                    tumblebug_exist_sshkey_response = tumblebug_exist_sshkey_response.replace(''- Http_Status_code:200'', '''')
                    echo JsonOutput.prettyPrint(tumblebug_exist_sshkey_response)
                } else {
                    def call_tumblebug_create_sshkey_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/resources/sshKey"""
                    def call_tumblebug_create_sshkey_payload = """{ \
                        "connectionName": "nhn-kr1", \
                        "name": "${SSHKEY_ID}" \
                    }"""
                    def tumblebug_create_sshkey_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_create_sshkey_url} -H "Content-Type: application/json" -d ''${call_tumblebug_create_sshkey_payload}'' --user ${USER}:${USERPASS}""", returnStdout: true).trim()

                    if (tumblebug_create_sshkey_response.indexOf(''Http_Status_code:200'') > 0 ) {
                        echo """Create sshkey >> ${SSHKEY_ID}"""
                        tumblebug_create_sshkey_response = tumblebug_create_sshkey_response.replace(''- Http_Status_code:200'', '''')
                        echo JsonOutput.prettyPrint(tumblebug_create_sshkey_response)
                    } else if (tumblebug_create_sshkey_response.indexOf(''Http_Status_code:201'') > 0 ) {
                        echo """Create sshkey >> ${SSHKEY_ID}"""
                        tumblebug_create_sshkey_response = tumblebug_create_sshkey_response.replace(''- Http_Status_code:201'', '''')
                        echo JsonOutput.prettyPrint(tumblebug_create_sshkey_response)
                    } else {
                        error """GET API call failed with status code: ${tumblebug_create_sshkey_response}"""
                    }
                }
            }
        }
    }');

INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (35, 6, 8, null, '
  }
}');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : create-k8s-cluster
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (36, 7, 1, null, '
import groovy.json.JsonOutput
import groovy.json.JsonSlurper
import groovy.json.JsonSlurperClassic
import groovy.json.JsonSlurper

pipeline {
  agent any
  stages {');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (37, 7, 2, 1, '
    stage(''Tumblebug Info Check'') {
        steps {
            echo ''>>>>> STAGE: Tumblebug Info Check''
            script {
                def call_tumblebug_status_url = """${TUMBLEBUG}/tumblebug/readyz"""
                def tumblebug_status_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${call_tumblebug_status_url} --user "${USER}:${USERPASS}" """, returnStdout: true).trim()

                if (tumblebug_status_response.indexOf(''Http_Status_code:200'') > 0 ) {
                    echo "GET API call successful."
                    tumblebug_status_response = tumblebug_status_response.replace(''- Http_Status_code:200'', '''')
                    echo JsonOutput.prettyPrint(tumblebug_status_response)
                } else {
                    error "GET API call failed with status code: ${tumblebug_status_response}"
                }
            }
        }
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (38, 7, 3, 7, '
    stage(''Infrastructure K8S Cluster Create'') {
        steps {
            echo ''>>>>> STAGE: Infrastructure K8S Cluster Create''
            script {
                def call_tumblebug_exist_k8s_cluster_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}"""
                def tumblebug_exist_k8s_cluster_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X GET ${call_tumblebug_exist_k8s_cluster_url} -H "Content-Type: application/json" --user ${USER}:${USERPASS}""", returnStdout: true).trim()

                if (tumblebug_exist_k8s_cluster_response.indexOf(''Http_Status_code:200'') > 0 ) {
                    echo "Exist cluster!"
                    tumblebug_exist_k8s_cluster_response = tumblebug_exist_k8s_cluster_response.replace(''- Http_Status_code:200'', '''')
                    echo JsonOutput.prettyPrint(tumblebug_exist_k8s_cluster_response)
                } else {
                    def call_tumblebug_create_cluster_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sClusterDynamic"""

                    // CPS에 따른 클러스터 페이로드 선택
                    def call_tumblebug_create_cluster_payload

                    if (CPS == "azure") {
                        call_tumblebug_create_cluster_payload = """{ \
                            "imageId": "default", \
                            "specId": "azure+koreacentral+standard_b4ms", \
                            "connectionName": "azure-koreacentral", \
                            "name": "k8scluster02", \
                            "nodeGroupName": "k8sng02" \
                        }"""
                    } else if (CPS == "nhn") {
                        call_tumblebug_create_cluster_payload = """{ \
                            "imageId": "efe7f58f-5a32-4905-aa3b-e7839bd191d7", \
                            "specId": "nhn+kr1+m2.c4m8", \
                            "connectionName": "nhn-kr1", \
                            "name": "k8scluster02", \
                            "nodeGroupName": "k8sng02" \
                        }"""
                    } else if (CPS == "gcp") {
                        call_tumblebug_create_cluster_payload = """{ \
                            "imageId": "default", \
                            "specId": "gcp+asia-east1+e2-standard-4", \
                            "connectionName": "gcp-asia-east1", \
                            "name": "k8s03", \
                            "nodeGroupName": "k8sng02", \
                            "version": "1.32.2-gke.1297002" \
                        }"""
                    } else if (CPS == "aws") {
                        call_tumblebug_create_cluster_payload = """{ \
                            "imageId": "default", \
                            "specId": "aws+ap-northeast-2+t3a.xlarge", \
                            "connectionName": "aws-ap-northeast-2", \
                            "name": "k8scluster01", \
                            "nodeGroupName": "k8sng01" \
                        }"""
                    } else {
                        error "Unsupported CPS: ${CPS}. Supported values are: azure, nhn, gcp, aws"
                    }

                    def tumblebug_create_cluster_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_create_cluster_url} -H "Content-Type: application/json" -d ''${call_tumblebug_create_cluster_payload}'' --user ${USER}:${USERPASS}""", returnStdout: true).trim()

                    if (tumblebug_create_cluster_response.indexOf(''Http_Status_code:200'') > 0 ) {
                        echo """Create cluster >> ${CLUSTER}"""
                        tumblebug_create_cluster_response = tumblebug_create_cluster_response.replace(''- Http_Status_code:200'', '''')
                        echo JsonOutput.prettyPrint(tumblebug_create_cluster_response)
                    } else if (tumblebug_create_cluster_response.indexOf(''Http_Status_code:201'') > 0 ) {
                        echo """Create cluster >> ${CLUSTER}"""
                        tumblebug_create_cluster_response = tumblebug_create_cluster_response.replace(''- Http_Status_code:201'', '''')
                        echo JsonOutput.prettyPrint(tumblebug_create_cluster_response)
                    } else {
                        error """GET API call failed with status code: ${tumblebug_create_cluster_response}"""
                    }
                }
            }
        }
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (39, 7, 4, 9, '
    stage(''Infrastructure K8S Cluster Running Status'') {
      steps {
        echo ''>>>>> STAGE: Infrastructure K8S Cluster Running Status''
        script {
          def tb_vm_status_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}?option=status"""
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (40, 7, 5, null, '
  }
}');
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : delete-k8s-cluster
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (41, 8, 1, null, '
import groovy.json.JsonOutput
import groovy.json.JsonSlurper
import groovy.json.JsonSlurperClassic
import groovy.json.JsonSlurper

pipeline {
  agent any
  stages {');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (42, 8, 2, 1, '
    stage(''Tumblebug Info Check'') {
      steps {
        echo ''>>>>> STAGE: Tumblebug Info Check''
        script {
          def response = sh(script: ''curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/tumblebug/readyz --user "${USER}:${USERPASS}"'', returnStdout: true).trim()
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (43, 8, 3, 8, '
    stage(''Infrastructure K8S Cluster Delete'') {
      steps {
        echo ''>>>>> STAGE: Infrastructure K8S Cluster Delete''
        script {
          def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}"""
          def call = """curl -X DELETE "${tb_vm_url}" -H "accept: application/json" --user ${USER}:${USERPASS}"""
          sh(script: """ ${call} """, returnStdout: true)
          echo "VM deletion successful."
        }
      }
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (44, 8, 4, 9, '
    stage(''Infrastructure K8S Cluster Running Status'') {
      steps {
        echo ''>>>>> STAGE: Infrastructure K8S Cluster Running Status''
        script {
          def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}?option=status"""
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (45, 8, 5, null, '
  }
}');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : mci-nginx-install
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (46, 9, 1, null, '
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (47, 9, 2, 11, '
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (48, 9, 3, 13, '
        stage(''WAIT FOR VM TO BE READY'') {
            steps {
                echo ''>>>>>STAGE: WAIT FOR VM TO BE READY''
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (49, 9, 4, 12, '
        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCI VM)
        //=============================================================================================
         stage(''install nginx'') {
            steps {
                echo ''>>>>>STAGE: install nginx''
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (50, 9, 5, null, '
    }
}');


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : mci-mariadb-install
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (51, 10, 1, null, '
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
    stages {');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (52, 10, 2, 11, '
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (53, 10, 3, 13, '
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (54, 10, 4, 12, '
        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCI VM)
        //=============================================================================================
        stage(''install MariaDB'') {
            steps {
                echo ''>>>>>STAGE: install MariaDB''
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (55, 10, 5, null, '
    }
}');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : k8s-nginx-install
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (56, 11, 1, null, '
import groovy.json.JsonOutput
import groovy.json.JsonSlurper

// JSON 파싱 함수 정의
def parseJson(String jsonString) {
    try {
        def json = new JsonSlurper().parseText(jsonString)
        return json.findAll { it.key == ''CspViewK8sClusterDetail'' }
                .collect { it.value.NodeGroupList.Status }
        return json
    } catch (Exception e) {
        error "Failed to parse JSON: ${e.message}"
    }
}

def kubeinfo = ""
def kubeconfig = ""


pipeline {
    agent any
    stages {');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (57, 11, 2, 9, '
        stage(''Infrastructure K8S Cluster Running Status'') {
            steps {
                echo ''>>>>> STAGE: Infrastructure K8S Cluster Running Status''
                script {
                    for (int attempt = 1; attempt <= 30; attempt++) {

                        def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}?option=status"""
                        kubeinfo = sh(script: """curl -w ''- Http_Status_code:%{http_code}'' ''${tb_vm_url}'' --user ''${USER}:${USERPASS}'' -H ''accept: application/json''""", returnStdout: true).trim()
                        if (kubeinfo.indexOf(''Http_Status_code:200'') > 0 ) {
                            echo "GET API call successful."
                            kubeinfo = kubeinfo.replace(''- Http_Status_code:200'', '''')
                        } else {
                            error "GET API call failed with status code: ${kubeinfo}"
                        }

                        def k8sstatus = parseJson(kubeinfo)

                        if(k8sstatus.flatten().contains(''Active'')) {
                            break
                        }
                        else {
                            echo """${k8sstatus}"""
                            sh ''sleep 60'' // 1분 대기
                        }
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (58, 11, 3, 15, '
        stage(''K8S ACCESS GET CONFIG INFO'') {
            steps {
                script {
                    echo ''>>>>>STAGE: K8S ACCESS GET CONFIG INFO''
                    def json = new JsonSlurper().parseText(kubeinfo)
                    kubeconfig = "${json.CspViewK8sClusterDetail.AccessInfo.Kubeconfig}"
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (59, 11, 4, 16, '
        stage(''K8S ACCESS AND SH(K8S Cluster)'') {
            steps {
                sh ''''''

cat > config << EOF
'''''' + kubeconfig + ''''''
EOF

export isRun=$(docker ps --format "table {{.Status}} | {{.Names}}" | grep k8s-tools)
if [ ! -z "$isRun" ];then
    echo "The k8s-tools is already running. Terminate k8s-tools"
	docker stop k8s-tools && docker rm -f k8s-tools
else
	echo "k8s-tools is not running."
fi

docker run -d --rm --name k8s-tools alpine/k8s:1.28.13 sleep 1m
docker cp config k8s-tools:/apps

docker exec -i k8s-tools helm --help

docker exec -i k8s-tools helm install test-nginx oci://registry-1.docker.io/bitnamicharts/nginx --kubeconfig=/apps/config

#parameter reference: artifacthub

#nginx: https://artifacthub.io/packages/helm/bitnami/nginx
#helm install {{RELEASENAME}} oci://registry-1.docker.io/bitnamicharts/nginx --kubeconfig=/apps/config

#grafana: https://artifacthub.io/packages/helm/grafana/grafana
#helm repo add grafana https://grafana.github.io/helm-charts
#helm repo update
#helm install {{RELEASENAME}} grafana/grafana

#prometheus: https://artifacthub.io/packages/helm/prometheus-community/prometheus
#helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
#helm repo update
#helm install {{RELEASENAME}} prometheus-community/prometheus

#mariadb: https://artifacthub.io/packages/helm/bitnami/mariadb
#helm install {{RELEASENAME}} oci://registry-1.docker.io/bitnamicharts/mariadb

#redis: https://artifacthub.io/packages/helm/bitnami/redis
#helm install {{RELEASENAME}} oci://registry-1.docker.io/bitnamicharts/redis

#tomcat: https://artifacthub.io/packages/helm/bitnami/tomcat
#helm install {{RELEASENAME}} oci://registry-1.docker.io/bitnamicharts/tomcat

#remove
#helm remove {{RELEASENAME}}

docker stop k8s-tools

''''''
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (60, 11, 5, null, '
    }
}
');


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : k8s-mariadb-install
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (61, 12, 1, null, '
import groovy.json.JsonOutput
import groovy.json.JsonSlurper

// JSON 파싱 함수 정의
def parseJson(String jsonString) {
    try {
        def json = new JsonSlurper().parseText(jsonString)
        return json.findAll { it.key == ''CspViewK8sClusterDetail'' }
                .collect { it.value.NodeGroupList.Status }
        return json
    } catch (Exception e) {
        error "Failed to parse JSON: ${e.message}"
    }
}

def kubeinfo = ""
def kubeconfig = ""


pipeline {
    agent any
    stages {');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (62, 12, 2, 9, '
        stage(''Infrastructure K8S Cluster Running Status'') {
            steps {
                echo ''>>>>> STAGE: Infrastructure K8S Cluster Running Status''
                script {
                    for (int attempt = 1; attempt <= 30; attempt++) {

                        def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}?option=status"""
                        kubeinfo = sh(script: """curl -w ''- Http_Status_code:%{http_code}'' ''${tb_vm_url}'' --user ''${USER}:${USERPASS}'' -H ''accept: application/json''""", returnStdout: true).trim()
                        if (kubeinfo.indexOf(''Http_Status_code:200'') > 0 ) {
                            echo "GET API call successful."
                            kubeinfo = kubeinfo.replace(''- Http_Status_code:200'', '''')
                        } else {
                            error "GET API call failed with status code: ${kubeinfo}"
                        }

                        def k8sstatus = parseJson(kubeinfo)

                        if(k8sstatus.flatten().contains(''Active'')) {
                            break
                        }
                        else {
                            echo """${k8sstatus}"""
                            sh ''sleep 60'' // 1분 대기
                        }
                    }
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (63, 12, 3, 15, '
        stage(''K8S ACCESS GET CONFIG INFO'') {
            steps {
                script {
                    echo ''>>>>>STAGE: K8S ACCESS GET CONFIG INFO''
                    def json = new JsonSlurper().parseText(kubeinfo)
                    kubeconfig = "${json.CspViewK8sClusterDetail.AccessInfo.Kubeconfig}"
                }
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (64, 12, 4, 16, '
        stage(''K8S ACCESS AND SH(K8S Cluster)'') {
            steps {
                sh ''''''

cat > config << EOF
'''''' + kubeconfig + ''''''
EOF

export isRun=$(docker ps --format "table {{.Status}} | {{.Names}}" | grep k8s-tools)
if [ ! -z "$isRun" ];then
    echo "The k8s-tools is already running. Terminate k8s-tools"
	docker stop k8s-tools && docker rm -f k8s-tools
else
	echo "k8s-tools is not running."
fi

docker run -d --rm --name k8s-tools alpine/k8s:1.28.13 sleep 1m
docker cp config k8s-tools:/apps

docker exec -i k8s-tools helm --help

docker exec -i k8s-tools helm install mariadb-test oci://registry-1.docker.io/bitnamicharts/mariadb --kubeconfig=/apps/config

#parameter reference: artifacthub

#nginx: https://artifacthub.io/packages/helm/bitnami/nginx
#helm install {{RELEASENAME}} oci://registry-1.docker.io/bitnamicharts/nginx --kubeconfig=/apps/config

#grafana: https://artifacthub.io/packages/helm/grafana/grafana
#helm repo add grafana https://grafana.github.io/helm-charts
#helm repo update
#helm install {{RELEASENAME}} grafana/grafana

#prometheus: https://artifacthub.io/packages/helm/prometheus-community/prometheus
#helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
#helm repo update
#helm install {{RELEASENAME}} prometheus-community/prometheus

#mariadb: https://artifacthub.io/packages/helm/bitnami/mariadb
#helm install {{RELEASENAME}} oci://registry-1.docker.io/bitnamicharts/mariadb

#redis: https://artifacthub.io/packages/helm/bitnami/redis
#helm install {{RELEASENAME}} oci://registry-1.docker.io/bitnamicharts/redis

#tomcat: https://artifacthub.io/packages/helm/bitnami/tomcat
#helm install {{RELEASENAME}} oci://registry-1.docker.io/bitnamicharts/tomcat

#remove
#helm remove {{RELEASENAME}}

docker stop k8s-tools

''''''
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (65, 12, 5, null, '
    }
}
');