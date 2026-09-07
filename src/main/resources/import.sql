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
                    echo groovy.json.JsonOutput.prettyPrint(response)
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
                    echo groovy.json.JsonOutput.prettyPrint(response)
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

                def payload = groovy.json.JsonOutput.toJson([
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

                echo groovy.json.JsonOutput.prettyPrint(response)
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
                    echo groovy.json.JsonOutput.prettyPrint(response)
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
                    echo groovy.json.JsonOutput.prettyPrint(tumblebug_exist_k8s_cluster_response)
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
                            "specId": "gcp+asia-northeast3+e2-medium", \
                            "connectionName": "gcp-asia-northeast3", \
                            "name": "${CLUSTER}", \
                            "nodeGroupName": "k8sng03", \
                            "version": "1.34.3-gke.1051003" \
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
                        echo groovy.json.JsonOutput.prettyPrint(tumblebug_create_cluster_response)
                        
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
                    echo groovy.json.JsonOutput.prettyPrint(response)
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
                        retry(30) { // Retry up to 30 times
                            sleep 10 // Wait 10 seconds
                            timeout(time: 5, unit: ''MINUTES'') { // 5 minute timeout
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
                    echo groovy.json.JsonOutput.prettyPrint(tumblebug_exist_ns_response)
                } else {
                    def call_tumblebug_create_ns_url = """${TUMBLEBUG}/tumblebug/ns"""
                    def call_tumblebug_create_ns_payload = """''{ "name": ${NAMESPACE}, "description": "Workflow Created Namespace" }''"""
                    def tumblebug_create_ns_response = sh(script: """curl -w "- Http_Status_code:%{http_code}" -X POST ${call_tumblebug_create_ns_url} -H "Content-Type: application/json" -d ''${call_tumblebug_create_ns_payload}'' --user ${USER}:${USERPASS}""", returnStdout: true).trim()

                    if (tumblebug_create_ns_response.indexOf(''Http_Status_code:200'') > 0 ) {
                        echo """Create Namespace successful >> ${NAMESPACE}"""
                        tumblebug_create_ns_response = tumblebug_create_ns_response.replace(''- Http_Status_code:200'', '''')
                        echo groovy.json.JsonOutput.prettyPrint(tumblebug_create_ns_response)
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

#mariadb: https://github.com/groundhog2k/helm-charts/tree/master/charts/mariadb
#helm repo add groundhog2k https://groundhog2k.github.io/helm-charts
#helm repo update
#helm install {{RELEASENAME}} groundhog2k/mariadb

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
-- category: infra, k8s, app, database, object-storage, utility
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES
(17, 'infra', 'Infrastructure'),
(18, 'k8s', 'Infrastructure - K8s'),
(19, 'app', 'Application Deployment'),
(20, 'database', 'Data - Backup / Restore'),
(21, 'utility', 'Common / Utility'),
(22, 'object-storage', 'Object Storage');

INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (17, 17, 1, 'infra-create', 'Create INFRA by CSP spec', '
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
                    payload = groovy.json.JsonOutput.toJson([
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
                echo "infra-create payload: ${payload}"
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
                        def keyCandidate = value.privateKey ?: value.sshKey ?: value.sshPrivateKey ?: value.private_key ?: value.ssh_private_key
                        if (!resolvedPrivateKey && keyCandidate) {
                            resolvedPrivateKey = keyCandidate.toString()
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (18, 17, 2, 'infra-get', 'Get single INFRA', '
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (19, 17, 3, 'infra-list', 'List INFRA', '
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (20, 17, 4, 'infra-update', 'Update INFRA spec, such as resize', '
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (21, 17, 5, 'infra-delete', 'Delete INFRA', '
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (22, 17, 6, 'infra-start', 'Start INFRA', '
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (23, 17, 7, 'infra-stop', 'Stop INFRA', '
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (24, 17, 8, 'infra-reboot', 'Reboot INFRA', '
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (25, 17, 9, 'infra-ssh-connect-check', 'Check INFRA SSH connectivity', '
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
                            def keyCandidate = value.privateKey ?: value.sshKey ?: value.sshPrivateKey ?: value.private_key ?: value.ssh_private_key
                            if (!resolvedPrivateKey && keyCandidate) {
                                resolvedPrivateKey = keyCandidate.toString()
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

                if (sshHost) {
                    def candidates = []
                    def addCandidate = { user ->
                        def candidate = user?.toString()?.trim()
                        if (candidate && !candidates.contains(candidate)) {
                            candidates << candidate
                        }
                    }
                    addCandidate(sshUser)
                    addCandidate(env.SSH_USER)
                    addCandidate(params.SSH_USER)
                    addCandidate("ubuntu")
                    addCandidate("ec2-user")
                    addCandidate("cb-user")
                    addCandidate("centos")
                    addCandidate("admin")
                    addCandidate("root")
                    def keyOpt = sshKeyFile ? "-i \"${sshKeyFile}\" -o IdentitiesOnly=yes" : ""
                    def connectedUser = ""
                    for (candidate in candidates) {
                        echo "SSH check try. user=${candidate}, host=${sshHost}"
                        def status = sh(script: """ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=15 ${keyOpt} "${candidate}@${sshHost}" "echo ssh-ok" """, returnStatus: true)
                        if (status == 0) {
                            connectedUser = candidate
                            break
                        }
                    }
                    if (!connectedUser) {
                        error "SSH connect check failed for host ${sshHost}. tried users: ${candidates.join(", ")}"
                    }
                    sshUser = connectedUser
                    env.SSH_HOST = sshHost
                    env.DB_HOST = sshHost
                    env.SSH_USER = connectedUser
                    if (sshKeyFile) {
                        env.SSH_KEY_FILE = sshKeyFile
                    }
                    echo "SSH connect check succeeded. SSH_HOST=${env.SSH_HOST}, SSH_USER=${env.SSH_USER}, SSH_KEY_FILE=${env.SSH_KEY_FILE ?: ""}"
                } else {
                    error "SSH_HOST is required for infra-ssh-connect-check"
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (50, 17, 10, 'multi-csp-vm-deploy', 'Deploy INFRA(VM) across 10 CSPs', '
    stage("multi-csp-vm-deploy") {
        steps {
            echo ">>>>> STAGE: multi-csp-vm-deploy"
            script {
                def cspList = (params.CSP_LIST ?: "").split(",").collect { it.trim() }.findAll { it }
                if (cspList.isEmpty()) {
                    error "CSP_LIST is required"
                }

                def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                def infraId = params.INFRA_ID ?: params.INFRA_PREFIX ?: "multi-csp-vm"
                def nodeGroupPrefix = params.INFRA_NODEGROUP_PREFIX ?: params.INFRA_NODEGROUP_NAME ?: "ng"
                def nodeGroups = []
                def providers = []
                def regions = []

                cspList.each { csp ->
                    def key = csp.toUpperCase().replaceAll("[^A-Z0-9]", "_")
                    def specId = params["${key}_SPEC_ID"]
                    def imageId = params["${key}_IMAGE_ID"]
                    def region = params["${key}_REGION"] ?: params.REGION ?: ""
                    def connectionName = params["${key}_CONNECTION_NAME"] ?: params.CONNECTION_NAME ?: (region ? "${csp}-${region}" : "")
                    def zone = params["${key}_ZONE"] ?: params.ZONE ?: ""
                    if (!specId || !imageId) {
                        error "${key}_SPEC_ID and ${key}_IMAGE_ID are required for ${csp}"
                    }

                    def nodeGroup = [
                        name: params["${key}_NODEGROUP_NAME"] ?: "${nodeGroupPrefix}-${key.toLowerCase().replaceAll("_", "-")}",
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

                    nodeGroups << nodeGroup
                    if (!providers.contains(csp)) {
                        providers << csp
                    }
                    if (region && !regions.contains(region)) {
                        regions << region
                    }
                }

                def payload = groovy.json.JsonOutput.toJson([
                    name: infraId,
                    description: params.INFRA_DESC ?: "Workflow multi CSP VM deploy",
                    installMonAgent: params.INSTALL_MON_AGENT ?: "no",
                    policyOnPartialFailure: params.POLICY_ON_PARTIAL_FAILURE ?: "continue",
                    label: [
                        csp: providers.join(","),
                        region: regions.join(",")
                    ],
                    nodeGroups: nodeGroups
                ])

                writeFile file: "infra-create.json", text: payload
                echo "multi-csp-vm-deploy payload: ${payload}"
                def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X POST "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/infraDynamic" -H "Content-Type: application/json" -d @infra-create.json ${auth}""", returnStdout: true).trim()
                echo response
                if (!response.contains("Http_Status_code:2")) {
                    error "multi-csp-vm-deploy failed: ${response}"
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (52, 17, 11, 'multi-csp-vm-delete', 'Delete INFRA(VM) created by multi-csp-vm-deploy', '
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
                def targetInfraIds = []

                if (!explicitInfraIds.isEmpty()) {
                    explicitInfraIds.each { infraId ->
                        if (!targetInfraIds.contains(infraId)) {
                            targetInfraIds << infraId
                        }
                    }
                } else {
                    def infraId = params.INFRA_ID ?: params.INFRA_PREFIX ?: "multi-csp-vm"
                    if (!targetInfraIds.contains(infraId)) {
                        targetInfraIds << infraId
                    }
                }

                def option = params.INFRA_DELETE_OPTION ?: "terminate"
                def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                def deletedInfra = []
                def skippedInfra = []
                def failedDeletes = []
                def isAbsent = { value ->
                    def textValue = value ?: ""
                    def lowerValue = textValue.toLowerCase()
                    return textValue.contains("Http_Status_code:404") ||
                            lowerValue.contains("not exist") ||
                            lowerValue.contains("does not exist") ||
                            lowerValue.contains("failed to find")
                }

                targetInfraIds.each { infraId ->
                    echo "Deleting infra ${infraId}"
                    def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X DELETE "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/infra/${infraId}?option=${option}" ${auth}""", returnStdout: true).trim()
                    echo response

                    if (isAbsent(response)) {
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (60, 17, 12, 'infra-cleanup', 'Idempotently clean up a single INFRA', '
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
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (26, 18, 1, 'k8s-cluster-create', 'Create K8s cluster', '
    stage("k8s-cluster-create") {
        steps {
            echo ">>>>> STAGE: k8s-cluster-create"
            script {
                def payload = params.K8S_CREATE_PAYLOAD?.trim()
                def k8sVersion = params.K8S_VERSION?.trim() ?: "1.33"
                def nodeGroupName = params.K8S_NODEGROUP_NAME ?: "ng1"
                def desiredNodeSize = (params.K8S_DESIRED_NODE_SIZE ?: "1").toInteger()
                def minNodeSize = (params.K8S_MIN_NODE_SIZE ?: "1").toInteger()
                def maxNodeSize = (params.K8S_MAX_NODE_SIZE ?: "3").toInteger()
                def resolveK8sRootDiskType = { csp ->
                    def diskType = params.ROOT_DISK_TYPE?.trim() ?: "default"
                    if (csp?.equalsIgnoreCase("alibaba") && diskType.equalsIgnoreCase("default")) {
                        return "cloud_essd"
                    }
                    return diskType
                }
                if (!payload) {
                    def provider = params.CSP ?: params.PROVIDER ?: ""
                    def region = params.REGION ?: ""
                    def connectionName = params.CONNECTION_NAME ?: params.CONNECTION_CONFIG_NAME ?: (provider && region ? "${provider}-${region}" : "")
                    def imageId = params.IMAGE_ID?.trim() ?: ""
                    def rootDiskType = resolveK8sRootDiskType(provider)
                    def usesProviderManagedK8sImage = provider?.equalsIgnoreCase("azure") || provider?.equalsIgnoreCase("ibm") || provider?.equalsIgnoreCase("ncp") || provider?.equalsIgnoreCase("tencent")
                    if (!params.SPEC_ID?.trim()) {
                        error "SPEC_ID is required"
                    }
                    if (!imageId && !usesProviderManagedK8sImage) {
                        error "IMAGE_ID is required"
                    }
                    def payloadMap = [
                        name: params.K8S_CLUSTER_ID,
                        nodeGroupName: nodeGroupName,
                        specId: params.SPEC_ID,
                        label: [
                            provider: provider,
                            region: region
                        ],
                        version: k8sVersion,
                        nodeGroupSize: desiredNodeSize,
                        desiredNodeSize: desiredNodeSize,
                        minNodeSize: minNodeSize,
                        maxNodeSize: maxNodeSize,
                        rootDiskType: rootDiskType,
                        rootDiskSize: (params.ROOT_DISK_SIZE ?: "30").toInteger()
                    ]
                    if (imageId) {
                        payloadMap.imageId = imageId
                    }
                    if (connectionName) {
                        payloadMap.connectionName = connectionName
                    }
                    if (params.ZONE?.trim()) {
                        payloadMap.zone = params.ZONE.trim()
                    }
                    payload = groovy.json.JsonOutput.toJson(payloadMap)
                } else if (payload.contains("\"version\":\"\"")) {
                    payload = payload.replace("\"version\":\"\"", "\"version\":\"${k8sVersion}\"")
                } else if (!payload.contains("\"version\"")) {
                    def trimmedPayload = payload.trim()
                    if (!trimmedPayload.endsWith("}")) {
                        error "K8S_CREATE_PAYLOAD must be a JSON object"
                    }
                    payload = trimmedPayload.substring(0, trimmedPayload.length() - 1) + ",\"version\":\"${k8sVersion}\"}"
                }
                writeFile file: "k8s-cluster-create.json", text: payload
                echo "k8s-cluster-create payload: ${payload}"
                def option = params.K8S_CREATE_OPTION ? "?option=${params.K8S_CREATE_OPTION}" : ""
                def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                def clusterCreated = false
                def existingResponse = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/k8sCluster/${params.K8S_CLUSTER_ID}?option=status" ${auth}""", returnStdout: true).trim()
                if (existingResponse.contains("Http_Status_code:2")) {
                    echo "k8s cluster already exists. reuse existing cluster: ${params.K8S_CLUSTER_ID}"
                } else {
                    def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X POST "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/k8sClusterDynamic${option}" -H "Content-Type: application/json" -d @k8s-cluster-create.json ${auth}""", returnStdout: true).trim()
                    echo response
                    if (!response.contains("Http_Status_code:2")) {
                        error "k8s-cluster-create failed: ${response}"
                    }
                    clusterCreated = true
                }
                if (clusterCreated) {
                    echo "k8s cluster create accepted. Wait 60 seconds before status polling."
                    sleep time: 60, unit: "SECONDS"
                }
                def readyStatuses = (params.K8S_READY_STATUS ?: "Active,Running").split(",").collect { it.trim().toLowerCase() }.findAll { it }
                def statusAttempts = (params.K8S_STATUS_MAX_ATTEMPTS ?: "60").toInteger()
                def statusIntervalSeconds = (params.K8S_STATUS_INTERVAL_SECONDS ?: "60").toInteger()
                def statusResponse = ""
                def currentStatus = ""
                def hasNodeGroupInfo = { response ->
                    def compactResponse = (response ?: "").replaceAll("\\s+", "").toLowerCase()
                    def hasDirectNodeGroup = compactResponse.contains("\"k8snodegrouplist\":[{")
                    def hasSpiderNodeGroup = compactResponse.contains("\"nodegrouplist\":[{")
                    return hasDirectNodeGroup || hasSpiderNodeGroup
                }
                def isKubeconfigReadyInStatus = { response ->
                    def compactResponse = (response ?: "").replaceAll("\\s+", "").toLowerCase()
                    if (!hasNodeGroupInfo(response)) {
                        return false
                    }
                    if (compactResponse.contains("\"k8snodes\":[]")) {
                        return false
                    }
                    if (compactResponse.contains("\"key\":\"clusternodenum\",\"value\":\"0\"")) {
                        return false
                    }
                    // Decide on what a ready kubeconfig looks like, not on how a CSP words its
                    // placeholder. Each Spider driver phrases "not ready yet" differently, so a list
                    // of those messages is never complete: NCP answers "Kubeconfig will be available
                    // after cluster reaches RUNNING status" and passed the old check as ready.
                    // Test what k8s-kubeconfig-get binds on: a kubeconfig that carries a server
                    // URL. Do not test which key comes first, because the drivers that hand the CSP
                    // bytes through unchanged may lead with a document marker, a comment or a BOM.
                    // In compacted JSON every key is followed by a quote before its colon, so a bare
                    // server:https:// can only come from YAML inside a string value.
                    def hasKubeconfigField = compactResponse.contains("\"kubeconfig\":\"")
                    def hasKubeconfigHead = compactResponse.contains("apiversion:v1") ||
                        compactResponse.contains("kind:config")
                    def hasKubeconfigServer = compactResponse.contains("server:https://") ||
                        compactResponse.contains("server:http://")
                    if (!hasKubeconfigField || !hasKubeconfigHead || !hasKubeconfigServer) {
                        return false
                    }
                    return true
                }
                for (int attempt = 1; attempt <= statusAttempts; attempt++) {
                    statusResponse = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/k8sCluster/${params.K8S_CLUSTER_ID}?option=status" ${auth}""", returnStdout: true).trim()
                    currentStatus = ""
                    if (statusResponse.contains("Http_Status_code:2")) {
                        def normalizedStatusResponse = statusResponse.toLowerCase()
                        for (def readyStatus : readyStatuses) {
                            if (normalizedStatusResponse.contains("\"status\":\"${readyStatus}\"") ||
                                    normalizedStatusResponse.contains("\"status\": \"${readyStatus}\"")) {
                                currentStatus = readyStatus
                                break
                            }
                        }
                    }
                    if (currentStatus) {
                        break
                    }
                    def displayStatus = currentStatus ?: "unknown"
                    echo "k8s cluster is not ready. currentStatus=${displayStatus}, attempt ${attempt}/${statusAttempts}: ${statusResponse}"
                    sleep time: statusIntervalSeconds, unit: "SECONDS"
                }
                if (!statusResponse.contains("Http_Status_code:2") || !currentStatus) {
                    error "k8s-cluster-create status check failed: ${statusResponse}"
                }
                def createNodeGroupIfMissing = !(params.K8S_NODEGROUP_CREATE_IF_MISSING?.trim()?.equalsIgnoreCase("false"))
                def waitForNodeGroupReadiness = { reason ->
                    echo "wait for k8s node group readiness. reason=${reason}"
                    for (int attempt = 1; attempt <= statusAttempts; attempt++) {
                        statusResponse = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/k8sCluster/${params.K8S_CLUSTER_ID}?option=status" ${auth}""", returnStdout: true).trim()
                        if (isKubeconfigReadyInStatus(statusResponse)) {
                            break
                        }
                        if (!hasNodeGroupInfo(statusResponse)) {
                            echo "k8s node group is not registered yet. attempt ${attempt}/${statusAttempts}: ${statusResponse}"
                        } else {
                            echo "k8s node group is registered but nodes or kubeconfig are not ready yet. attempt ${attempt}/${statusAttempts}: ${statusResponse}"
                        }
                        sleep time: statusIntervalSeconds, unit: "SECONDS"
                    }
                    if (!isKubeconfigReadyInStatus(statusResponse)) {
                        error "k8s kubeconfig or node group was not ready: ${statusResponse}"
                    }
                }
                if (!hasNodeGroupInfo(statusResponse)) {
                    if (!createNodeGroupIfMissing) {
                        error "k8s cluster is ready but node group is missing: ${statusResponse}"
                    }
                    def missingConfirmed = true
                    for (int missingAttempt = 1; missingAttempt <= 3; missingAttempt++) {
                        if (missingAttempt > 1) {
                            sleep time: statusIntervalSeconds, unit: "SECONDS"
                            statusResponse = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/k8sCluster/${params.K8S_CLUSTER_ID}?option=status" ${auth}""", returnStdout: true).trim()
                        }
                        if (hasNodeGroupInfo(statusResponse)) {
                            echo "k8s node group appeared before create request. confirmation ${missingAttempt}/3."
                            missingConfirmed = false
                            break
                        }
                        echo "k8s node group is missing after cluster ready. confirmation ${missingAttempt}/3: ${statusResponse}"
                    }
                    if (!missingConfirmed) {
                        waitForNodeGroupReadiness("node group appeared during missing confirmation")
                    } else {
                        echo "k8s node group is missing. Create node group ${nodeGroupName} with k8sNodeGroupDynamic."
                        def nodeGroupZone = params.ZONE?.trim() ?: ""
                        if (!nodeGroupZone) {
                            def assignedZoneMarker = "\"assignedZone\":\""
                            def assignedZoneIndex = (statusResponse ?: "").indexOf(assignedZoneMarker)
                            if (assignedZoneIndex >= 0) {
                                def assignedZoneStart = assignedZoneIndex + assignedZoneMarker.length()
                                def assignedZoneEnd = statusResponse.indexOf("\"", assignedZoneStart)
                                if (assignedZoneEnd > assignedZoneStart) {
                                    nodeGroupZone = statusResponse.substring(assignedZoneStart, assignedZoneEnd)
                                }
                            }
                        }
                        if (!nodeGroupZone) {
                            def zoneMarker = "\"key\":\"ZoneId\",\"value\":\""
                            def zoneIndex = (statusResponse ?: "").indexOf(zoneMarker)
                            if (zoneIndex >= 0) {
                                def zoneStart = zoneIndex + zoneMarker.length()
                                def zoneEnd = statusResponse.indexOf("\"", zoneStart)
                                if (zoneEnd > zoneStart) {
                                    nodeGroupZone = statusResponse.substring(zoneStart, zoneEnd)
                                }
                            }
                        }
                        echo "k8s node group resolved zone: ${nodeGroupZone}"
                        def nodeGroupRootDiskType = resolveK8sRootDiskType(params.CSP ?: params.PROVIDER ?: "")
                        def nodeGroupMap = [
                            name: nodeGroupName,
                            specId: params.SPEC_ID,
                            nodeGroupSize: desiredNodeSize,
                            desiredNodeSize: desiredNodeSize,
                            minNodeSize: minNodeSize,
                            maxNodeSize: maxNodeSize,
                            rootDiskType: nodeGroupRootDiskType,
                            rootDiskSize: (params.ROOT_DISK_SIZE ?: "30").toInteger()
                        ]
                        if (params.IMAGE_ID?.trim()) {
                            nodeGroupMap.imageId = params.IMAGE_ID.trim()
                        }
                        if (nodeGroupZone) {
                            nodeGroupMap.zone = nodeGroupZone
                        }
                        def nodeGroupPayload = groovy.json.JsonOutput.toJson(nodeGroupMap)
                        writeFile file: "k8s-nodegroup-add.json", text: nodeGroupPayload
                        echo "k8s-nodegroup-add payload: ${nodeGroupPayload}"
                        def nodeGroupAccepted = false
                        for (int nodeGroupCreateAttempt = 1; nodeGroupCreateAttempt <= 3; nodeGroupCreateAttempt++) {
                            echo "k8s-nodegroup-add request attempt ${nodeGroupCreateAttempt}/3"
                            def nodeGroupResponse = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X POST "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/k8sCluster/${params.K8S_CLUSTER_ID}/k8sNodeGroupDynamic" -H "Content-Type: application/json" -d @k8s-nodegroup-add.json ${auth}""", returnStdout: true).trim()
                            echo nodeGroupResponse
                            if (nodeGroupResponse.contains("Http_Status_code:2") || nodeGroupResponse.toLowerCase().contains("already")) {
                                nodeGroupAccepted = true
                                break
                            }
                            if (nodeGroupCreateAttempt == 3) {
                                error "k8s-nodegroup-add failed after 3 attempts: ${nodeGroupResponse}"
                            }
                            echo "k8s-nodegroup-add was not accepted. Wait ${statusIntervalSeconds} seconds before retry."
                            sleep time: statusIntervalSeconds, unit: "SECONDS"
                        }
                        if (nodeGroupAccepted) {
                            waitForNodeGroupReadiness("node group create accepted")
                        }
                    }
                } else if (!isKubeconfigReadyInStatus(statusResponse)) {
                    waitForNodeGroupReadiness("node group already exists")
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (27, 18, 2, 'k8s-cluster-get', 'Get single cluster', '
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (28, 18, 3, 'k8s-cluster-list', 'List clusters', '
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (29, 18, 4, 'k8s-cluster-update', 'Update cluster, such as node count', '
    stage("k8s-cluster-update") {
        steps {
            echo ">>>>> STAGE: k8s-cluster-update"
            script {
                def payload = params.K8S_UPDATE_PAYLOAD?.trim()
                if (!payload) {
                    payload = groovy.json.JsonOutput.toJson([version: params.K8S_VERSION])
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (30, 18, 5, 'k8s-cluster-delete', 'Delete cluster', '
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (31, 18, 6, 'k8s-nodegroup-add', 'Add node group', '
    stage("k8s-nodegroup-add") {
        steps {
            echo ">>>>> STAGE: k8s-nodegroup-add"
            script {
                def payload = params.K8S_NODEGROUP_PAYLOAD?.trim()
                if (!payload) {
                    def imageId = params.IMAGE_ID?.trim() ?: ""
                    def provider = params.CSP ?: params.PROVIDER ?: ""
                    def rootDiskType = params.ROOT_DISK_TYPE?.trim() ?: "default"
                    if (provider?.equalsIgnoreCase("alibaba") && rootDiskType.equalsIgnoreCase("default")) {
                        rootDiskType = "cloud_essd"
                    }
                    def usesProviderManagedK8sImage = provider?.equalsIgnoreCase("azure") || provider?.equalsIgnoreCase("ibm") || provider?.equalsIgnoreCase("ncp") || provider?.equalsIgnoreCase("tencent")
                    if (!params.SPEC_ID?.trim()) {
                        error "SPEC_ID is required"
                    }
                    if (!imageId && !usesProviderManagedK8sImage) {
                        error "IMAGE_ID is required"
                    }
                    def payloadMap = [
                        name: params.K8S_NODEGROUP_NAME,
                        specId: params.SPEC_ID,
                        nodeGroupSize: (params.K8S_DESIRED_NODE_SIZE ?: "1").toInteger(),
                        desiredNodeSize: (params.K8S_DESIRED_NODE_SIZE ?: "1").toInteger(),
                        minNodeSize: (params.K8S_MIN_NODE_SIZE ?: "1").toInteger(),
                        maxNodeSize: (params.K8S_MAX_NODE_SIZE ?: "3").toInteger(),
                        rootDiskType: rootDiskType,
                        rootDiskSize: (params.ROOT_DISK_SIZE ?: "30").toInteger()
                    ]
                    if (imageId) {
                        payloadMap.imageId = imageId
                    }
                    if (params.ZONE?.trim()) {
                        payloadMap.zone = params.ZONE.trim()
                    }
                    payload = groovy.json.JsonOutput.toJson(payloadMap)
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (32, 18, 7, 'k8s-nodegroup-remove', 'Remove node group', '
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (33, 18, 8, 'k8s-kubeconfig-get', 'Get kubeconfig', '
    stage("k8s-kubeconfig-get") {
        steps {
            echo ">>>>> STAGE: k8s-kubeconfig-get"
            script {
                def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                def response = ""
                def kubeconfigAttempts = (params.K8S_KUBECONFIG_MAX_ATTEMPTS ?: "30").toInteger()
                def kubeconfigIntervalSeconds = (params.K8S_KUBECONFIG_INTERVAL_SECONDS ?: "10").toInteger()
                def isKubeconfigResponseReady = { text ->
                    def lowerText = (text ?: "").toLowerCase()
                    if (!text?.contains("Http_Status_code:2")) {
                        return false
                    }
                    if (lowerText.contains("kubeconfig is not ready yet")) {
                        return false
                    }
                    if (lowerText.contains("first, add a nodegroup")) {
                        return false
                    }
                    return lowerText.contains("apiversion:") || lowerText.contains("\"kubeconfig\"") || lowerText.contains("\"kubeconfig\":")
                }
                for (int attempt = 1; attempt <= kubeconfigAttempts; attempt++) {
                    response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/k8sCluster/${params.K8S_CLUSTER_ID}/kubeconfig" ${auth}""", returnStdout: true).trim()
                    if (isKubeconfigResponseReady(response)) {
                        break
                    }
                    echo "kubeconfig is not ready. attempt ${attempt}/${kubeconfigAttempts}: ${response}"
                    sleep time: kubeconfigIntervalSeconds, unit: "SECONDS"
                }
                echo response
                if (!isKubeconfigResponseReady(response)) {
                    error "k8s-kubeconfig-get failed or kubeconfig was not ready: ${response}"
                }
                def body = response.replaceAll("- Http_Status_code:[0-9]{3}", "").trim()
                writeFile file: "kubeconfig-response.json", text: body
                def kubeconfig = null
                def extractJsonStringValue = { text, keys ->
                    if (!text) {
                        return null
                    }
                    def quote = "\"".charAt(0)
                    def backslash = "\\".charAt(0)
                    for (def key : keys) {
                        def keyMarker = "\"" + key + "\""
                        def searchFrom = 0
                        while (searchFrom < text.length()) {
                            def keyIndex = text.indexOf(keyMarker, searchFrom)
                            if (keyIndex < 0) {
                                break
                            }
                            def colonIndex = text.indexOf(":", keyIndex + keyMarker.length())
                            if (colonIndex < 0) {
                                break
                            }
                            def quoteIndex = text.indexOf("\"", colonIndex + 1)
                            if (quoteIndex < 0) {
                                break
                            }
                            def value = new StringBuilder()
                            def escaped = false
                            for (int i = quoteIndex + 1; i < text.length(); i++) {
                                def ch = text.charAt(i)
                                if (escaped) {
                                    if (ch == "n".charAt(0)) {
                                        value.append("\n")
                                    } else if (ch == "r".charAt(0)) {
                                        value.append("\r")
                                    } else if (ch == "t".charAt(0)) {
                                        value.append("\t")
                                    } else if (ch == "b".charAt(0)) {
                                        value.append("\b")
                                    } else if (ch == "f".charAt(0)) {
                                        value.append("\f")
                                    } else {
                                        value.append(ch)
                                    }
                                    escaped = false
                                } else if (ch == backslash) {
                                    escaped = true
                                } else if (ch == quote) {
                                    return value.toString()
                                } else {
                                    value.append(ch)
                                }
                            }
                            searchFrom = keyIndex + keyMarker.length()
                        }
                    }
                    return null
                }
                if (body.startsWith("apiVersion:") && body.contains("\nclusters:")) {
                    kubeconfig = body
                } else {
                    kubeconfig = extractJsonStringValue(body, ["Kubeconfig", "kubeconfig", "config"])
                }
                if (!kubeconfig) {
                    error "kubeconfig content was not found in response"
                }
                if (!kubeconfig.readLines().any { it.trim().startsWith("server:") }) {
                    error "kubeconfig server was not found after decoding Tumblebug response"
                }
                if (kubeconfig.contains("exec:")
                        && params.TUMBLEBUG?.trim()
                        && params.NAMESPACE?.trim()
                        && params.K8S_CLUSTER_ID?.trim()) {
                    def tokenResponse = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/k8sCluster/${params.K8S_CLUSTER_ID}/token" ${auth}""", returnStdout: true).trim()
                    if (tokenResponse.contains("Http_Status_code:2")) {
                        def tokenBody = tokenResponse.replaceAll("- Http_Status_code:[0-9]{3}", "").trim()
                        writeFile file: "kubeconfig-token-response.json", text: tokenBody
                        def k8sToken = extractJsonStringValue(tokenBody, ["token"])
                        if (k8sToken) {
                            def rewritten = []
                            def skipExecBlock = false
                            def injected = false
                            for (def line : kubeconfig.readLines()) {
                                if (!skipExecBlock && line.trim() == "exec:") {
                                    rewritten << line.replace("exec:", "token: ${k8sToken}")
                                    skipExecBlock = true
                                    injected = true
                                    continue
                                }
                                if (skipExecBlock) {
                                    if (line.startsWith("      ") || !line.trim()) {
                                        continue
                                    }
                                    skipExecBlock = false
                                }
                                rewritten << line
                            }
                            if (injected) {
                                kubeconfig = rewritten.join("\n") + "\n"
                                echo "kubeconfig auth was converted from exec plugin to Tumblebug-issued token"
                            }
                        } else {
                            echo "Tumblebug token response did not include execCredential.status.token"
                        }
                    } else {
                        echo "Tumblebug token request failed. Keep kubeconfig exec auth. response=${tokenResponse}"
                    }
                }
                writeFile file: "kubeconfig", text: kubeconfig
                env.KUBECONFIG_FILE = "kubeconfig"
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (51, 18, 9, 'multi-csp-k8s-cluster-deploy', 'Deploy K8s clusters across 8 CSPs', '
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
                    def k8sVersion = params["${key}_K8S_VERSION"]?.trim() ?: params.K8S_VERSION?.trim() ?: "1.33"
                    def rootDiskType = params.ROOT_DISK_TYPE?.trim() ?: "default"
                    if (csp?.equalsIgnoreCase("alibaba") && rootDiskType.equalsIgnoreCase("default")) {
                        rootDiskType = "cloud_essd"
                    }
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
                        version: k8sVersion,
                        nodeGroupSize: (params.K8S_DESIRED_NODE_SIZE ?: "1").toInteger(),
                        desiredNodeSize: (params.K8S_DESIRED_NODE_SIZE ?: "1").toInteger(),
                        minNodeSize: (params.K8S_MIN_NODE_SIZE ?: "1").toInteger(),
                        maxNodeSize: (params.K8S_MAX_NODE_SIZE ?: "3").toInteger(),
                        rootDiskType: rootDiskType,
                        rootDiskSize: (params.ROOT_DISK_SIZE ?: "30").toInteger()
                    ]
                    if (connectionName) {
                        payloadMap.connectionName = connectionName
                    }

                    def payload = groovy.json.JsonOutput.toJson(payloadMap)

                    writeFile file: "k8s-cluster-create-${csp}.json", text: payload
                    echo "k8s-cluster-create-${csp} payload: ${payload}"
                    def option = params.K8S_CREATE_OPTION ? "?option=${params.K8S_CREATE_OPTION}" : ""
                    def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X POST "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/k8sClusterDynamic${option}" -H "Content-Type: application/json" -d @k8s-cluster-create-${csp}.json ${auth}""", returnStdout: true).trim()
                    echo response
                    if (!response.contains("Http_Status_code:2")) {
                        error "multi-csp-k8s-cluster-deploy failed for ${csp}: ${response}"
                    }
                    def readyStatuses = (params.K8S_READY_STATUS ?: "Active,Running").split(",").collect { it.trim().toLowerCase() }.findAll { it }
                    def statusAttempts = (params.K8S_STATUS_MAX_ATTEMPTS ?: "360").toInteger()
                    def statusIntervalSeconds = (params.K8S_STATUS_INTERVAL_SECONDS ?: "10").toInteger()
                    def statusResponse = ""
                    def currentStatus = ""
                    for (int attempt = 1; attempt <= statusAttempts; attempt++) {
                        statusResponse = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/k8sCluster/${clusterId}?option=status" ${auth}""", returnStdout: true).trim()
                        currentStatus = ""
                        if (statusResponse.contains("Http_Status_code:2")) {
                            def normalizedStatusResponse = statusResponse.toLowerCase()
                            for (def readyStatus : readyStatuses) {
                                if (normalizedStatusResponse.contains("\"status\":\"${readyStatus}\"") ||
                                        normalizedStatusResponse.contains("\"status\": \"${readyStatus}\"")) {
                                    currentStatus = readyStatus
                                    break
                                }
                            }
                        }
                        if (currentStatus) {
                            break
                        }
                        def displayStatus = currentStatus ?: "unknown"
                        echo "k8s cluster ${clusterId} is not ready. currentStatus=${displayStatus}, attempt ${attempt}/${statusAttempts}: ${statusResponse}"
                        sleep time: statusIntervalSeconds, unit: "SECONDS"
                    }
                    if (!statusResponse.contains("Http_Status_code:2") || !currentStatus) {
                        error "multi-csp-k8s-cluster-deploy status check failed for ${csp}: ${statusResponse}"
                    }
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (53, 18, 10, 'multi-csp-k8s-cluster-delete', 'Delete K8s clusters created by multi-csp-k8s-cluster-deploy', '
    stage("multi-csp-k8s-cluster-delete") {
        steps {
            echo ">>>>> STAGE: multi-csp-k8s-cluster-delete"
            script {
                if (!params.TUMBLEBUG?.trim()) {
                    error "TUMBLEBUG is required"
                }
                if (!params.NAMESPACE?.trim()) {
                    error "NAMESPACE is required"
                }

                def explicitClusterIds = (params.K8S_CLUSTER_ID_LIST ?: "").split(",").collect { it.trim() }.findAll { it }
                def cspList = (params.CSP_LIST ?: "").split(",").collect { it.trim() }.findAll { it }
                def targetClusters = []

                def resolveNodeGroupNames = { csp ->
                    def explicitNodeGroups = (params.K8S_NODEGROUP_NAME_LIST ?: params.K8S_NODEGROUP_NAME ?: "").split(",").collect { it.trim() }.findAll { it }
                    if (!explicitNodeGroups.isEmpty()) {
                        return explicitNodeGroups
                    }
                    def nodeGroupPrefix = params.K8S_NODEGROUP_PREFIX ?: "ng"
                    return csp ? ["${nodeGroupPrefix}-${csp}"] : []
                }

                if (!explicitClusterIds.isEmpty()) {
                    explicitClusterIds.each { clusterId ->
                        targetClusters << [clusterId: clusterId, csp: "", nodeGroupNames: resolveNodeGroupNames("")]
                    }
                } else {
                    if (cspList.isEmpty()) {
                        error "CSP_LIST or K8S_CLUSTER_ID_LIST is required"
                    }
                    def clusterPrefix = params.CLUSTER_PREFIX ?: "multi-csp-k8s"
                    cspList.each { csp ->
                        targetClusters << [clusterId: "${clusterPrefix}-${csp}", csp: csp, nodeGroupNames: resolveNodeGroupNames(csp)]
                    }
                }

                def option = params.K8S_DELETE_OPTION ?: "force"
                def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                def intervalSeconds = (params.K8S_DELETE_INTERVAL_SECONDS ?: "10").toInteger()
                def nodeGroupAttempts = (params.K8S_NODEGROUP_DELETE_MAX_ATTEMPTS ?: "120").toInteger()
                def clusterAttempts = (params.K8S_CLUSTER_DELETE_MAX_ATTEMPTS ?: "120").toInteger()
                def deletedClusters = []
                def skippedClusters = []
                def failedDeletes = []

                def isAbsent = { value ->
                    def textValue = value ?: ""
                    def lowerValue = textValue.toLowerCase()
                    def notFoundStatus = textValue.contains("Http_Status_code:404")
                    def notExistMessage = lowerValue.contains("not exist")
                    def failedToFindMessage = lowerValue.contains("failed to find")
                    return notFoundStatus || notExistMessage || failedToFindMessage
                }
                def hasNodeGroupInfo = { value ->
                    def compactValue = (value ?: "").replaceAll("\\s+", "").toLowerCase()
                    def directNodeGroup = compactValue.contains("\"k8snodegrouplist\":[{")
                    def spiderNodeGroup = compactValue.contains("\"nodegrouplist\":[{")
                    return directNodeGroup || spiderNodeGroup
                }
                def extractNodeGroupNames = { value ->
                    def textValue = value ?: ""
                    def names = []
                    def addName = { name ->
                        def normalizedName = (name ?: "").trim()
                        if (normalizedName && !names.contains(normalizedName)) {
                            names << normalizedName
                        }
                    }
                    (textValue =~ /"k8sNodeGroupList"\s*:\s*\[\s*\{[^]]*?"id"\s*:\s*"([^"]+)"/).each { match ->
                        addName(match[1])
                    }
                    (textValue =~ /"k8sNodeGroupList"\s*:\s*\[\s*\{[^]]*?"name"\s*:\s*"([^"]+)"/).each { match ->
                        addName(match[1])
                    }
                    (textValue =~ /"NodeGroupList"\s*:\s*\[\s*\{[^]]*?"NameId"\s*:\s*"([^"]+)"/).each { match ->
                        addName(match[1])
                    }
                    (textValue =~ /"spiderViewK8sNodeGroupDetail"\s*:\s*\{.*?"NameId"\s*:\s*"([^"]+)"/).each { match ->
                        addName(match[1])
                    }
                    return names
                }
                def deleteAccepted = { action, value ->
                    def textValue = value ?: ""
                    def lowerValue = textValue.toLowerCase()
                    if (isAbsent(value)) {
                        echo "${action} target is already absent."
                        return true
                    }
                    if (lowerValue.contains("not deleted")) {
                        echo "${action} was not deleted by Tumblebug: ${value}"
                        return false
                    }
                    if (!textValue.contains("Http_Status_code:2")) {
                        echo "${action} failed: ${value}"
                        return false
                    }
                    return true
                }

                targetClusters.each { target ->
                    def clusterId = target.clusterId
                    def clusterUrl = "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/k8sCluster/${clusterId}"
                    echo "Deleting K8s cluster ${clusterId}"

                    def statusResponse = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${clusterUrl}?option=status" ${auth}""", returnStdout: true).trim()
                    echo statusResponse
                    if (isAbsent(statusResponse)) {
                        skippedClusters << clusterId
                        echo "K8s cluster ${clusterId} is already absent in Tumblebug."
                        return
                    }
                    if (!statusResponse.contains("Http_Status_code:2")) {
                        failedDeletes << "${clusterId}: status check failed: ${statusResponse}"
                        return
                    }

                    if (hasNodeGroupInfo(statusResponse)) {
                        def nodeGroupNames = []
                        (target.nodeGroupNames ?: []).each { nodeGroupName ->
                            def normalizedName = (nodeGroupName ?: "").trim()
                            if (normalizedName && !nodeGroupNames.contains(normalizedName)) {
                                nodeGroupNames << normalizedName
                            }
                        }
                        extractNodeGroupNames(statusResponse).each { nodeGroupName ->
                            if (nodeGroupName && !nodeGroupNames.contains(nodeGroupName)) {
                                nodeGroupNames << nodeGroupName
                            }
                        }
                        if (nodeGroupNames.isEmpty()) {
                            echo "K8s node group exists in ${clusterId}, but node group name is not configured. Try cluster delete fallback."
                        } else {
                            def nodeGroupDeleteFailed = false
                            def nodeGroupDeleteRequested = false
                            echo "K8s node groups selected for ${clusterId}: ${nodeGroupNames.join(", ")}"
                            nodeGroupNames.each { nodeGroupName ->
                                def nodeGroupUrl = "${clusterUrl}/k8sNodeGroup/${nodeGroupName}?option=${option}"
                                def nodeGroupResponse = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X DELETE "${nodeGroupUrl}" ${auth}""", returnStdout: true).trim()
                                echo nodeGroupResponse
                                def nodeGroupAlreadyAbsent = isAbsent(nodeGroupResponse)
                                def nodeGroupAccepted = deleteAccepted("k8s-nodegroup-remove ${clusterId}/${nodeGroupName}", nodeGroupResponse)
                                if (!nodeGroupAccepted) {
                                    nodeGroupDeleteFailed = true
                                    echo "k8s-nodegroup-remove ${clusterId}/${nodeGroupName} failed. Try cluster delete fallback."
                                } else if (!nodeGroupAlreadyAbsent) {
                                    nodeGroupDeleteRequested = true
                                }
                            }

                            if (nodeGroupDeleteFailed) {
                                echo "Skip node group delete polling for ${clusterId}. Continue with cluster delete fallback."
                            } else if (!nodeGroupDeleteRequested) {
                                echo "No existing node group delete request was accepted for ${clusterId}. Continue with cluster delete fallback."
                            } else {
                                for (int attempt = 1; attempt <= nodeGroupAttempts; attempt++) {
                                    statusResponse = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${clusterUrl}?option=status" ${auth}""", returnStdout: true).trim()
                                    if (isAbsent(statusResponse) || !hasNodeGroupInfo(statusResponse)) {
                                        break
                                    }
                                    def lowerStatus = statusResponse.toLowerCase()
                                    def nodeGroupState = "Unknown"
                                    if (lowerStatus.contains("\"status\":\"deleting\"") || lowerStatus.contains("\"status\": \"deleting\"")) {
                                        nodeGroupState = "Deleting"
                                    }
                                    echo "k8s node group for ${clusterId} is still deleting. state=${nodeGroupState}, attempt ${attempt}/${nodeGroupAttempts}"
                                    sleep time: intervalSeconds, unit: "SECONDS"
                                }
                                if (!isAbsent(statusResponse) && hasNodeGroupInfo(statusResponse)) {
                                    echo "k8s node group for ${clusterId} still exists after polling. Continue with cluster delete fallback."
                                }
                            }
                        }
                    }

                    def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X DELETE "${clusterUrl}?option=${option}" ${auth}""", returnStdout: true).trim()
                    echo response
                    if (!deleteAccepted("multi-csp-k8s-cluster-delete ${clusterId}", response)) {
                        failedDeletes << "${clusterId}: cluster delete failed: ${response}"
                        return
                    }

                    def clusterDeleted = isAbsent(response)
                    for (int attempt = 1; !clusterDeleted && attempt <= clusterAttempts; attempt++) {
                        statusResponse = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${clusterUrl}?option=status" ${auth}""", returnStdout: true).trim()
                        clusterDeleted = isAbsent(statusResponse)
                        if (clusterDeleted) {
                            break
                        }
                        if (statusResponse.toLowerCase().contains("not deleted")) {
                            failedDeletes << "${clusterId}: cluster was not deleted by Tumblebug: ${statusResponse}"
                            break
                        }
                        def lowerClusterStatus = statusResponse.toLowerCase()
                        def clusterState = "Unknown"
                        if (lowerClusterStatus.contains("\"status\":\"deleting\"") || lowerClusterStatus.contains("\"status\": \"deleting\"")) {
                            clusterState = "Deleting"
                        }
                        echo "k8s cluster ${clusterId} is still deleting. state=${clusterState}, attempt ${attempt}/${clusterAttempts}"
                        sleep time: intervalSeconds, unit: "SECONDS"
                    }
                    if (!clusterDeleted) {
                        failedDeletes << "${clusterId}: cluster was not deleted within timeout: ${statusResponse}"
                        return
                    }
                    deletedClusters << clusterId
                    echo "K8s cluster ${clusterId} cleanup completed in Tumblebug."
                }

                echo "Deleted K8s clusters: ${deletedClusters.join(", ")}"
                echo "Skipped absent K8s clusters: ${skippedClusters.join(", ")}"
                if (!failedDeletes.isEmpty()) {
                    error "multi-csp-k8s-cluster-delete completed with failures: ${failedDeletes.join(" | ")}"
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (61, 18, 11, 'k8s-cluster-cleanup', 'Idempotently clean up a K8s cluster and wait for deletion', '
    stage("k8s-cluster-cleanup") {
        steps {
            echo ">>>>> STAGE: k8s-cluster-cleanup"
            script {
                if (!params.TUMBLEBUG?.trim()) {
                    error "TUMBLEBUG is required"
                }
                if (!params.NAMESPACE?.trim()) {
                    error "NAMESPACE is required"
                }
                if (!params.K8S_CLUSTER_ID?.trim()) {
                    error "K8S_CLUSTER_ID is required"
                }

                def option = params.K8S_DELETE_OPTION ?: "force"
                def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                def clusterUrl = "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/k8sCluster/${params.K8S_CLUSTER_ID}"
                def isAbsent = { value ->
                    def textValue = value ?: ""
                    def lowerValue = textValue.toLowerCase()
                    return textValue.contains("Http_Status_code:404") ||
                            lowerValue.contains("not exist") ||
                            lowerValue.contains("failed to find")
                }
                def hasNodeGroupInfo = { value ->
                    def compactValue = (value ?: "").replaceAll("\\s+", "").toLowerCase()
                    return compactValue.contains("\"k8snodegrouplist\":[{") ||
                            compactValue.contains("\"nodegrouplist\":[{")
                }
                def extractNodeGroupNames = { value ->
                    def textValue = value ?: ""
                    def names = []
                    def addName = { name ->
                        def normalizedName = (name ?: "").trim()
                        if (normalizedName && !names.contains(normalizedName)) {
                            names << normalizedName
                        }
                    }
                    (textValue =~ /"k8sNodeGroupList"\s*:\s*\[\s*\{[^]]*?"id"\s*:\s*"([^"]+)"/).each { match ->
                        addName(match[1])
                    }
                    (textValue =~ /"k8sNodeGroupList"\s*:\s*\[\s*\{[^]]*?"name"\s*:\s*"([^"]+)"/).each { match ->
                        addName(match[1])
                    }
                    (textValue =~ /"NodeGroupList"\s*:\s*\[\s*\{[^]]*?"NameId"\s*:\s*"([^"]+)"/).each { match ->
                        addName(match[1])
                    }
                    (textValue =~ /"spiderViewK8sNodeGroupDetail"\s*:\s*\{.*?"NameId"\s*:\s*"([^"]+)"/).each { match ->
                        addName(match[1])
                    }
                    return names
                }
                def deleteAccepted = { action, value ->
                    def textValue = value ?: ""
                    def lowerValue = textValue.toLowerCase()
                    if (isAbsent(value)) {
                        echo "${action} target is already absent."
                        return true
                    } else if (lowerValue.contains("not deleted")) {
                        echo "${action} was not deleted by Tumblebug: ${value}"
                        return false
                    } else if (!textValue.contains("Http_Status_code:2")) {
                        echo "${action} failed: ${value}"
                        return false
                    }
                    return true
                }

                def statusResponse = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${clusterUrl}?option=status" ${auth}""", returnStdout: true).trim()
                echo statusResponse
                if (isAbsent(statusResponse)) {
                    echo "K8s cluster ${params.K8S_CLUSTER_ID} is already absent in Tumblebug."
                } else if (!statusResponse.contains("Http_Status_code:2")) {
                    error "k8s-cluster-cleanup status check failed: ${statusResponse}"
                } else {
                    def intervalSeconds = (params.K8S_DELETE_INTERVAL_SECONDS ?: "10").toInteger()
                    if (hasNodeGroupInfo(statusResponse)) {
                        def nodeGroupNames = []
                        (params.K8S_NODEGROUP_NAME ?: "ng1").split(",").collect { it.trim() }.findAll { it }.each { nodeGroupName ->
                            if (!nodeGroupNames.contains(nodeGroupName)) {
                                nodeGroupNames << nodeGroupName
                            }
                        }
                        extractNodeGroupNames(statusResponse).each { nodeGroupName ->
                            if (nodeGroupName && !nodeGroupNames.contains(nodeGroupName)) {
                                nodeGroupNames << nodeGroupName
                            }
                        }

                        if (nodeGroupNames.isEmpty()) {
                            echo "K8s node group exists in ${params.K8S_CLUSTER_ID}, but node group name is not configured. Try cluster delete fallback."
                        } else {
                            def nodeGroupDeleteFailed = false
                            def nodeGroupDeleteRequested = false
                            echo "K8s node groups selected for ${params.K8S_CLUSTER_ID}: ${nodeGroupNames.join(", ")}"
                            for (def nodeGroupName : nodeGroupNames) {
                                def nodeGroupUrl = "${clusterUrl}/k8sNodeGroup/${nodeGroupName}?option=${option}"
                                def nodeGroupResponse = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X DELETE "${nodeGroupUrl}" ${auth}""", returnStdout: true).trim()
                                echo nodeGroupResponse
                                def nodeGroupAlreadyAbsent = isAbsent(nodeGroupResponse)
                                def nodeGroupAccepted = deleteAccepted("k8s-nodegroup-remove ${nodeGroupName}", nodeGroupResponse)
                                if (!nodeGroupAccepted) {
                                    nodeGroupDeleteFailed = true
                                    echo "k8s-nodegroup-remove ${nodeGroupName} failed. Try cluster delete fallback."
                                } else if (!nodeGroupAlreadyAbsent) {
                                    nodeGroupDeleteRequested = true
                                }
                            }

                            if (nodeGroupDeleteFailed) {
                                echo "Skip node group delete polling for ${params.K8S_CLUSTER_ID}. Continue with cluster delete fallback."
                            } else if (!nodeGroupDeleteRequested) {
                                echo "No existing node group delete request was accepted for ${params.K8S_CLUSTER_ID}. Continue with cluster delete fallback."
                            } else {
                                def nodeGroupAttempts = (params.K8S_NODEGROUP_DELETE_MAX_ATTEMPTS ?: "120").toInteger()
                                for (int attempt = 1; attempt <= nodeGroupAttempts; attempt++) {
                                    statusResponse = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${clusterUrl}?option=status" ${auth}""", returnStdout: true).trim()
                                    if (isAbsent(statusResponse) || !hasNodeGroupInfo(statusResponse)) {
                                        break
                                    }
                                    def lowerStatus = statusResponse.toLowerCase()
                                    def nodeGroupState = "Unknown"
                                    if (lowerStatus.contains("\"status\":\"deleting\"") || lowerStatus.contains("\"status\": \"deleting\"")) {
                                        nodeGroupState = "Deleting"
                                    }
                                    echo "k8s node group is still deleting. state=${nodeGroupState}, attempt ${attempt}/${nodeGroupAttempts}"
                                    sleep time: intervalSeconds, unit: "SECONDS"
                                }
                                if (!isAbsent(statusResponse) && hasNodeGroupInfo(statusResponse)) {
                                    echo "k8s node group still exists after polling. Continue with cluster delete fallback."
                                }
                            }
                        }
                    }
                }

                def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X DELETE "${clusterUrl}?option=${option}" ${auth}""", returnStdout: true).trim()
                echo response
                if (!deleteAccepted("k8s-cluster-cleanup ${params.K8S_CLUSTER_ID}", response)) {
                    error "k8s-cluster-cleanup ${params.K8S_CLUSTER_ID} failed: ${response}"
                }

                def clusterAttempts = (params.K8S_CLUSTER_DELETE_MAX_ATTEMPTS ?: "120").toInteger()
                def clusterDeleted = isAbsent(response)
                for (int attempt = 1; !clusterDeleted && attempt <= clusterAttempts; attempt++) {
                    statusResponse = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${clusterUrl}?option=status" ${auth}""", returnStdout: true).trim()
                    clusterDeleted = isAbsent(statusResponse)
                    if (clusterDeleted) {
                        break
                    }
                    if (statusResponse.toLowerCase().contains("not deleted")) {
                        error "k8s-cluster-cleanup was not completed by Tumblebug: ${statusResponse}"
                    }
                    def lowerClusterStatus = statusResponse.toLowerCase()
                    def clusterState = "Unknown"
                    if (lowerClusterStatus.contains("\"status\":\"deleting\"") || lowerClusterStatus.contains("\"status\": \"deleting\"")) {
                        clusterState = "Deleting"
                    }
                    echo "k8s cluster is still deleting. state=${clusterState}, attempt ${attempt}/${clusterAttempts}"
                    sleep time: (params.K8S_DELETE_INTERVAL_SECONDS ?: "10").toInteger(), unit: "SECONDS"
                }
                if (!clusterDeleted) {
                    error "k8s cluster was not deleted within timeout: ${statusResponse}"
                }
                echo "K8s cluster ${params.K8S_CLUSTER_ID} cleanup completed in Tumblebug."
            }
        }
    }
');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (34, 19, 1, 'app-deploy-helm', 'Deploy app with Helm chart', '
    stage("app-deploy-helm") {
        steps {
            echo ">>>>> STAGE: app-deploy-helm"
            script {
                echo ">>>>> TOOLCHAIN: k8s-helm-bootstrap-v3"
                def kubeconfigFile = env.KUBECONFIG_FILE ?: "kubeconfig"
                if (params.KUBECONFIG_CONTENT?.trim()) {
                    writeFile file: kubeconfigFile, text: params.KUBECONFIG_CONTENT
                }
                if (!fileExists(kubeconfigFile)) {
                    error "KUBECONFIG_CONTENT is required or run k8s-kubeconfig-get before app-deploy-helm"
                }
                def toolsBin = "${pwd()}/.workflow-tools/bin"
                env.PATH = "${toolsBin}:${env.PATH}"
                def helmVersion = params.HELM_VERSION?.trim() ?: "v3.18.6"
                if (helmVersion == "v3.15.4") {
                    echo "Ignoring stale HELM_VERSION=${helmVersion}; using v3.18.6"
                    helmVersion = "v3.18.6"
                }
                def kubectlVersionSpec = params.KUBECTL_VERSION?.trim()
                if (kubectlVersionSpec == "v1.30.4" || kubectlVersionSpec == "1.30.4") {
                    echo "Ignoring stale KUBECTL_VERSION=${kubectlVersionSpec}; deriving kubectl from K8S_VERSION"
                    kubectlVersionSpec = ""
                }
                if (!kubectlVersionSpec) {
                    def normalizedK8sVersion = (params.K8S_VERSION?.trim() ?: "1.33").replaceFirst("^v", "")
                    def k8sVersionParts = normalizedK8sVersion.tokenize(".")
                    kubectlVersionSpec = k8sVersionParts.size() >= 2 ? "stable-${k8sVersionParts[0]}.${k8sVersionParts[1]}" : "stable-1.33"
                }
                sh """#!/bin/sh
set -e
mkdir -p "${toolsBin}"
os=\$(uname -s | tr "[:upper:]" "[:lower:]")
arch=\$(uname -m)
case "\${arch}" in
  x86_64|amd64) arch="amd64" ;;
  aarch64|arm64) arch="arm64" ;;
  *) echo "Unsupported CPU architecture for Kubernetes tools: \${arch}"; exit 1 ;;
esac

installed_helm_version=""
if command -v helm >/dev/null 2>&1; then
  installed_helm_version=\$(helm version --short 2>/dev/null | sed "s/+.*//; s/ .*//")
fi
if [ "\${installed_helm_version}" != "${helmVersion}" ]; then
  echo "Installing helm ${helmVersion} into ${toolsBin} (current: \${installed_helm_version:-not found})"
  curl -fsSL "https://get.helm.sh/helm-${helmVersion}-\${os}-\${arch}.tar.gz" -o ".workflow-tools/helm.tar.gz"
  tar -xzf ".workflow-tools/helm.tar.gz" -C ".workflow-tools"
  cp ".workflow-tools/\${os}-\${arch}/helm" "${toolsBin}/helm"
  chmod +x "${toolsBin}/helm"
fi

kubectl_version="${kubectlVersionSpec}"
case "\${kubectl_version}" in
  stable-*) kubectl_version=\$(curl -fsSL "https://dl.k8s.io/release/\${kubectl_version}.txt") ;;
esac
installed_kubectl_version=""
if command -v kubectl >/dev/null 2>&1; then
  installed_kubectl_version=\$(kubectl version --client=true 2>/dev/null | sed -n "s/^Client Version: \\(v[0-9.]*\\).*/\\1/p" | head -1)
fi
if [ "\${installed_kubectl_version}" != "\${kubectl_version}" ]; then
  echo "Installing kubectl \${kubectl_version} into ${toolsBin} (current: \${installed_kubectl_version:-not found})"
  curl -fsSL "https://dl.k8s.io/release/\${kubectl_version}/bin/\${os}/\${arch}/kubectl" -o "${toolsBin}/kubectl"
  chmod +x "${toolsBin}/kubectl"
fi

helm version --short
kubectl version --client=true
"""
                if (readFile(kubeconfigFile).contains("aws-iam-authenticator")) {
                    def authVersion = params.AWS_IAM_AUTHENTICATOR_VERSION ?: "0.6.31"
                    sh """#!/bin/sh
set -e
os=\$(uname -s | tr "[:upper:]" "[:lower:]")
arch=\$(uname -m)
case "\${arch}" in
  x86_64|amd64) arch="amd64" ;;
  aarch64|arm64) arch="arm64" ;;
  *) echo "Unsupported CPU architecture for aws-iam-authenticator: \${arch}"; exit 1 ;;
esac
current_auth_version=""
if [ -x "${toolsBin}/aws-iam-authenticator" ]; then
  current_auth_version=\$("${toolsBin}/aws-iam-authenticator" version 2>/dev/null || true)
fi
if ! printf "%s" "\${current_auth_version}" | grep -q "${authVersion}"; then
  echo "Installing aws-iam-authenticator v${authVersion} into ${toolsBin}"
  curl -fsSL "https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${authVersion}/aws-iam-authenticator_${authVersion}_\${os}_\${arch}" -o "${toolsBin}/aws-iam-authenticator"
  chmod +x "${toolsBin}/aws-iam-authenticator"
fi
"${toolsBin}/aws-iam-authenticator" version
"""
                }
                def apiReadyAttempts = (params.K8S_API_READY_MAX_ATTEMPTS ?: "360").toInteger()
                def apiReadyIntervalSeconds = (params.K8S_API_READY_INTERVAL_SECONDS ?: "10").toInteger()
                def minReadyNodes = (params.K8S_NODE_READY_MIN_COUNT ?: "1").toInteger()
                def apiReady = false
                for (int attempt = 1; attempt <= apiReadyAttempts; attempt++) {
                    def readyResult = sh(script: """#!/bin/sh
set +e
api_server=\$(sed -n "s/^[[:space:]]*server:[[:space:]]*//p" "${kubeconfigFile}" | head -1)
echo "Checking Kubernetes nodes from \${api_server}"
if [ -z "\${api_server}" ]; then
  echo "kubeconfig server is empty. Check k8s-kubeconfig-get response decoding."
  exit 87
fi
kubectl --kubeconfig "${kubeconfigFile}" get nodes -o wide --no-headers > k8s-nodes.log 2>&1
rc=\$?
cat k8s-nodes.log
if grep -q "invalid character ''<''" k8s-nodes.log; then
  echo "Kubernetes API/auth response was HTML, not JSON. Check Jenkins network/proxy, EKS endpoint access, and aws-iam-authenticator credentials."
  exit 88
fi
if [ "\${rc}" -ne 0 ]; then
  exit "\${rc}"
fi
if grep -q "No resources found" k8s-nodes.log; then
  echo "Kubernetes API is reachable, but no worker nodes are registered yet."
  exit 89
fi
ready_count=\$(grep -E "[[:space:]]Ready[[:space:],]" k8s-nodes.log | grep -v "NotReady" | wc -l | tr -d " ")
if [ "\${ready_count:-0}" -lt "${minReadyNodes}" ]; then
  echo "Ready worker nodes are not enough. ready=\${ready_count:-0}, required=${minReadyNodes}"
  exit 89
fi
exit "\${rc}"
""", returnStatus: true)
                    if (readyResult == 0) {
                        apiReady = true
                        break
                    }
                    if (readyResult == 87) {
                        error "kubeconfig server is empty after decoding Tumblebug response"
                    }
                    if (readyResult == 88) {
                        error "Kubernetes API/auth response was HTML while running kubectl get nodes"
                    }
                    echo "Kubernetes Ready nodes are not available. attempt ${attempt}/${apiReadyAttempts}"
                    sleep time: apiReadyIntervalSeconds, unit: "SECONDS"
                }
                if (!apiReady) {
                    error "Kubernetes Ready nodes are not available with kubeconfig"
                }
                def namespace = params.KUBE_NAMESPACE ?: "default"
                def chartRef = params.HELM_CHART ?: "groundhog2k/mariadb"
                def repoUrl = params.HELM_REPO_URL?.trim()
                if (repoUrl) {
                    def repoName = params.HELM_REPO_NAME?.trim()
                    if (!repoName && chartRef.contains("/")) {
                        repoName = chartRef.tokenize("/")[0]
                    }
                    if (!repoName) {
                        repoName = "workflow-chart"
                    }
                    sh """#!/bin/sh
set -e
helm repo add "${repoName}" "${repoUrl}" --force-update
helm repo update"""
                }
                def chartVersion = params.HELM_CHART_VERSION?.trim()
                def versionArg = chartVersion ? "--version \"${chartVersion}\"" : ""
                def valuesArgs = params.HELM_VALUES_ARGS ?: ""
                def releaseName = params.RELEASE_NAME ?: "mariadb"
                def helmInstallCommand = """helm upgrade --install "${releaseName}" "${chartRef}" ${versionArg} --namespace "${namespace}" --create-namespace --kubeconfig "${kubeconfigFile}" ${valuesArgs}"""
                def helmStatus = sh(script: """#!/bin/sh
set +e
${helmInstallCommand} > helm-upgrade.log 2>&1
rc=\$?
cat helm-upgrade.log
exit \${rc}
""", returnStatus: true)
                if (helmStatus != 0) {
                    def helmOutput = readFile("helm-upgrade.log")
                    def recreateOnImmutableError = !(params.HELM_RECREATE_ON_IMMUTABLE_ERROR?.trim()?.equalsIgnoreCase("false"))
                    if (recreateOnImmutableError && helmOutput.contains("Forbidden: updates to statefulset spec")) {
                        echo "Helm upgrade hit immutable StatefulSet fields. Recreating release ${releaseName}."
                        sh """#!/bin/sh
set -e
helm uninstall "${releaseName}" --namespace "${namespace}" --kubeconfig "${kubeconfigFile}" || true
kubectl delete statefulset "${releaseName}" --namespace "${namespace}" --kubeconfig "${kubeconfigFile}" --ignore-not-found=true
kubectl delete service "${releaseName}" --namespace "${namespace}" --kubeconfig "${kubeconfigFile}" --ignore-not-found=true
kubectl delete secret "${releaseName}" --namespace "${namespace}" --kubeconfig "${kubeconfigFile}" --ignore-not-found=true
kubectl delete configmap "${releaseName}" --namespace "${namespace}" --kubeconfig "${kubeconfigFile}" --ignore-not-found=true
${helmInstallCommand}
"""
                    } else {
                        error "app-deploy-helm failed: ${helmOutput}"
                    }
                }
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (35, 19, 2, 'app-deploy-manifest', 'Deploy app with K8s manifest', '
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (36, 19, 3, 'app-deploy-status-check', 'Check deployment status (pod/deployment ready)', '
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (37, 19, 4, 'app-undeploy', 'Delete app', '
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (38, 19, 5, 'app-rollback', 'Roll back to previous version', '
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (58, 19, 6, 'jupyter-inbound-rule-add', 'Add a Jupyter TCP inbound rule for an allowed IPv4 CIDR', '
    stage("jupyter-inbound-rule-add") {
        steps {
            echo ">>>>> STAGE: jupyter-inbound-rule-add"
            script {
                def jupyterBindHost = (params.JUPYTER_BIND_HOST ?: "0.0.0.0").trim().toLowerCase()
                def jupyterPort = (params.JUPYTER_PORT ?: "8888").trim()
                if (!(jupyterPort ==~ /[0-9]+/) || jupyterPort.toInteger() < 1 || jupyterPort.toInteger() > 65535) {
                    error "JUPYTER_PORT must be between 1 and 65535"
                }

                if (jupyterBindHost in ["127.0.0.1", "localhost", "::1"]) {
                    echo "Jupyter is bound to loopback. Skip the Tumblebug inbound rule."
                } else {
                    def tumblebug = (params.TUMBLEBUG ?: "").trim().replaceAll("/+\$", "")
                    def namespace = (params.NAMESPACE ?: "").trim()
                    def infraId = (params.INFRA_ID ?: "").trim()
                    def allowedCidr = (params.JUPYTER_ALLOWED_CIDR ?: "0.0.0.0/0").trim()
                    if (!tumblebug || !namespace || !infraId) {
                        error "TUMBLEBUG, NAMESPACE and INFRA_ID are required for direct Jupyter access"
                    }

                    def safeValues = [tumblebug: [tumblebug, /[A-Za-z0-9._:\/-]+/], namespace: [namespace, /[A-Za-z0-9._-]+/], infraId: [infraId, /[A-Za-z0-9._-]+/]]
                    safeValues.each { name, validation ->
                        if (!(validation[0] ==~ validation[1]) || validation[0].contains("..")) {
                            error "Invalid ${name}"
                        }
                    }

                    if (!allowedCidr.contains("/")) {
                        allowedCidr = allowedCidr + "/32"
                    }
                    def cidrParts = allowedCidr.split("/", -1)
                    def octets = cidrParts.size() == 2 ? cidrParts[0].split("\\.", -1) : []
                    def validAddress = octets.size() == 4 && octets.every { octet ->
                        (octet ==~ /[0-9]+/) && octet.toInteger() >= 0 && octet.toInteger() <= 255
                    }
                    def validPrefix = cidrParts.size() == 2 && (cidrParts[1] ==~ /[0-9]+/) && cidrParts[1].toInteger() >= 0 && cidrParts[1].toInteger() <= 32
                    if (!validAddress || !validPrefix) {
                        error "JUPYTER_ALLOWED_CIDR must be a valid IPv4 address or IPv4 CIDR"
                    }

                    def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                    def associatedUrl = "${tumblebug}/tumblebug/ns/${namespace}/infra/${infraId}/associatedResources"
                    def associatedResponse = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${associatedUrl}" ${auth}""", returnStdout: true).trim()
                    if (!associatedResponse.contains("Http_Status_code:2")) {
                        error "Failed to get security groups for ${infraId}: ${associatedResponse}"
                    }

                    def associatedBody = associatedResponse.replaceAll("- Http_Status_code:[0-9]{3}", "").trim()
                    def associatedResources = new groovy.json.JsonSlurper().parseText(associatedBody)
                    def securityGroupIds = (associatedResources.securityGroupIds ?: []).collect { it.toString().trim() }.findAll { it }
                    associatedResources = null
                    if (!securityGroupIds) {
                        error "No security group is associated with infra ${infraId}"
                    }

                    securityGroupIds.each { securityGroupId ->
                        if (!(securityGroupId ==~ /[A-Za-z0-9._-]+/)) {
                            error "Invalid securityGroupId returned by Tumblebug"
                        }

                        def securityGroupUrl = "${tumblebug}/tumblebug/ns/${namespace}/resources/securityGroup/${securityGroupId}"
                        def securityGroupResponse = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${securityGroupUrl}" ${auth}""", returnStdout: true).trim()
                        if (!securityGroupResponse.contains("Http_Status_code:2")) {
                            error "Failed to read security group ${securityGroupId}: ${securityGroupResponse}"
                        }

                        def securityGroupBody = securityGroupResponse.replaceAll("- Http_Status_code:[0-9]{3}", "").trim()
                        def securityGroup = new groovy.json.JsonSlurper().parseText(securityGroupBody)
                        def ruleExists = (securityGroup.firewallRules ?: []).any { rule ->
                            def port = (rule["Port"] ?: rule["port"] ?: "").toString().trim()
                            def protocol = (rule["Protocol"] ?: rule["protocol"] ?: "").toString().trim().toUpperCase()
                            def direction = (rule["Direction"] ?: rule["direction"] ?: "").toString().trim().toLowerCase()
                            def cidr = (rule["CIDR"] ?: rule["cidr"] ?: "").toString().trim()
                            port == jupyterPort && protocol == "TCP" && direction == "inbound" && cidr == allowedCidr
                        }
                        securityGroup = null

                        if (ruleExists) {
                            echo "Jupyter inbound rule already exists. securityGroup=${securityGroupId}, port=${jupyterPort}, cidr=${allowedCidr}"
                        } else {
                            def payload = groovy.json.JsonOutput.toJson([
                                firewallRules: [[Ports: jupyterPort, Protocol: "TCP", Direction: "inbound", CIDR: allowedCidr]]
                            ])
                            writeFile file: "jupyter-firewall-rule.json", text: payload
                            try {
                                def addResponse = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X POST "${securityGroupUrl}/rules" -H "Content-Type: application/json" -d @jupyter-firewall-rule.json ${auth}""", returnStdout: true).trim()
                                def duplicateResponse = addResponse.toLowerCase().contains("already exists")
                                if (!addResponse.contains("Http_Status_code:2") && !duplicateResponse) {
                                    error "Failed to add the Jupyter inbound rule to ${securityGroupId}: ${addResponse}"
                                }
                                echo "Jupyter inbound rule is ready. securityGroup=${securityGroupId}, port=${jupyterPort}, cidr=${allowedCidr}"
                            } finally {
                                sh "rm -f jupyter-firewall-rule.json"
                            }
                        }
                    }
                }
            }
        }
    }');

INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (59, 19, 8, 'jupyter-inbound-rule-remove', 'Remove the selected Jupyter inbound rule when both port and CIDR are provided', '
    stage("jupyter-inbound-rule-remove") {
        steps {
            echo ">>>>> STAGE: jupyter-inbound-rule-remove"
            script {
                def jupyterPort = (params.JUPYTER_PORT ?: "").trim()
                def allowedCidr = (params.JUPYTER_ALLOWED_CIDR ?: "").trim()

                if (!jupyterPort || !allowedCidr) {
                    echo "JUPYTER_PORT and JUPYTER_ALLOWED_CIDR were not both provided. Skip the Jupyter inbound rule removal."
                } else {
                    if (!(jupyterPort ==~ /[0-9]+/) || jupyterPort.toInteger() < 1 || jupyterPort.toInteger() > 65535) {
                        error "JUPYTER_PORT must be between 1 and 65535"
                    }

                    if (!allowedCidr.contains("/")) {
                        allowedCidr = allowedCidr + "/32"
                    }
                    def cidrParts = allowedCidr.split("/", -1)
                    def octets = cidrParts.size() == 2 ? cidrParts[0].split("\\.", -1) : []
                    def validAddress = octets.size() == 4 && octets.every { octet ->
                        (octet ==~ /[0-9]+/) && octet.toInteger() >= 0 && octet.toInteger() <= 255
                    }
                    def validPrefix = cidrParts.size() == 2 && (cidrParts[1] ==~ /[0-9]+/) && cidrParts[1].toInteger() >= 0 && cidrParts[1].toInteger() <= 32
                    if (!validAddress || !validPrefix) {
                        error "JUPYTER_ALLOWED_CIDR must be a valid IPv4 address or IPv4 CIDR"
                    }

                    def tumblebug = (params.TUMBLEBUG ?: "").trim().replaceAll("/+\$", "")
                    def namespace = (params.NAMESPACE ?: "").trim()
                    def infraId = (params.INFRA_ID ?: "").trim()
                    if (!tumblebug || !namespace || !infraId) {
                        error "TUMBLEBUG, NAMESPACE and INFRA_ID are required for Jupyter inbound rule removal"
                    }

                    def safeValues = [tumblebug: [tumblebug, /[A-Za-z0-9._:\/-]+/], namespace: [namespace, /[A-Za-z0-9._-]+/], infraId: [infraId, /[A-Za-z0-9._-]+/]]
                    safeValues.each { name, validation ->
                        if (!(validation[0] ==~ validation[1]) || validation[0].contains("..")) {
                            error "Invalid ${name}"
                        }
                    }

                    def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                    def associatedUrl = "${tumblebug}/tumblebug/ns/${namespace}/infra/${infraId}/associatedResources"
                    def associatedResponse = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${associatedUrl}" ${auth}""", returnStdout: true).trim()
                    def associatedResponseLower = associatedResponse.toLowerCase()
                    def infraAlreadyAbsent = associatedResponse.contains("Http_Status_code:404") || associatedResponseLower.contains("does not exist") || associatedResponseLower.contains("not found")
                    if (infraAlreadyAbsent) {
                        echo "Infra ${infraId} is already absent. Skip the Jupyter inbound rule removal."
                    } else if (!associatedResponse.contains("Http_Status_code:2")) {
                        error "Failed to get security groups for ${infraId}: ${associatedResponse}"
                    } else {
                        def associatedBody = associatedResponse.replaceAll("- Http_Status_code:[0-9]{3}", "").trim()
                        def associatedResources = new groovy.json.JsonSlurper().parseText(associatedBody)
                        def securityGroupIds = (associatedResources.securityGroupIds ?: []).collect { it.toString().trim() }.findAll { it }
                        associatedResources = null

                        if (!securityGroupIds) {
                            echo "No security group is associated with infra ${infraId}. Skip the Jupyter inbound rule removal."
                        } else {
                            securityGroupIds.each { securityGroupId ->
                                if (!(securityGroupId ==~ /[A-Za-z0-9._-]+/)) {
                                    error "Invalid securityGroupId returned by Tumblebug"
                                }

                                def securityGroupUrl = "${tumblebug}/tumblebug/ns/${namespace}/resources/securityGroup/${securityGroupId}"
                                def securityGroupResponse = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${securityGroupUrl}" ${auth}""", returnStdout: true).trim()
                                def securityGroupResponseLower = securityGroupResponse.toLowerCase()
                                def securityGroupAlreadyAbsent = securityGroupResponse.contains("Http_Status_code:404") || securityGroupResponseLower.contains("does not exist") || securityGroupResponseLower.contains("not found")
                                if (securityGroupAlreadyAbsent) {
                                    echo "Security group ${securityGroupId} is already absent. Skip it."
                                } else if (!securityGroupResponse.contains("Http_Status_code:2")) {
                                    error "Failed to read security group ${securityGroupId}: ${securityGroupResponse}"
                                } else {
                                    def securityGroupBody = securityGroupResponse.replaceAll("- Http_Status_code:[0-9]{3}", "").trim()
                                    def securityGroup = new groovy.json.JsonSlurper().parseText(securityGroupBody)
                                    def ruleExists = (securityGroup.firewallRules ?: []).any { rule ->
                                        def port = (rule["Port"] ?: rule["port"] ?: "").toString().trim()
                                        def protocol = (rule["Protocol"] ?: rule["protocol"] ?: "").toString().trim().toUpperCase()
                                        def direction = (rule["Direction"] ?: rule["direction"] ?: "").toString().trim().toLowerCase()
                                        def cidr = (rule["CIDR"] ?: rule["cidr"] ?: "").toString().trim()
                                        port == jupyterPort && protocol == "TCP" && direction == "inbound" && cidr == allowedCidr
                                    }
                                    securityGroup = null

                                    if (!ruleExists) {
                                        echo "The matching Jupyter inbound rule is already absent. securityGroup=${securityGroupId}, port=${jupyterPort}, cidr=${allowedCidr}"
                                    } else {
                                        def payload = groovy.json.JsonOutput.toJson([
                                            firewallRules: [[Ports: jupyterPort, Protocol: "TCP", Direction: "inbound", CIDR: allowedCidr]]
                                        ])
                                        writeFile file: "jupyter-firewall-rule-delete.json", text: payload
                                        try {
                                            def deleteResponse = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X DELETE "${securityGroupUrl}/rules" -H "Content-Type: application/json" -d @jupyter-firewall-rule-delete.json ${auth}""", returnStdout: true).trim()
                                            def deleteResponseLower = deleteResponse.toLowerCase()
                                            def alreadyAbsent = deleteResponseLower.contains("does not exist") || deleteResponseLower.contains("not found")
                                            if (!deleteResponse.contains("Http_Status_code:2") && !alreadyAbsent) {
                                                error "Failed to remove the Jupyter inbound rule from ${securityGroupId}: ${deleteResponse}"
                                            }
                                            if (alreadyAbsent) {
                                                echo "The matching Jupyter inbound rule is already absent. securityGroup=${securityGroupId}, port=${jupyterPort}, cidr=${allowedCidr}"
                                            } else {
                                                echo "Removed the Jupyter inbound rule. securityGroup=${securityGroupId}, port=${jupyterPort}, cidr=${allowedCidr}"
                                            }
                                        } finally {
                                            sh "rm -f jupyter-firewall-rule-delete.json"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }');

INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (62, 19, 7, 'jupyter-object-storage-presigned-analysis-install', 'Install JupyterLab with a restricted presigned URL broker for Object Storage analysis', '
    stage("jupyter-object-storage-presigned-analysis-install") {
        steps {
            echo ">>>>> STAGE: jupyter-object-storage-presigned-analysis-install"
            script {
                def provider = (params.OBJECT_STORAGE_PROVIDER ?: params.CSP ?: params.PROVIDER ?: "").trim().toLowerCase()
                def supportedProviders = ["aws", "gcp", "ncp", "alibaba", "tencent", "ibm", "nhn"]
                if (!supportedProviders.contains(provider)) {
                    error "OBJECT_STORAGE_PROVIDER must be one of: ${supportedProviders.join(", ")}"
                }

                // Presigned URLs are issued against the Tumblebug logical ID, not the generated CSP bucket name.
                def storageId = (params.OBJECT_STORAGE_BUCKET ?: "").trim()
                def osNamespace = (params.OBJECT_STORAGE_NAMESPACE ?: params.NAMESPACE ?: "").trim()
                if (params.MC_INFRA_MANAGER_RUNTIME_URL != null) {
                    error "MC_INFRA_MANAGER_RUNTIME_URL is system-managed and cannot be a workflow parameter"
                }
                def runtimeTumblebug = (env.MC_INFRA_MANAGER_RUNTIME_URL ?: "").trim().replaceAll("/+\$", "")
                def dataPrefix = (params.DATA_PREFIX ?: "").trim().replaceAll("^/+|/+\$", "")
                def resultPrefix = (params.RESULT_PREFIX ?: "results").trim().replaceAll("^/+|/+\$", "")
                def writeResultEnabled = (params.WRITE_RESULT_ENABLED ?: "true").trim().toLowerCase()
                def presignedExpires = (params.PRESIGNED_URL_EXPIRES ?: "3600").trim()
                def jupyterImage = (params.JUPYTER_IMAGE ?: "quay.io/jupyter/scipy-notebook:2025-03-14").trim()
                def duckdbVersion = (params.DUCKDB_VERSION ?: "1.3.2").trim()
                def jupyterBindHost = (params.JUPYTER_BIND_HOST ?: "0.0.0.0").trim()
                def jupyterPort = (params.JUPYTER_PORT ?: "8888").trim()

                if (!storageId || !osNamespace) {
                    error "OBJECT_STORAGE_BUCKET and OBJECT_STORAGE_NAMESPACE/NAMESPACE are required"
                }
                if (!runtimeTumblebug) {
                    error "MC_INFRA_MANAGER_RUNTIME_URL must be configured in the Jenkins environment"
                }
                if (!params.USER?.trim() || !params.USERPASS) {
                    error "USER and USERPASS are required by the presigned URL broker"
                }
                if (params.USER.contains("\n") || params.USER.contains("\r") || params.USERPASS.contains("\n") || params.USERPASS.contains("\r")) {
                    error "Tumblebug credentials must not contain line breaks"
                }
                if (!(writeResultEnabled in ["true", "false"])) {
                    error "WRITE_RESULT_ENABLED must be true or false"
                }
                if (writeResultEnabled == "true" && !resultPrefix) {
                    error "RESULT_PREFIX is required when WRITE_RESULT_ENABLED is true"
                }
                if (!(presignedExpires ==~ /[0-9]+/) || presignedExpires.toInteger() < 60 || presignedExpires.toInteger() > 86400) {
                    error "PRESIGNED_URL_EXPIRES must be between 60 and 86400 seconds"
                }
                if (!(jupyterPort ==~ /[0-9]+/) || jupyterPort.toInteger() < 1 || jupyterPort.toInteger() > 65535) {
                    error "JUPYTER_PORT must be between 1 and 65535"
                }

                def safePatterns = [
                    provider: [provider, /[A-Za-z0-9._-]+/],
                    storageId: [storageId, /[A-Za-z0-9._-]+/],
                    osNamespace: [osNamespace, /[A-Za-z0-9._-]+/],
                    runtimeTumblebug: [runtimeTumblebug, /https?:\/\/[A-Za-z0-9._:\/-]+/],
                    dataPrefix: [dataPrefix, /[A-Za-z0-9._\/-]+/],
                    resultPrefix: [resultPrefix, /[A-Za-z0-9._\/-]+/],
                    jupyterImage: [jupyterImage, /[A-Za-z0-9._:\/@-]+/],
                    duckdbVersion: [duckdbVersion, /[0-9.]+/],
                    jupyterBindHost: [jupyterBindHost, /[A-Za-z0-9.:-]+/]
                ]
                safePatterns.each { name, validation ->
                    if (validation[0] && (!(validation[0] ==~ validation[1]) || validation[0].contains(".."))) {
                        error "Invalid ${name}"
                    }
                }

                def sshHost = env.SSH_HOST ?: params.SSH_HOST
                def sshUser = env.SSH_USER ?: params.SSH_USER ?: "cb-user"
                def sshKeyFile = env.SSH_KEY_FILE ?: params.SSH_KEY_FILE
                if (!sshHost || !sshUser) {
                    error "SSH_HOST and SSH_USER are required for jupyter-object-storage-presigned-analysis-install"
                }
                def keyOpt = sshKeyFile ? "-i \"${sshKeyFile}\"" : ""

                def brokerSource = """import hashlib
import json
import os
import shutil
import tempfile
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import quote, unquote, urlsplit

import requests


TUMBLEBUG_URL = os.environ["TUMBLEBUG_URL"].rstrip("/")
TUMBLEBUG_API = TUMBLEBUG_URL if TUMBLEBUG_URL.endswith("/tumblebug") else TUMBLEBUG_URL + "/tumblebug"
TUMBLEBUG_USERNAME = os.environ["TUMBLEBUG_USERNAME"]
TUMBLEBUG_PASSWORD = os.environ["TUMBLEBUG_PASSWORD"]
NAMESPACE = os.environ["OBJECT_STORAGE_NAMESPACE"]
STORAGE_ID = os.environ["OBJECT_STORAGE_ID"]
DATA_PREFIX = os.environ.get("DATA_PREFIX", "").strip("/")
RESULT_PREFIX = os.environ.get("RESULT_PREFIX", "results").strip("/")
URL_TTL = int(os.environ.get("PRESIGNED_URL_EXPIRES", "3600"))
BROKER_TOKEN = os.environ["BROKER_TOKEN"]

CONTROL_SESSION = requests.Session()
CONTROL_SESSION.auth = (TUMBLEBUG_USERNAME, TUMBLEBUG_PASSWORD)
STORAGE_SESSION = requests.Session()
SIGNED_URL_CACHE = {}
CACHE_LOCK = threading.Lock()


def is_within(prefix, key):
    return not prefix or key == prefix or key.startswith(prefix + "/")


def normalize_key(raw_key):
    key = unquote(raw_key)
    if not key or key.startswith("/") or "\\\\" in key or "\\n" in key or "\\r" in key:
        raise ValueError("invalid object key")
    if any(part == ".." for part in key.split("/")):
        raise ValueError("invalid object key")
    return key


def can_download(key):
    return is_within(DATA_PREFIX, key) or is_within(RESULT_PREFIX, key)


def can_upload(key):
    return bool(RESULT_PREFIX) and is_within(RESULT_PREFIX, key)


def tumblebug_path(suffix):
    return TUMBLEBUG_API + "/ns/" + quote(NAMESPACE, safe="") + "/resources/objectStorage/" + quote(STORAGE_ID, safe="") + suffix


def list_objects():
    response = CONTROL_SESSION.get(tumblebug_path("/object"), timeout=30)
    if response.status_code < 200 or response.status_code >= 300:
        raise RuntimeError("Tumblebug object list failed with status %d" % response.status_code)
    objects = response.json().get("objects", [])
    return [item for item in objects if can_download(str(item.get("key", "")))]


def invalidate_url(key, operation):
    with CACHE_LOCK:
        SIGNED_URL_CACHE.pop((operation, key), None)


def key_fingerprint(key):
    return hashlib.sha256(key.encode("utf-8")).hexdigest()[:12]


def audit_presign(operation, key, expires_at, reason):
    expires_text = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime(expires_at))
    print(
        "presigned_url_issued operation=%s key_sha256=%s expires_at=%s reason=%s"
        % (operation, key_fingerprint(key), expires_text, reason),
        flush=True,
    )


def presign(key, operation, force=False, reason="request"):
    cache_key = (operation, key)
    now = time.time()
    cached = None
    if operation == "download" and not force:
        with CACHE_LOCK:
            cached = SIGNED_URL_CACHE.get(cache_key)
            if cached and cached["refresh_at"] > now:
                return cached
        reason = "expired" if cached else "cache_miss"

    suffix = "/object/" + quote(key, safe="") + "/presignedUrl"
    response = CONTROL_SESSION.post(
        tumblebug_path(suffix),
        params={"operation": operation, "expires": URL_TTL},
        timeout=30,
    )
    if response.status_code < 200 or response.status_code >= 300:
        raise RuntimeError("Tumblebug presigned URL request failed with status %d" % response.status_code)
    payload = response.json()
    signed_url = payload.get("presignedURL", "")
    if not signed_url:
        raise RuntimeError("Tumblebug returned an empty presigned URL")
    try:
        expires_at = float(payload.get("expires") or 0)
    except (TypeError, ValueError):
        expires_at = 0
    if expires_at <= now:
        expires_at = now + URL_TTL
    entry = {
        "url": signed_url,
        "headers": payload.get("requiredHeaders") or {},
        "expires_at": expires_at,
        "refresh_at": max(now + 1, expires_at - 30),
    }
    if operation == "download":
        with CACHE_LOCK:
            SIGNED_URL_CACHE[cache_key] = entry
    audit_presign(operation, key, expires_at, reason)
    return entry


def storage_get(key, range_header=None):
    for attempt in range(2):
        signed = presign(
            key,
            "download",
            force=attempt > 0,
            reason="storage_auth_retry" if attempt > 0 else "request",
        )
        headers = dict(signed["headers"])
        headers["Accept-Encoding"] = "identity"
        if range_header:
            headers["Range"] = range_header
        response = STORAGE_SESSION.get(signed["url"], headers=headers, stream=True, timeout=(10, 300))
        response.raw.decode_content = False
        if response.status_code not in (401, 403) or attempt == 1:
            return response
        response.close()
        invalidate_url(key, "download")
    raise RuntimeError("unreachable")


class BrokerHandler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def log_message(self, format_text, *args):
        print("%s %s" % (self.command, urlsplit(self.path).path), flush=True)

    def authorized(self):
        return self.headers.get("Authorization", "") == "Bearer " + BROKER_TOKEN

    def send_json(self, status, payload):
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        if self.command != "HEAD":
            self.wfile.write(body)

    def object_key(self, route_prefix):
        path = urlsplit(self.path).path
        if not path.startswith(route_prefix):
            raise ValueError("invalid route")
        return normalize_key(path[len(route_prefix):])

    def do_HEAD(self):
        if self.path == "/health":
            self.send_response(200)
            self.send_header("Content-Length", "0")
            self.end_headers()
            return
        if not self.authorized():
            self.send_json(401, {"error": "unauthorized"})
            return
        try:
            key = self.object_key("/object/")
            if not can_download(key):
                self.send_json(403, {"error": "object is outside the allowed prefixes"})
                return
            upstream = storage_get(key, "bytes=0-0")
            try:
                if upstream.status_code not in (200, 206):
                    self.send_json(502, {"error": "Object Storage returned status %d" % upstream.status_code})
                    return
                content_range = upstream.headers.get("Content-Range", "")
                total_size = content_range.rsplit("/", 1)[-1] if "/" in content_range else upstream.headers.get("Content-Length", "")
                self.send_response(200)
                if total_size and total_size.isdigit():
                    self.send_header("Content-Length", total_size)
                self.send_header("Accept-Ranges", "bytes")
                for header_name in ("Content-Type", "ETag", "Last-Modified"):
                    if upstream.headers.get(header_name):
                        self.send_header(header_name, upstream.headers[header_name])
                self.end_headers()
            finally:
                upstream.close()
        except (ValueError, RuntimeError, requests.RequestException):
            self.send_json(502, {"error": "object metadata request failed"})

    def do_GET(self):
        path = urlsplit(self.path).path
        if path == "/health":
            self.send_json(200, {"status": "ok"})
            return
        if not self.authorized():
            self.send_json(401, {"error": "unauthorized"})
            return
        if path == "/objects":
            try:
                self.send_json(200, {"objects": list_objects()})
            except (RuntimeError, ValueError, requests.RequestException, json.JSONDecodeError):
                self.send_json(502, {"error": "Tumblebug object list request failed"})
            return
        try:
            key = self.object_key("/object/")
            if not can_download(key):
                self.send_json(403, {"error": "object is outside the allowed prefixes"})
                return
            range_header = self.headers.get("Range")
            upstream = storage_get(key, range_header)
            try:
                if upstream.status_code not in (200, 206):
                    self.send_json(502, {"error": "Object Storage returned status %d" % upstream.status_code})
                    return
                self.send_response(upstream.status_code)
                for header_name in ("Content-Length", "Content-Range", "Accept-Ranges", "Content-Type", "ETag", "Last-Modified"):
                    if upstream.headers.get(header_name):
                        self.send_header(header_name, upstream.headers[header_name])
                self.send_header("Connection", "close")
                self.end_headers()
                self.close_connection = True
                shutil.copyfileobj(upstream.raw, self.wfile, length=1024 * 1024)
            finally:
                upstream.close()
        except (ValueError, RuntimeError, requests.RequestException, BrokenPipeError, ConnectionResetError):
            if not self.wfile.closed:
                self.close_connection = True

    def do_PUT(self):
        if not self.authorized():
            self.send_json(401, {"error": "unauthorized"})
            return
        temp_path = ""
        try:
            key = self.object_key("/result/")
            if not can_upload(key):
                self.send_json(403, {"error": "object is outside RESULT_PREFIX"})
                return
            content_length = self.headers.get("Content-Length", "")
            if not content_length.isdigit():
                self.send_json(411, {"error": "Content-Length is required"})
                return
            remaining = int(content_length)
            with tempfile.NamedTemporaryFile(delete=False) as temp_file:
                temp_path = temp_file.name
                while remaining:
                    chunk = self.rfile.read(min(1024 * 1024, remaining))
                    if not chunk:
                        raise RuntimeError("incomplete upload")
                    temp_file.write(chunk)
                    remaining -= len(chunk)

            for attempt in range(2):
                signed = presign(
                    key,
                    "upload",
                    force=True,
                    reason="storage_auth_retry" if attempt > 0 else "upload_request",
                )
                headers = dict(signed["headers"])
                headers["Content-Length"] = content_length
                with open(temp_path, "rb") as upload_file:
                    upstream = STORAGE_SESSION.put(
                        signed["url"],
                        headers=headers,
                        data=upload_file,
                        timeout=(10, 3600),
                        allow_redirects=False,
                    )
                if upstream.status_code not in (401, 403) or attempt == 1:
                    break
            if upstream.status_code < 200 or upstream.status_code >= 300:
                self.send_json(502, {"error": "Object Storage upload returned status %d" % upstream.status_code})
                return
            self.send_json(200, {"key": key, "size": int(content_length)})
        except (ValueError, RuntimeError, requests.RequestException):
            self.send_json(502, {"error": "result upload failed"})
        finally:
            if temp_path:
                try:
                    os.remove(temp_path)
                except FileNotFoundError:
                    pass


if __name__ == "__main__":
    ThreadingHTTPServer(("0.0.0.0", 8765), BrokerHandler).serve_forever()
"""

                def helperSource = """import os
from urllib.parse import quote

import duckdb
import requests


BROKER_URL = os.environ.get("OBJECT_STORAGE_BROKER_URL", "http://object-storage-broker:8765").rstrip("/")
BROKER_TOKEN = os.environ["OBJECT_STORAGE_BROKER_TOKEN"]


def broker_headers():
    return {"Authorization": "Bearer " + BROKER_TOKEN}


def sql_quote(value):
    text = str(value)
    return chr(39) + text.replace(chr(39), chr(39) * 2) + chr(39)


def sql_identifier(value):
    text = str(value)
    return chr(34) + text.replace(chr(34), chr(34) * 2) + chr(34)


def create_connection():
    connection = duckdb.connect()
    connection.execute("INSTALL httpfs")
    connection.execute("LOAD httpfs")
    connection.execute(
        "CREATE SECRET object_storage_broker (TYPE http, SCOPE "
        + sql_quote(BROKER_URL)
        + ", BEARER_TOKEN ?)",
        [BROKER_TOKEN],
    )
    return connection


def list_objects():
    response = requests.get(BROKER_URL + "/objects", headers=broker_headers(), timeout=30)
    response.raise_for_status()
    return response.json().get("objects", [])


def object_url(key):
    return BROKER_URL + "/object/" + quote(key, safe="")


def upload_file(key, local_path):
    size = os.path.getsize(local_path)
    headers = broker_headers()
    headers["Content-Length"] = str(size)
    with open(local_path, "rb") as source:
        response = requests.put(
            BROKER_URL + "/result/" + quote(key, safe=""),
            headers=headers,
            data=source,
            timeout=(10, 3600),
        )
    response.raise_for_status()
    return response.json()
"""

                def verifierSource = """import os
import requests

from object_storage_access import broker_headers, list_objects, object_url


def verify():
    objects = list_objects()
    print("Object Storage broker access verified. provider=%s, storageId=%s, objects=%d" % (
        os.environ.get("OBJECT_STORAGE_PROVIDER", ""),
        os.environ.get("OBJECT_STORAGE_ID", ""),
        len(objects),
    ))
    if objects:
        first_key = str(objects[0].get("key", ""))
        response = requests.head(object_url(first_key), headers=broker_headers(), timeout=30)
        response.raise_for_status()
        for item in objects[:10]:
            print("  -", item.get("key", ""))
        if len(objects) > 10:
            print("  ... and %d more" % (len(objects) - 10))
    else:
        print("The bucket is empty. Upload data and rerun the notebook cells.")


if __name__ == "__main__":
    verify()
"""

                def notebook = [
                    cells: [
                        [cell_type: "markdown", metadata: [:], source: [
                            "# Object Storage Data Lab\n",
                            "\n",
                            "CB-Tumblebug가 발급한 presigned URL을 제한된 로컬 broker를 통해 사용합니다.\n",
                            "Jupyter 컨테이너에는 CSP Access Key / Secret Key와 Tumblebug 자격증명이 없습니다.\n",
                            "노트북은 고정된 broker URL을 사용하며, broker가 만료 전에 새 presigned URL로 자동 교체합니다.\n",
                            "\n",
                            "버킷에 파일을 올린 뒤 아래 셀을 위에서부터 실행하세요."
                        ]],
                        [cell_type: "markdown", metadata: [:], source: [
                            "## 1. 버킷 파일 목록"
                        ]],
                        [cell_type: "code", execution_count: null, metadata: [:], outputs: [], source: [
                            "import os\n",
                            "import matplotlib.pyplot as plt\n",
                            "from object_storage_access import create_connection, list_objects, object_url, sql_identifier, sql_quote, upload_file\n",
                            "\n",
                            "con = create_connection()\n",
                            "objects = list_objects()\n",
                            "files = [str(item.get(\"key\", \"\")) for item in objects if item.get(\"key\")]\n",
                            "print(\"storage:\", os.environ.get(\"OBJECT_STORAGE_ID\", \"\"))\n",
                            "print(\"objects:\", len(files))\n",
                            "for name in files[:30]:\n",
                            "    print(\" -\", name)"
                        ]],
                        [cell_type: "markdown", metadata: [:], source: [
                            "## 2. 데이터 로드\n",
                            "\n",
                            "Parquet이 있으면 Parquet을, 없으면 CSV를 읽습니다. `TARGET_KEYS`에 분석할 객체 키 목록을 직접 지정할 수도 있습니다."
                        ]],
                        [cell_type: "code", execution_count: null, metadata: [:], outputs: [], source: [
                            "TARGET_KEYS = None\n",
                            "\n",
                            "def pick_reader():\n",
                            "    selected = list(TARGET_KEYS) if TARGET_KEYS else []\n",
                            "    if selected:\n",
                            "        reader = \"read_parquet\" if all(name.lower().endswith(\".parquet\") for name in selected) else \"read_csv_auto\"\n",
                            "        return selected, reader\n",
                            "    parquet_files = [name for name in files if name.lower().endswith(\".parquet\")]\n",
                            "    if parquet_files:\n",
                            "        return parquet_files, \"read_parquet\"\n",
                            "    csv_files = [name for name in files if name.lower().endswith(\".csv\")]\n",
                            "    if csv_files:\n",
                            "        return csv_files, \"read_csv_auto\"\n",
                            "    return [], None\n",
                            "\n",
                            "selected_keys, reader = pick_reader()\n",
                            "if not selected_keys:\n",
                            "    df = None\n",
                            "    print(\"읽을 Parquet / CSV 파일이 없습니다. 버킷에 파일을 올린 뒤 1번 셀부터 다시 실행하세요.\")\n",
                            "else:\n",
                            "    urls = [object_url(name) for name in selected_keys]\n",
                            "    url_list_sql = \"[\" + \", \".join(sql_quote(url) for url in urls) + \"]\"\n",
                            "    df = con.execute(\"SELECT * FROM \" + reader + \"(\" + url_list_sql + \", union_by_name=true)\").df()\n",
                            "    print(reader, \"objects:\", len(selected_keys))\n",
                            "    print(\"rows:\", len(df), \"columns:\", list(df.columns))\n",
                            "    display(df.head())"
                        ]],
                        [cell_type: "markdown", metadata: [:], source: [
                            "## 3. 집계와 차트\n",
                            "\n",
                            "문자열 컬럼을 기준으로 숫자 컬럼을 합계 냅니다. `GROUP_COL` / `VALUE_COL`로 직접 지정할 수 있습니다."
                        ]],
                        [cell_type: "code", execution_count: null, metadata: [:], outputs: [], source: [
                            "GROUP_COL = None\n",
                            "VALUE_COL = None\n",
                            "summary = None\n",
                            "\n",
                            "if df is None or df.empty:\n",
                            "    print(\"로드된 데이터가 없습니다.\")\n",
                            "else:\n",
                            "    text_cols = [c for c in df.columns if df[c].dtype == object]\n",
                            "    num_cols = [c for c in df.columns if df[c].dtype.kind in \"ifu\"]\n",
                            "    group_col = GROUP_COL or (\"region\" if \"region\" in df.columns else (text_cols[0] if text_cols else None))\n",
                            "    value_col = VALUE_COL or (num_cols[0] if num_cols else None)\n",
                            "    if group_col is None or value_col is None:\n",
                            "        print(\"집계할 컬럼을 찾지 못했습니다. GROUP_COL과 VALUE_COL을 직접 지정하세요.\")\n",
                            "    else:\n",
                            "        con.register(\"loaded\", df)\n",
                            "        summary = con.execute(\n",
                            "            \"SELECT \" + sql_identifier(group_col) + \" AS group_key, SUM(\" + sql_identifier(value_col) + \") AS total \"\n",
                            "            \"FROM loaded GROUP BY 1 ORDER BY 1\"\n",
                            "        ).df()\n",
                            "        display(summary)\n",
                            "        summary.plot.bar(x=\"group_key\", y=\"total\", legend=False, title=value_col + \" by \" + group_col)\n",
                            "        plt.tight_layout()\n",
                            "        plt.show()"
                        ]],
                        [cell_type: "markdown", metadata: [:], source: [
                            "## 4. 새 파일 추가 후 재실행\n",
                            "\n",
                            "버킷에 파일을 더 올린 뒤 1~3번 셀을 다시 실행하면 목록과 결과, 차트가 갱신됩니다."
                        ]],
                        [cell_type: "markdown", metadata: [:], source: [
                            "## 5. 분석 결과 저장 (선택)"
                        ]],
                        [cell_type: "code", execution_count: null, metadata: [:], outputs: [], source: [
                            "if summary is None:\n",
                            "    print(\"저장할 집계 결과가 없습니다.\")\n",
                            "elif os.environ.get(\"WRITE_RESULT_ENABLED\", \"true\").lower() != \"true\":\n",
                            "    print(\"WRITE_RESULT_ENABLED가 false라 저장하지 않습니다.\")\n",
                            "else:\n",
                            "    result_prefix = os.environ.get(\"RESULT_PREFIX\", \"results\").strip(\"/\")\n",
                            "    result_key = result_prefix + \"/summary.parquet\"\n",
                            "    local_result = \"/tmp/object-storage-data-lab-summary.parquet\"\n",
                            "    con.register(\"summary_data\", summary)\n",
                            "    con.execute(\"COPY summary_data TO \" + sql_quote(local_result) + \" (FORMAT PARQUET)\")\n",
                            "    upload_file(result_key, local_result)\n",
                            "    print(\"Saved:\", result_key)\n",
                            "    display(con.execute(\"SELECT * FROM read_parquet(\" + sql_quote(object_url(result_key)) + \")\").df())"
                        ]]
                    ],
                    metadata: [
                        kernelspec: [display_name: "Python 3 (ipykernel)", language: "python", name: "python3"],
                        language_info: [name: "python", version: "3"]
                    ],
                    nbformat: 4,
                    nbformat_minor: 5
                ]

                def installerSource = """#!/usr/bin/env bash
set -euo pipefail

APP_ROOT="/opt/object-storage-data-lab"
CONFIG_DIR="\${APP_ROOT}/config"
WORK_DIR="\${APP_ROOT}/work"
BUILD_DIR="\${APP_ROOT}/build"
BROKER_DIR="\${APP_ROOT}/broker"
ENV_FILE="\${CONFIG_DIR}/data-lab.env"
BROKER_ENV_FILE="\${CONFIG_DIR}/broker.env"
INCOMING_ENV="/tmp/object-storage-data-lab.env"
INCOMING_BROKER_ENV="/tmp/object-storage-data-lab-broker.env"
CONTAINER_NAME="object-storage-data-lab"
BROKER_CONTAINER_NAME="object-storage-data-lab-broker"
NETWORK_NAME="object-storage-data-lab"

cleanup_incoming_files() {
  sudo rm -f /tmp/object-storage-data-lab.env /tmp/object-storage-data-lab-broker.env /tmp/object-storage-data-lab.ipynb /tmp/object_storage_access.py /tmp/presigned_broker.py /tmp/verify_object_storage.py /tmp/object-storage-data-lab-install.sh || true
}
trap cleanup_incoming_files EXIT

get_env_value() {
  grep -m1 "^\${1}=" "\${INCOMING_ENV}" | cut -d= -f2-
}

if ! command -v docker >/dev/null 2>&1; then
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y docker.io curl ca-certificates
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y docker curl ca-certificates
  elif command -v yum >/dev/null 2>&1; then
    sudo yum install -y docker curl ca-certificates
  else
    echo "Unsupported package manager"
    exit 1
  fi
fi
sudo systemctl enable --now docker

sudo mkdir -p "\${CONFIG_DIR}" "\${WORK_DIR}" "\${BUILD_DIR}" "\${BROKER_DIR}"
jupyter_token=""
if sudo test -f "\${ENV_FILE}"; then
  jupyter_token=\$(sudo grep -m1 "^JUPYTER_TOKEN=" "\${ENV_FILE}" | cut -d= -f2- || true)
fi
if [ -z "\${jupyter_token}" ]; then
  jupyter_token=\$(od -An -N24 -tx1 /dev/urandom | tr -d " \\n")
fi
broker_token=\$(od -An -N32 -tx1 /dev/urandom | tr -d " \\n")

sudo install -m 600 "\${INCOMING_ENV}" "\${ENV_FILE}"
printf "JUPYTER_TOKEN=%s\\nOBJECT_STORAGE_BROKER_TOKEN=%s\\n" "\${jupyter_token}" "\${broker_token}" | sudo tee -a "\${ENV_FILE}" >/dev/null
sudo install -m 600 "\${INCOMING_BROKER_ENV}" "\${BROKER_ENV_FILE}"
printf "BROKER_TOKEN=%s\\n" "\${broker_token}" | sudo tee -a "\${BROKER_ENV_FILE}" >/dev/null
sudo install -m 644 /tmp/object-storage-data-lab.ipynb "\${WORK_DIR}/object-storage-data-lab.ipynb"
sudo install -m 644 /tmp/object_storage_access.py "\${WORK_DIR}/object_storage_access.py"
sudo install -m 644 /tmp/verify_object_storage.py "\${WORK_DIR}/verify_object_storage.py"
sudo install -m 644 /tmp/presigned_broker.py "\${BROKER_DIR}/presigned_broker.py"
sudo chown -R 1000:100 "\${WORK_DIR}"

JUPYTER_IMAGE=\$(get_env_value JUPYTER_IMAGE)
DUCKDB_VERSION=\$(get_env_value DUCKDB_VERSION)
JUPYTER_BIND_HOST=\$(get_env_value JUPYTER_BIND_HOST)
JUPYTER_PORT=\$(get_env_value JUPYTER_PORT)
LOCAL_IMAGE="object-storage-data-lab:duckdb-\${DUCKDB_VERSION}"

sudo tee "\${BUILD_DIR}/Dockerfile" >/dev/null <<EOF
FROM \${JUPYTER_IMAGE}
RUN python -m pip install --no-cache-dir duckdb==\${DUCKDB_VERSION} requests
EOF
sudo docker build --pull -t "\${LOCAL_IMAGE}" "\${BUILD_DIR}"
sudo docker network inspect "\${NETWORK_NAME}" >/dev/null 2>&1 || sudo docker network create "\${NETWORK_NAME}" >/dev/null

sudo docker rm -f "\${CONTAINER_NAME}" "\${BROKER_CONTAINER_NAME}" >/dev/null 2>&1 || true
sudo docker run -d \\
  --name "\${BROKER_CONTAINER_NAME}" \\
  --restart unless-stopped \\
  --network "\${NETWORK_NAME}" \\
  --network-alias object-storage-broker \\
  --env-file "\${BROKER_ENV_FILE}" \\
  -v "\${BROKER_DIR}/presigned_broker.py:/opt/presigned_broker.py:ro" \\
  "\${LOCAL_IMAGE}" \\
  python /opt/presigned_broker.py

broker_healthy="false"
for attempt in \$(seq 1 30); do
  if sudo docker exec "\${BROKER_CONTAINER_NAME}" python -c "import urllib.request; urllib.request.urlopen(\\\"http://127.0.0.1:8765/health\\\", timeout=3).read()" >/dev/null; then
    broker_healthy="true"
    break
  fi
  sleep 2
done
if [ "\${broker_healthy}" != "true" ]; then
  sudo docker logs --tail 100 "\${BROKER_CONTAINER_NAME}"
  echo "Object Storage presigned URL broker health check failed"
  exit 1
fi

sudo docker run --rm \\
  --env-file "\${ENV_FILE}" \\
  --network "\${NETWORK_NAME}" \\
  -v "\${WORK_DIR}:/home/jovyan/work" \\
  "\${LOCAL_IMAGE}" \\
  python /home/jovyan/work/verify_object_storage.py

sudo docker run -d \\
  --name "\${CONTAINER_NAME}" \\
  --restart unless-stopped \\
  --network "\${NETWORK_NAME}" \\
  --env-file "\${ENV_FILE}" \\
  -p "\${JUPYTER_BIND_HOST}:\${JUPYTER_PORT}:8888" \\
  -v "\${WORK_DIR}:/home/jovyan/work" \\
  "\${LOCAL_IMAGE}" \\
  start-notebook.py --ServerApp.ip=0.0.0.0

healthy="false"
for attempt in \$(seq 1 30); do
  if curl -fsS "http://127.0.0.1:\${JUPYTER_PORT}/api?token=\${jupyter_token}" >/dev/null; then
    healthy="true"
    break
  fi
  sleep 5
done
if [ "\${healthy}" != "true" ]; then
  sudo docker logs --tail 100 "\${CONTAINER_NAME}" | sed "s/\${jupyter_token}/****/g"
  echo "JupyterLab health check failed"
  exit 1
fi

echo ""
echo ">>>>> Object Storage Data Lab is ready."
echo "      access mode   : CB-Tumblebug presigned URL broker"
echo "      remote bind   : \${JUPYTER_BIND_HOST}:\${JUPYTER_PORT}"
echo "      token file    : \${ENV_FILE} (on the VM)"
echo "      jupyter token : \${jupyter_token}"
echo ""
if [ "\${JUPYTER_BIND_HOST}" != "127.0.0.1" ] && [ "\${JUPYTER_BIND_HOST}" != "localhost" ] && [ "\${JUPYTER_BIND_HOST}" != "::1" ]; then
  echo "      direct URL    : http://${sshHost}:\${JUPYTER_PORT}/lab?token=\${jupyter_token}"
  echo ""
fi
echo "      SSH tunnel alternative:"
echo "         ssh -N -L \${JUPYTER_PORT}:127.0.0.1:\${JUPYTER_PORT} ${sshUser}@${sshHost}"
echo "      then open:"
echo "         http://127.0.0.1:\${JUPYTER_PORT}/lab?token=\${jupyter_token}"
"""

                writeFile file: "presigned_broker.py", text: brokerSource
                writeFile file: "object_storage_access.py", text: helperSource
                writeFile file: "verify_object_storage.py", text: verifierSource
                writeFile file: "object-storage-data-lab.ipynb", text: groovy.json.JsonOutput.prettyPrint(groovy.json.JsonOutput.toJson(notebook))
                writeFile file: "object-storage-data-lab-install.sh", text: installerSource
                writeFile file: "object-storage-data-lab.env", text: """OBJECT_STORAGE_PROVIDER=${provider}
OBJECT_STORAGE_ID=${storageId}
DATA_PREFIX=${dataPrefix}
RESULT_PREFIX=${resultPrefix}
WRITE_RESULT_ENABLED=${writeResultEnabled}
PRESIGNED_URL_EXPIRES=${presignedExpires}
OBJECT_STORAGE_BROKER_URL=http://object-storage-broker:8765
JUPYTER_IMAGE=${jupyterImage}
DUCKDB_VERSION=${duckdbVersion}
JUPYTER_BIND_HOST=${jupyterBindHost}
JUPYTER_PORT=${jupyterPort}
"""
                writeFile file: "object-storage-data-lab-broker.env", text: """TUMBLEBUG_URL=${runtimeTumblebug}
TUMBLEBUG_USERNAME=${params.USER}
TUMBLEBUG_PASSWORD=${params.USERPASS}
OBJECT_STORAGE_NAMESPACE=${osNamespace}
OBJECT_STORAGE_ID=${storageId}
DATA_PREFIX=${dataPrefix}
RESULT_PREFIX=${resultPrefix}
PRESIGNED_URL_EXPIRES=${presignedExpires}
"""
                try {
                    sh "chmod 600 object-storage-data-lab.env object-storage-data-lab-broker.env && chmod 700 object-storage-data-lab-install.sh"
                    sh """scp -o StrictHostKeyChecking=no ${keyOpt} object-storage-data-lab.env object-storage-data-lab-broker.env object-storage-data-lab.ipynb object_storage_access.py presigned_broker.py verify_object_storage.py object-storage-data-lab-install.sh "${sshUser}@${sshHost}:/tmp/"
ssh -o StrictHostKeyChecking=no ${keyOpt} "${sshUser}@${sshHost}" "chmod 600 /tmp/object-storage-data-lab.env /tmp/object-storage-data-lab-broker.env && chmod 700 /tmp/object-storage-data-lab-install.sh && /tmp/object-storage-data-lab-install.sh"
"""
                } finally {
                    sh "rm -f object-storage-data-lab.env object-storage-data-lab-broker.env object-storage-data-lab.ipynb object_storage_access.py presigned_broker.py verify_object_storage.py object-storage-data-lab-install.sh"
                }
            }
        }
    }');
-- Replace any existing direct-credential mappings before retiring the legacy catalog stage.
UPDATE workflow_stage_mapping
SET workflow_stage_idx = 62,
    stage = (SELECT workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 62)
WHERE workflow_stage_idx = 55;
DELETE FROM workflow_param
WHERE UPPER(param_key) IN ('TUMBLEBUG_RUNTIME_URL', 'MC_INFRA_MANAGER_RUNTIME_URL')
  AND workflow_idx IN (
      SELECT workflow_idx FROM workflow_stage_mapping WHERE workflow_stage_idx = 62
  );
DELETE FROM workflow_stage WHERE workflow_stage_idx = 55;

INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (48, 20, 1, 'mariadb-install', 'Install MariaDB', '
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (39, 20, 2, 'db-backup-export', 'Export DB backup file', '
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (40, 20, 3, 'db-backup-import', 'Import backup file (restore)', '
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (41, 20, 5, 'db-data-insert', 'Insert initial data', '
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (42, 20, 6, 'db-data-verify', 'Verify loaded data', '
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (43, 21, 1, 'ssh-command-exec', 'Execute remote SSH command', '
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (44, 21, 2, 'http-request', 'Call REST API', '
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (45, 21, 3, 'wait-for-condition', 'Wait until condition is met (polling)', '
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (46, 21, 4, 'notification-send', 'Send result notification, such as Slack', '
    stage("notification-send") {
        steps {
            echo ">>>>> STAGE: notification-send"
            script {
                def payload = params.NOTIFICATION_PAYLOAD?.trim()
                if (!payload) {
                    payload = groovy.json.JsonOutput.toJson([text: params.NOTIFICATION_MESSAGE ?: "Workflow finished"])
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (47, 21, 5, 'script-exec', 'Run shell script', '
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (54, 21, 6, 'namespace-ensure', 'Check and create Tumblebug namespace', '
    stage("namespace-ensure") {
        steps {
            echo ">>>>> STAGE: namespace-ensure"
            script {
                if (!params.TUMBLEBUG?.trim()) {
                    error "TUMBLEBUG is required"
                }
                if (!params.NAMESPACE?.trim()) {
                    error "NAMESPACE is required"
                }

                def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                def namespaceUrl = "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}"
                def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${namespaceUrl}" ${auth}""", returnStdout: true).trim()
                if (response.contains("Http_Status_code:2")) {
                    echo "Namespace ${params.NAMESPACE} already exists."
                    return
                }
                if (!response.contains("Http_Status_code:404")) {
                    error "namespace-ensure lookup failed: ${response}"
                }

                def payload = groovy.json.JsonOutput.toJson([
                    name: params.NAMESPACE,
                    description: params.NAMESPACE_DESC ?: "Workflow created namespace"
                ])
                writeFile file: "namespace-create.json", text: payload
                def createResponse = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X POST "${params.TUMBLEBUG}/tumblebug/ns" -H "Content-Type: application/json" -d @namespace-create.json ${auth}""", returnStdout: true).trim()
                echo createResponse
                def lowerCreateResponse = createResponse.toLowerCase()
                def createdOrExists = createResponse.contains("Http_Status_code:2") || createResponse.contains("Http_Status_code:409") || lowerCreateResponse.contains("already")
                if (!createdOrExists) {
                    error "namespace-ensure create failed: ${createResponse}"
                }
                echo "Namespace ${params.NAMESPACE} is ready."
            }
        }
    }');


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (56, 22, 1, 'object-storage-ensure', 'Reuse or create an Object Storage bucket via CB-Tumblebug and resolve its CSP name', '
    stage("object-storage-ensure") {
        steps {
            echo ">>>>> STAGE: object-storage-ensure"
            script {
                def tumblebug = (params.TUMBLEBUG ?: "").trim().replaceAll("/+\$", "")
                if (!tumblebug) {
                    error "TUMBLEBUG is required"
                }
                if (!params.NAMESPACE?.trim()) {
                    error "NAMESPACE is required"
                }

                def storageName = (params.OBJECT_STORAGE_BUCKET ?: "").trim()
                def provider = (params.OBJECT_STORAGE_PROVIDER ?: params.CSP ?: params.PROVIDER ?: "").trim().toLowerCase()
                def region = (params.OBJECT_STORAGE_REGION ?: params.REGION ?: "").trim()
                def osNamespace = (params.OBJECT_STORAGE_NAMESPACE ?: params.NAMESPACE ?: "").trim()
                def connectionName = "${provider}-${region}"
                if (!storageName || !provider || !region) {
                    error "OBJECT_STORAGE_BUCKET, OBJECT_STORAGE_PROVIDER and OBJECT_STORAGE_REGION are required"
                }

                def safeValues = [storageName: storageName, provider: provider, region: region, tumblebug: tumblebug, osNamespace: osNamespace, connectionName: connectionName]
                safeValues.each { name, value ->
                    if (!(value ==~ /[A-Za-z0-9._:\/-]+/) || value.contains("..")) {
                        error "Invalid ${name}"
                    }
                }

                def extractJsonStringValue = { text, key ->
                    def marker = "\"" + key + "\""
                    def keyIdx = text.indexOf(marker)
                    if (keyIdx < 0) {
                        return ""
                    }
                    def colonIdx = text.indexOf(":", keyIdx + marker.length())
                    if (colonIdx < 0) {
                        return ""
                    }
                    def startIdx = text.indexOf("\"", colonIdx + 1)
                    if (startIdx < 0) {
                        return ""
                    }
                    def endIdx = text.indexOf("\"", startIdx + 1)
                    if (endIdx < 0) {
                        return ""
                    }
                    return text.substring(startIdx + 1, endIdx)
                }

                def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                def objectStorageUrl = "${tumblebug}/tumblebug/ns/${osNamespace}/resources/objectStorage"
                def detailUrl = "${objectStorageUrl}/${storageName}"

                // The selector offers only registered buckets, while custom text denotes a new logical ID.
                // Check the authoritative Tumblebug list again at run time to avoid a stale UI decision.
                def listResponse = sh(script: "curl -sS -w \"- Http_Status_code:%{http_code}\" -X GET \"${objectStorageUrl}\" ${auth}", returnStdout: true).trim()
                if (!listResponse.contains("Http_Status_code:2")) {
                    error "object-storage-ensure failed to list object storages: ${listResponse}"
                }
                def listBody = listResponse.replaceAll("- Http_Status_code:[0-9]{3}", "").trim()
                def listPayload = new groovy.json.JsonSlurper().parseText(listBody)
                def listedBuckets = listPayload instanceof List ? listPayload : (listPayload.objectStorage ?: [])
                def existingBucket = listedBuckets.find { bucket ->
                    (bucket.id ?: bucket.name ?: "").toString().trim() == storageName
                }
                def existingBucketFound = existingBucket != null
                def existingConnectionName = existingBucketFound ? (existingBucket.connectionName ?: "").toString().trim() : ""
                def existingCspBucket = existingBucketFound ? (existingBucket.cspResourceName ?: existingBucket.uid ?: "").toString().trim() : ""
                existingBucket = null
                listedBuckets = null
                listPayload = null
                def cspBucket = ""

                if (existingBucketFound) {
                    if (existingConnectionName && existingConnectionName != connectionName) {
                        error "Object storage ${storageName} already exists with connection ${existingConnectionName}, not ${connectionName}"
                    }
                    cspBucket = existingCspBucket
                    echo "Reusing existing object storage ${storageName} in namespace ${osNamespace}."
                } else {
                    def payload = groovy.json.JsonOutput.toJson([
                        bucketName: storageName,
                        connectionName: connectionName
                    ])
                    writeFile file: "object-storage-create.json", text: payload
                    try {
                        echo "Requesting CB-Tumblebug to create bucket ${storageName} with connection ${connectionName}"
                        def createResponse = sh(script: "curl -sS -w \"- Http_Status_code:%{http_code}\" -X PUT \"${objectStorageUrl}\" -H \"Content-Type: application/json\" -d @object-storage-create.json ${auth}", returnStdout: true).trim()
                        echo createResponse
                        if (!createResponse.contains("Http_Status_code:2")) {
                            error "object-storage-ensure failed: ${createResponse}"
                        }
                    } finally {
                        sh "rm -f object-storage-create.json"
                    }
                }

                def maxAttempts = (params.OBJECT_STORAGE_READY_MAX_ATTEMPTS ?: "30").toInteger()
                def intervalSeconds = (params.OBJECT_STORAGE_READY_INTERVAL_SECONDS ?: "5").toInteger()
                def attempt = 0
                while (!cspBucket && attempt < maxAttempts) {
                    attempt = attempt + 1
                    def detail = sh(script: "curl -sS -w \"- Http_Status_code:%{http_code}\" -X GET \"${detailUrl}\" ${auth}", returnStdout: true).trim()
                    if (detail.contains("Http_Status_code:2")) {
                        def resolved = extractJsonStringValue(detail, "cspResourceName")
                        if (!resolved) {
                            resolved = extractJsonStringValue(detail, "uid")
                        }
                        def status = extractJsonStringValue(detail, "status")
                        if (resolved) {
                            cspBucket = resolved
                            echo "Object storage is ready. status=${status}"
                        } else {
                            echo "Waiting for the CSP bucket name. attempt ${attempt}/${maxAttempts}, status=${status}"
                            sleep intervalSeconds
                        }
                    } else if (detail.contains("Http_Status_code:404")) {
                        echo "Object storage ${storageName} is not registered yet. attempt ${attempt}/${maxAttempts}"
                        sleep intervalSeconds
                    } else {
                        error "object-storage-ensure failed to read the object storage detail: ${detail}"
                    }
                }

                if (!cspBucket) {
                    error "Unable to resolve the CSP bucket name for ${storageName} within ${maxAttempts} attempts. Tumblebug creates the bucket under a generated name, so the pipeline cannot continue without it."
                }

                // Preserve the resolved CSP name for legacy direct-access stages. The presigned
                // stage intentionally reads params.OBJECT_STORAGE_BUCKET as the Tumblebug logical ID.
                env.OBJECT_STORAGE_BUCKET = cspBucket
                echo "Bucket ready. tumblebugId=${storageName}, cspBucket=${cspBucket}"
            }
        }
    }');




INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (57, 22, 2, 'object-storage-delete', 'Delete an Object Storage bucket and its contents via CB-Tumblebug', '
    stage("object-storage-delete") {
        steps {
            echo ">>>>> STAGE: object-storage-delete"
            script {
                def enabled = (params.OBJECT_STORAGE_DELETE_ENABLED ?: "true").trim().toLowerCase()
                if (!(enabled in ["true", "false"])) {
                    error "OBJECT_STORAGE_DELETE_ENABLED must be true or false"
                }
                if (enabled == "false") {
                    echo "OBJECT_STORAGE_DELETE_ENABLED is false. Keeping the bucket and its contents."
                } else {
                    def tumblebug = (params.TUMBLEBUG ?: "").trim().replaceAll("/+\$", "")
                    if (!tumblebug) {
                        error "TUMBLEBUG is required"
                    }
                    if (!params.NAMESPACE?.trim()) {
                        error "NAMESPACE is required"
                    }

                    // Deliberately not env: object-storage-ensure publishes the resolved CSP name there, while
                    // Tumblebug deletes by the logical name supplied as the workflow parameter.
                    def storageName = (params.OBJECT_STORAGE_BUCKET ?: "").trim()
                    def provider = (params.OBJECT_STORAGE_PROVIDER ?: params.CSP ?: params.PROVIDER ?: "").trim().toLowerCase()
                    def region = (params.OBJECT_STORAGE_REGION ?: params.REGION ?: "").trim()
                    def osNamespace = (params.OBJECT_STORAGE_NAMESPACE ?: params.NAMESPACE ?: "").trim()
                    if (!storageName || !provider || !region) {
                        error "OBJECT_STORAGE_BUCKET, OBJECT_STORAGE_PROVIDER and OBJECT_STORAGE_REGION are required"
                    }

                    def safeValues = [storageName: storageName, provider: provider, region: region, tumblebug: tumblebug, osNamespace: osNamespace]
                    safeValues.each { name, value ->
                        if (!(value ==~ /[A-Za-z0-9._:\/-]+/) || value.contains("..")) {
                            error "Invalid ${name}"
                        }
                    }

                    def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                    def objectStorageUrl = "${tumblebug}/tumblebug/ns/${osNamespace}/resources/objectStorage"
                    def detailUrl = "${objectStorageUrl}/${storageName}"

                    def listResponse = sh(script: "curl -sS -w \"- Http_Status_code:%{http_code}\" -X GET \"${objectStorageUrl}\" ${auth}", returnStdout: true).trim()
                    if (!listResponse.contains("Http_Status_code:2")) {
                        error "object-storage-delete failed to list object storages: ${listResponse}"
                    }
                    def listBody = listResponse.replaceAll("- Http_Status_code:[0-9]{3}", "").trim()
                    def listPayload = new groovy.json.JsonSlurper().parseText(listBody)
                    def listedBuckets = listPayload instanceof List ? listPayload : (listPayload.objectStorage ?: [])
                    def bucketExists = listedBuckets.any { bucket ->
                        (bucket.id ?: bucket.name ?: "").toString().trim() == storageName
                    }
                    listedBuckets = null
                    listPayload = null

                    if (!bucketExists) {
                        echo "Object storage ${storageName} is already absent. Nothing to delete."
                    } else {
                        echo "Requesting CB-Tumblebug to delete bucket ${storageName} including its contents"
                        def deleteResponse = sh(script: "curl -sS -w \"- Http_Status_code:%{http_code}\" -X DELETE \"${detailUrl}?option=force\" ${auth}", returnStdout: true).trim()
                        echo deleteResponse
                        if (!deleteResponse.contains("Http_Status_code:2")) {
                            error "object-storage-delete failed: ${deleteResponse}"
                        }

                        def confirmResponse = sh(script: "curl -sS -w \"- Http_Status_code:%{http_code}\" -X GET \"${objectStorageUrl}\" ${auth}", returnStdout: true).trim()
                        if (!confirmResponse.contains("Http_Status_code:2")) {
                            error "object-storage-delete failed to confirm object storage deletion: ${confirmResponse}"
                        }
                        def confirmBody = confirmResponse.replaceAll("- Http_Status_code:[0-9]{3}", "").trim()
                        def confirmPayload = new groovy.json.JsonSlurper().parseText(confirmBody)
                        def remainingBuckets = confirmPayload instanceof List ? confirmPayload : (confirmPayload.objectStorage ?: [])
                        def stillExists = remainingBuckets.any { bucket ->
                            (bucket.id ?: bucket.name ?: "").toString().trim() == storageName
                        }
                        remainingBuckets = null
                        confirmPayload = null
                        if (!stillExists) {
                            echo "Bucket ${storageName} removed."
                        } else {
                            echo "Delete accepted, but the object storage record still responds. It may still be finalizing."
                        }
                    }
                }
            }
        }
    }');

-- Step 5: Insert into workflow
-- Legacy test workflow seed data intentionally omitted.
-- Step 8: Insert scenario workflows
-- A. vm-mariadb-backup-import-data-init
-- B. multi-csp-vm-deploy
-- C. k8s-mariadb-backup-import-data-init
-- D. multi-csp-k8s-cluster-deploy
-- E. vm-mariadb-data-init-cleanup
-- F. multi-csp-vm-cleanup
-- G. k8s-mariadb-data-init-cleanup
-- H. multi-csp-k8s-cluster-cleanup
-- I. vm-object-storage-data-lab-init
-- J. vm-object-storage-data-lab-cleanup

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

DELETE FROM workflow_stage_mapping WHERE workflow_idx IN (101, 102, 103, 104, 105, 106, 107, 108, 109, 110);
DELETE FROM workflow_param WHERE workflow_idx IN (101, 102, 103, 104, 105, 106, 107, 108, 109, 110);
ALTER TABLE workflow_param ALTER COLUMN param_idx RESTART WITH 10000;
ALTER TABLE workflow_stage_mapping ALTER COLUMN mapping_idx RESTART WITH 10000;

MERGE INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script, run_date) KEY(workflow_idx)
SELECT 101, 'vm-mariadb-backup-import-data-init', 'For Deployment', 1,
'import groovy.json.JsonOutput

pipeline {
    agent any
    stages {
'
|| (SELECT workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 54)
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
        stage("namespace-ensure") {
            steps {
                echo ">>>>> STAGE: namespace-ensure"
                script {
                    if (!params.TUMBLEBUG?.trim()) {
                        error "TUMBLEBUG is required"
                    }
                    if (!params.NAMESPACE?.trim()) {
                        error "NAMESPACE is required"
                    }

                    def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                    def namespaceUrl = "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}"
                    def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${namespaceUrl}" ${auth}""", returnStdout: true).trim()
                    if (response.contains("Http_Status_code:2")) {
                        echo "Namespace ${params.NAMESPACE} already exists."
                        return
                    }
                    if (!response.contains("Http_Status_code:404")) {
                        error "namespace-ensure lookup failed: ${response}"
                    }

                    def payload = groovy.json.JsonOutput.toJson([
                        name: params.NAMESPACE,
                        description: params.NAMESPACE_DESC ?: "Workflow created namespace"
                    ])
                    writeFile file: "namespace-create.json", text: payload
                    def createResponse = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X POST "${params.TUMBLEBUG}/tumblebug/ns" -H "Content-Type: application/json" -d @namespace-create.json ${auth}""", returnStdout: true).trim()
                    echo createResponse
                    def lowerCreateResponse = createResponse.toLowerCase()
                    def createdOrExists = createResponse.contains("Http_Status_code:2") || createResponse.contains("Http_Status_code:409") || lowerCreateResponse.contains("already")
                    if (!createdOrExists) {
                        error "namespace-ensure create failed: ${createResponse}"
                    }
                    echo "Namespace ${params.NAMESPACE} is ready."
                }
            }
        }
        stage("multi-csp-vm-deploy") {
            steps {
                echo ">>>>> STAGE: multi-csp-vm-deploy"
                script {
                    def cspList = (params.CSP_LIST ?: "").split(",").collect { it.trim() }.findAll { it }
                    if (cspList.isEmpty()) {
                        error "CSP_LIST is required"
                    }

                    def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                    def infraId = params.INFRA_ID ?: params.INFRA_PREFIX ?: "multi-csp-vm"
                    def nodeGroupPrefix = params.INFRA_NODEGROUP_PREFIX ?: params.INFRA_NODEGROUP_NAME ?: "ng"
                    def nodeGroups = []
                    def providers = []
                    def regions = []

                    cspList.each { csp ->
                        def key = csp.toUpperCase().replaceAll("[^A-Z0-9]", "_")
                        def specId = params["${key}_SPEC_ID"]
                        def imageId = params["${key}_IMAGE_ID"]
                        def region = params["${key}_REGION"] ?: params.REGION ?: ""
                        def connectionName = params["${key}_CONNECTION_NAME"] ?: params.CONNECTION_NAME ?: (region ? "${csp}-${region}" : "")
                        def zone = params["${key}_ZONE"] ?: params.ZONE ?: ""
                        if (!specId || !imageId) {
                            error "${key}_SPEC_ID and ${key}_IMAGE_ID are required for ${csp}"
                        }

                        def nodeGroup = [
                            name: params["${key}_NODEGROUP_NAME"] ?: "${nodeGroupPrefix}-${key.toLowerCase().replaceAll("_", "-")}",
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

                        nodeGroups << nodeGroup
                        if (!providers.contains(csp)) {
                            providers << csp
                        }
                        if (region && !regions.contains(region)) {
                            regions << region
                        }
                    }

                    def payload = groovy.json.JsonOutput.toJson([
                        name: infraId,
                        description: params.INFRA_DESC ?: "Workflow multi CSP VM deploy",
                        installMonAgent: params.INSTALL_MON_AGENT ?: "no",
                        policyOnPartialFailure: params.POLICY_ON_PARTIAL_FAILURE ?: "continue",
                        label: [
                            csp: providers.join(","),
                            region: regions.join(",")
                        ],
                        nodeGroups: nodeGroups
                    ])

                    writeFile file: "infra-create.json", text: payload
                    echo "multi-csp-vm-deploy payload: ${payload}"
                    def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X POST "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/infraDynamic" -H "Content-Type: application/json" -d @infra-create.json ${auth}""", returnStdout: true).trim()
                    echo response
                    if (!response.contains("Http_Status_code:2")) {
                        error "multi-csp-vm-deploy failed: ${response}"
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
|| (SELECT workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 54)
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
        stage("namespace-ensure") {
            steps {
                echo ">>>>> STAGE: namespace-ensure"
                script {
                    if (!params.TUMBLEBUG?.trim()) {
                        error "TUMBLEBUG is required"
                    }
                    if (!params.NAMESPACE?.trim()) {
                        error "NAMESPACE is required"
                    }

                    def auth = (params.USER && params.USERPASS) ? "--user \"${params.USER}:${params.USERPASS}\"" : ""
                    def namespaceUrl = "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}"
                    def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${namespaceUrl}" ${auth}""", returnStdout: true).trim()
                    if (response.contains("Http_Status_code:2")) {
                        echo "Namespace ${params.NAMESPACE} already exists."
                        return
                    }
                    if (!response.contains("Http_Status_code:404")) {
                        error "namespace-ensure lookup failed: ${response}"
                    }

                    def payload = groovy.json.JsonOutput.toJson([
                        name: params.NAMESPACE,
                        description: params.NAMESPACE_DESC ?: "Workflow created namespace"
                    ])
                    writeFile file: "namespace-create.json", text: payload
                    def createResponse = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X POST "${params.TUMBLEBUG}/tumblebug/ns" -H "Content-Type: application/json" -d @namespace-create.json ${auth}""", returnStdout: true).trim()
                    echo createResponse
                    def lowerCreateResponse = createResponse.toLowerCase()
                    def createdOrExists = createResponse.contains("Http_Status_code:2") || createResponse.contains("Http_Status_code:409") || lowerCreateResponse.contains("already")
                    if (!createdOrExists) {
                        error "namespace-ensure create failed: ${createResponse}"
                    }
                    echo "Namespace ${params.NAMESPACE} is ready."
                }
            }
        }
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
                        def zone = params["${key}_ZONE"] ?: params.ZONE ?: ""
                        def k8sVersion = params["${key}_K8S_VERSION"]?.trim() ?: params.K8S_VERSION?.trim() ?: "1.33"
                        def rootDiskType = params.ROOT_DISK_TYPE?.trim() ?: "default"
                        if (csp?.equalsIgnoreCase("alibaba") && rootDiskType.equalsIgnoreCase("default")) {
                            rootDiskType = "cloud_essd"
                        }
                        def usesProviderManagedK8sImage = csp?.equalsIgnoreCase("azure") || csp?.equalsIgnoreCase("ibm") || csp?.equalsIgnoreCase("ncp") || csp?.equalsIgnoreCase("tencent")
                        if (!specId) {
                            error "SPEC_ID is required for ${csp}"
                        }
                        if (!imageId && !usesProviderManagedK8sImage) {
                            error "IMAGE_ID is required for ${csp}"
                        }

                        def payloadMap = [
                            name: clusterId,
                            nodeGroupName: nodeGroupName,
                            specId: specId,
                            label: [
                                csp: csp,
                                region: region
                            ],
                            version: k8sVersion,
                            nodeGroupSize: (params.K8S_DESIRED_NODE_SIZE ?: "1").toInteger(),
                            desiredNodeSize: (params.K8S_DESIRED_NODE_SIZE ?: "1").toInteger(),
                            minNodeSize: (params.K8S_MIN_NODE_SIZE ?: "1").toInteger(),
                            maxNodeSize: (params.K8S_MAX_NODE_SIZE ?: "3").toInteger(),
                            rootDiskType: rootDiskType,
                            rootDiskSize: (params.ROOT_DISK_SIZE ?: "30").toInteger()
                        ]
                        if (imageId) {
                            payloadMap.imageId = imageId
                        }
                        if (connectionName) {
                            payloadMap.connectionName = connectionName
                        }
                        if (zone) {
                            payloadMap.zone = zone
                        }

                        def payload = groovy.json.JsonOutput.toJson(payloadMap)

                        writeFile file: "k8s-cluster-create-${csp}.json", text: payload
                        echo "k8s-cluster-create-${csp} payload: ${payload}"
                        def option = params.K8S_CREATE_OPTION ? "?option=${params.K8S_CREATE_OPTION}" : ""
                        def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X POST "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/k8sClusterDynamic${option}" -H "Content-Type: application/json" -d @k8s-cluster-create-${csp}.json ${auth}""", returnStdout: true).trim()
                        echo response
                        if (!response.contains("Http_Status_code:2")) {
                            error "multi-csp-k8s-cluster-deploy failed for ${csp}: ${response}"
                        }
                        def readyStatuses = (params.K8S_READY_STATUS ?: "Active,Running").split(",").collect { it.trim().toLowerCase() }.findAll { it }
                        def statusAttempts = (params.K8S_STATUS_MAX_ATTEMPTS ?: "360").toInteger()
                        def statusIntervalSeconds = (params.K8S_STATUS_INTERVAL_SECONDS ?: "10").toInteger()
                        def statusResponse = ""
                        def currentStatus = ""
                        for (int attempt = 1; attempt <= statusAttempts; attempt++) {
                            statusResponse = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/k8sCluster/${clusterId}?option=status" ${auth}""", returnStdout: true).trim()
                            currentStatus = ""
                            if (statusResponse.contains("Http_Status_code:2")) {
                                def normalizedStatusResponse = statusResponse.toLowerCase()
                                for (def readyStatus : readyStatuses) {
                                    if (normalizedStatusResponse.contains("\"status\":\"${readyStatus}\"") ||
                                            normalizedStatusResponse.contains("\"status\": \"${readyStatus}\"")) {
                                        currentStatus = readyStatus
                                        break
                                    }
                                }
                            }
                            if (currentStatus) {
                                break
                            }
                            def displayStatus = currentStatus ?: "unknown"
                            echo "k8s cluster ${clusterId} is not ready. currentStatus=${displayStatus}, attempt ${attempt}/${statusAttempts}: ${statusResponse}"
                            sleep time: statusIntervalSeconds, unit: "SECONDS"
                        }
                        if (!statusResponse.contains("Http_Status_code:2") || !currentStatus) {
                            error "multi-csp-k8s-cluster-deploy status check failed for ${csp}: ${statusResponse}"
                        }
                    }
                }
            }
        }
    }
}
', NULL);

MERGE INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script, run_date) KEY(workflow_idx)
SELECT 105, 'vm-mariadb-data-init-cleanup', 'For Cleanup', 1,
'pipeline {
    agent any
    stages {
'
|| (SELECT workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 60)
|| '
    }
}
', NULL;

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

MERGE INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script, run_date) KEY(workflow_idx)
SELECT 107, 'k8s-mariadb-data-init-cleanup', 'For Cleanup', 1,
'pipeline {
    agent any
    stages {
'
|| (SELECT workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 61)
|| '
    }
}
', NULL;

MERGE INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script, run_date) KEY(workflow_idx) VALUES (108, 'multi-csp-k8s-cluster-cleanup', 'For Cleanup', 1,
(SELECT 'pipeline {
    agent any
    stages {
'
|| workflow_stage_content
|| '
    }
}
' FROM workflow_stage WHERE workflow_stage_idx = 53), NULL);

MERGE INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script, run_date) KEY(workflow_idx)
SELECT 109, 'vm-object-storage-data-lab-init', 'For Deployment', 1,
'import groovy.json.JsonOutput

pipeline {
    agent any
    stages {
'
|| (SELECT workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 54)
|| (SELECT workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 56)
|| (SELECT workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 17)
|| (SELECT workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 25)
|| (SELECT workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 58)
|| (SELECT workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 62)
|| '
    }
}
', NULL;

MERGE INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script, run_date) KEY(workflow_idx)
SELECT 110, 'vm-object-storage-data-lab-cleanup', 'For Cleanup', 1,
'pipeline {
    agent any
    stages {
'
|| (SELECT workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 59)
|| (SELECT workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 60)
|| (SELECT workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 57)
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
(101, 'REGION', 'ap-northeast-1', 'N'),
(101, 'CONNECTION_NAME', 'aws-ap-northeast-1', 'N'),
(101, 'ZONE', 'ap-northeast-1a', 'N'),
(101, 'IMAGE', 'ami-091de58da07595152', 'N'),
(101, 'IMAGE_ID', 'ami-091de58da07595152', 'N'),
(101, 'SPEC', 'aws+ap-northeast-1+t3.small', 'N'),
(101, 'SPEC_ID', 'aws+ap-northeast-1+t3.small', 'N'),
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
(102, 'INFRA_ID', 'multi-csp-vm', 'N'),
(102, 'INFRA_PREFIX', 'multi-csp-vm', 'N'),
(102, 'INFRA_NODEGROUP_PREFIX', 'ng', 'N'),
(102, 'INFRA_NODEGROUP_SIZE', '1', 'N'),
(102, 'ROOT_DISK_TYPE', 'default', 'N'),
(102, 'ROOT_DISK_SIZE', '50', 'N'),
(102, 'ALIBABA_REGION', 'ap-northeast-2', 'N'),
(102, 'ALIBABA_CONNECTION_NAME', 'alibaba-ap-northeast-2', 'N'),
(102, 'ALIBABA_ZONE', 'ap-northeast-2a', 'N'),
(102, 'ALIBABA_SPEC_ID', 'alibaba+ap-northeast-2+ecs.e-c1m1.large', 'N'),
(102, 'ALIBABA_IMAGE_ID', 'ubuntu_22_04_x64_20G_alibase_20260615.vhd', 'N'),
(102, 'AWS_REGION', 'ap-northeast-1', 'N'),
(102, 'AWS_CONNECTION_NAME', 'aws-ap-northeast-1', 'N'),
(102, 'AWS_ZONE', 'ap-northeast-1a', 'N'),
(102, 'AWS_SPEC_ID', 'aws+ap-northeast-1+t3.small', 'N'),
(102, 'AWS_IMAGE_ID', 'ami-091de58da07595152', 'N'),
(102, 'AZURE_REGION', 'koreacentral', 'N'),
(102, 'AZURE_CONNECTION_NAME', 'azure-koreacentral', 'N'),
(102, 'AZURE_ZONE', '1', 'N'),
(102, 'AZURE_SPEC_ID', 'azure+koreacentral+Standard_D2s_v3', 'N'),
(102, 'AZURE_IMAGE_ID', 'Canonical:ubuntu-22_04-lts:server:22.04.202603110', 'N'),
(102, 'GCP_REGION', 'asia-northeast3', 'N'),
(102, 'GCP_CONNECTION_NAME', 'gcp-asia-northeast3', 'N'),
(102, 'GCP_ZONE', 'asia-northeast3-a', 'N'),
(102, 'GCP_SPEC_ID', 'gcp+asia-northeast3+e2-medium', 'N'),
(102, 'GCP_IMAGE_ID', 'https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20260623', 'N'),
(102, 'IBM_REGION', 'jp-osa', 'N'),
(102, 'IBM_CONNECTION_NAME', 'ibm-jp-osa', 'N'),
(102, 'IBM_ZONE', 'jp-osa-1', 'N'),
(102, 'IBM_SPEC_ID', 'ibm+jp-osa+bxf-2x8', 'N'),
(102, 'IBM_IMAGE_ID', 'r034-3cb1bb72-002d-45fe-8ac1-6e36906963c4', 'N'),
(102, 'KT_REGION', 'kr1', 'N'),
(102, 'KT_CONNECTION_NAME', 'kt-kr1', 'N'),
(102, 'KT_ZONE', '', 'N'),
(102, 'KT_SPEC_ID', '', 'N'),
(102, 'KT_IMAGE_ID', '', 'N'),
(102, 'NCP_REGION', 'kr', 'N'),
(102, 'NCP_CONNECTION_NAME', 'ncp-kr', 'N'),
(102, 'NCP_ZONE', 'KR-1', 'N'),
(102, 'NCP_SPEC_ID', 'ncp+kr+c2-g3a', 'N'),
(102, 'NCP_IMAGE_ID', '104630229', 'N'),
(102, 'NHN_REGION', 'kr1', 'N'),
(102, 'NHN_CONNECTION_NAME', 'nhn-kr1', 'N'),
(102, 'NHN_ZONE', 'kr-pub-a', 'N'),
(102, 'NHN_SPEC_ID', 'nhn+kr1+m2.c1m2', 'N'),
(102, 'NHN_IMAGE_ID', '0f07c795-2a46-44fc-a61b-fa0d96763ce2', 'N'),
(102, 'TENCENT_REGION', 'ap-seoul', 'N'),
(102, 'TENCENT_CONNECTION_NAME', 'tencent-ap-seoul', 'N'),
(102, 'TENCENT_ZONE', 'ap-seoul-1', 'N'),
(102, 'TENCENT_SPEC_ID', 'tencent+ap-seoul+BF1.MEDIUM2', 'N'),
(102, 'TENCENT_IMAGE_ID', 'img-487zeit5', 'N');

INSERT INTO workflow_param (workflow_idx, param_key, param_value, event_listener_yn) VALUES
(103, 'TUMBLEBUG', 'http://mc-infra-manager:1323', 'N'),
(103, 'TUMBLEBUG_SELECTOR_YN', 'Y', 'N'),
(103, 'USER', 'default', 'N'),
(103, 'USERPASS', 'default', 'N'),
(103, 'NAMESPACE', 'ns01', 'N'),
(103, 'PROVIDER', 'aws', 'N'),
(103, 'CSP', 'aws', 'N'),
(103, 'REGION', 'ap-northeast-1', 'N'),
(103, 'CONNECTION_NAME', 'aws-ap-northeast-1', 'N'),
(103, 'ZONE', 'ap-northeast-1a', 'N'),
(103, 'K8S_CLUSTER_ID', 'k8s-mariadb-data-init', 'N'),
(103, 'K8S_NODEGROUP_NAME', 'ng1', 'N'),
(103, 'IMAGE', 'AL2023_x86_64_STANDARD', 'N'),
(103, 'SPEC_ID', 'aws+ap-northeast-1+t3.small', 'N'),
(103, 'SPEC', 'aws+ap-northeast-1+t3.small', 'N'),
(103, 'IMAGE_ID', 'AL2023_x86_64_STANDARD', 'N'),
(103, 'K8S_VERSION', '1.33', 'N'),
(103, 'K8S_DESIRED_NODE_SIZE', '1', 'N'),
(103, 'K8S_MIN_NODE_SIZE', '1', 'N'),
(103, 'K8S_MAX_NODE_SIZE', '3', 'N'),
(103, 'ROOT_DISK_TYPE', 'default', 'N'),
(103, 'ROOT_DISK_SIZE', '30', 'N'),
(103, 'K8S_CREATE_OPTION', '', 'N'),
(103, 'K8S_NODEGROUP_CREATE_IF_MISSING', 'true', 'N'),
(103, 'K8S_STATUS_MAX_ATTEMPTS', '60', 'N'),
(103, 'K8S_STATUS_INTERVAL_SECONDS', '60', 'N'),
(103, 'K8S_READY_STATUS', 'Active,Running', 'N'),
(103, 'KUBECONFIG_CONTENT', '', 'N'),
(103, 'KUBE_NAMESPACE', 'default', 'N'),
(103, 'K8S_API_READY_MAX_ATTEMPTS', '360', 'N'),
(103, 'K8S_API_READY_INTERVAL_SECONDS', '10', 'N'),
(103, 'K8S_NODE_READY_MIN_COUNT', '1', 'N'),
(103, 'RELEASE_NAME', 'mariadb', 'N'),
(103, 'HELM_REPO_NAME', 'groundhog2k', 'N'),
(103, 'HELM_REPO_URL', 'https://groundhog2k.github.io/helm-charts', 'N'),
(103, 'HELM_CHART', 'groundhog2k/mariadb', 'N'),
(103, 'HELM_CHART_VERSION', '4.5.0', 'N'),
(103, 'HELM_VERSION', 'v3.18.6', 'N'),
(103, 'KUBECTL_VERSION', '', 'N'),
(103, 'HELM_RECREATE_ON_IMMUTABLE_ERROR', 'true', 'N'),
(103, 'HELM_VALUES_ARGS', '--set settings.rootPassword.value=mariadb_pass --set userDatabase.name.value=testdb --set userDatabase.user.value=mariadb_user --set userDatabase.password.value=mariadb_pass --wait --timeout 10m', 'N'),
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
(104, 'CSP_LIST', 'aws,azure,gcp,ncp,nhn,alibaba,tencent,ibm', 'N'),
(104, 'CLUSTER_PREFIX', 'multi-csp-k8s', 'N'),
(104, 'K8S_NODEGROUP_PREFIX', 'ng', 'N'),
(104, 'K8S_VERSION', '1.33', 'N'),
(104, 'K8S_DESIRED_NODE_SIZE', '1', 'N'),
(104, 'K8S_MIN_NODE_SIZE', '1', 'N'),
(104, 'K8S_MAX_NODE_SIZE', '3', 'N'),
(104, 'ROOT_DISK_TYPE', 'default', 'N'),
(104, 'ROOT_DISK_SIZE', '30', 'N'),
(104, 'K8S_CREATE_OPTION', '', 'N'),
(104, 'K8S_STATUS_MAX_ATTEMPTS', '360', 'N'),
(104, 'K8S_STATUS_INTERVAL_SECONDS', '10', 'N'),
(104, 'K8S_READY_STATUS', 'Active,Running', 'N'),
(104, 'AWS_REGION', 'ap-northeast-1', 'N'),
(104, 'AWS_CONNECTION_NAME', 'aws-ap-northeast-1', 'N'),
(104, 'AWS_ZONE', 'ap-northeast-1a', 'N'),
(104, 'AWS_SPEC_ID', 'aws+ap-northeast-1+t3.small', 'N'),
(104, 'AWS_IMAGE_ID', 'AL2023_x86_64_STANDARD', 'N'),
(104, 'AWS_K8S_VERSION', '1.33', 'N'),
(104, 'AZURE_REGION', 'koreacentral', 'N'),
(104, 'AZURE_CONNECTION_NAME', 'azure-koreacentral', 'N'),
(104, 'AZURE_ZONE', '1', 'N'),
(104, 'AZURE_SPEC_ID', 'azure+koreacentral+Standard_D8ds_v5', 'N'),
(104, 'AZURE_IMAGE_ID', 'Canonical:ubuntu-22_04-lts:server:22.04.202603110', 'N'),
(104, 'AZURE_K8S_VERSION', '1.33.12', 'N'),
(104, 'GCP_REGION', 'asia-northeast3', 'N'),
(104, 'GCP_CONNECTION_NAME', 'gcp-asia-northeast3', 'N'),
(104, 'GCP_ZONE', 'asia-northeast3-a', 'N'),
(104, 'GCP_SPEC_ID', 'gcp+asia-northeast3+e2-medium', 'N'),
(104, 'GCP_IMAGE_ID', 'UBUNTU_CONTAINERD', 'N'),
(104, 'GCP_K8S_VERSION', '1.33.12-gke.1000000', 'N'),
(104, 'NCP_REGION', 'kr', 'N'),
(104, 'NCP_CONNECTION_NAME', 'ncp-kr', 'N'),
(104, 'NCP_ZONE', 'KR-1', 'N'),
(104, 'NCP_SPEC_ID', 'ncp+kr+c2-g3a', 'N'),
(104, 'NCP_IMAGE_ID', '23214590', 'N'),
(104, 'NCP_K8S_VERSION', '1.33.4-nks.1', 'N'),
(104, 'NHN_REGION', 'kr1', 'N'),
(104, 'NHN_CONNECTION_NAME', 'nhn-kr1', 'N'),
(104, 'NHN_ZONE', 'kr-pub-a', 'N'),
(104, 'NHN_SPEC_ID', 'nhn+kr1+m2.c1m2', 'N'),
(104, 'NHN_IMAGE_ID', '0f07c795-2a46-44fc-a61b-fa0d96763ce2', 'N'),
(104, 'NHN_K8S_VERSION', 'v1.33.4', 'N'),
(104, 'ALIBABA_REGION', 'ap-northeast-1', 'N'),
(104, 'ALIBABA_CONNECTION_NAME', 'alibaba-ap-northeast-1', 'N'),
(104, 'ALIBABA_ZONE', 'ap-northeast-1b', 'N'),
(104, 'ALIBABA_SPEC_ID', 'alibaba+ap-northeast-1+ecs.u1-c1m4.xlarge', 'N'),
(104, 'ALIBABA_IMAGE_ID', 'Ubuntu', 'N'),
(104, 'ALIBABA_K8S_VERSION', '1.34.3-aliyun.1', 'N'),
(104, 'TENCENT_REGION', 'ap-seoul', 'N'),
(104, 'TENCENT_CONNECTION_NAME', 'tencent-ap-seoul', 'N'),
(104, 'TENCENT_ZONE', 'Ap-seoul-2', 'N'),
(104, 'TENCENT_SPEC_ID', 'tencent+ap-seoul+BF1.MEDIUM2', 'N'),
(104, 'TENCENT_IMAGE_ID', 'ubuntu22.04x86_64', 'N'),
(104, 'TENCENT_K8S_VERSION', '1.32.2', 'N'),
(104, 'IBM_REGION', 'jp-osa', 'N'),
(104, 'IBM_CONNECTION_NAME', 'ibm-jp-osa', 'N'),
(104, 'IBM_ZONE', 'jp-osa-1', 'N'),
(104, 'IBM_SPEC_ID', 'ibm+jp-osa+bx2-2x8', 'N'),
(104, 'IBM_IMAGE_ID', 'r034-ed053bf7-43c9-4b64-844b-77918ac3d597', 'N'),
(104, 'IBM_K8S_VERSION', '1.33.6', 'N');

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
(106, 'INFRA_ID', 'multi-csp-vm', 'N'),
(106, 'INFRA_PREFIX', 'multi-csp-vm', 'N'),
(106, 'INFRA_ID_LIST', '', 'N'),
(106, 'INFRA_DELETE_OPTION', 'terminate', 'N');

INSERT INTO workflow_param (workflow_idx, param_key, param_value, event_listener_yn) VALUES
(107, 'TUMBLEBUG', 'http://mc-infra-manager:1323', 'N'),
(107, 'TUMBLEBUG_SELECTOR_YN', 'N', 'N'),
(107, 'USER', 'default', 'N'),
(107, 'USERPASS', 'default', 'N'),
(107, 'NAMESPACE', 'ns01', 'N'),
(107, 'K8S_CLUSTER_ID', 'k8s-mariadb-data-init', 'N'),
(107, 'K8S_NODEGROUP_NAME', 'ng1', 'N'),
(107, 'K8S_DELETE_OPTION', 'force', 'N'),
(107, 'K8S_NODEGROUP_DELETE_MAX_ATTEMPTS', '120', 'N'),
(107, 'K8S_CLUSTER_DELETE_MAX_ATTEMPTS', '120', 'N'),
(107, 'K8S_DELETE_INTERVAL_SECONDS', '10', 'N');

INSERT INTO workflow_param (workflow_idx, param_key, param_value, event_listener_yn) VALUES
(108, 'TUMBLEBUG', 'http://mc-infra-manager:1323', 'N'),
(108, 'TUMBLEBUG_SELECTOR_YN', 'N', 'N'),
(108, 'USER', 'default', 'N'),
(108, 'USERPASS', 'default', 'N'),
(108, 'NAMESPACE', 'ns01', 'N'),
(108, 'CSP_LIST', 'aws,azure,gcp,ncp,nhn,alibaba,tencent,ibm', 'N'),
(108, 'CLUSTER_PREFIX', 'multi-csp-k8s', 'N'),
(108, 'K8S_CLUSTER_ID_LIST', '', 'N'),
(108, 'K8S_NODEGROUP_PREFIX', 'ng', 'N'),
(108, 'K8S_NODEGROUP_NAME_LIST', '', 'N'),
(108, 'K8S_DELETE_OPTION', 'force', 'N'),
(108, 'K8S_NODEGROUP_DELETE_MAX_ATTEMPTS', '120', 'N'),
(108, 'K8S_CLUSTER_DELETE_MAX_ATTEMPTS', '120', 'N'),
(108, 'K8S_DELETE_INTERVAL_SECONDS', '10', 'N');

INSERT INTO workflow_param (workflow_idx, param_key, param_value, event_listener_yn) VALUES
(109, 'TUMBLEBUG', 'http://mc-infra-manager:1323', 'N'),
(109, 'TUMBLEBUG_SELECTOR_YN', 'Y', 'N'),
(109, 'USER', 'default', 'N'),
(109, 'USERPASS', 'default', 'N'),
(109, 'NAMESPACE', 'ns01', 'N'),
(109, 'PROVIDER', 'aws', 'N'),
(109, 'CSP', 'aws', 'N'),
(109, 'INFRA_ID', 'vm-object-storage-data-lab', 'N'),
(109, 'INFRA_NODEGROUP_SIZE', '1', 'N'),
(109, 'ROOT_DISK_TYPE', 'default', 'N'),
(109, 'ROOT_DISK_SIZE', '50', 'N'),
(109, 'REGION', 'ap-northeast-1', 'N'),
(109, 'CONNECTION_NAME', 'aws-ap-northeast-1', 'N'),
(109, 'ZONE', 'ap-northeast-1a', 'N'),
(109, 'IMAGE', 'ami-091de58da07595152', 'N'),
(109, 'IMAGE_ID', 'ami-091de58da07595152', 'N'),
(109, 'SPEC', 'aws+ap-northeast-1+t3.small', 'N'),
(109, 'SPEC_ID', 'aws+ap-northeast-1+t3.small', 'N'),
(109, 'SSH_HOST', '', 'N'),
(109, 'SSH_USER', 'cb-user', 'N'),
(109, 'SSH_KEY_FILE', '', 'N'),
(109, 'INFRA_ACCESS_INFO_MAX_ATTEMPTS', '30', 'N'),
(109, 'INFRA_ACCESS_INFO_INTERVAL_SECONDS', '10', 'N'),
(109, 'OBJECT_STORAGE_PROVIDER', '', 'N'),
(109, 'OBJECT_STORAGE_BUCKET', '', 'N'),
(109, 'OBJECT_STORAGE_NAMESPACE', '', 'N'),
(109, 'OBJECT_STORAGE_READY_MAX_ATTEMPTS', '30', 'N'),
(109, 'OBJECT_STORAGE_READY_INTERVAL_SECONDS', '5', 'N'),
(109, 'OBJECT_STORAGE_REGION', '', 'N'),
(109, 'PRESIGNED_URL_EXPIRES', '3600', 'N'),
(109, 'DATA_PREFIX', '', 'N'),
(109, 'RESULT_PREFIX', 'results', 'N'),
(109, 'WRITE_RESULT_ENABLED', 'true', 'N'),
(109, 'JUPYTER_IMAGE', 'quay.io/jupyter/scipy-notebook:2025-03-14', 'N'),
(109, 'DUCKDB_VERSION', '1.3.2', 'N'),
(109, 'JUPYTER_BIND_HOST', '0.0.0.0', 'N'),
(109, 'JUPYTER_ALLOWED_CIDR', '0.0.0.0/0', 'N'),
(109, 'JUPYTER_PORT', '8888', 'N');

INSERT INTO workflow_param (workflow_idx, param_key, param_value, event_listener_yn) VALUES
(110, 'TUMBLEBUG', 'http://mc-infra-manager:1323', 'N'),
(110, 'TUMBLEBUG_SELECTOR_YN', 'N', 'N'),
(110, 'USER', 'default', 'N'),
(110, 'USERPASS', 'default', 'N'),
(110, 'NAMESPACE', 'ns01', 'N'),
(110, 'INFRA_ID', 'vm-object-storage-data-lab', 'N'),
(110, 'INFRA_DELETE_OPTION', 'terminate', 'N'),
(110, 'OBJECT_STORAGE_DELETE_ENABLED', 'true', 'N'),
(110, 'OBJECT_STORAGE_BUCKET', '', 'N'),
(110, 'OBJECT_STORAGE_NAMESPACE', '', 'N'),
(110, 'OBJECT_STORAGE_PROVIDER', '', 'N'),
(110, 'OBJECT_STORAGE_REGION', '', 'N'),
(110, 'JUPYTER_PORT', '', 'N'),
(110, 'JUPYTER_ALLOWED_CIDR', '', 'N');

INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage) VALUES
(101, 1, null, 'import groovy.json.JsonOutput

pipeline {
    agent any
    stages {
');
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 101, 2, 54, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 54;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 101, 3, 17, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 17;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 101, 4, 25, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 25;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 101, 5, 48, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 48;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 101, 6, 40, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 40;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 101, 7, 41, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 41;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage) VALUES
(101, 8, null, '
    }
}
');

INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage) VALUES
(102, 1, null, 'import groovy.json.JsonOutput

pipeline {
    agent any
    stages {
');
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 102, 2, 54, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 54;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 102, 3, 50, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 50;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage) VALUES
(102, 4, null, '
    }
}
');

INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage) VALUES
(103, 1, null, 'import groovy.json.JsonOutput

pipeline {
    agent any
    stages {
');
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 103, 2, 54, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 54;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 103, 3, 26, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 26;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 103, 4, 33, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 33;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 103, 5, 34, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 34;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 103, 6, 40, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 40;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 103, 7, 41, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 41;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage) VALUES
(103, 8, null, '
    }
}
');

INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage) VALUES
(104, 1, null, 'import groovy.json.JsonOutput

pipeline {
    agent any
    stages {
');
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 104, 2, 54, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 54;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 104, 3, 51, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 51;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage) VALUES
(104, 4, null, '
    }
}
');

INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage) VALUES
(105, 1, null, 'pipeline {
    agent any
    stages {
');
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 105, 2, 60, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 60;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage) VALUES
(105, 3, null, '
    }
}
');

INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage) VALUES
(106, 1, null, 'pipeline {
    agent any
    stages {
');
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 106, 2, 52, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 52;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage) VALUES
(106, 3, null, '
    }
}
');

INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage) VALUES
(107, 1, null, 'pipeline {
    agent any
    stages {
');
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 107, 2, 61, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 61;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage) VALUES
(107, 3, null, '
    }
}
');

INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage) VALUES
(108, 1, null, 'pipeline {
    agent any
    stages {
');
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 108, 2, 53, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 53;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage) VALUES
(108, 3, null, '
    }
}
');

INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage) VALUES
(109, 1, null, 'import groovy.json.JsonOutput

pipeline {
    agent any
    stages {
');
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 109, 2, 54, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 54;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 109, 3, 56, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 56;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 109, 4, 17, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 17;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 109, 5, 25, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 25;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 109, 6, 58, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 58;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 109, 7, 62, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 62;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage) VALUES
(109, 8, null, '
    }
}
');

INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage) VALUES
(110, 1, null, 'pipeline {
    agent any
    stages {
');
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 110, 2, 59, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 59;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 110, 3, 60, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 60;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage)
SELECT 110, 4, 57, workflow_stage_content FROM workflow_stage WHERE workflow_stage_idx = 57;
INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage) VALUES
(110, 5, null, '
    }
}
');

-- End Step 8
