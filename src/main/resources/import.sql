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
                def imageId, specId, rootDiskType, rootDiskSize, sgName
                if (CSP == "aws") {
                    sgName = "g1"
                    imageId = "ami-03236529070b4a0a5"
                    specId = "aws+ap-northeast-2+t2.small"
                    rootDiskType = "gp3"
                    rootDiskSize = 20
                } else if (CSP == "azure") {
                    sgName = "g2"
                    imageId = "Canonical:0001-com-ubuntu-server-jammy:22_04-lts:22.04.202505210"
                    specId = "azure+koreasouth+standard_b1s"
                    rootDiskType = "default"
                    rootDiskSize = "default"
                } else if (CSP == "gcp") {
                    sgName = "g3"
                    imageId = "https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20250712"
                    specId = "gcp+asia-northeast3+g1-small"
                    rootDiskType = "default"
                    rootDiskSize = "default"
                } else if (CSP == "ncp") {
                    sgName = "g4"
                    imageId = "23214590"
                    specId = "ncp+kr+c8-g3a"
                    rootDiskType = "default"
                    rootDiskSize = "default"
                } else if (CSP == "nhn") {
                    sgName = "g5"
                    imageId = "abc5d0a0-4001-4e5b-ac28-de341b2a0834"
                    specId = "nhn+kr1+r2.c4m16"
                    rootDiskType = "default"
                    rootDiskSize = "default"
                } else if (CSP == "alibaba") {
                    sgName = "g6"
                    imageId = "ubuntu_22_04_uefi_x64_20G_alibase_20240807.vhd"
                    specId = "alibaba+ap-northeast-2+ecs.t6-c1m4.xlarge"
                    rootDiskType = "default"
                    rootDiskSize = "default"
                } else if (CSP == "tencent") {
                    sgName = "g7"
                    imageId = "img-7rotv4ux"
                    specId = "tencent+ap-shanghai+m9.medium16"
                    rootDiskType = "default"
                    rootDiskSize = "30"
                } else if (CSP == "ibm") {
                    sgName = "g8"
                    imageId = "r034-76e0174f-fd2f-4c31-b95b-b859a403f85f"
                    specId = "ibm+jp-osa+cx2d-2x4"
                    rootDiskType = "default"
                    rootDiskSize = "default"
                } else {
                    error "Unsupported CSP: ${CSP}. Supported values are: aws, azure, gcp, ncp, nhn, alibaba, tencent, ibm"
                }

                def payload = JsonOutput.toJson([
                    name: "${MCI}",
                    nodeGroups: [
                        [
                            name: sgName,
                            specId: specId,
                            imageId: imageId,
                            rootDiskType: rootDiskType,
                            rootDiskSize: rootDiskSize
                        ]
                    ]
                ])

                def tb_vm_url = "${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/infraDynamic"
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
          def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/infra/${MCI}?option=terminate"""
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
                def tb_vm_status_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/infra/${MCI}?option=status"""
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
                    def call_tumblebug_create_cluster_payload

                    if (CPS == "azure") {
                        call_tumblebug_create_cluster_payload = """{ \
                            "imageId": "default", \
                            "specId": "azure+koreacentral+standard_b4ms", \
                            "connectionName": "azure-koreacentral", \
                            "name": "${CLUSTER}", \
                            "nodeGroupName": "k8sng01" \
                        }"""
                    } else if (CPS == "nhn") {
                        call_tumblebug_create_cluster_payload = """{ \
                            "imageId": "efe7f58f-5a32-4905-aa3b-e7839bd191d7", \
                            "specId": "nhn+kr1+m2.c4m8", \
                            "connectionName": "nhn-kr1", \
                            "name": "${CLUSTER}", \
                            "nodeGroupName": "k8sng02" \
                        }"""
                    } else if (CPS == "gcp") {
                        call_tumblebug_create_cluster_payload = """{ \
                            "imageId": "default", \
                            "specId": "gcp+asia-east1+e2-standard-4", \
                            "connectionName": "gcp-asia-east1", \
                            "name": "${CLUSTER}", \
                            "nodeGroupName": "k8sng03", \
                            "version": "1.33.5-gke.1125000" \
                        }"""
                    } else if (CPS == "aws") {
                        call_tumblebug_create_cluster_payload = """{ \
                            "imageId": "default", \
                            "specId": "aws+ap-northeast-2+t3a.xlarge", \
                            "connectionName": "aws-ap-northeast-2", \
                            "name": "${CLUSTER}", \
                            "nodeGroupName": "k8sng04" \
                        }"""
                    } else if (CPS == "ncp") {
                        call_tumblebug_create_cluster_payload = """{ \
                            "imageId": "default", \
                            "specId": "ncp+kr1+c4m8", \
                            "connectionName": "ncp-kr1", \
                            "name": "${CLUSTER}", \
                            "nodeGroupName": "k8sng05" \
                        }"""
                    } else if (CPS == "alibaba") {
                        call_tumblebug_create_cluster_payload = """{ \
                            "imageId": "aliyun_3_x64_20G_container_optimized_alibase_20250629.vhd", \
                            "specId": "alibaba+ap-southeast-1+ecs.t6-c1m4.2xlarge", \
                            "connectionName": "alibaba-ap-southeast-1", \
                            "name": "${CLUSTER}", \
                            "nodeGroupName": "k8sng06" \
                        }"""
                    } else if (CPS == "tencent") {
                        call_tumblebug_create_cluster_payload = """{ \
                            "imageId": "img-22trbn9x", \
                            "specId": "tencent+ap-seoul+s5.medium4", \
                            "connectionName": "tencent-ap-seoul", \
                            "name": "${CLUSTER}", \
                            "nodeGroupName": "k8sng07" \
                        }"""
                    } else {
                        error "Unsupported CPS: ${CPS}. Supported values are: azure, nhn, gcp, aws, ncp, alibaba, tencent"
                    }

                    def tumblebug_create_cluster_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_create_cluster_url} -H "Content-Type: application/json" -d ''${call_tumblebug_create_cluster_payload}'' --user ${USER}:${USERPASS}""", returnStdout: true).trim()

                    if (tumblebug_create_cluster_response.indexOf(''Http_Status_code:200'') > 0 || tumblebug_create_cluster_response.indexOf(''Http_Status_code:201'') > 0) {
                        echo """Create cluster >> ${CLUSTER}"""
                        def responseCode = tumblebug_create_cluster_response.indexOf(''Http_Status_code:200'') > 0 ? ''- Http_Status_code:200'' : ''- Http_Status_code:201''
                        tumblebug_create_cluster_response = tumblebug_create_cluster_response.replace(responseCode, '''')
                        echo JsonOutput.prettyPrint(tumblebug_create_cluster_response)
                        
                        // Wait for cluster to be Active before creating node group
                        echo "Waiting for cluster to be Active..."
                        def isActive = false
                        for (int attempt = 1; attempt <= 30; attempt++) {
                            def tb_vm_status_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}?option=status"""
                            def status_response = sh(script: """curl -w ''- Http_Status_code:%{http_code}'' ''${tb_vm_status_url}'' --user ''${USER}:${USERPASS}'' -H ''accept: application/json''""", returnStdout: true).trim()
                            if (status_response.indexOf(''Http_Status_code:200'') > 0 ) {
                                status_response = status_response.replace(''- Http_Status_code:200'', '''')
                                
                                if(status_response.contains(''Active'')) {
                                    echo "Cluster is Active!"
                                    isActive = true
                                    break
                                } else {
                                    echo "Cluster not yet Active. Waiting... (attempt ${attempt}/30)"
                                    sh ''sleep 60''
                                }
                            } else {
                                echo "Status check attempt ${attempt}/30 failed"
                                sh ''sleep 60''
                            }
                        }
                        
                        // Additional: When CPS is aws, create extra node group via k8sNodeGroupDynamic
                        if (CPS == "aws") {
                            def call_tumblebug_create_nodegroup_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}/k8sNodeGroupDynamic"""
                            def call_tumblebug_create_nodegroup_payload = """{ \
                                "imageId": "default", \
                                "specId": "aws+ap-northeast-2+t3a.xlarge", \
                                "name": "k8sng01" \
                            }"""
                            def tumblebug_create_nodegroup_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_create_nodegroup_url} -H "Content-Type: application/json" -d ''${call_tumblebug_create_nodegroup_payload}'' --user ${USER}:${USERPASS}""", returnStdout: true).trim()
                            if (tumblebug_create_nodegroup_response.indexOf(''Http_Status_code:200'') > 0 || tumblebug_create_nodegroup_response.indexOf(''Http_Status_code:201'') > 0) {
                                echo "Create nodeGroup >> k8sng01"
                            } else {
                                echo "k8sNodeGroupDynamic call response: ${tumblebug_create_nodegroup_response}"
                            }
                        }

                        // Additional: When CPS is tencent, create node group via k8sNodeGroupDynamic
                        if (CPS == "tencent") {
                            def call_tumblebug_create_nodegroup_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}/k8sNodeGroupDynamic"""
                            def call_tumblebug_create_nodegroup_payload = """{ \
                                "imageId": "img-22trbn9x", \
                                "specId": "tencent+ap-seoul+s5.medium4", \
                                "name": "k8sng07" \
                            }"""
                            def tumblebug_create_nodegroup_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_create_nodegroup_url} -H "Content-Type: application/json" -d ''${call_tumblebug_create_nodegroup_payload}'' --user ${USER}:${USERPASS}""", returnStdout: true).trim()
                            if (tumblebug_create_nodegroup_response.indexOf(''Http_Status_code:200'') > 0 || tumblebug_create_nodegroup_response.indexOf(''Http_Status_code:201'') > 0) {
                                echo "Create nodeGroup >> k8sng07"
                            } else {
                                echo "k8sNodeGroupDynamic call response: ${tumblebug_create_nodegroup_response}"
                            }
                        }

                        // Additional: When CPS is alibaba, create node group via k8sNodeGroupDynamic
                        if (CPS == "alibaba") {
                            def call_tumblebug_create_nodegroup_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}/k8sNodeGroupDynamic"""
                            def call_tumblebug_create_nodegroup_payload = """{ \
                                "imageId": "default", \
                                "specId": "alibaba+ap-southeast-1+ecs.t6-c1m4.2xlarge", \
                                "nodeGroupName": "k8sng06", \
                                "RootDiskType": "cloud_efficiency", \
                                "RootDiskSize": "40" \
                            }"""
                            def tumblebug_create_nodegroup_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_create_nodegroup_url} -H "Content-Type: application/json" -d ''${call_tumblebug_create_nodegroup_payload}'' --user ${USER}:${USERPASS}""", returnStdout: true).trim()
                            if (tumblebug_create_nodegroup_response.indexOf(''Http_Status_code:200'') > 0 || tumblebug_create_nodegroup_response.indexOf(''Http_Status_code:201'') > 0) {
                                echo "Create nodeGroup >> k8sng06"
                            } else {
                                echo "k8sNodeGroupDynamic call response: ${tumblebug_create_nodegroup_response}"
                            }
                        }
                        
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
                def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/infra/${MCI}?option=accessinfo --user "default:default" """, returnStdout: true).trim()
                if (response.contains(''Http_Status_code:200'')) {
                    echo "GET API call successful."
                    callData = response.replace(''- Http_Status_code:200'', '''')
                    echo(callData)
                } else {
                    error "GET API call failed with status code: ${response}"
                }

                def tb_sw_url = "${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/infra/${MCI}?option=accessinfo&accessInfoOption=showSshKey"
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
-- Step 4-1: Insert category-managed workflow stages
-- category: infra, k8s, app-deploy, db-backup-restore, common-util
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES
(17, 'infra', '인프라'),
(18, 'k8s', '인프라 - K8s'),
(19, 'app-deploy', '앱 배포'),
(20, 'db-backup-restore', '데이터 - Backup / Restore'),
(21, 'common-util', '공통 / 유틸');

INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (17, 17, 1, 'infra-create', 'INFRA 생성 (CSP별 spec 기반)', '
    stage("infra-create") {
        steps {
            echo ">>>>> STAGE: infra-create"
            script {
                def payload = params.INFRA_CREATE_PAYLOAD?.trim()
                if (!payload) {
                    def specId = params.SPEC_ID ?: params.SPEC
                    def imageId = params.IMAGE_ID ?: params.IMAGE
                    payload = JsonOutput.toJson([
                        name: params.INFRA_ID,
                        description: params.INFRA_DESC ?: "Workflow created infra",
                        installMonAgent: params.INSTALL_MON_AGENT ?: "no",
                        policyOnPartialFailure: params.POLICY_ON_PARTIAL_FAILURE ?: "continue",
                        label: [
                            region: params.REGION ?: ""
                        ],
                        nodeGroups: [[
                            name: params.INFRA_NODEGROUP_NAME ?: "g1",
                            nodeGroupSize: (params.INFRA_NODEGROUP_SIZE ?: "1").toInteger(),
                            specId: specId,
                            imageId: imageId,
                            rootDiskType: params.ROOT_DISK_TYPE ?: "default",
                            rootDiskSize: (params.ROOT_DISK_SIZE ?: "50").toInteger()
                        ]]
                    ])
                }
                writeFile file: "infra-create.json", text: payload
                def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X POST "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/infraDynamic" -H "Content-Type: application/json" -d @infra-create.json ${auth}""", returnStdout: true).trim()
                echo response
                if (!response.contains("Http_Status_code:2")) {
                    error "infra-create failed: ${response}"
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (18, 17, 2, 'infra-get', 'INFRA 단건 조회', '
    stage("infra-get") {
        steps {
            echo ">>>>> STAGE: infra-get"
            script {
                def option = params.INFRA_GET_OPTION ? "?option=${params.INFRA_GET_OPTION}" : ""
                def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/infra/${params.INFRA_ID}${option}" ${auth}""", returnStdout: true).trim()
                echo response
                if (!response.contains("Http_Status_code:2")) {
                    error "infra-get failed: ${response}"
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (19, 17, 3, 'infra-list', 'INFRA 목록 조회', '
    stage("infra-list") {
        steps {
            echo ">>>>> STAGE: infra-list"
            script {
                def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/infra" ${auth}""", returnStdout: true).trim()
                echo response
                if (!response.contains("Http_Status_code:2")) {
                    error "infra-list failed: ${response}"
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (20, 17, 4, 'infra-update', 'INFRA 스펙 변경 (resize 등)', '
    stage("infra-update") {
        steps {
            echo ">>>>> STAGE: infra-update"
            script {
                def method = params.INFRA_UPDATE_METHOD ?: "PUT"
                def path = params.INFRA_UPDATE_PATH ?: "/tumblebug/ns/${params.NAMESPACE}/infra/${params.INFRA_ID}"
                def payload = params.INFRA_UPDATE_PAYLOAD ?: "{}"
                writeFile file: "infra-update.json", text: payload
                def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X "${method}" "${params.TUMBLEBUG}${path}" -H "Content-Type: application/json" -d @infra-update.json ${auth}""", returnStdout: true).trim()
                echo response
                if (!response.contains("Http_Status_code:2")) {
                    error "infra-update failed: ${response}"
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (21, 17, 5, 'infra-delete', 'INFRA 삭제', '
    stage("infra-delete") {
        steps {
            echo ">>>>> STAGE: infra-delete"
            script {
                def option = params.INFRA_DELETE_OPTION ?: "terminate"
                def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X DELETE "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/infra/${params.INFRA_ID}?option=${option}" ${auth}""", returnStdout: true).trim()
                echo response
                if (!response.contains("Http_Status_code:2")) {
                    error "infra-delete failed: ${response}"
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (22, 17, 6, 'infra-start', 'INFRA 시작', '
    stage("infra-start") {
        steps {
            echo ">>>>> STAGE: infra-start"
            script {
                def force = params.INFRA_CONTROL_FORCE ?: "false"
                def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/control/infra/${params.INFRA_ID}?action=resume&force=${force}" ${auth}""", returnStdout: true).trim()
                echo response
                if (!response.contains("Http_Status_code:2")) {
                    error "infra-start failed: ${response}"
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (23, 17, 7, 'infra-stop', 'INFRA 중지', '
    stage("infra-stop") {
        steps {
            echo ">>>>> STAGE: infra-stop"
            script {
                def force = params.INFRA_CONTROL_FORCE ?: "false"
                def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/control/infra/${params.INFRA_ID}?action=suspend&force=${force}" ${auth}""", returnStdout: true).trim()
                echo response
                if (!response.contains("Http_Status_code:2")) {
                    error "infra-stop failed: ${response}"
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (24, 17, 8, 'infra-reboot', 'INFRA 재시작', '
    stage("infra-reboot") {
        steps {
            echo ">>>>> STAGE: infra-reboot"
            script {
                def force = params.INFRA_CONTROL_FORCE ?: "false"
                def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/control/infra/${params.INFRA_ID}?action=reboot&force=${force}" ${auth}""", returnStdout: true).trim()
                echo response
                if (!response.contains("Http_Status_code:2")) {
                    error "infra-reboot failed: ${response}"
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (25, 17, 9, 'infra-ssh-connect-check', 'INFRA SSH 연결 확인', '
    stage("infra-ssh-connect-check") {
        steps {
            echo ">>>>> STAGE: infra-ssh-connect-check"
            script {
                def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/infra/${params.INFRA_ID}?option=accessInfo" ${auth}""", returnStdout: true).trim()
                echo response
                if (!response.contains("Http_Status_code:2")) {
                    error "infra accessInfo lookup failed: ${response}"
                }
                if (params.SSH_HOST && params.SSH_USER) {
                    def keyOpt = params.SSH_KEY_FILE ? "-i \"${params.SSH_KEY_FILE}\"" : ""
                    sh """ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=10 ${keyOpt} "${params.SSH_USER}@${params.SSH_HOST}" "echo ssh-ok" """
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (26, 18, 1, 'k8s-cluster-create', 'K8s 클러스터 생성', '
    stage("k8s-cluster-create") {
        steps {
            echo ">>>>> STAGE: k8s-cluster-create"
            script {
                def payload = params.K8S_CREATE_PAYLOAD?.trim()
                if (!payload) {
                    payload = JsonOutput.toJson([
                        name: params.K8S_CLUSTER_ID,
                        nodeGroupName: params.K8S_NODEGROUP_NAME ?: "ng1",
                        specId: params.SPEC_ID,
                        imageId: params.IMAGE_ID,
                        version: params.K8S_VERSION ?: "",
                        desiredNodeSize: (params.K8S_DESIRED_NODE_SIZE ?: "1").toInteger(),
                        minNodeSize: (params.K8S_MIN_NODE_SIZE ?: "1").toInteger(),
                        maxNodeSize: (params.K8S_MAX_NODE_SIZE ?: "3").toInteger(),
                        rootDiskType: params.ROOT_DISK_TYPE ?: "default",
                        rootDiskSize: (params.ROOT_DISK_SIZE ?: "30").toInteger()
                    ])
                }
                writeFile file: "k8s-cluster-create.json", text: payload
                def option = params.K8S_CREATE_OPTION ? "?option=${params.K8S_CREATE_OPTION}" : ""
                def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X POST "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/k8sClusterDynamic${option}" -H "Content-Type: application/json" -d @k8s-cluster-create.json ${auth}""", returnStdout: true).trim()
                echo response
                if (!response.contains("Http_Status_code:2")) {
                    error "k8s-cluster-create failed: ${response}"
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (27, 18, 2, 'k8s-cluster-get', '클러스터 단건 조회', '
    stage("k8s-cluster-get") {
        steps {
            echo ">>>>> STAGE: k8s-cluster-get"
            script {
                def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/k8sCluster/${params.K8S_CLUSTER_ID}" ${auth}""", returnStdout: true).trim()
                echo response
                if (!response.contains("Http_Status_code:2")) {
                    error "k8s-cluster-get failed: ${response}"
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (28, 18, 3, 'k8s-cluster-list', '클러스터 목록 조회', '
    stage("k8s-cluster-list") {
        steps {
            echo ">>>>> STAGE: k8s-cluster-list"
            script {
                def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/k8sCluster" ${auth}""", returnStdout: true).trim()
                echo response
                if (!response.contains("Http_Status_code:2")) {
                    error "k8s-cluster-list failed: ${response}"
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (29, 18, 4, 'k8s-cluster-update', '클러스터 수정 (노드 수 등)', '
    stage("k8s-cluster-update") {
        steps {
            echo ">>>>> STAGE: k8s-cluster-update"
            script {
                def payload = params.K8S_UPDATE_PAYLOAD?.trim()
                if (!payload) {
                    payload = JsonOutput.toJson([version: params.K8S_VERSION])
                }
                writeFile file: "k8s-cluster-update.json", text: payload
                def skipVersionCheck = params.K8S_SKIP_VERSION_CHECK ?: "false"
                def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X PUT "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/k8sCluster/${params.K8S_CLUSTER_ID}/upgrade?skipVersionCheck=${skipVersionCheck}" -H "Content-Type: application/json" -d @k8s-cluster-update.json ${auth}""", returnStdout: true).trim()
                echo response
                if (!response.contains("Http_Status_code:2")) {
                    error "k8s-cluster-update failed: ${response}"
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (30, 18, 5, 'k8s-cluster-delete', '클러스터 삭제', '
    stage("k8s-cluster-delete") {
        steps {
            echo ">>>>> STAGE: k8s-cluster-delete"
            script {
                def option = params.K8S_DELETE_OPTION ?: "force"
                def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X DELETE "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/k8sCluster/${params.K8S_CLUSTER_ID}?option=${option}" ${auth}""", returnStdout: true).trim()
                echo response
                if (!response.contains("Http_Status_code:2")) {
                    error "k8s-cluster-delete failed: ${response}"
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (31, 18, 6, 'k8s-nodegroup-add', '노드그룹 추가', '
    stage("k8s-nodegroup-add") {
        steps {
            echo ">>>>> STAGE: k8s-nodegroup-add"
            script {
                def payload = params.K8S_NODEGROUP_PAYLOAD?.trim()
                if (!payload) {
                    payload = JsonOutput.toJson([
                        name: params.K8S_NODEGROUP_NAME,
                        specId: params.SPEC_ID,
                        imageId: params.IMAGE_ID,
                        desiredNodeSize: (params.K8S_DESIRED_NODE_SIZE ?: "1").toInteger(),
                        minNodeSize: (params.K8S_MIN_NODE_SIZE ?: "1").toInteger(),
                        maxNodeSize: (params.K8S_MAX_NODE_SIZE ?: "3").toInteger(),
                        rootDiskType: params.ROOT_DISK_TYPE ?: "default",
                        rootDiskSize: (params.ROOT_DISK_SIZE ?: "30").toInteger()
                    ])
                }
                writeFile file: "k8s-nodegroup-add.json", text: payload
                def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X POST "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/k8sCluster/${params.K8S_CLUSTER_ID}/k8sNodeGroupDynamic" -H "Content-Type: application/json" -d @k8s-nodegroup-add.json ${auth}""", returnStdout: true).trim()
                echo response
                if (!response.contains("Http_Status_code:2")) {
                    error "k8s-nodegroup-add failed: ${response}"
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (32, 18, 7, 'k8s-nodegroup-remove', '노드그룹 제거', '
    stage("k8s-nodegroup-remove") {
        steps {
            echo ">>>>> STAGE: k8s-nodegroup-remove"
            script {
                def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X DELETE "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/k8sCluster/${params.K8S_CLUSTER_ID}/k8sNodeGroup/${params.K8S_NODEGROUP_NAME}" ${auth}""", returnStdout: true).trim()
                echo response
                if (!response.contains("Http_Status_code:2")) {
                    error "k8s-nodegroup-remove failed: ${response}"
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (33, 18, 8, 'k8s-kubeconfig-get', 'kubeconfig 조회', '
    stage("k8s-kubeconfig-get") {
        steps {
            echo ">>>>> STAGE: k8s-kubeconfig-get"
            script {
                def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/k8sCluster/${params.K8S_CLUSTER_ID}/kubeconfig" ${auth}""", returnStdout: true).trim()
                echo response
                if (!response.contains("Http_Status_code:2")) {
                    error "k8s-kubeconfig-get failed: ${response}"
                }
                def body = response.replaceAll("- Http_Status_code:[0-9]{3}", "").trim()
                writeFile file: "kubeconfig-response.json", text: body
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (34, 19, 1, 'app-deploy-helm', 'Helm chart 기반 앱 배포', '
    stage("app-deploy-helm") {
        steps {
            echo ">>>>> STAGE: app-deploy-helm"
            script {
                writeFile file: "kubeconfig", text: params.KUBECONFIG_CONTENT ?: ""
                def namespace = params.KUBE_NAMESPACE ?: "default"
                def valuesArgs = params.HELM_VALUES_ARGS ?: ""
                sh """helm upgrade --install "${params.RELEASE_NAME}" "${params.HELM_CHART}" --namespace "${namespace}" --create-namespace --kubeconfig kubeconfig ${valuesArgs}"""
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (35, 19, 2, 'app-deploy-manifest', 'K8s manifest 기반 앱 배포', '
    stage("app-deploy-manifest") {
        steps {
            echo ">>>>> STAGE: app-deploy-manifest"
            script {
                writeFile file: "kubeconfig", text: params.KUBECONFIG_CONTENT ?: ""
                writeFile file: "manifest.yaml", text: params.K8S_MANIFEST ?: ""
                def namespace = params.KUBE_NAMESPACE ?: "default"
                sh """kubectl apply -f manifest.yaml --namespace "${namespace}" --kubeconfig kubeconfig"""
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (36, 19, 3, 'app-deploy-status-check', '배포 상태 확인 (pod/deployment ready)', '
    stage("app-deploy-status-check") {
        steps {
            echo ">>>>> STAGE: app-deploy-status-check"
            script {
                writeFile file: "kubeconfig", text: params.KUBECONFIG_CONTENT ?: ""
                def namespace = params.KUBE_NAMESPACE ?: "default"
                def deployment = params.DEPLOYMENT_NAME
                if (deployment) {
                    sh """kubectl rollout status deployment/${deployment} --namespace "${namespace}" --kubeconfig kubeconfig --timeout="${params.ROLLOUT_TIMEOUT ?: "300s"}" """
                } else {
                    sh """kubectl get pods --namespace "${namespace}" --kubeconfig kubeconfig"""
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (37, 19, 4, 'app-undeploy', '앱 삭제', '
    stage("app-undeploy") {
        steps {
            echo ">>>>> STAGE: app-undeploy"
            script {
                writeFile file: "kubeconfig", text: params.KUBECONFIG_CONTENT ?: ""
                def namespace = params.KUBE_NAMESPACE ?: "default"
                def deployType = params.APP_DEPLOY_TYPE ?: "helm"
                if (deployType == "manifest") {
                    writeFile file: "manifest.yaml", text: params.K8S_MANIFEST ?: ""
                    sh """kubectl delete -f manifest.yaml --namespace "${namespace}" --kubeconfig kubeconfig --ignore-not-found=true"""
                } else {
                    sh """helm uninstall "${params.RELEASE_NAME}" --namespace "${namespace}" --kubeconfig kubeconfig || true"""
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (38, 19, 5, 'app-rollback', '이전 버전 롤백', '
    stage("app-rollback") {
        steps {
            echo ">>>>> STAGE: app-rollback"
            script {
                writeFile file: "kubeconfig", text: params.KUBECONFIG_CONTENT ?: ""
                def namespace = params.KUBE_NAMESPACE ?: "default"
                def revision = params.HELM_REVISION ?: ""
                sh """helm rollback "${params.RELEASE_NAME}" ${revision} --namespace "${namespace}" --kubeconfig kubeconfig"""
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (48, 20, 1, 'mariadb-install', 'MariaDB 설치', '
    stage("mariadb-install") {
        steps {
            echo ">>>>> STAGE: mariadb-install"
            script {
                def dbName = params.DB_NAME ?: "testdb"
                def dbUser = params.DB_USER ?: "mariadb_user"
                def dbPassword = params.DB_PASSWORD ?: "mariadb_pass"
                def keyOpt = params.SSH_KEY_FILE ? "-i \"${params.SSH_KEY_FILE}\"" : ""
                if (!params.SSH_HOST || !params.SSH_USER) {
                    error "SSH_HOST and SSH_USER are required for mariadb-install"
                }
                sh """ssh -o StrictHostKeyChecking=no ${keyOpt} "${params.SSH_USER}@${params.SSH_HOST}" << "EOF"
set -e
if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mariadb-server mariadb-client
elif command -v yum >/dev/null 2>&1; then
  sudo yum install -y mariadb-server mariadb
else
  echo "Unsupported package manager"
  exit 1
fi
sudo systemctl enable --now mariadb || sudo systemctl enable --now mysql
sudo mariadb -e "CREATE DATABASE IF NOT EXISTS \`${dbName}\`;"
sudo mariadb -e "CREATE USER IF NOT EXISTS ''${dbUser}''@''%'' IDENTIFIED BY ''${dbPassword}'';"
sudo mariadb -e "GRANT ALL PRIVILEGES ON \`${dbName}\`.* TO ''${dbUser}''@''%'';"
sudo mariadb -e "FLUSH PRIVILEGES;"
EOF"""
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (39, 20, 2, 'db-backup-export', 'DB 백업 파일 export', '
    stage("db-backup-export") {
        steps {
            echo ">>>>> STAGE: db-backup-export"
            script {
                def dbPort = params.DB_PORT ?: "3306"
                def backupFile = params.DB_BACKUP_FILE ?: "${params.DB_NAME}.sql"
                sh """MYSQL_PWD="${params.DB_PASSWORD}" mariadb-dump -h "${params.DB_HOST}" -P "${dbPort}" -u "${params.DB_USER}" "${params.DB_NAME}" > "${backupFile}" """
                archiveArtifacts artifacts: backupFile, allowEmptyArchive: false
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (40, 20, 3, 'db-backup-import', '백업 파일 import (restore)', '
    stage("db-backup-import") {
        steps {
            echo ">>>>> STAGE: db-backup-import"
            script {
                def dbPort = params.DB_PORT ?: "3306"
                def backupFile = params.DB_BACKUP_FILE ?: "${params.DB_NAME}.sql"
                if (params.SCHEMA_SQL_CONTENT?.trim()) {
                    writeFile file: backupFile, text: params.SCHEMA_SQL_CONTENT
                }
                sh """MYSQL_PWD="${params.DB_PASSWORD}" mariadb -h "${params.DB_HOST}" -P "${dbPort}" -u "${params.DB_USER}" "${params.DB_NAME}" < "${backupFile}" """
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (49, 20, 4, 'db-schema-import', 'schema.sql import', '
    stage("db-schema-import") {
        steps {
            echo ">>>>> STAGE: db-schema-import"
            script {
                def dbPort = params.DB_PORT ?: "3306"
                def schemaFile = params.SCHEMA_SQL_FILE ?: "schema.sql"
                if (params.SCHEMA_SQL_CONTENT?.trim()) {
                    writeFile file: schemaFile, text: params.SCHEMA_SQL_CONTENT
                }
                sh """MYSQL_PWD="${params.DB_PASSWORD}" mariadb -h "${params.DB_HOST}" -P "${dbPort}" -u "${params.DB_USER}" "${params.DB_NAME}" < "${schemaFile}" """
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (41, 20, 5, 'db-data-insert', '초기 데이터 insert', '
    stage("db-data-insert") {
        steps {
            echo ">>>>> STAGE: db-data-insert"
            script {
                def dbPort = params.DB_PORT ?: "3306"
                writeFile file: "insert.sql", text: params.INSERT_SQL ?: ""
                sh """MYSQL_PWD="${params.DB_PASSWORD}" mariadb -h "${params.DB_HOST}" -P "${dbPort}" -u "${params.DB_USER}" "${params.DB_NAME}" < insert.sql"""
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (42, 20, 6, 'db-data-verify', '데이터 적재 결과 확인', '
    stage("db-data-verify") {
        steps {
            echo ">>>>> STAGE: db-data-verify"
            script {
                def dbPort = params.DB_PORT ?: "3306"
                writeFile file: "verify.sql", text: params.VERIFY_SQL ?: "SELECT 1"
                sh """MYSQL_PWD="${params.DB_PASSWORD}" mariadb -h "${params.DB_HOST}" -P "${dbPort}" -u "${params.DB_USER}" "${params.DB_NAME}" < verify.sql"""
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (43, 21, 1, 'ssh-command-exec', 'SSH 원격 명령 실행', '
    stage("ssh-command-exec") {
        steps {
            echo ">>>>> STAGE: ssh-command-exec"
            script {
                def keyOpt = params.SSH_KEY_FILE ? "-i \"${params.SSH_KEY_FILE}\"" : ""
                sh """ssh -o StrictHostKeyChecking=no ${keyOpt} "${params.SSH_USER}@${params.SSH_HOST}" "${params.SSH_COMMAND}" """
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (44, 21, 2, 'http-request', 'REST API 호출', '
    stage("http-request") {
        steps {
            echo ">>>>> STAGE: http-request"
            script {
                def method = params.HTTP_METHOD ?: "GET"
                def headers = params.HTTP_HEADERS ?: ""
                def body = params.HTTP_BODY ?: ""
                def bodyArg = ""
                if (body) {
                    writeFile file: "http-request-body.json", text: body
                    bodyArg = "-d @http-request-body.json"
                }
                def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X "${method}" ${headers} ${bodyArg} "${params.HTTP_URL}" """, returnStdout: true).trim()
                echo response
                if (!response.contains("Http_Status_code:2")) {
                    error "http-request failed: ${response}"
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (45, 21, 3, 'wait-for-condition', '조건 충족까지 대기 (polling)', '
    stage("wait-for-condition") {
        steps {
            echo ">>>>> STAGE: wait-for-condition"
            script {
                def method = params.WAIT_METHOD ?: "GET"
                def expectedStatus = params.WAIT_HTTP_STATUS ?: "200"
                def containsText = params.WAIT_CONTAINS ?: ""
                def maxAttempts = (params.WAIT_MAX_ATTEMPTS ?: "30").toInteger()
                def intervalSeconds = (params.WAIT_INTERVAL_SECONDS ?: "10").toInteger()
                for (int attempt = 1; attempt <= maxAttempts; attempt++) {
                    def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X "${method}" "${params.WAIT_URL}" """, returnStdout: true).trim()
                    echo "wait attempt ${attempt}/${maxAttempts}: ${response}"
                    def statusMatched = response.contains("Http_Status_code:${expectedStatus}")
                    def bodyMatched = !containsText || response.contains(containsText)
                    if (statusMatched && bodyMatched) {
                        echo "condition matched"
                        return
                    }
                    sleep time: intervalSeconds, unit: "SECONDS"
                }
                error "wait-for-condition timeout"
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (46, 21, 4, 'notification-send', '결과 알림 발송 (Slack 등)', '
    stage("notification-send") {
        steps {
            echo ">>>>> STAGE: notification-send"
            script {
                def payload = params.NOTIFICATION_PAYLOAD?.trim()
                if (!payload) {
                    payload = JsonOutput.toJson([text: params.NOTIFICATION_MESSAGE ?: "Workflow finished"])
                }
                writeFile file: "notification.json", text: payload
                def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X POST "${params.NOTIFICATION_WEBHOOK_URL}" -H "Content-Type: application/json" -d @notification.json""", returnStdout: true).trim()
                echo response
                if (!response.contains("Http_Status_code:2")) {
                    error "notification-send failed: ${response}"
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (47, 21, 5, 'script-exec', '쉘 스크립트 실행', '
    stage("script-exec") {
        steps {
            echo ">>>>> STAGE: script-exec"
            script {
                writeFile file: "workflow-script.sh", text: params.SCRIPT_CONTENT ?: "echo no script"
                sh "chmod +x workflow-script.sh"
                sh "./workflow-script.sh"
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
-- 6. k8s pre-installation tasks
-- 7. create-k8s-cluster
-- 8. delete-k8s-cluster
-- 9. mci-nginx-install
-- 10. mci-mariadb-install
-- 11. k8s-nginx-install
-- 12. k8s-mariadb-install
-- INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script, run_date) VALUES (1, 'create vm', 'test', 1, '', NULL);
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script, run_date) VALUES (1, 'vm-mariadb-nginx-all-in-one', 'test', 1, '
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
                    string(name: ''CSP'', value: CSP),
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
}', NULL);

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script, run_date) VALUES (2, 'k8s-mariadb-nginx-all-in-one', 'test', 1, '
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
                    string(name: ''USERPASS'', value: USERPASS),
                    string(name: ''CPS'', value: CPS)
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
}', NULL);

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script, run_date) VALUES (3, 'create-ns', 'test', 1, '
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
}', NULL);

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script, run_date) VALUES (4, 'create-mci', 'test', 1, '
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
                // CSP에 따른 MCI 설정 선택
                def imageId, specId, rootDiskType, rootDiskSize, sgName

                if (CSP == "aws") {
                    sgName = "g1"
                    imageId = "ami-03236529070b4a0a5"
                    specId = "aws+ap-northeast-2+t2.small"
                    rootDiskType = "gp3"
                    rootDiskSize = 20
                } else if (CSP == "azure") {
                    sgName = "g2"
                    imageId = "Canonical:0001-com-ubuntu-server-jammy:22_04-lts:22.04.202505210"
                    specId = "azure+koreasouth+standard_b1s"
                    rootDiskType = "default"
                    rootDiskSize = "default"
                } else if (CSP == "gcp") {
                    sgName = "g3"
                    imageId = "https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20250712"
                    specId = "gcp+asia-northeast3+g1-small"
                    rootDiskType = "default"
                    rootDiskSize = "default"
                } else if (CSP == "ncp") {
                    sgName = "g4"
                    imageId = "23214590"
                    specId = "ncp+kr+c8-g3a"
                    rootDiskType = "default"
                    rootDiskSize = "default"
                } else if (CSP == "nhn") {
                    sgName = "g5"
                    imageId = "abc5d0a0-4001-4e5b-ac28-de341b2a0834"
                    specId = "nhn+kr1+r2.c4m16"
                    rootDiskType = "default"
                    rootDiskSize = "default"
                } else if (CSP == "alibaba") {
                    sgName = "g6"
                    imageId = "ubuntu_22_04_uefi_x64_20G_alibase_20240807.vhd"
                    specId = "alibaba+ap-northeast-2+ecs.t6-c1m4.xlarge"
                    rootDiskType = "default"
                    rootDiskSize = "default"
                } else if (CSP == "tencent") {
                    sgName = "g7"
                    imageId = "img-7rotv4ux"
                    specId = "tencent+ap-shanghai+m9.medium16"
                    rootDiskType = "default"
                    rootDiskSize = "30"
                } else if (CSP == "ibm") {
                    sgName = "g8"
                    imageId = "r034-76e0174f-fd2f-4c31-b95b-b859a403f85f"
                    specId = "ibm+jp-osa+cx2d-2x4"
                    rootDiskType = "default"
                    rootDiskSize = "default"
                } else {
                    error "Unsupported CSP: ${CSP}. Supported values are: aws, azure, gcp, ncp, nhn, alibaba, tencent, ibm"
                }

                def payload = JsonOutput.toJson([
                    name: "${MCI}",
                    nodeGroups: [
                        [
                            name: sgName,
                            specId: specId,
                            imageId: imageId,
                            rootDiskType: rootDiskType,
                            rootDiskSize: rootDiskSize
                        ]
                    ]
                ])

                def tb_vm_url = "${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/infraDynamic"
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
                def tb_vm_status_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/infra/${MCI}?option=status"""
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
}', NULL);

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script, run_date) VALUES (5, 'delete-mci', 'test', 1, '
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
          def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/infra/${MCI}?option=terminate"""
          sh(script: """curl -X DELETE --user ${USER}:${USERPASS} "${tb_vm_url}" -H ''accept: application/json'' """, returnStdout: true)
          echo "MCI Terminate successful."
        }
      }
    }
    stage(''Infrastructure MCI Running Status'') {
      steps {
        echo ''>>>>> STAGE: Infrastructure MCI Running Status''
        script {
          def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/infra/${MCI}?option=status"""
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
}', NULL);

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script, run_date) VALUES (6, 'k8s pre-installation tasks', 'test', 1, '
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
}', NULL);

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script, run_date) VALUES (7, 'create-k8s-cluster', 'test', 1, '
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
                            "name": "${CLUSTER}", \
                            "nodeGroupName": "k8sng01" \
                        }"""
                    } else if (CPS == "nhn") {
                        call_tumblebug_create_cluster_payload = """{ \
                            "imageId": "efe7f58f-5a32-4905-aa3b-e7839bd191d7", \
                            "specId": "nhn+kr1+m2.c4m8", \
                            "connectionName": "nhn-kr1", \
                            "name": "${CLUSTER}", \
                            "nodeGroupName": "k8sng02" \
                        }"""
                    } else if (CPS == "gcp") {
                        call_tumblebug_create_cluster_payload = """{ \
                            "imageId": "default", \
                            "specId": "gcp+asia-east1+e2-standard-4", \
                            "connectionName": "gcp-asia-east1", \
                            "name": "${CLUSTER}", \
                            "nodeGroupName": "k8sng03", \
                            "version": "1.33.5-gke.1125000" \
                        }"""
                    } else if (CPS == "aws") {
                        call_tumblebug_create_cluster_payload = """{ \
                            "imageId": "default", \
                            "specId": "aws+ap-northeast-2+t3a.xlarge", \
                            "connectionName": "aws-ap-northeast-2", \
                            "name": "${CLUSTER}", \
                            "nodeGroupName": "k8sng04" \
                        }"""
                    } else if (CPS == "ncp") {
                        call_tumblebug_create_cluster_payload = """{ \
                            "imageId": "default", \
                            "specId": "ncp+kr1+c4m8", \
                            "connectionName": "ncp-kr1", \
                            "name": "${CLUSTER}", \
                            "nodeGroupName": "k8sng05" \
                        }"""
                    } else if (CPS == "alibaba") {
                        call_tumblebug_create_cluster_payload = """{ \
                            "imageId": "aliyun_3_x64_20G_container_optimized_alibase_20250629.vhd", \
                            "specId": "alibaba+ap-southeast-1+ecs.t6-c1m4.2xlarge", \
                            "connectionName": "alibaba-ap-southeast-1", \
                            "name": "${CLUSTER}", \
                            "nodeGroupName": "k8sng06" \
                        }"""
                    } else if (CPS == "tencent") {
                        call_tumblebug_create_cluster_payload = """{ \
                            "imageId": "img-22trbn9x", \
                            "specId": "tencent+ap-seoul+s5.medium4", \
                            "connectionName": "tencent-ap-seoul", \
                            "name": "${CLUSTER}", \
                            "nodeGroupName": "k8sng07" \
                        }"""
                    } else {
                        error "Unsupported CPS: ${CPS}. Supported values are: azure, nhn, gcp, aws, ncp, alibaba, tencent"
                    }

                    def tumblebug_create_cluster_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_create_cluster_url} -H "Content-Type: application/json" -d ''${call_tumblebug_create_cluster_payload}'' --user ${USER}:${USERPASS}""", returnStdout: true).trim()

                    // Additional: When CPS is aws, create extra node group via k8sNodeGroupDynamic
                    if (CPS == "aws") {
                        def call_tumblebug_create_nodegroup_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}/k8sNodeGroupDynamic"""
                        def call_tumblebug_create_nodegroup_payload = """{ \
                            "imageId": "default", \
                            "specId": "aws+ap-northeast-2+t3a.xlarge", \
                            "name": "k8sng01" \
                        }"""
                        def tumblebug_create_nodegroup_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_create_nodegroup_url} -H "Content-Type: application/json" -d ''${call_tumblebug_create_nodegroup_payload}'' --user ${USER}:${USERPASS}""", returnStdout: true).trim()
                        if (tumblebug_create_nodegroup_response.indexOf(''Http_Status_code:200'') > 0 || tumblebug_create_nodegroup_response.indexOf(''Http_Status_code:201'') > 0) {
                            echo "Create nodeGroup >> k8sng01"
                        } else {
                            echo "k8sNodeGroupDynamic call response: ${tumblebug_create_nodegroup_response}"
                        }
                    }

                    // Additional: When CPS is tencent, create node group via k8sNodeGroupDynamic
                    if (CPS == "tencent") {
                        def call_tumblebug_create_nodegroup_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}/k8sNodeGroupDynamic"""
                        def call_tumblebug_create_nodegroup_payload = """{ \
                            "imageId": "img-22trbn9x", \
                            "specId": "tencent+ap-seoul+s5.medium4", \
                            "name": "k8sng07" \
                        }"""
                        def tumblebug_create_nodegroup_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_create_nodegroup_url} -H "Content-Type: application/json" -d ''${call_tumblebug_create_nodegroup_payload}'' --user ${USER}:${USERPASS}""", returnStdout: true).trim()
                        if (tumblebug_create_nodegroup_response.indexOf(''Http_Status_code:200'') > 0 || tumblebug_create_nodegroup_response.indexOf(''Http_Status_code:201'') > 0) {
                            echo "Create nodeGroup >> k8sng07"
                        } else {
                            echo "k8sNodeGroupDynamic call response: ${tumblebug_create_nodegroup_response}"
                        }
                    }

                    // Additional: When CPS is alibaba, create node group via k8sNodeGroupDynamic
                    if (CPS == "alibaba") {
                        def call_tumblebug_create_nodegroup_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}/k8sNodeGroupDynamic"""
                        def call_tumblebug_create_nodegroup_payload = """{ \
                            "imageId": "default", \
                            "specId": "alibaba+ap-southeast-1+ecs.t6-c1m4.2xlarge", \
                            "nodeGroupName": "k8sng06", \
                            "RootDiskType": "cloud_efficiency", \
                            "RootDiskSize": "40" \
                        }"""
                        def tumblebug_create_nodegroup_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_create_nodegroup_url} -H "Content-Type: application/json" -d ''${call_tumblebug_create_nodegroup_payload}'' --user ${USER}:${USERPASS}""", returnStdout: true).trim()
                        if (tumblebug_create_nodegroup_response.indexOf(''Http_Status_code:200'') > 0 || tumblebug_create_nodegroup_response.indexOf(''Http_Status_code:201'') > 0) {
                            echo "Create nodeGroup >> k8sng06"
                        } else {
                            echo "k8sNodeGroupDynamic call response: ${tumblebug_create_nodegroup_response}"
                        }
                    }

                    if (tumblebug_create_cluster_response.indexOf(''Http_Status_code:200'') > 0 || tumblebug_create_cluster_response.indexOf(''Http_Status_code:201'') > 0) {
                        echo """Create cluster >> ${CLUSTER}"""
                        def responseCode = tumblebug_create_cluster_response.indexOf(''Http_Status_code:200'') > 0 ? ''- Http_Status_code:200'' : ''- Http_Status_code:201''
                        tumblebug_create_cluster_response = tumblebug_create_cluster_response.replace(responseCode, '''')
                        echo JsonOutput.prettyPrint(tumblebug_create_cluster_response)
                        
                        // Wait for cluster to be Active before creating node group
                        echo "Waiting for cluster to be Active..."
                        def isActive = false
                        for (int attempt = 1; attempt <= 30; attempt++) {
                            def tb_vm_status_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}?option=status"""
                            def status_response = sh(script: """curl -w ''- Http_Status_code:%{http_code}'' ''${tb_vm_status_url}'' --user ''${USER}:${USERPASS}'' -H ''accept: application/json''""", returnStdout: true).trim()
                            if (status_response.indexOf(''Http_Status_code:200'') > 0 ) {
                                status_response = status_response.replace(''- Http_Status_code:200'', '''')
                                
                                if(status_response.contains(''Active'')) {
                                    echo "Cluster is Active!"
                                    isActive = true
                                    break
                                } else {
                                    echo "Cluster not yet Active. Waiting... (attempt ${attempt}/30)"
                                    sh ''sleep 60''
                                }
                            } else {
                                echo "Status check attempt ${attempt}/30 failed"
                                sh ''sleep 60''
                            }
                        }
                        
                        // Additional: When CPS is aws, create extra node group via k8sNodeGroupDynamic
                        if (CPS == "aws") {
                            def call_tumblebug_create_nodegroup_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}/k8sNodeGroupDynamic"""
                            def call_tumblebug_create_nodegroup_payload = """{ \
                                "imageId": "default", \
                                "specId": "aws+ap-northeast-2+t3a.xlarge", \
                                "name": "k8sng01" \
                            }"""
                            def tumblebug_create_nodegroup_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_create_nodegroup_url} -H "Content-Type: application/json" -d ''${call_tumblebug_create_nodegroup_payload}'' --user ${USER}:${USERPASS}""", returnStdout: true).trim()
                            if (tumblebug_create_nodegroup_response.indexOf(''Http_Status_code:200'') > 0 || tumblebug_create_nodegroup_response.indexOf(''Http_Status_code:201'') > 0) {
                                echo "Create nodeGroup >> k8sng01"
                            } else {
                                echo "k8sNodeGroupDynamic call response: ${tumblebug_create_nodegroup_response}"
                            }
                        }

                        // Additional: When CPS is tencent, create node group via k8sNodeGroupDynamic
                        if (CPS == "tencent") {
                            def call_tumblebug_create_nodegroup_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}/k8sNodeGroupDynamic"""
                            def call_tumblebug_create_nodegroup_payload = """{ \
                                "imageId": "img-22trbn9x", \
                                "specId": "tencent+ap-seoul+s5.medium4", \
                                "name": "k8sng07" \
                            }"""
                            def tumblebug_create_nodegroup_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_create_nodegroup_url} -H "Content-Type: application/json" -d ''${call_tumblebug_create_nodegroup_payload}'' --user ${USER}:${USERPASS}""", returnStdout: true).trim()
                            if (tumblebug_create_nodegroup_response.indexOf(''Http_Status_code:200'') > 0 || tumblebug_create_nodegroup_response.indexOf(''Http_Status_code:201'') > 0) {
                                echo "Create nodeGroup >> k8sng07"
                            } else {
                                echo "k8sNodeGroupDynamic call response: ${tumblebug_create_nodegroup_response}"
                            }
                        }

                        // Additional: When CPS is alibaba, create node group via k8sNodeGroupDynamic
                        if (CPS == "alibaba") {
                            def call_tumblebug_create_nodegroup_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}/k8sNodeGroupDynamic"""
                            def call_tumblebug_create_nodegroup_payload = """{ \
                                "imageId": "default", \
                                "specId": "alibaba+ap-southeast-1+ecs.t6-c1m4.2xlarge", \
                                "nodeGroupName": "k8sng06", \
                                "RootDiskType": "cloud_efficiency", \
                                "RootDiskSize": "40" \
                            }"""
                            def tumblebug_create_nodegroup_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_create_nodegroup_url} -H "Content-Type: application/json" -d ''${call_tumblebug_create_nodegroup_payload}'' --user ${USER}:${USERPASS}""", returnStdout: true).trim()
                            if (tumblebug_create_nodegroup_response.indexOf(''Http_Status_code:200'') > 0 || tumblebug_create_nodegroup_response.indexOf(''Http_Status_code:201'') > 0) {
                                echo "Create nodeGroup >> k8sng06"
                            } else {
                                echo "k8sNodeGroupDynamic call response: ${tumblebug_create_nodegroup_response}"
                            }
                        }
                        
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
}', NULL);

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script, run_date) VALUES (8, 'delete-k8s-cluster', 'test', 1, '
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
          if (response.indexOf(''Http_Status_code:404'') > 0 ) {
            echo "K8S Cluster is not found."
            response = response.replace(''- Http_Status_code:404'', '''')
            echo JsonOutput.prettyPrint(response)
          } else {
            error "K8S Cluster is exist."
          }
        }
      }
    }
  }
}', NULL);

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script, run_date) VALUES (9, 'mci-nginx-install', 'test', 1, '
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
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/tumblebug/ns/ns01/infra/${MCI}?option=accessinfo --user "default:default" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/infra/${MCI}?option=accessinfo&accessInfoOption=showSshKey"
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
}', NULL);
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script, run_date) VALUES (10, 'mci-mariadb-install', 'test', 1, '
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
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/infra/${MCI}?option=accessinfo --user "default:default" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/infra/${MCI}?option=accessinfo&accessInfoOption=showSshKey"
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
}', NULL);

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script, run_date) VALUES (11, 'k8s-nginx-install', 'test', 1, '
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
}', NULL);

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script, run_date) VALUES (12, 'k8s-mariadb-install', 'test', 1, '
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
}', NULL);


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
(6, 1, 'CSP', 'aws', 'N');
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
(24, 4, 'CSP', 'aws', 'N');

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
                    string(name: ''CSP'', value: CSP),
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
                    string(name: ''USERPASS'', value: USERPASS),
                    string(name: ''CPS'', value: CPS)
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
                // CSP에 따른 MCI 설정 선택
                def imageId, specId, rootDiskType, rootDiskSize, sgName

                if (CSP == "aws") {
                    sgName = "g1"
                    imageId = "ami-03236529070b4a0a5"
                    specId = "aws+ap-northeast-2+t2.small"
                    rootDiskType = "gp3"
                    rootDiskSize = 20
                } else if (CSP == "azure") {
                    sgName = "g2"
                    imageId = "Canonical:0001-com-ubuntu-server-jammy:22_04-lts:22.04.202505210"
                    specId = "azure+koreasouth+standard_b1s"
                    rootDiskType = "default"
                    rootDiskSize = "default"
                } else if (CSP == "gcp") {
                    sgName = "g3"
                    imageId = "https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20250712"
                    specId = "gcp+asia-northeast3+g1-small"
                    rootDiskType = "default"
                    rootDiskSize = "default"
                } else if (CSP == "ncp") {
                    sgName = "g4"
                    imageId = "23214590"
                    specId = "ncp+kr+c8-g3a"
                    rootDiskType = "default"
                    rootDiskSize = "default"
                } else if (CSP == "nhn") {
                    sgName = "g5"
                    imageId = "abc5d0a0-4001-4e5b-ac28-de341b2a0834"
                    specId = "nhn+kr1+r2.c4m16"
                    rootDiskType = "default"
                    rootDiskSize = "default"
                } else if (CSP == "alibaba") {
                    sgName = "g6"
                    imageId = "ubuntu_22_04_uefi_x64_20G_alibase_20240807.vhd"
                    specId = "alibaba+ap-northeast-2+ecs.t6-c1m4.xlarge"
                    rootDiskType = "default"
                    rootDiskSize = "default"
                } else if (CSP == "tencent") {
                    sgName = "g7"
                    imageId = "img-7rotv4ux"
                    specId = "tencent+ap-shanghai+m9.medium16"
                    rootDiskType = "default"
                    rootDiskSize = "30"
                } else if (CSP == "ibm") {
                    sgName = "g8"
                    imageId = "r034-76e0174f-fd2f-4c31-b95b-b859a403f85f"
                    specId = "ibm+jp-osa+cx2d-2x4"
                    rootDiskType = "default"
                    rootDiskSize = "default"
                } else {
                    error "Unsupported CSP: ${CSP}. Supported values are: aws, azure, gcp, ncp, nhn, alibaba, tencent, ibm"
                }

                def payload = JsonOutput.toJson([
                    name: "${MCI}",
                    nodeGroups: [
                        [
                            name: sgName,
                            specId: specId,
                            imageId: imageId,
                            rootDiskType: rootDiskType,
                            rootDiskSize: rootDiskSize
                        ]
                    ]
                ])

                def tb_vm_url = "${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/infraDynamic"
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
                def tb_vm_status_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/infra/${MCI}?option=status"""
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
          def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/infra/${MCI}?option=terminate"""
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
          def tb_vm_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/infra/${MCI}?option=status"""
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
                            "name": "${CLUSTER}", \
                            "nodeGroupName": "k8sng01" \
                        }"""
                    } else if (CPS == "nhn") {
                        call_tumblebug_create_cluster_payload = """{ \
                            "imageId": "efe7f58f-5a32-4905-aa3b-e7839bd191d7", \
                            "specId": "nhn+kr1+m2.c4m8", \
                            "connectionName": "nhn-kr1", \
                            "name": "${CLUSTER}", \
                            "nodeGroupName": "k8sng02" \
                        }"""
                    } else if (CPS == "gcp") {
                        call_tumblebug_create_cluster_payload = """{ \
                            "imageId": "default", \
                            "specId": "gcp+asia-east1+e2-standard-4", \
                            "connectionName": "gcp-asia-east1", \
                            "name": "${CLUSTER}", \
                            "nodeGroupName": "k8sng03", \
                            "version": "1.33.5-gke.1125000" \
                        }"""
                    } else if (CPS == "aws") {
                        call_tumblebug_create_cluster_payload = """{ \
                            "imageId": "default", \
                            "specId": "aws+ap-northeast-2+t3a.xlarge", \
                            "connectionName": "aws-ap-northeast-2", \
                            "name": "${CLUSTER}", \
                            "nodeGroupName": "k8sng04" \
                        }"""
                    } else if (CPS == "ncp") {
                        call_tumblebug_create_cluster_payload = """{ \
                            "imageId": "default", \
                            "specId": "ncp+kr1+c4m8", \
                            "connectionName": "ncp-kr1", \
                            "name": "${CLUSTER}", \
                            "nodeGroupName": "k8sng05" \
                        }"""
                    } else if (CPS == "alibaba") {
                        call_tumblebug_create_cluster_payload = """{ \
                            "imageId": "aliyun_3_x64_20G_container_optimized_alibase_20250629.vhd", \
                            "specId": "alibaba+ap-southeast-1+ecs.t6-c1m4.2xlarge", \
                            "connectionName": "alibaba-ap-southeast-1", \
                            "name": "${CLUSTER}", \
                            "nodeGroupName": "k8sng06" \
                        }"""
                    } else if (CPS == "tencent") {
                        call_tumblebug_create_cluster_payload = """{ \
                            "imageId": "img-22trbn9x", \
                            "specId": "tencent+ap-seoul+s5.medium4", \
                            "connectionName": "tencent-ap-seoul", \
                            "name": "${CLUSTER}", \
                            "nodeGroupName": "k8sng07" \
                        }"""
                    } else {
                        error "Unsupported CPS: ${CPS}. Supported values are: azure, nhn, gcp, aws, ncp, alibaba, tencent"
                    }

                    def tumblebug_create_cluster_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_create_cluster_url} -H "Content-Type: application/json" -d ''${call_tumblebug_create_cluster_payload}'' --user ${USER}:${USERPASS}""", returnStdout: true).trim()

                    // Additional: When CPS is aws, create extra node group via k8sNodeGroupDynamic
                    if (CPS == "aws") {
                        def call_tumblebug_create_nodegroup_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}/k8sNodeGroupDynamic"""
                        def call_tumblebug_create_nodegroup_payload = """{ \
                            "imageId": "default", \
                            "specId": "aws+ap-northeast-2+t3a.xlarge", \
                            "name": "k8sng01" \
                        }"""
                        def tumblebug_create_nodegroup_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_create_nodegroup_url} -H "Content-Type: application/json" -d ''${call_tumblebug_create_nodegroup_payload}'' --user ${USER}:${USERPASS}""", returnStdout: true).trim()
                        if (tumblebug_create_nodegroup_response.indexOf(''Http_Status_code:200'') > 0 || tumblebug_create_nodegroup_response.indexOf(''Http_Status_code:201'') > 0) {
                            echo "Create nodeGroup >> k8sng01"
                        } else {
                            echo "k8sNodeGroupDynamic call response: ${tumblebug_create_nodegroup_response}"
                        }
                    }

                    // Additional: When CPS is tencent, create node group via k8sNodeGroupDynamic
                    if (CPS == "tencent") {
                        def call_tumblebug_create_nodegroup_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}/k8sNodeGroupDynamic"""
                        def call_tumblebug_create_nodegroup_payload = """{ \
                            "imageId": "img-22trbn9x", \
                            "specId": "tencent+ap-seoul+s5.medium4", \
                            "name": "k8sng07" \
                        }"""
                        def tumblebug_create_nodegroup_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_create_nodegroup_url} -H "Content-Type: application/json" -d ''${call_tumblebug_create_nodegroup_payload}'' --user ${USER}:${USERPASS}""", returnStdout: true).trim()
                        if (tumblebug_create_nodegroup_response.indexOf(''Http_Status_code:200'') > 0 || tumblebug_create_nodegroup_response.indexOf(''Http_Status_code:201'') > 0) {
                            echo "Create nodeGroup >> k8sng07"
                        } else {
                            echo "k8sNodeGroupDynamic call response: ${tumblebug_create_nodegroup_response}"
                        }
                    }

                    // Additional: When CPS is alibaba, create node group via k8sNodeGroupDynamic
                    if (CPS == "alibaba") {
                        def call_tumblebug_create_nodegroup_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}/k8sNodeGroupDynamic"""
                        def call_tumblebug_create_nodegroup_payload = """{ \
                            "imageId": "default", \
                            "specId": "alibaba+ap-southeast-1+ecs.t6-c1m4.2xlarge", \
                            "nodeGroupName": "k8sng06", \
                            "RootDiskType": "cloud_efficiency", \
                            "RootDiskSize": "40" \
                        }"""
                        def tumblebug_create_nodegroup_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_create_nodegroup_url} -H "Content-Type: application/json" -d ''${call_tumblebug_create_nodegroup_payload}'' --user ${USER}:${USERPASS}""", returnStdout: true).trim()
                        if (tumblebug_create_nodegroup_response.indexOf(''Http_Status_code:200'') > 0 || tumblebug_create_nodegroup_response.indexOf(''Http_Status_code:201'') > 0) {
                            echo "Create nodeGroup >> k8sng06"
                        } else {
                            echo "k8sNodeGroupDynamic call response: ${tumblebug_create_nodegroup_response}"
                        }
                    }

                    if (tumblebug_create_cluster_response.indexOf(''Http_Status_code:200'') > 0 || tumblebug_create_cluster_response.indexOf(''Http_Status_code:201'') > 0) {
                        echo """Create cluster >> ${CLUSTER}"""
                        def responseCode = tumblebug_create_cluster_response.indexOf(''Http_Status_code:200'') > 0 ? ''- Http_Status_code:200'' : ''- Http_Status_code:201''
                        tumblebug_create_cluster_response = tumblebug_create_cluster_response.replace(responseCode, '''')
                        echo JsonOutput.prettyPrint(tumblebug_create_cluster_response)
                        
                        // Wait for cluster to be Active before creating node group
                        echo "Waiting for cluster to be Active..."
                        def isActive = false
                        for (int attempt = 1; attempt <= 30; attempt++) {
                            def tb_vm_status_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}?option=status"""
                            def status_response = sh(script: """curl -w ''- Http_Status_code:%{http_code}'' ''${tb_vm_status_url}'' --user ''${USER}:${USERPASS}'' -H ''accept: application/json''""", returnStdout: true).trim()
                            if (status_response.indexOf(''Http_Status_code:200'') > 0 ) {
                                status_response = status_response.replace(''- Http_Status_code:200'', '''')
                                
                                if(status_response.contains(''Active'')) {
                                    echo "Cluster is Active!"
                                    isActive = true
                                    break
                                } else {
                                    echo "Cluster not yet Active. Waiting... (attempt ${attempt}/30)"
                                    sh ''sleep 60''
                                }
                            } else {
                                echo "Status check attempt ${attempt}/30 failed"
                                sh ''sleep 60''
                            }
                        }
                        
                        // Additional: When CPS is aws, create extra node group via k8sNodeGroupDynamic
                        if (CPS == "aws") {
                            def call_tumblebug_create_nodegroup_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}/k8sNodeGroupDynamic"""
                            def call_tumblebug_create_nodegroup_payload = """{ \
                                "imageId": "default", \
                                "specId": "aws+ap-northeast-2+t3a.xlarge", \
                                "name": "k8sng01" \
                            }"""
                            def tumblebug_create_nodegroup_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_create_nodegroup_url} -H "Content-Type: application/json" -d ''${call_tumblebug_create_nodegroup_payload}'' --user ${USER}:${USERPASS}""", returnStdout: true).trim()
                            if (tumblebug_create_nodegroup_response.indexOf(''Http_Status_code:200'') > 0 || tumblebug_create_nodegroup_response.indexOf(''Http_Status_code:201'') > 0) {
                                echo "Create nodeGroup >> k8sng01"
                            } else {
                                echo "k8sNodeGroupDynamic call response: ${tumblebug_create_nodegroup_response}"
                            }
                        }

                        // Additional: When CPS is tencent, create node group via k8sNodeGroupDynamic
                        if (CPS == "tencent") {
                            def call_tumblebug_create_nodegroup_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}/k8sNodeGroupDynamic"""
                            def call_tumblebug_create_nodegroup_payload = """{ \
                                "imageId": "img-22trbn9x", \
                                "specId": "tencent+ap-seoul+s5.medium4", \
                                "name": "k8sng07" \
                            }"""
                            def tumblebug_create_nodegroup_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_create_nodegroup_url} -H "Content-Type: application/json" -d ''${call_tumblebug_create_nodegroup_payload}'' --user ${USER}:${USERPASS}""", returnStdout: true).trim()
                            if (tumblebug_create_nodegroup_response.indexOf(''Http_Status_code:200'') > 0 || tumblebug_create_nodegroup_response.indexOf(''Http_Status_code:201'') > 0) {
                                echo "Create nodeGroup >> k8sng07"
                            } else {
                                echo "k8sNodeGroupDynamic call response: ${tumblebug_create_nodegroup_response}"
                            }
                        }

                        // Additional: When CPS is alibaba, create node group via k8sNodeGroupDynamic
                        if (CPS == "alibaba") {
                            def call_tumblebug_create_nodegroup_url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/k8sCluster/${CLUSTER}/k8sNodeGroupDynamic"""
                            def call_tumblebug_create_nodegroup_payload = """{ \
                                "imageId": "default", \
                                "specId": "alibaba+ap-southeast-1+ecs.t6-c1m4.2xlarge", \
                                "nodeGroupName": "k8sng06", \
                                "RootDiskType": "cloud_efficiency", \
                                "RootDiskSize": "40" \
                            }"""
                            def tumblebug_create_nodegroup_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_create_nodegroup_url} -H "Content-Type: application/json" -d ''${call_tumblebug_create_nodegroup_payload}'' --user ${USER}:${USERPASS}""", returnStdout: true).trim()
                            if (tumblebug_create_nodegroup_response.indexOf(''Http_Status_code:200'') > 0 || tumblebug_create_nodegroup_response.indexOf(''Http_Status_code:201'') > 0) {
                                echo "Create nodeGroup >> k8sng06"
                            } else {
                                echo "k8sNodeGroupDynamic call response: ${tumblebug_create_nodegroup_response}"
                            }
                        }
                        
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
          if (response.indexOf(''Http_Status_code:404'') > 0 ) {
            echo "K8S Cluster is not found."
            response = response.replace(''- Http_Status_code:404'', '''')
            echo JsonOutput.prettyPrint(response)
          } else {
            error "K8S Cluster is exist."
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
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/tumblebug/ns/ns01/infra/${MCI}?option=accessinfo --user "default:default" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/infra/${MCI}?option=accessinfo&accessInfoOption=showSshKey"
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
                    def response = sh(script: """curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/infra/${MCI}?option=accessinfo --user "default:default" """, returnStdout: true).trim()
                    if (response.contains(''Http_Status_code:200'')) {
                        echo "GET API call successful."
                        callData = response.replace(''- Http_Status_code:200'', '''')
                        echo(callData)
                    } else {
                        error "GET API call failed with status code: ${response}"
                    }

                    def tb_sw_url = "${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/infra/${MCI}?option=accessinfo&accessInfoOption=showSshKey"
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

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- New Workflow : clean ns
INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script, run_date) VALUES (13, 'clean ns', 'test', 1, '
pipeline {
  agent any
  stages {
    stage (''delete securityGroup'') {
      steps {
        script {
          def url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/resources/securityGroup"""
          def call = """curl -X DELETE ${url} --user "${USER}:${USERPASS}""""
          sh(script: """ ${call} """, returnStdout: true)
        }
      }
    }
    stage (''delete sshKey'') {
      steps {
        script {
          def url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/resources/sshKey"""
          def call = """curl -X DELETE ${url} --user "${USER}:${USERPASS}""""
          sh(script: """ ${call} """, returnStdout: true)
        }
      }
    }
    stage (''delete vNet'') {
      steps {
        script {
          def url = """${TUMBLEBUG}/tumblebug/ns/${NAMESPACE}/resources/vNet"""
          def call = """curl -X DELETE ${url} --user "${USER}:${USERPASS}""""
          sh(script: """ ${call} """, returnStdout: true)
        }
      }
    }
  }
}', NULL);

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Workflow : clean ns params
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES
(81, 13, 'NAMESPACE', 'ns01', 'N'),
(82, 13, 'TUMBLEBUG', 'http://localhost:1323', 'N'),
(83, 13, 'USER', 'default', 'N'),
(84, 13, 'USERPASS', 'default', 'N');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
