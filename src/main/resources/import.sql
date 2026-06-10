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
-- category: infra, k8s, app, database, utility
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES
(17, 'infra', '인프라'),
(18, 'k8s', '인프라 - K8s'),
(19, 'app', '앱 배포'),
(20, 'database', '데이터 - Backup / Restore'),
(21, 'utility', '공통 / 유틸');

INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (17, 17, 1, 'infra-create', 'INFRA 생성 (CSP별 spec 기반)', '
    stage("infra-create") {
        steps {
            echo ">>>>> STAGE: infra-create"
            script {
                def payload = params.INFRA_CREATE_PAYLOAD?.trim()
                if (!payload) {
                    def specId = params.SPEC_ID ?: params.SPEC
                    def imageId = params.IMAGE_ID ?: params.IMAGE
                    def provider = params.CSP ?: params.PROVIDER ?: ""
                    def region = params.REGION ?: ""
                    def connectionName = params.CONNECTION_NAME ?: params.CONNECTION_CONFIG_NAME ?: (provider && region ? "${provider}-${region}" : "")
                    def nodeGroup = [
                        name: params.INFRA_NODEGROUP_NAME ?: "g1",
                        nodeGroupSize: (params.INFRA_NODEGROUP_SIZE ?: "1").toInteger(),
                        specId: specId,
                        imageId: imageId,
                        rootDiskType: params.ROOT_DISK_TYPE ?: "default",
                        rootDiskSize: (params.ROOT_DISK_SIZE ?: "50").toInteger()
                    ]
                    if (connectionName) {
                        nodeGroup.connectionName = connectionName
                    }
                    if (params.ZONE) {
                        nodeGroup.zone = params.ZONE
                    }
                    payload = JsonOutput.toJson([
                        name: params.INFRA_ID,
                        description: params.INFRA_DESC ?: "Workflow created infra",
                        installMonAgent: params.INSTALL_MON_AGENT ?: "no",
                        policyOnPartialFailure: params.POLICY_ON_PARTIAL_FAILURE ?: "continue",
                        label: [
                            provider: provider,
                            region: region
                        ],
                        nodeGroups: [nodeGroup]
                    ])
                }
                writeFile file: "infra-create.json", text: payload
                def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X POST "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/infraDynamic" -H "Content-Type: application/json" -d @infra-create.json ${auth}""", returnStdout: true).trim()
                echo response
                if (!response.contains("Http_Status_code:2")) {
                    error "infra-create failed: ${response}"
                }
                def body = response.replaceAll("- Http_Status_code:[0-9]{3}", "").trim()
                writeFile file: "infra-create-response.json", text: body

                def accessInfoResponse = ""
                def accessInfoAttempts = (params.INFRA_ACCESS_INFO_MAX_ATTEMPTS ?: "30").toInteger()
                def accessInfoIntervalSeconds = (params.INFRA_ACCESS_INFO_INTERVAL_SECONDS ?: "10").toInteger()
                for (int attempt = 1; attempt <= accessInfoAttempts; attempt++) {
                    accessInfoResponse = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/infra/${params.INFRA_ID}?option=accessinfo&accessInfoOption=showSshKey" ${auth}""", returnStdout: true).trim()
                    if (accessInfoResponse.contains("Http_Status_code:2")) {
                        break
                    }
                    echo "infra accessInfo is not ready. attempt ${attempt}/${accessInfoAttempts}: ${accessInfoResponse}"
                    sleep time: accessInfoIntervalSeconds, unit: "SECONDS"
                }
                if (!accessInfoResponse.contains("Http_Status_code:2")) {
                    error "infra accessInfo lookup failed: ${accessInfoResponse}"
                }

                def accessInfoBody = accessInfoResponse.replaceAll("- Http_Status_code:[0-9]{3}", "").trim()
                writeFile file: "infra-access-info.json", text: accessInfoBody
                def accessInfo = new groovy.json.JsonSlurper().parseText(accessInfoBody)
                def accessNodes = []
                def resolvedPrivateKey = ""
                def collectAccessInfo
                collectAccessInfo = { value ->
                    if (value instanceof Map) {
                        if (!resolvedPrivateKey && value.privateKey) {
                            resolvedPrivateKey = value.privateKey.toString()
                        }
                        if (value.publicIP || value.publicIp || value.privateIP || value.privateIp || value.host) {
                            accessNodes << value
                        }
                        value.values().each { collectAccessInfo(it) }
                    } else if (value instanceof List) {
                        value.each { collectAccessInfo(it) }
                    }
                }
                collectAccessInfo(accessInfo)

                def firstNode = accessNodes.find { it.publicIP || it.publicIp || it.privateIP || it.privateIp || it.host }
                if (!firstNode) {
                    error "No VM access host was found in infra accessInfo"
                }
                def resolvedSshHost = (firstNode.publicIP ?: firstNode.publicIp ?: firstNode.privateIP ?: firstNode.privateIp ?: firstNode.host).toString()
                def resolvedSshUser = (firstNode.nodeUserName ?: firstNode.userName ?: firstNode.sshUser ?: params.SSH_USER ?: "cb-user").toString()
                accessInfo = null
                accessNodes = null
                firstNode = null
                collectAccessInfo = null

                env.SSH_HOST = resolvedSshHost
                env.DB_HOST = env.SSH_HOST
                env.SSH_USER = resolvedSshUser
                if (resolvedPrivateKey) {
                    def pemName = params.INFRA_ID ?: "infra"
                    env.SSH_KEY_FILE = "${pemName}.pem"
                    writeFile file: env.SSH_KEY_FILE, text: resolvedPrivateKey
                    sh """chmod 600 "${env.SSH_KEY_FILE}" """
                }
                echo "Resolved infra access host. SSH_HOST=${env.SSH_HOST}, SSH_USER=${env.SSH_USER}, SSH_KEY_FILE=${env.SSH_KEY_FILE ?: ""}"
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
                def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/infra/${params.INFRA_ID}?option=accessinfo" ${auth}""", returnStdout: true).trim()
                echo response
                if (!response.contains("Http_Status_code:2")) {
                    error "infra accessInfo lookup failed: ${response}"
                }
                def sshHost = env.SSH_HOST ?: params.SSH_HOST
                def sshUser = env.SSH_USER ?: params.SSH_USER
                def sshKeyFile = env.SSH_KEY_FILE ?: params.SSH_KEY_FILE

                if (!sshHost || !sshUser) {
                    def body = response.replaceAll("- Http_Status_code:[0-9]{3}", "").trim()
                    def accessInfo = new groovy.json.JsonSlurper().parseText(body)
                    def accessNodes = []
                    def resolvedPrivateKey = ""
                    def collectAccessInfo
                    collectAccessInfo = { value ->
                        if (value instanceof Map) {
                            if (!resolvedPrivateKey && value.privateKey) {
                                resolvedPrivateKey = value.privateKey.toString()
                            }
                            if (value.publicIP || value.publicIp || value.privateIP || value.privateIp || value.host) {
                                accessNodes << value
                            }
                            value.values().each { collectAccessInfo(it) }
                        } else if (value instanceof List) {
                            value.each { collectAccessInfo(it) }
                        }
                    }
                    collectAccessInfo(accessInfo)

                    def firstNode = accessNodes.find { it.publicIP || it.publicIp || it.privateIP || it.privateIp || it.host }
                    def resolvedSshHost = ""
                    def resolvedSshUser = ""
                    if (firstNode) {
                        resolvedSshHost = (firstNode.publicIP ?: firstNode.publicIp ?: firstNode.privateIP ?: firstNode.privateIp ?: firstNode.host).toString()
                        resolvedSshUser = (firstNode.nodeUserName ?: firstNode.userName ?: firstNode.sshUser ?: params.SSH_USER ?: "cb-user").toString()
                    }
                    accessInfo = null
                    accessNodes = null
                    firstNode = null
                    collectAccessInfo = null

                    if (resolvedSshHost) {
                        sshHost = resolvedSshHost
                        sshUser = resolvedSshUser
                        env.SSH_HOST = sshHost
                        env.DB_HOST = sshHost
                        env.SSH_USER = sshUser
                    }

                    if (resolvedPrivateKey && !sshKeyFile) {
                        def pemName = params.INFRA_ID ?: "infra"
                        sshKeyFile = "${pemName}.pem"
                        writeFile file: sshKeyFile, text: resolvedPrivateKey
                        sh """chmod 600 "${sshKeyFile}" """
                        env.SSH_KEY_FILE = sshKeyFile
                    }
                }

                if (sshHost && sshUser) {
                    def keyOpt = sshKeyFile ? "-i \"${sshKeyFile}\"" : ""
                    sh """ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=10 ${keyOpt} "${sshUser}@${sshHost}" "echo ssh-ok" """
                } else {
                    error "SSH_HOST and SSH_USER are required for infra-ssh-connect-check"
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (50, 17, 10, 'multi-csp-vm-deploy', '9종 CSP 대상 INFRA(VM) 배포', '
    stage("multi-csp-vm-deploy") {
        steps {
            echo ">>>>> STAGE: multi-csp-vm-deploy"
            script {
                def cspList = (params.CSP_LIST ?: "").split(",").collect { it.trim() }.findAll { it }
                if (cspList.isEmpty()) {
                    error "CSP_LIST is required"
                }

                def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                cspList.each { csp ->
                    def key = csp.toUpperCase().replaceAll("[^A-Z0-9]", "_")
                    def infraId = (params.INFRA_PREFIX ?: "multi-csp-vm") + "-" + csp
                    def specId = params["${key}_SPEC_ID"]
                    def imageId = params["${key}_IMAGE_ID"]
                    def region = params["${key}_REGION"] ?: params.REGION ?: ""
                    def connectionName = params["${key}_CONNECTION_NAME"] ?: params.CONNECTION_NAME ?: (region ? "${csp}-${region}" : "")
                    def zone = params["${key}_ZONE"] ?: params.ZONE ?: ""
                    if (!specId || !imageId) {
                        error "${key}_SPEC_ID and ${key}_IMAGE_ID are required for ${csp}"
                    }

                    def nodeGroup = [
                        name: params.INFRA_NODEGROUP_NAME ?: "g1",
                        nodeGroupSize: (params.INFRA_NODEGROUP_SIZE ?: "1").toInteger(),
                        specId: specId,
                        imageId: imageId,
                        rootDiskType: params.ROOT_DISK_TYPE ?: "default",
                        rootDiskSize: (params.ROOT_DISK_SIZE ?: "50").toInteger()
                    ]
                    if (connectionName) {
                        nodeGroup.connectionName = connectionName
                    }
                    if (zone) {
                        nodeGroup.zone = zone
                    }

                    def payload = JsonOutput.toJson([
                        name: infraId,
                        description: "Workflow multi CSP VM deploy - ${csp}",
                        installMonAgent: params.INSTALL_MON_AGENT ?: "no",
                        policyOnPartialFailure: params.POLICY_ON_PARTIAL_FAILURE ?: "continue",
                        label: [
                            csp: csp,
                            region: region
                        ],
                        nodeGroups: [nodeGroup]
                    ])

                    writeFile file: "infra-create-${csp}.json", text: payload
                    def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X POST "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/infraDynamic" -H "Content-Type: application/json" -d @infra-create-${csp}.json ${auth}""", returnStdout: true).trim()
                    echo response
                    if (!response.contains("Http_Status_code:2")) {
                        error "multi-csp-vm-deploy failed for ${csp}: ${response}"
                    }
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (52, 17, 11, 'multi-csp-vm-delete', 'multi-csp-vm-deploy로 생성된 INFRA(VM) 일괄 삭제', '
    stage("multi-csp-vm-delete") {
        steps {
            echo ">>>>> STAGE: multi-csp-vm-delete"
            script {
                if (!params.TUMBLEBUG?.trim()) {
                    error "TUMBLEBUG is required"
                }
                if (!params.NAMESPACE?.trim()) {
                    error "NAMESPACE is required"
                }

                def explicitInfraIds = (params.INFRA_ID_LIST ?: "").split(",").collect { it.trim() }.findAll { it }
                def cspList = (params.CSP_LIST ?: "").split(",").collect { it.trim() }.findAll { it }
                def targetInfraIds = []

                if (!explicitInfraIds.isEmpty()) {
                    explicitInfraIds.each { infraId ->
                        if (!targetInfraIds.contains(infraId)) {
                            targetInfraIds << infraId
                        }
                    }
                } else {
                    if (cspList.isEmpty()) {
                        error "CSP_LIST or INFRA_ID_LIST is required"
                    }

                    def infraPrefix = params.INFRA_PREFIX ?: "multi-csp-vm"
                    cspList.each { csp ->
                        def infraId = "${infraPrefix}-${csp}"
                        if (!targetInfraIds.contains(infraId)) {
                            targetInfraIds << infraId
                        }
                    }
                }

                def option = params.INFRA_DELETE_OPTION ?: "terminate"
                def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                def deletedInfra = []
                def skippedInfra = []
                def failedDeletes = []

                targetInfraIds.each { infraId ->
                    echo "Deleting infra ${infraId}"
                    def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X DELETE "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/infra/${infraId}?option=${option}" ${auth}""", returnStdout: true).trim()
                    echo response

                    if (response.contains("Http_Status_code:404")) {
                        skippedInfra << infraId
                        echo "Infra ${infraId} is already absent. Skip."
                    } else if (response.contains("Http_Status_code:2")) {
                        deletedInfra << infraId
                        echo "Infra ${infraId} delete requested."
                    } else {
                        failedDeletes << "${infraId}: ${response}"
                        echo "Infra ${infraId} delete failed, continuing cleanup."
                    }
                }

                echo "Deleted infra: ${deletedInfra.join(", ")}"
                echo "Skipped absent infra: ${skippedInfra.join(", ")}"
                if (!failedDeletes.isEmpty()) {
                    error "multi-csp-vm-delete completed with failures: ${failedDeletes.join(" | ")}"
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
                    def provider = params.CSP ?: params.PROVIDER ?: ""
                    def region = params.REGION ?: ""
                    def connectionName = params.CONNECTION_NAME ?: params.CONNECTION_CONFIG_NAME ?: (provider && region ? "${provider}-${region}" : "")
                    def payloadMap = [
                        name: params.K8S_CLUSTER_ID,
                        nodeGroupName: params.K8S_NODEGROUP_NAME ?: "ng1",
                        specId: params.SPEC_ID,
                        imageId: params.IMAGE_ID,
                        label: [
                            provider: provider,
                            region: region
                        ],
                        version: params.K8S_VERSION ?: "",
                        desiredNodeSize: (params.K8S_DESIRED_NODE_SIZE ?: "1").toInteger(),
                        minNodeSize: (params.K8S_MIN_NODE_SIZE ?: "1").toInteger(),
                        maxNodeSize: (params.K8S_MAX_NODE_SIZE ?: "3").toInteger(),
                        rootDiskType: params.ROOT_DISK_TYPE ?: "default",
                        rootDiskSize: (params.ROOT_DISK_SIZE ?: "30").toInteger()
                    ]
                    if (connectionName) {
                        payloadMap.connectionName = connectionName
                    }
                    payload = JsonOutput.toJson(payloadMap)
                }
                writeFile file: "k8s-cluster-create.json", text: payload
                def option = params.K8S_CREATE_OPTION ? "?option=${params.K8S_CREATE_OPTION}" : ""
                def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X POST "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/k8sClusterDynamic${option}" -H "Content-Type: application/json" -d @k8s-cluster-create.json ${auth}""", returnStdout: true).trim()
                echo response
                if (!response.contains("Http_Status_code:2")) {
                    error "k8s-cluster-create failed: ${response}"
                }
                def readyStatuses = (params.K8S_READY_STATUS ?: "Active,Running").split(",").collect { it.trim().toLowerCase() }.findAll { it }
                def statusAttempts = (params.K8S_STATUS_MAX_ATTEMPTS ?: "60").toInteger()
                def statusIntervalSeconds = (params.K8S_STATUS_INTERVAL_SECONDS ?: "10").toInteger()
                def statusResponse = ""
                for (int attempt = 1; attempt <= statusAttempts; attempt++) {
                    statusResponse = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/k8sCluster/${params.K8S_CLUSTER_ID}?option=status" ${auth}""", returnStdout: true).trim()
                    def normalizedStatusResponse = statusResponse.toLowerCase()
                    if (statusResponse.contains("Http_Status_code:2") && readyStatuses.any { normalizedStatusResponse.contains(it) }) {
                        break
                    }
                    echo "k8s cluster is not ready. attempt ${attempt}/${statusAttempts}: ${statusResponse}"
                    sleep time: statusIntervalSeconds, unit: "SECONDS"
                }
                def normalizedFinalStatusResponse = statusResponse.toLowerCase()
                if (!statusResponse.contains("Http_Status_code:2") || !readyStatuses.any { normalizedFinalStatusResponse.contains(it) }) {
                    error "k8s-cluster-create status check failed: ${statusResponse}"
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
                def method = params.K8S_UPDATE_METHOD ?: "PUT"
                def path = params.K8S_UPDATE_PATH ?: "/tumblebug/ns/${params.NAMESPACE}/k8sCluster/${params.K8S_CLUSTER_ID}/upgrade?skipVersionCheck=${skipVersionCheck}"
                def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X "${method}" "${params.TUMBLEBUG}${path}" -H "Content-Type: application/json" -d @k8s-cluster-update.json ${auth}""", returnStdout: true).trim()
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
                def response = ""
                def kubeconfigAttempts = (params.K8S_KUBECONFIG_MAX_ATTEMPTS ?: "30").toInteger()
                def kubeconfigIntervalSeconds = (params.K8S_KUBECONFIG_INTERVAL_SECONDS ?: "10").toInteger()
                for (int attempt = 1; attempt <= kubeconfigAttempts; attempt++) {
                    response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/k8sCluster/${params.K8S_CLUSTER_ID}/kubeconfig" ${auth}""", returnStdout: true).trim()
                    if (response.contains("Http_Status_code:2")) {
                        break
                    }
                    echo "kubeconfig is not ready. attempt ${attempt}/${kubeconfigAttempts}: ${response}"
                    sleep time: kubeconfigIntervalSeconds, unit: "SECONDS"
                }
                echo response
                if (!response.contains("Http_Status_code:2")) {
                    error "k8s-kubeconfig-get failed: ${response}"
                }
                def body = response.replaceAll("- Http_Status_code:[0-9]{3}", "").trim()
                writeFile file: "kubeconfig-response.json", text: body
                def kubeconfig = null
                if (body.contains("apiVersion") && body.contains("clusters:")) {
                    kubeconfig = body
                } else {
                    def parsed = new groovy.json.JsonSlurper().parseText(body)
                    def findKubeconfig
                    findKubeconfig = { value ->
                        if (value instanceof Map) {
                            def direct = value.Kubeconfig ?: value.kubeconfig ?: value.config
                            if (direct) {
                                return direct.toString()
                            }
                            for (def child : value.values()) {
                                def found = findKubeconfig(child)
                                if (found) {
                                    return found
                                }
                            }
                        } else if (value instanceof List) {
                            for (def child : value) {
                                def found = findKubeconfig(child)
                                if (found) {
                                    return found
                                }
                            }
                        } else if (value instanceof String && value.contains("apiVersion") && value.contains("clusters:")) {
                            return value
                        }
                        return null
                    }
                    def resolvedKubeconfig = findKubeconfig(parsed)
                    parsed = null
                    findKubeconfig = null
                    kubeconfig = resolvedKubeconfig
                }
                if (!kubeconfig) {
                    error "kubeconfig content was not found in response"
                }
                writeFile file: "kubeconfig", text: kubeconfig
                env.KUBECONFIG_FILE = "kubeconfig"
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (51, 18, 9, 'multi-csp-k8s-cluster-deploy', '6종 CSP 대상 K8s Cluster 배포', '
    stage("multi-csp-k8s-cluster-deploy") {
        steps {
            echo ">>>>> STAGE: multi-csp-k8s-cluster-deploy"
            script {
                def cspList = (params.CSP_LIST ?: "").split(",").collect { it.trim() }.findAll { it }
                if (cspList.isEmpty()) {
                    error "CSP_LIST is required"
                }

                def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                cspList.each { csp ->
                    def key = csp.toUpperCase().replaceAll("[^A-Z0-9]", "_")
                    def clusterId = (params.CLUSTER_PREFIX ?: "multi-csp-k8s") + "-" + csp
                    def nodeGroupName = (params.K8S_NODEGROUP_PREFIX ?: "ng") + "-" + csp
                    def specId = params["${key}_SPEC_ID"] ?: params.SPEC_ID
                    def imageId = params["${key}_IMAGE_ID"] ?: params.IMAGE_ID
                    def region = params["${key}_REGION"] ?: params.REGION ?: ""
                    def connectionName = params["${key}_CONNECTION_NAME"] ?: params.CONNECTION_NAME ?: (region ? "${csp}-${region}" : "")
                    if (!specId || !imageId) {
                        error "SPEC_ID and IMAGE_ID are required for ${csp}"
                    }

                    def payloadMap = [
                        name: clusterId,
                        nodeGroupName: nodeGroupName,
                        specId: specId,
                        imageId: imageId,
                        label: [
                            csp: csp,
                            region: region
                        ],
                        version: params.K8S_VERSION ?: "",
                        desiredNodeSize: (params.K8S_DESIRED_NODE_SIZE ?: "1").toInteger(),
                        minNodeSize: (params.K8S_MIN_NODE_SIZE ?: "1").toInteger(),
                        maxNodeSize: (params.K8S_MAX_NODE_SIZE ?: "3").toInteger(),
                        rootDiskType: params.ROOT_DISK_TYPE ?: "default",
                        rootDiskSize: (params.ROOT_DISK_SIZE ?: "30").toInteger()
                    ]
                    if (connectionName) {
                        payloadMap.connectionName = connectionName
                    }

                    def payload = JsonOutput.toJson(payloadMap)

                    writeFile file: "k8s-cluster-create-${csp}.json", text: payload
                    def option = params.K8S_CREATE_OPTION ? "?option=${params.K8S_CREATE_OPTION}" : ""
                    def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X POST "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/k8sClusterDynamic${option}" -H "Content-Type: application/json" -d @k8s-cluster-create-${csp}.json ${auth}""", returnStdout: true).trim()
                    echo response
                    if (!response.contains("Http_Status_code:2")) {
                        error "multi-csp-k8s-cluster-deploy failed for ${csp}: ${response}"
                    }
                    def readyStatuses = (params.K8S_READY_STATUS ?: "Active,Running").split(",").collect { it.trim().toLowerCase() }.findAll { it }
                    def statusAttempts = (params.K8S_STATUS_MAX_ATTEMPTS ?: "60").toInteger()
                    def statusIntervalSeconds = (params.K8S_STATUS_INTERVAL_SECONDS ?: "10").toInteger()
                    def statusResponse = ""
                    for (int attempt = 1; attempt <= statusAttempts; attempt++) {
                        statusResponse = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/k8sCluster/${clusterId}?option=status" ${auth}""", returnStdout: true).trim()
                        def normalizedStatusResponse = statusResponse.toLowerCase()
                        if (statusResponse.contains("Http_Status_code:2") && readyStatuses.any { normalizedStatusResponse.contains(it) }) {
                            break
                        }
                        echo "k8s cluster ${clusterId} is not ready. attempt ${attempt}/${statusAttempts}: ${statusResponse}"
                        sleep time: statusIntervalSeconds, unit: "SECONDS"
                    }
                    def normalizedFinalStatusResponse = statusResponse.toLowerCase()
                    if (!statusResponse.contains("Http_Status_code:2") || !readyStatuses.any { normalizedFinalStatusResponse.contains(it) }) {
                        error "multi-csp-k8s-cluster-deploy status check failed for ${csp}: ${statusResponse}"
                    }
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (34, 19, 1, 'app-deploy-helm', 'Helm chart 기반 앱 배포', '
    stage("app-deploy-helm") {
        steps {
            echo ">>>>> STAGE: app-deploy-helm"
            script {
                def kubeconfigFile = env.KUBECONFIG_FILE ?: "kubeconfig"
                if (params.KUBECONFIG_CONTENT?.trim()) {
                    writeFile file: kubeconfigFile, text: params.KUBECONFIG_CONTENT
                }
                if (!fileExists(kubeconfigFile)) {
                    error "KUBECONFIG_CONTENT is required or run k8s-kubeconfig-get before app-deploy-helm"
                }
                def namespace = params.KUBE_NAMESPACE ?: "default"
                def valuesArgs = params.HELM_VALUES_ARGS ?: ""
                sh """helm upgrade --install "${params.RELEASE_NAME}" "${params.HELM_CHART}" --namespace "${namespace}" --create-namespace --kubeconfig "${kubeconfigFile}" ${valuesArgs}"""
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (35, 19, 2, 'app-deploy-manifest', 'K8s manifest 기반 앱 배포', '
    stage("app-deploy-manifest") {
        steps {
            echo ">>>>> STAGE: app-deploy-manifest"
            script {
                def kubeconfigFile = env.KUBECONFIG_FILE ?: "kubeconfig"
                if (params.KUBECONFIG_CONTENT?.trim()) {
                    writeFile file: kubeconfigFile, text: params.KUBECONFIG_CONTENT
                }
                if (!fileExists(kubeconfigFile)) {
                    error "KUBECONFIG_CONTENT is required or run k8s-kubeconfig-get before app-deploy-manifest"
                }
                writeFile file: "manifest.yaml", text: params.K8S_MANIFEST ?: ""
                def namespace = params.KUBE_NAMESPACE ?: "default"
                sh """kubectl apply -f manifest.yaml --namespace "${namespace}" --kubeconfig "${kubeconfigFile}" """
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (36, 19, 3, 'app-deploy-status-check', '배포 상태 확인 (pod/deployment ready)', '
    stage("app-deploy-status-check") {
        steps {
            echo ">>>>> STAGE: app-deploy-status-check"
            script {
                def kubeconfigFile = env.KUBECONFIG_FILE ?: "kubeconfig"
                if (params.KUBECONFIG_CONTENT?.trim()) {
                    writeFile file: kubeconfigFile, text: params.KUBECONFIG_CONTENT
                }
                if (!fileExists(kubeconfigFile)) {
                    error "KUBECONFIG_CONTENT is required or run k8s-kubeconfig-get before app-deploy-status-check"
                }
                def namespace = params.KUBE_NAMESPACE ?: "default"
                def deployment = params.DEPLOYMENT_NAME
                if (deployment) {
                    sh """kubectl rollout status deployment/${deployment} --namespace "${namespace}" --kubeconfig "${kubeconfigFile}" --timeout="${params.ROLLOUT_TIMEOUT ?: "300s"}" """
                } else {
                    sh """kubectl get pods --namespace "${namespace}" --kubeconfig "${kubeconfigFile}" """
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (37, 19, 4, 'app-undeploy', '앱 삭제', '
    stage("app-undeploy") {
        steps {
            echo ">>>>> STAGE: app-undeploy"
            script {
                def kubeconfigFile = env.KUBECONFIG_FILE ?: "kubeconfig"
                if (params.KUBECONFIG_CONTENT?.trim()) {
                    writeFile file: kubeconfigFile, text: params.KUBECONFIG_CONTENT
                }
                if (!fileExists(kubeconfigFile)) {
                    error "KUBECONFIG_CONTENT is required or run k8s-kubeconfig-get before app-undeploy"
                }
                def namespace = params.KUBE_NAMESPACE ?: "default"
                def deployType = params.APP_DEPLOY_TYPE ?: "helm"
                if (deployType == "manifest") {
                    writeFile file: "manifest.yaml", text: params.K8S_MANIFEST ?: ""
                    sh """kubectl delete -f manifest.yaml --namespace "${namespace}" --kubeconfig "${kubeconfigFile}" --ignore-not-found=true"""
                } else {
                    sh """helm uninstall "${params.RELEASE_NAME}" --namespace "${namespace}" --kubeconfig "${kubeconfigFile}" || true"""
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (38, 19, 5, 'app-rollback', '이전 버전 롤백', '
    stage("app-rollback") {
        steps {
            echo ">>>>> STAGE: app-rollback"
            script {
                def kubeconfigFile = env.KUBECONFIG_FILE ?: "kubeconfig"
                if (params.KUBECONFIG_CONTENT?.trim()) {
                    writeFile file: kubeconfigFile, text: params.KUBECONFIG_CONTENT
                }
                if (!fileExists(kubeconfigFile)) {
                    error "KUBECONFIG_CONTENT is required or run k8s-kubeconfig-get before app-rollback"
                }
                def namespace = params.KUBE_NAMESPACE ?: "default"
                def revision = params.HELM_REVISION ?: params.ROLLBACK_REVISION ?: ""
                sh """helm rollback "${params.RELEASE_NAME}" ${revision} --namespace "${namespace}" --kubeconfig "${kubeconfigFile}" """
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (48, 20, 1, 'mariadb-install', 'MariaDB 설치', '
    stage("mariadb-install") {
        steps {
            echo ">>>>> STAGE: mariadb-install"
            script {
                def dbName = params.DB_NAME ?: "testdb"
                def safeDbName = dbName.replaceAll(/[^A-Za-z0-9_]/, "_")
                def dbUser = params.DB_USER ?: "mariadb_user"
                def dbPassword = params.DB_PASSWORD ?: "mariadb_pass"
                def sshHost = env.SSH_HOST ?: params.SSH_HOST
                def sshUser = env.SSH_USER ?: params.SSH_USER ?: "cb-user"
                def sshKeyFile = env.SSH_KEY_FILE ?: params.SSH_KEY_FILE
                def keyOpt = sshKeyFile ? "-i \"${sshKeyFile}\"" : ""
                if (!sshHost || !sshUser) {
                    error "SSH_HOST and SSH_USER are required for mariadb-install"
                }
                env.SSH_HOST = sshHost
                env.SSH_USER = sshUser
                env.DB_HOST = env.DB_HOST ?: params.DB_HOST ?: sshHost
                if (sshKeyFile) {
                    env.SSH_KEY_FILE = sshKeyFile
                }
                sh """ssh -o StrictHostKeyChecking=no ${keyOpt} "${sshUser}@${sshHost}" << "EOF"
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
sudo mariadb -e "CREATE DATABASE IF NOT EXISTS ${safeDbName};"
sudo mariadb -e "CREATE USER IF NOT EXISTS ''${dbUser}''@''%'' IDENTIFIED BY ''${dbPassword}'';"
sudo mariadb -e "GRANT ALL PRIVILEGES ON ${safeDbName}.* TO ''${dbUser}''@''%'';"
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
                def dbHost = env.DB_HOST ?: params.DB_HOST ?: "127.0.0.1"
                def sshHost = env.SSH_HOST ?: params.SSH_HOST
                def sshUser = env.SSH_USER ?: params.SSH_USER
                def sshKeyFile = env.SSH_KEY_FILE ?: params.SSH_KEY_FILE
                def useK8s = (params.DB_EXEC_MODE ?: "").equalsIgnoreCase("k8s") || ((env.KUBECONFIG_FILE || params.KUBECONFIG_CONTENT?.trim()) && !sshHost)
                def backupFile = params.DB_BACKUP_FILE ?: "${params.DB_NAME}.sql"
                if (useK8s) {
                    def kubeconfigFile = env.KUBECONFIG_FILE ?: "kubeconfig"
                    if (params.KUBECONFIG_CONTENT?.trim() && !fileExists(kubeconfigFile)) {
                        writeFile file: kubeconfigFile, text: params.KUBECONFIG_CONTENT
                    }
                    if (!fileExists(kubeconfigFile)) {
                        error "KUBECONFIG_CONTENT is required or run k8s-kubeconfig-get before db-backup-export"
                    }
                    def namespace = params.KUBE_NAMESPACE ?: "default"
                    def releaseName = params.RELEASE_NAME ?: "mariadb"
                    def podSelector = params.DB_POD_SELECTOR ?: "app.kubernetes.io/instance=${releaseName},app.kubernetes.io/name=mariadb"
                    def podName = sh(script: """kubectl get pod --namespace "${namespace}" --kubeconfig "${kubeconfigFile}" -l "${podSelector}" -o jsonpath="{.items[0].metadata.name}" """, returnStdout: true).trim()
                    if (!podName) {
                        error "MariaDB pod was not found. selector=${podSelector}"
                    }
                    sh """kubectl exec --namespace "${namespace}" "${podName}" --kubeconfig "${kubeconfigFile}" -- sh -c "MYSQL_PWD=\"${params.DB_PASSWORD}\" mariadb-dump -h \"127.0.0.1\" -P \"${dbPort}\" -u \"${params.DB_USER}\" \"${params.DB_NAME}\"" > "${backupFile}" """
                } else if (sshHost && sshUser) {
                    def keyOpt = sshKeyFile ? "-i \"${sshKeyFile}\"" : ""
                    sh """ssh -o StrictHostKeyChecking=no ${keyOpt} "${sshUser}@${sshHost}" "MYSQL_PWD=\"${params.DB_PASSWORD}\" mariadb-dump -h \"127.0.0.1\" -P \"${dbPort}\" -u \"${params.DB_USER}\" \"${params.DB_NAME}\"" > "${backupFile}" """
                } else {
                    sh """MYSQL_PWD="${params.DB_PASSWORD}" mariadb-dump -h "${dbHost}" -P "${dbPort}" -u "${params.DB_USER}" "${params.DB_NAME}" > "${backupFile}" """
                }
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
                def dbHost = env.DB_HOST ?: params.DB_HOST ?: "127.0.0.1"
                def sshHost = env.SSH_HOST ?: params.SSH_HOST
                def sshUser = env.SSH_USER ?: params.SSH_USER
                def sshKeyFile = env.SSH_KEY_FILE ?: params.SSH_KEY_FILE
                def useK8s = (params.DB_EXEC_MODE ?: "").equalsIgnoreCase("k8s") || ((env.KUBECONFIG_FILE || params.KUBECONFIG_CONTENT?.trim()) && !sshHost)
                def backupFile = params.DB_BACKUP_FILE ?: "${params.DB_NAME}.sql"
                if (params.SCHEMA_SQL_CONTENT?.trim()) {
                    writeFile file: backupFile, text: params.SCHEMA_SQL_CONTENT
                }
                if (useK8s) {
                    def kubeconfigFile = env.KUBECONFIG_FILE ?: "kubeconfig"
                    if (params.KUBECONFIG_CONTENT?.trim() && !fileExists(kubeconfigFile)) {
                        writeFile file: kubeconfigFile, text: params.KUBECONFIG_CONTENT
                    }
                    if (!fileExists(kubeconfigFile)) {
                        error "KUBECONFIG_CONTENT is required or run k8s-kubeconfig-get before db-backup-import"
                    }
                    def namespace = params.KUBE_NAMESPACE ?: "default"
                    def releaseName = params.RELEASE_NAME ?: "mariadb"
                    def podSelector = params.DB_POD_SELECTOR ?: "app.kubernetes.io/instance=${releaseName},app.kubernetes.io/name=mariadb"
                    def podName = sh(script: """kubectl get pod --namespace "${namespace}" --kubeconfig "${kubeconfigFile}" -l "${podSelector}" -o jsonpath="{.items[0].metadata.name}" """, returnStdout: true).trim()
                    if (!podName) {
                        error "MariaDB pod was not found. selector=${podSelector}"
                    }
                    sh """cat "${backupFile}" | kubectl exec -i --namespace "${namespace}" "${podName}" --kubeconfig "${kubeconfigFile}" -- sh -c "MYSQL_PWD=\"${params.DB_PASSWORD}\" mariadb -h \"127.0.0.1\" -P \"${dbPort}\" -u \"${params.DB_USER}\" \"${params.DB_NAME}\"" """
                } else if (sshHost && sshUser) {
                    def keyOpt = sshKeyFile ? "-i \"${sshKeyFile}\"" : ""
                    def remoteFile = "/tmp/${backupFile}"
                    sh """scp -o StrictHostKeyChecking=no ${keyOpt} "${backupFile}" "${sshUser}@${sshHost}:${remoteFile}" """
                    sh """ssh -o StrictHostKeyChecking=no ${keyOpt} "${sshUser}@${sshHost}" "MYSQL_PWD=\"${params.DB_PASSWORD}\" mariadb -h \"127.0.0.1\" -P \"${dbPort}\" -u \"${params.DB_USER}\" \"${params.DB_NAME}\" < \"${remoteFile}\"" """
                } else {
                    sh """MYSQL_PWD="${params.DB_PASSWORD}" mariadb -h "${dbHost}" -P "${dbPort}" -u "${params.DB_USER}" "${params.DB_NAME}" < "${backupFile}" """
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (49, 20, 4, 'db-schema-import', 'schema.sql import', '
    stage("db-schema-import") {
        steps {
            echo ">>>>> STAGE: db-schema-import"
            script {
                def dbPort = params.DB_PORT ?: "3306"
                def dbHost = env.DB_HOST ?: params.DB_HOST ?: "127.0.0.1"
                def sshHost = env.SSH_HOST ?: params.SSH_HOST
                def sshUser = env.SSH_USER ?: params.SSH_USER
                def sshKeyFile = env.SSH_KEY_FILE ?: params.SSH_KEY_FILE
                def useK8s = (params.DB_EXEC_MODE ?: "").equalsIgnoreCase("k8s") || ((env.KUBECONFIG_FILE || params.KUBECONFIG_CONTENT?.trim()) && !sshHost)
                def schemaFile = params.SCHEMA_SQL_FILE ?: "schema.sql"
                if (params.SCHEMA_SQL_CONTENT?.trim()) {
                    writeFile file: schemaFile, text: params.SCHEMA_SQL_CONTENT
                }
                if (useK8s) {
                    def kubeconfigFile = env.KUBECONFIG_FILE ?: "kubeconfig"
                    if (params.KUBECONFIG_CONTENT?.trim() && !fileExists(kubeconfigFile)) {
                        writeFile file: kubeconfigFile, text: params.KUBECONFIG_CONTENT
                    }
                    if (!fileExists(kubeconfigFile)) {
                        error "KUBECONFIG_CONTENT is required or run k8s-kubeconfig-get before db-schema-import"
                    }
                    def namespace = params.KUBE_NAMESPACE ?: "default"
                    def releaseName = params.RELEASE_NAME ?: "mariadb"
                    def podSelector = params.DB_POD_SELECTOR ?: "app.kubernetes.io/instance=${releaseName},app.kubernetes.io/name=mariadb"
                    def podName = sh(script: """kubectl get pod --namespace "${namespace}" --kubeconfig "${kubeconfigFile}" -l "${podSelector}" -o jsonpath="{.items[0].metadata.name}" """, returnStdout: true).trim()
                    if (!podName) {
                        error "MariaDB pod was not found. selector=${podSelector}"
                    }
                    sh """cat "${schemaFile}" | kubectl exec -i --namespace "${namespace}" "${podName}" --kubeconfig "${kubeconfigFile}" -- sh -c "MYSQL_PWD=\"${params.DB_PASSWORD}\" mariadb -h \"127.0.0.1\" -P \"${dbPort}\" -u \"${params.DB_USER}\" \"${params.DB_NAME}\"" """
                } else if (sshHost && sshUser) {
                    def keyOpt = sshKeyFile ? "-i \"${sshKeyFile}\"" : ""
                    def remoteFile = "/tmp/${schemaFile}"
                    sh """scp -o StrictHostKeyChecking=no ${keyOpt} "${schemaFile}" "${sshUser}@${sshHost}:${remoteFile}" """
                    sh """ssh -o StrictHostKeyChecking=no ${keyOpt} "${sshUser}@${sshHost}" "MYSQL_PWD=\"${params.DB_PASSWORD}\" mariadb -h \"127.0.0.1\" -P \"${dbPort}\" -u \"${params.DB_USER}\" \"${params.DB_NAME}\" < \"${remoteFile}\"" """
                } else {
                    sh """MYSQL_PWD="${params.DB_PASSWORD}" mariadb -h "${dbHost}" -P "${dbPort}" -u "${params.DB_USER}" "${params.DB_NAME}" < "${schemaFile}" """
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (41, 20, 5, 'db-data-insert', '초기 데이터 insert', '
    stage("db-data-insert") {
        steps {
            echo ">>>>> STAGE: db-data-insert"
            script {
                def dbPort = params.DB_PORT ?: "3306"
                def dbHost = env.DB_HOST ?: params.DB_HOST ?: "127.0.0.1"
                def sshHost = env.SSH_HOST ?: params.SSH_HOST
                def sshUser = env.SSH_USER ?: params.SSH_USER
                def sshKeyFile = env.SSH_KEY_FILE ?: params.SSH_KEY_FILE
                def useK8s = (params.DB_EXEC_MODE ?: "").equalsIgnoreCase("k8s") || ((env.KUBECONFIG_FILE || params.KUBECONFIG_CONTENT?.trim()) && !sshHost)
                writeFile file: "insert.sql", text: params.INSERT_SQL ?: ""
                if (useK8s) {
                    def kubeconfigFile = env.KUBECONFIG_FILE ?: "kubeconfig"
                    if (params.KUBECONFIG_CONTENT?.trim() && !fileExists(kubeconfigFile)) {
                        writeFile file: kubeconfigFile, text: params.KUBECONFIG_CONTENT
                    }
                    if (!fileExists(kubeconfigFile)) {
                        error "KUBECONFIG_CONTENT is required or run k8s-kubeconfig-get before db-data-insert"
                    }
                    def namespace = params.KUBE_NAMESPACE ?: "default"
                    def releaseName = params.RELEASE_NAME ?: "mariadb"
                    def podSelector = params.DB_POD_SELECTOR ?: "app.kubernetes.io/instance=${releaseName},app.kubernetes.io/name=mariadb"
                    def podName = sh(script: """kubectl get pod --namespace "${namespace}" --kubeconfig "${kubeconfigFile}" -l "${podSelector}" -o jsonpath="{.items[0].metadata.name}" """, returnStdout: true).trim()
                    if (!podName) {
                        error "MariaDB pod was not found. selector=${podSelector}"
                    }
                    sh """cat "insert.sql" | kubectl exec -i --namespace "${namespace}" "${podName}" --kubeconfig "${kubeconfigFile}" -- sh -c "MYSQL_PWD=\"${params.DB_PASSWORD}\" mariadb -h \"127.0.0.1\" -P \"${dbPort}\" -u \"${params.DB_USER}\" \"${params.DB_NAME}\"" """
                } else if (sshHost && sshUser) {
                    def keyOpt = sshKeyFile ? "-i \"${sshKeyFile}\"" : ""
                    sh """scp -o StrictHostKeyChecking=no ${keyOpt} "insert.sql" "${sshUser}@${sshHost}:/tmp/insert.sql" """
                    sh """ssh -o StrictHostKeyChecking=no ${keyOpt} "${sshUser}@${sshHost}" "MYSQL_PWD=\"${params.DB_PASSWORD}\" mariadb -h \"127.0.0.1\" -P \"${dbPort}\" -u \"${params.DB_USER}\" \"${params.DB_NAME}\" < \"/tmp/insert.sql\"" """
                } else {
                    sh """MYSQL_PWD="${params.DB_PASSWORD}" mariadb -h "${dbHost}" -P "${dbPort}" -u "${params.DB_USER}" "${params.DB_NAME}" < insert.sql"""
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (42, 20, 6, 'db-data-verify', '데이터 적재 결과 확인', '
    stage("db-data-verify") {
        steps {
            echo ">>>>> STAGE: db-data-verify"
            script {
                def dbPort = params.DB_PORT ?: "3306"
                def dbHost = env.DB_HOST ?: params.DB_HOST ?: "127.0.0.1"
                def sshHost = env.SSH_HOST ?: params.SSH_HOST
                def sshUser = env.SSH_USER ?: params.SSH_USER
                def sshKeyFile = env.SSH_KEY_FILE ?: params.SSH_KEY_FILE
                def useK8s = (params.DB_EXEC_MODE ?: "").equalsIgnoreCase("k8s") || ((env.KUBECONFIG_FILE || params.KUBECONFIG_CONTENT?.trim()) && !sshHost)
                writeFile file: "verify.sql", text: params.VERIFY_SQL ?: "SELECT 1"
                if (useK8s) {
                    def kubeconfigFile = env.KUBECONFIG_FILE ?: "kubeconfig"
                    if (params.KUBECONFIG_CONTENT?.trim() && !fileExists(kubeconfigFile)) {
                        writeFile file: kubeconfigFile, text: params.KUBECONFIG_CONTENT
                    }
                    if (!fileExists(kubeconfigFile)) {
                        error "KUBECONFIG_CONTENT is required or run k8s-kubeconfig-get before db-data-verify"
                    }
                    def namespace = params.KUBE_NAMESPACE ?: "default"
                    def releaseName = params.RELEASE_NAME ?: "mariadb"
                    def podSelector = params.DB_POD_SELECTOR ?: "app.kubernetes.io/instance=${releaseName},app.kubernetes.io/name=mariadb"
                    def podName = sh(script: """kubectl get pod --namespace "${namespace}" --kubeconfig "${kubeconfigFile}" -l "${podSelector}" -o jsonpath="{.items[0].metadata.name}" """, returnStdout: true).trim()
                    if (!podName) {
                        error "MariaDB pod was not found. selector=${podSelector}"
                    }
                    sh """cat "verify.sql" | kubectl exec -i --namespace "${namespace}" "${podName}" --kubeconfig "${kubeconfigFile}" -- sh -c "MYSQL_PWD=\"${params.DB_PASSWORD}\" mariadb -h \"127.0.0.1\" -P \"${dbPort}\" -u \"${params.DB_USER}\" \"${params.DB_NAME}\"" """
                } else if (sshHost && sshUser) {
                    def keyOpt = sshKeyFile ? "-i \"${sshKeyFile}\"" : ""
                    sh """scp -o StrictHostKeyChecking=no ${keyOpt} "verify.sql" "${sshUser}@${sshHost}:/tmp/verify.sql" """
                    sh """ssh -o StrictHostKeyChecking=no ${keyOpt} "${sshUser}@${sshHost}" "MYSQL_PWD=\"${params.DB_PASSWORD}\" mariadb -h \"127.0.0.1\" -P \"${dbPort}\" -u \"${params.DB_USER}\" \"${params.DB_NAME}\" < \"/tmp/verify.sql\"" """
                } else {
                    sh """MYSQL_PWD="${params.DB_PASSWORD}" mariadb -h "${dbHost}" -P "${dbPort}" -u "${params.DB_USER}" "${params.DB_NAME}" < verify.sql"""
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (43, 21, 1, 'ssh-command-exec', 'SSH 원격 명령 실행', '
    stage("ssh-command-exec") {
        steps {
            echo ">>>>> STAGE: ssh-command-exec"
            script {
                def sshHost = env.SSH_HOST ?: params.SSH_HOST
                def sshUser = env.SSH_USER ?: params.SSH_USER
                def sshKeyFile = env.SSH_KEY_FILE ?: params.SSH_KEY_FILE
                if (!sshHost || !sshUser) {
                    error "SSH_HOST and SSH_USER are required for ssh-command-exec"
                }
                def keyOpt = sshKeyFile ? "-i \"${sshKeyFile}\"" : ""
                sh """ssh -o StrictHostKeyChecking=no ${keyOpt} "${sshUser}@${sshHost}" "${params.SSH_COMMAND}" """
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
-- Legacy test workflow seed data intentionally omitted.
-- Step 8: Insert scenario workflows
-- A. vm-mariadb-backup-import-data-init
-- B. multi-csp-vm-deploy
-- C. k8s-mariadb-backup-import-data-init
-- D. multi-csp-k8s-cluster-deploy
-- E. vm-mariadb-data-init-cleanup
-- F. multi-csp-vm-cleanup

DELETE FROM event_listener_param WHERE event_listener_idx IN (
    SELECT event_listener_idx FROM event_listener
    WHERE workflow_idx IN (SELECT workflow_idx FROM workflow WHERE workflow_purpose = 'test')
);
DELETE FROM event_listener WHERE workflow_idx IN (SELECT workflow_idx FROM workflow WHERE workflow_purpose = 'test');
DELETE FROM workflow_history WHERE workflow_idx IN (SELECT workflow_idx FROM workflow WHERE workflow_purpose = 'test');
DELETE FROM workflow_param_history WHERE workflow_idx IN (SELECT workflow_idx FROM workflow WHERE workflow_purpose = 'test');
DELETE FROM workflow_stage_mapping WHERE workflow_idx IN (SELECT workflow_idx FROM workflow WHERE workflow_purpose = 'test');
DELETE FROM workflow_param WHERE workflow_idx IN (SELECT workflow_idx FROM workflow WHERE workflow_purpose = 'test');
DELETE FROM workflow WHERE workflow_purpose = 'test';

DELETE FROM workflow_stage_mapping WHERE workflow_idx IN (101, 102, 103, 104, 105, 106);
DELETE FROM workflow_param WHERE workflow_idx IN (101, 102, 103, 104, 105, 106);
ALTER TABLE workflow_param ALTER COLUMN param_idx RESTART WITH 10000;
ALTER TABLE workflow_stage_mapping ALTER COLUMN mapping_idx RESTART WITH 10000;

MERGE INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script, run_date) KEY(workflow_idx)
SELECT 101, 'vm-mariadb-backup-import-data-init', 'For Deployment', 1,
'import groovy.json.JsonOutput

pipeline {
    agent any
    stages {
'
|| (SELECT workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 17)
|| (SELECT workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 25)
|| (SELECT workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 48)
|| (SELECT workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 40)
|| (SELECT workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 41)
|| '
    }
}
', NULL;

MERGE INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script, run_date) KEY(workflow_idx) VALUES (102, 'multi-csp-vm-deploy', 'For Deployment', 1, '
import groovy.json.JsonOutput

pipeline {
    agent any
    stages {
        stage("multi-csp-vm-deploy") {
            steps {
                echo ">>>>> STAGE: multi-csp-vm-deploy"
                script {
                    def cspList = (params.CSP_LIST ?: "").split(",").collect { it.trim() }.findAll { it }
                    if (cspList.isEmpty()) {
                        error "CSP_LIST is required"
                    }

                    def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                    cspList.each { csp ->
                        def key = csp.toUpperCase().replaceAll("[^A-Z0-9]", "_")
                        def infraId = (params.INFRA_PREFIX ?: "multi-csp-vm") + "-" + csp
                        def specId = params["${key}_SPEC_ID"]
                        def imageId = params["${key}_IMAGE_ID"]
                        def region = params["${key}_REGION"] ?: params.REGION ?: ""
                        def connectionName = params["${key}_CONNECTION_NAME"] ?: params.CONNECTION_NAME ?: (region ? "${csp}-${region}" : "")
                        def zone = params["${key}_ZONE"] ?: params.ZONE ?: ""
                        if (!specId || !imageId) {
                            error "${key}_SPEC_ID and ${key}_IMAGE_ID are required for ${csp}"
                        }

                        def nodeGroup = [
                            name: params.INFRA_NODEGROUP_NAME ?: "g1",
                            nodeGroupSize: (params.INFRA_NODEGROUP_SIZE ?: "1").toInteger(),
                            specId: specId,
                            imageId: imageId,
                            rootDiskType: params.ROOT_DISK_TYPE ?: "default",
                            rootDiskSize: (params.ROOT_DISK_SIZE ?: "50").toInteger()
                        ]
                        if (connectionName) {
                            nodeGroup.connectionName = connectionName
                        }
                        if (zone) {
                            nodeGroup.zone = zone
                        }

                        def payload = JsonOutput.toJson([
                            name: infraId,
                            description: "Workflow multi CSP VM deploy - ${csp}",
                            installMonAgent: params.INSTALL_MON_AGENT ?: "no",
                            policyOnPartialFailure: params.POLICY_ON_PARTIAL_FAILURE ?: "continue",
                            label: [
                                csp: csp,
                                region: region
                            ],
                            nodeGroups: [nodeGroup]
                        ])

                        writeFile file: "infra-create-${csp}.json", text: payload
                        def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X POST "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/infraDynamic" -H "Content-Type: application/json" -d @infra-create-${csp}.json ${auth}""", returnStdout: true).trim()
                        echo response
                        if (!response.contains("Http_Status_code:2")) {
                            error "multi-csp-vm-deploy failed for ${csp}: ${response}"
                        }
                    }
                }
            }
        }
    }
}
', NULL);

MERGE INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script, run_date) KEY(workflow_idx)
SELECT 103, 'k8s-mariadb-backup-import-data-init', 'For Deployment', 1,
'import groovy.json.JsonOutput

pipeline {
    agent any
    stages {
'
|| (SELECT workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 26)
|| (SELECT workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 33)
|| (SELECT workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 34)
|| (SELECT workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 40)
|| (SELECT workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 41)
|| '
    }
}
', NULL;

MERGE INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script, run_date) KEY(workflow_idx) VALUES (104, 'multi-csp-k8s-cluster-deploy', 'For Deployment', 1, '
import groovy.json.JsonOutput

pipeline {
    agent any
    stages {
        stage("multi-csp-k8s-cluster-deploy") {
            steps {
                echo ">>>>> STAGE: multi-csp-k8s-cluster-deploy"
                script {
                    def cspList = (params.CSP_LIST ?: "").split(",").collect { it.trim() }.findAll { it }
                    if (cspList.isEmpty()) {
                        error "CSP_LIST is required"
                    }

                    def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                    cspList.each { csp ->
                        def key = csp.toUpperCase().replaceAll("[^A-Z0-9]", "_")
                        def clusterId = (params.CLUSTER_PREFIX ?: "multi-csp-k8s") + "-" + csp
                        def nodeGroupName = (params.K8S_NODEGROUP_PREFIX ?: "ng") + "-" + csp
                        def specId = params["${key}_SPEC_ID"] ?: params.SPEC_ID
                        def imageId = params["${key}_IMAGE_ID"] ?: params.IMAGE_ID
                        def region = params["${key}_REGION"] ?: params.REGION ?: ""
                        def connectionName = params["${key}_CONNECTION_NAME"] ?: params.CONNECTION_NAME ?: (region ? "${csp}-${region}" : "")
                        if (!specId || !imageId) {
                            error "SPEC_ID and IMAGE_ID are required for ${csp}"
                        }

                        def payloadMap = [
                            name: clusterId,
                            nodeGroupName: nodeGroupName,
                            specId: specId,
                            imageId: imageId,
                            label: [
                                csp: csp,
                                region: region
                            ],
                            version: params.K8S_VERSION ?: "",
                            desiredNodeSize: (params.K8S_DESIRED_NODE_SIZE ?: "1").toInteger(),
                            minNodeSize: (params.K8S_MIN_NODE_SIZE ?: "1").toInteger(),
                            maxNodeSize: (params.K8S_MAX_NODE_SIZE ?: "3").toInteger(),
                            rootDiskType: params.ROOT_DISK_TYPE ?: "default",
                            rootDiskSize: (params.ROOT_DISK_SIZE ?: "30").toInteger()
                        ]
                        if (connectionName) {
                            payloadMap.connectionName = connectionName
                        }

                        def payload = JsonOutput.toJson(payloadMap)

                        writeFile file: "k8s-cluster-create-${csp}.json", text: payload
                        def option = params.K8S_CREATE_OPTION ? "?option=${params.K8S_CREATE_OPTION}" : ""
                        def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X POST "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/k8sClusterDynamic${option}" -H "Content-Type: application/json" -d @k8s-cluster-create-${csp}.json ${auth}""", returnStdout: true).trim()
                        echo response
                        if (!response.contains("Http_Status_code:2")) {
                            error "multi-csp-k8s-cluster-deploy failed for ${csp}: ${response}"
                        }
                        def readyStatuses = (params.K8S_READY_STATUS ?: "Active,Running").split(",").collect { it.trim().toLowerCase() }.findAll { it }
                        def statusAttempts = (params.K8S_STATUS_MAX_ATTEMPTS ?: "60").toInteger()
                        def statusIntervalSeconds = (params.K8S_STATUS_INTERVAL_SECONDS ?: "10").toInteger()
                        def statusResponse = ""
                        for (int attempt = 1; attempt <= statusAttempts; attempt++) {
                            statusResponse = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/k8sCluster/${clusterId}?option=status" ${auth}""", returnStdout: true).trim()
                            def normalizedStatusResponse = statusResponse.toLowerCase()
                            if (statusResponse.contains("Http_Status_code:2") && readyStatuses.any { normalizedStatusResponse.contains(it) }) {
                                break
                            }
                            echo "k8s cluster ${clusterId} is not ready. attempt ${attempt}/${statusAttempts}: ${statusResponse}"
                            sleep time: statusIntervalSeconds, unit: "SECONDS"
                        }
                        def normalizedFinalStatusResponse = statusResponse.toLowerCase()
                        if (!statusResponse.contains("Http_Status_code:2") || !readyStatuses.any { normalizedFinalStatusResponse.contains(it) }) {
                            error "multi-csp-k8s-cluster-deploy status check failed for ${csp}: ${statusResponse}"
                        }
                    }
                }
            }
        }
    }
}
', NULL);

MERGE INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script, run_date) KEY(workflow_idx) VALUES (105, 'vm-mariadb-data-init-cleanup', 'For Cleanup', 1, '
pipeline {
    agent any
    stages {
        stage("infra-cleanup") {
            steps {
                echo ">>>>> STAGE: infra-cleanup"
                script {
                    if (!params.TUMBLEBUG?.trim()) {
                        error "TUMBLEBUG is required"
                    }
                    if (!params.NAMESPACE?.trim()) {
                        error "NAMESPACE is required"
                    }
                    if (!params.INFRA_ID?.trim()) {
                        error "INFRA_ID is required"
                    }

                    def option = params.INFRA_DELETE_OPTION ?: "terminate"
                    def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                    def url = "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/infra/${params.INFRA_ID}?option=${option}"
                    def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X DELETE "${url}" ${auth}""", returnStdout: true).trim()
                    echo response
                    if (response.contains("Http_Status_code:404")) {
                        echo "Infra ${params.INFRA_ID} is already absent."
                    } else if (!response.contains("Http_Status_code:2")) {
                        error "infra-cleanup failed: ${response}"
                    } else {
                        echo "Infra ${params.INFRA_ID} cleanup requested."
                    }
                }
            }
        }
    }
}
', NULL);

MERGE INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script, run_date) KEY(workflow_idx)
SELECT 106, 'multi-csp-vm-cleanup', 'For Cleanup', 1,
'pipeline {
    agent any
    stages {
'
|| (SELECT workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 52)
|| '
    }
}
', NULL;

INSERT INTO workflow_param (workflow_idx, param_key, param_value, event_listener_yn) VALUES
(101, 'TUMBLEBUG', 'http://mc-infra-manager:1323', 'N'),
(101, 'TUMBLEBUG_SELECTOR_YN', 'Y', 'N'),
(101, 'USER', 'default', 'N'),
(101, 'USERPASS', 'default', 'N'),
(101, 'NAMESPACE', 'ns01', 'N'),
(101, 'INFRA_ID', 'vm-mariadb-data-init', 'N'),
(101, 'REGION', 'ap-northeast-2', 'N'),
(101, 'CONNECTION_NAME', 'aws-ap-northeast-2', 'N'),
(101, 'ZONE', '', 'N'),
(101, 'IMAGE', '', 'N'),
(101, 'IMAGE_ID', '', 'N'),
(101, 'SPEC', '', 'N'),
(101, 'SPEC_ID', '', 'N'),
(101, 'SSH_HOST', '', 'N'),
(101, 'SSH_USER', 'cb-user', 'N'),
(101, 'SSH_KEY_FILE', '', 'N'),
(101, 'DB_EXEC_MODE', 'ssh', 'N'),
(101, 'DB_HOST', '', 'N'),
(101, 'DB_PORT', '3306', 'N'),
(101, 'DB_NAME', 'testdb', 'N'),
(101, 'DB_USER', 'mariadb_user', 'N'),
(101, 'DB_PASSWORD', 'mariadb_pass', 'N'),
(101, 'DB_BACKUP_FILE', 'schema.sql', 'N'),
(101, 'SCHEMA_SQL_CONTENT', 'CREATE TABLE IF NOT EXISTS sample_data (id INT PRIMARY KEY, name VARCHAR(100));', 'N'),
(101, 'INSERT_SQL', 'INSERT INTO sample_data (id, name) VALUES (1, ''sample row'');', 'N');

INSERT INTO workflow_param (workflow_idx, param_key, param_value, event_listener_yn) VALUES
(102, 'TUMBLEBUG', 'http://mc-infra-manager:1323', 'N'),
(102, 'TUMBLEBUG_SELECTOR_YN', 'Y', 'N'),
(102, 'USER', 'default', 'N'),
(102, 'USERPASS', 'default', 'N'),
(102, 'NAMESPACE', 'ns01', 'N'),
(102, 'CSP_LIST', 'aws,azure,gcp,ncp,nhn,alibaba,tencent,ibm,kt', 'N'),
(102, 'INFRA_PREFIX', 'multi-csp-vm', 'N'),
(102, 'INFRA_NODEGROUP_NAME', 'g1', 'N'),
(102, 'INFRA_NODEGROUP_SIZE', '1', 'N'),
(102, 'ROOT_DISK_TYPE', 'default', 'N'),
(102, 'ROOT_DISK_SIZE', '50', 'N'),
(102, 'AWS_REGION', 'ap-northeast-2', 'N'),
(102, 'AWS_CONNECTION_NAME', 'aws-ap-northeast-2', 'N'),
(102, 'AWS_ZONE', '', 'N'),
(102, 'AWS_SPEC_ID', '', 'N'),
(102, 'AWS_IMAGE_ID', '', 'N'),
(102, 'AZURE_REGION', 'koreasouth', 'N'),
(102, 'AZURE_CONNECTION_NAME', 'azure-koreasouth', 'N'),
(102, 'AZURE_ZONE', '', 'N'),
(102, 'AZURE_SPEC_ID', '', 'N'),
(102, 'AZURE_IMAGE_ID', '', 'N'),
(102, 'GCP_REGION', 'asia-northeast3', 'N'),
(102, 'GCP_CONNECTION_NAME', 'gcp-asia-northeast3', 'N'),
(102, 'GCP_ZONE', '', 'N'),
(102, 'GCP_SPEC_ID', '', 'N'),
(102, 'GCP_IMAGE_ID', '', 'N'),
(102, 'NCP_REGION', 'kr', 'N'),
(102, 'NCP_CONNECTION_NAME', 'ncp-kr', 'N'),
(102, 'NCP_ZONE', '', 'N'),
(102, 'NCP_SPEC_ID', 'ncp+kr+mi1-g3', 'N'),
(102, 'NCP_IMAGE_ID', '104630229', 'N'),
(102, 'NHN_REGION', 'kr1', 'N'),
(102, 'NHN_CONNECTION_NAME', 'nhn-kr1', 'N'),
(102, 'NHN_ZONE', '', 'N'),
(102, 'NHN_SPEC_ID', '', 'N'),
(102, 'NHN_IMAGE_ID', '', 'N'),
(102, 'ALIBABA_REGION', 'ap-northeast-2', 'N'),
(102, 'ALIBABA_CONNECTION_NAME', 'alibaba-ap-northeast-2', 'N'),
(102, 'ALIBABA_ZONE', '', 'N'),
(102, 'ALIBABA_SPEC_ID', '', 'N'),
(102, 'ALIBABA_IMAGE_ID', '', 'N'),
(102, 'TENCENT_REGION', 'ap-seoul', 'N'),
(102, 'TENCENT_CONNECTION_NAME', 'tencent-ap-seoul', 'N'),
(102, 'TENCENT_ZONE', '', 'N'),
(102, 'TENCENT_SPEC_ID', '', 'N'),
(102, 'TENCENT_IMAGE_ID', '', 'N'),
(102, 'IBM_REGION', 'jp-osa', 'N'),
(102, 'IBM_CONNECTION_NAME', 'ibm-jp-osa', 'N'),
(102, 'IBM_ZONE', '', 'N'),
(102, 'IBM_SPEC_ID', '', 'N'),
(102, 'IBM_IMAGE_ID', '', 'N'),
(102, 'KT_REGION', 'kr1', 'N'),
(102, 'KT_CONNECTION_NAME', 'kt-kr1', 'N'),
(102, 'KT_ZONE', '', 'N'),
(102, 'KT_SPEC_ID', '', 'N'),
(102, 'KT_IMAGE_ID', '', 'N');

INSERT INTO workflow_param (workflow_idx, param_key, param_value, event_listener_yn) VALUES
(103, 'TUMBLEBUG', 'http://mc-infra-manager:1323', 'N'),
(103, 'TUMBLEBUG_SELECTOR_YN', 'Y', 'N'),
(103, 'USER', 'default', 'N'),
(103, 'USERPASS', 'default', 'N'),
(103, 'NAMESPACE', 'ns01', 'N'),
(103, 'PROVIDER', 'aws', 'N'),
(103, 'CSP', 'aws', 'N'),
(103, 'REGION', 'ap-northeast-2', 'N'),
(103, 'CONNECTION_NAME', 'aws-ap-northeast-2', 'N'),
(103, 'K8S_CLUSTER_ID', 'k8s-mariadb-data-init', 'N'),
(103, 'K8S_NODEGROUP_NAME', 'ng1', 'N'),
(103, 'IMAGE', '', 'N'),
(103, 'SPEC_ID', '', 'N'),
(103, 'SPEC', '', 'N'),
(103, 'IMAGE_ID', '', 'N'),
(103, 'K8S_VERSION', '', 'N'),
(103, 'K8S_DESIRED_NODE_SIZE', '1', 'N'),
(103, 'K8S_MIN_NODE_SIZE', '1', 'N'),
(103, 'K8S_MAX_NODE_SIZE', '3', 'N'),
(103, 'ROOT_DISK_TYPE', 'default', 'N'),
(103, 'ROOT_DISK_SIZE', '30', 'N'),
(103, 'K8S_CREATE_OPTION', '', 'N'),
(103, 'K8S_STATUS_MAX_ATTEMPTS', '60', 'N'),
(103, 'K8S_STATUS_INTERVAL_SECONDS', '10', 'N'),
(103, 'K8S_READY_STATUS', 'Active,Running', 'N'),
(103, 'KUBECONFIG_CONTENT', '', 'N'),
(103, 'KUBE_NAMESPACE', 'default', 'N'),
(103, 'RELEASE_NAME', 'mariadb', 'N'),
(103, 'HELM_CHART', 'oci://registry-1.docker.io/bitnamicharts/mariadb', 'N'),
(103, 'HELM_VALUES_ARGS', '--set auth.rootPassword=mariadb_pass --set auth.database=testdb --set auth.username=mariadb_user --set auth.password=mariadb_pass --wait --timeout 10m', 'N'),
(103, 'DB_EXEC_MODE', 'k8s', 'N'),
(103, 'DB_POD_SELECTOR', 'app.kubernetes.io/instance=mariadb,app.kubernetes.io/name=mariadb', 'N'),
(103, 'DB_HOST', 'mariadb.default.svc.cluster.local', 'N'),
(103, 'DB_PORT', '3306', 'N'),
(103, 'DB_NAME', 'testdb', 'N'),
(103, 'DB_USER', 'mariadb_user', 'N'),
(103, 'DB_PASSWORD', 'mariadb_pass', 'N'),
(103, 'DB_BACKUP_FILE', 'schema.sql', 'N'),
(103, 'SCHEMA_SQL_CONTENT', 'CREATE TABLE IF NOT EXISTS sample_data (id INT PRIMARY KEY, name VARCHAR(100));', 'N'),
(103, 'INSERT_SQL', 'INSERT INTO sample_data (id, name) VALUES (1, ''sample row'');', 'N');

INSERT INTO workflow_param (workflow_idx, param_key, param_value, event_listener_yn) VALUES
(104, 'TUMBLEBUG', 'http://mc-infra-manager:1323', 'N'),
(104, 'TUMBLEBUG_SELECTOR_YN', 'Y', 'N'),
(104, 'USER', 'default', 'N'),
(104, 'USERPASS', 'default', 'N'),
(104, 'NAMESPACE', 'ns01', 'N'),
(104, 'CSP_LIST', 'aws,azure,gcp,ncp,nhn,tencent', 'N'),
(104, 'CLUSTER_PREFIX', 'multi-csp-k8s', 'N'),
(104, 'K8S_NODEGROUP_PREFIX', 'ng', 'N'),
(104, 'K8S_VERSION', '', 'N'),
(104, 'K8S_DESIRED_NODE_SIZE', '1', 'N'),
(104, 'K8S_MIN_NODE_SIZE', '1', 'N'),
(104, 'K8S_MAX_NODE_SIZE', '3', 'N'),
(104, 'ROOT_DISK_TYPE', 'default', 'N'),
(104, 'ROOT_DISK_SIZE', '30', 'N'),
(104, 'K8S_CREATE_OPTION', '', 'N'),
(104, 'K8S_STATUS_MAX_ATTEMPTS', '60', 'N'),
(104, 'K8S_STATUS_INTERVAL_SECONDS', '10', 'N'),
(104, 'K8S_READY_STATUS', 'Active,Running', 'N'),
(104, 'AWS_REGION', 'ap-northeast-2', 'N'),
(104, 'AWS_CONNECTION_NAME', 'aws-ap-northeast-2', 'N'),
(104, 'AWS_SPEC_ID', '', 'N'),
(104, 'AWS_IMAGE_ID', '', 'N'),
(104, 'AZURE_REGION', 'koreacentral', 'N'),
(104, 'AZURE_CONNECTION_NAME', 'azure-koreacentral', 'N'),
(104, 'AZURE_SPEC_ID', '', 'N'),
(104, 'AZURE_IMAGE_ID', '', 'N'),
(104, 'GCP_REGION', 'asia-east1', 'N'),
(104, 'GCP_CONNECTION_NAME', 'gcp-asia-east1', 'N'),
(104, 'GCP_SPEC_ID', '', 'N'),
(104, 'GCP_IMAGE_ID', '', 'N'),
(104, 'NCP_REGION', 'kr1', 'N'),
(104, 'NCP_CONNECTION_NAME', 'ncp-kr1', 'N'),
(104, 'NCP_SPEC_ID', '', 'N'),
(104, 'NCP_IMAGE_ID', '', 'N'),
(104, 'NHN_REGION', 'kr1', 'N'),
(104, 'NHN_CONNECTION_NAME', 'nhn-kr1', 'N'),
(104, 'NHN_SPEC_ID', '', 'N'),
(104, 'NHN_IMAGE_ID', '', 'N'),
(104, 'TENCENT_REGION', 'ap-seoul', 'N'),
(104, 'TENCENT_CONNECTION_NAME', 'tencent-ap-seoul', 'N'),
(104, 'TENCENT_SPEC_ID', '', 'N'),
(104, 'TENCENT_IMAGE_ID', '', 'N');

INSERT INTO workflow_param (workflow_idx, param_key, param_value, event_listener_yn) VALUES
(105, 'TUMBLEBUG', 'http://mc-infra-manager:1323', 'N'),
(105, 'TUMBLEBUG_SELECTOR_YN', 'N', 'N'),
(105, 'USER', 'default', 'N'),
(105, 'USERPASS', 'default', 'N'),
(105, 'NAMESPACE', 'ns01', 'N'),
(105, 'INFRA_ID', 'vm-mariadb-data-init', 'N'),
(105, 'INFRA_DELETE_OPTION', 'terminate', 'N');

INSERT INTO workflow_param (workflow_idx, param_key, param_value, event_listener_yn) VALUES
(106, 'TUMBLEBUG', 'http://mc-infra-manager:1323', 'N'),
(106, 'TUMBLEBUG_SELECTOR_YN', 'N', 'N'),
(106, 'USER', 'default', 'N'),
(106, 'USERPASS', 'default', 'N'),
(106, 'NAMESPACE', 'ns01', 'N'),
(106, 'CSP_LIST', 'aws,azure,gcp,ncp,nhn,alibaba,tencent,ibm,kt', 'N'),
(106, 'INFRA_PREFIX', 'multi-csp-vm', 'N'),
(106, 'INFRA_ID_LIST', '', 'N'),
(106, 'INFRA_DELETE_OPTION', 'terminate', 'N');

INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage) VALUES
(101, 1, null, 'import groovy.json.JsonOutput

pipeline {
    agent any
    stages {
');
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 101, 2, 17, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 17;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 101, 3, 25, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 25;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 101, 4, 48, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 48;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 101, 5, 40, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 40;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 101, 6, 41, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 41;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage) VALUES
(101, 7, null, '
    }
}
');

INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage) VALUES
(102, 1, 50, (SELECT script FROM workflow WHERE workflow_idx = 102));

INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage) VALUES
(103, 1, null, 'import groovy.json.JsonOutput

pipeline {
    agent any
    stages {
');
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 103, 2, 26, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 26;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 103, 3, 33, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 33;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 103, 4, 34, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 34;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 103, 5, 40, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 40;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 103, 6, 41, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 41;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage) VALUES
(103, 7, null, '
    }
}
');

INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage) VALUES
(104, 1, 51, (SELECT script FROM workflow WHERE workflow_idx = 104));

INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage) VALUES
(105, 1, null, (SELECT script FROM workflow WHERE workflow_idx = 105));

INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage) VALUES
(106, 1, 52, (SELECT script FROM workflow WHERE workflow_idx = 106));

-- End Step 8
