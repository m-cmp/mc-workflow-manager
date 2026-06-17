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
-- category: infra, k8s, app, database, utility
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES
(17, 'infra', 'Infrastructure'),
(18, 'k8s', 'Infrastructure - K8s'),
(19, 'app', 'Application Deployment'),
(20, 'database', 'Data - Backup / Restore'),
(21, 'utility', 'Common / Utility');

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

                    def payload = groovy.json.JsonOutput.toJson([
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
                def existingResponse = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X GET "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/k8sCluster/${params.K8S_CLUSTER_ID}?option=status" ${auth}""", returnStdout: true).trim()
                if (existingResponse.contains("Http_Status_code:2")) {
                    echo "k8s cluster already exists. reuse existing cluster: ${params.K8S_CLUSTER_ID}"
                } else {
                    def response = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X POST "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/k8sClusterDynamic${option}" -H "Content-Type: application/json" -d @k8s-cluster-create.json ${auth}""", returnStdout: true).trim()
                    echo response
                    if (!response.contains("Http_Status_code:2")) {
                        error "k8s-cluster-create failed: ${response}"
                    }
                }
                def readyStatuses = (params.K8S_READY_STATUS ?: "Active,Running").split(",").collect { it.trim().toLowerCase() }.findAll { it }
                def statusAttempts = (params.K8S_STATUS_MAX_ATTEMPTS ?: "360").toInteger()
                def statusIntervalSeconds = (params.K8S_STATUS_INTERVAL_SECONDS ?: "10").toInteger()
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
                    if (compactResponse.contains("kubeconfigisnotreadyyet")) {
                        return false
                    }
                    if (compactResponse.contains("first,addanodegroup")) {
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
                if (!hasNodeGroupInfo(statusResponse)) {
                    if (!createNodeGroupIfMissing) {
                        error "k8s cluster is ready but node group is missing: ${statusResponse}"
                    }
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
                    def nodeGroupResponse = sh(script: """curl -sS -w "- Http_Status_code:%{http_code}" -X POST "${params.TUMBLEBUG}/tumblebug/ns/${params.NAMESPACE}/k8sCluster/${params.K8S_CLUSTER_ID}/k8sNodeGroupDynamic" -H "Content-Type: application/json" -d @k8s-nodegroup-add.json ${auth}""", returnStdout: true).trim()
                    echo nodeGroupResponse
                    if (!nodeGroupResponse.contains("Http_Status_code:2") && !nodeGroupResponse.toLowerCase().contains("already")) {
                        error "k8s-nodegroup-add failed: ${nodeGroupResponse}"
                    }
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
                        error "k8s node group or kubeconfig was not ready: ${statusResponse}"
                    }
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
                if (kubeconfig.contains("aws-iam-authenticator")
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

DELETE FROM workflow_stage_mapping WHERE workflow_idx IN (101, 102, 103, 104, 105, 106, 107, 108);
DELETE FROM workflow_param WHERE workflow_idx IN (101, 102, 103, 104, 105, 106, 107, 108);
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

                        def payload = groovy.json.JsonOutput.toJson([
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

MERGE INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script, run_date) KEY(workflow_idx) VALUES (107, 'k8s-mariadb-data-init-cleanup', 'For Cleanup', 1, '
pipeline {
    agent any
    stages {
        stage("k8s-cleanup") {
            steps {
                echo ">>>>> STAGE: k8s-cleanup"
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
                        error "k8s-cleanup status check failed: ${statusResponse}"
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
                    if (!deleteAccepted("k8s-cleanup ${params.K8S_CLUSTER_ID}", response)) {
                        error "k8s-cleanup ${params.K8S_CLUSTER_ID} failed: ${response}"
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
                            error "k8s-cleanup was not completed by Tumblebug: ${statusResponse}"
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
    }
}
', NULL);

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
(102, 'ALIBABA_REGION', 'ap-northeast-2', 'N'),
(102, 'ALIBABA_CONNECTION_NAME', 'alibaba-ap-northeast-2', 'N'),
(102, 'ALIBABA_ZONE', 'ap-northeast-2a', 'N'),
(102, 'ALIBABA_SPEC_ID', 'alibaba+ap-northeast-2+ecs.e-c1m1.large', 'N'),
(102, 'ALIBABA_IMAGE_ID', 'ubuntu_22_04_x64_20G_alibase_20260522.vhd', 'N'),
(102, 'AWS_REGION', 'ap-northeast-1', 'N'),
(102, 'AWS_CONNECTION_NAME', 'aws-ap-northeast-1', 'N'),
(102, 'AWS_ZONE', 'ap-northeast-1a', 'N'),
(102, 'AWS_SPEC_ID', 'aws+ap-northeast-1+t3.small', 'N'),
(102, 'AWS_IMAGE_ID', 'ami-00b4561fe1d28c285', 'N'),
(102, 'AZURE_REGION', 'koreacentral', 'N'),
(102, 'AZURE_CONNECTION_NAME', 'azure-koreacentral', 'N'),
(102, 'AZURE_ZONE', '1', 'N'),
(102, 'AZURE_SPEC_ID', 'azure+koreacentral+Standard_D2s_v3', 'N'),
(102, 'AZURE_IMAGE_ID', 'Canonical:ubuntu-22_04-lts:server:22.04.202603110', 'N'),
(102, 'GCP_REGION', 'asia-northeast3', 'N'),
(102, 'GCP_CONNECTION_NAME', 'gcp-asia-northeast3', 'N'),
(102, 'GCP_ZONE', '', 'N'),
(102, 'GCP_SPEC_ID', '', 'N'),
(102, 'GCP_IMAGE_ID', '', 'N'),
(102, 'IBM_REGION', 'jp-osa', 'N'),
(102, 'IBM_CONNECTION_NAME', 'ibm-jp-osa', 'N'),
(102, 'IBM_ZONE', 'jp-osa-1', 'N'),
(102, 'IBM_SPEC_ID', 'ibm+jp-osa+bxf-2x8', 'N'),
(102, 'IBM_IMAGE_ID', 'r034-ed053bf7-43c9-4b64-844b-77918ac3d597', 'N'),
(102, 'KT_REGION', 'kr1', 'N'),
(102, 'KT_CONNECTION_NAME', 'kt-kr1', 'N'),
(102, 'KT_ZONE', '', 'N'),
(102, 'KT_SPEC_ID', '', 'N'),
(102, 'KT_IMAGE_ID', '', 'N'),
(102, 'NCP_REGION', 'kr', 'N'),
(102, 'NCP_CONNECTION_NAME', 'ncp-kr', 'N'),
(102, 'NCP_ZONE', 'KR-1', 'N'),
(102, 'NCP_SPEC_ID', 'ncp+kr+c2-g3', 'N'),
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
(103, 'REGION', 'ap-northeast-2', 'N'),
(103, 'CONNECTION_NAME', 'aws-ap-northeast-2', 'N'),
(103, 'ZONE', '', 'N'),
(103, 'K8S_CLUSTER_ID', 'k8s-mariadb-data-init', 'N'),
(103, 'K8S_NODEGROUP_NAME', 'ng1', 'N'),
(103, 'IMAGE', '', 'N'),
(103, 'SPEC_ID', '', 'N'),
(103, 'SPEC', '', 'N'),
(103, 'IMAGE_ID', '', 'N'),
(103, 'K8S_VERSION', '1.33', 'N'),
(103, 'K8S_DESIRED_NODE_SIZE', '1', 'N'),
(103, 'K8S_MIN_NODE_SIZE', '1', 'N'),
(103, 'K8S_MAX_NODE_SIZE', '3', 'N'),
(103, 'ROOT_DISK_TYPE', 'default', 'N'),
(103, 'ROOT_DISK_SIZE', '30', 'N'),
(103, 'K8S_CREATE_OPTION', '', 'N'),
(103, 'K8S_NODEGROUP_CREATE_IF_MISSING', 'true', 'N'),
(103, 'K8S_STATUS_MAX_ATTEMPTS', '360', 'N'),
(103, 'K8S_STATUS_INTERVAL_SECONDS', '10', 'N'),
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
(104, 'AWS_REGION', 'ap-northeast-2', 'N'),
(104, 'AWS_CONNECTION_NAME', 'aws-ap-northeast-2', 'N'),
(104, 'AWS_ZONE', '', 'N'),
(104, 'AWS_SPEC_ID', '', 'N'),
(104, 'AWS_IMAGE_ID', '', 'N'),
(104, 'AWS_K8S_VERSION', '', 'N'),
(104, 'AZURE_REGION', 'koreacentral', 'N'),
(104, 'AZURE_CONNECTION_NAME', 'azure-koreacentral', 'N'),
(104, 'AZURE_ZONE', '', 'N'),
(104, 'AZURE_SPEC_ID', '', 'N'),
(104, 'AZURE_IMAGE_ID', '', 'N'),
(104, 'AZURE_K8S_VERSION', '', 'N'),
(104, 'GCP_REGION', 'asia-east1', 'N'),
(104, 'GCP_CONNECTION_NAME', 'gcp-asia-east1', 'N'),
(104, 'GCP_ZONE', '', 'N'),
(104, 'GCP_SPEC_ID', '', 'N'),
(104, 'GCP_IMAGE_ID', '', 'N'),
(104, 'GCP_K8S_VERSION', '', 'N'),
(104, 'NCP_REGION', 'kr1', 'N'),
(104, 'NCP_CONNECTION_NAME', 'ncp-kr1', 'N'),
(104, 'NCP_ZONE', '', 'N'),
(104, 'NCP_SPEC_ID', '', 'N'),
(104, 'NCP_IMAGE_ID', '', 'N'),
(104, 'NCP_K8S_VERSION', '', 'N'),
(104, 'NHN_REGION', 'kr1', 'N'),
(104, 'NHN_CONNECTION_NAME', 'nhn-kr1', 'N'),
(104, 'NHN_ZONE', '', 'N'),
(104, 'NHN_SPEC_ID', '', 'N'),
(104, 'NHN_IMAGE_ID', '', 'N'),
(104, 'NHN_K8S_VERSION', '', 'N'),
(104, 'ALIBABA_REGION', 'ap-northeast-2', 'N'),
(104, 'ALIBABA_CONNECTION_NAME', 'alibaba-ap-northeast-2', 'N'),
(104, 'ALIBABA_ZONE', '', 'N'),
(104, 'ALIBABA_SPEC_ID', '', 'N'),
(104, 'ALIBABA_IMAGE_ID', '', 'N'),
(104, 'ALIBABA_K8S_VERSION', '', 'N'),
(104, 'TENCENT_REGION', 'ap-seoul', 'N'),
(104, 'TENCENT_CONNECTION_NAME', 'tencent-ap-seoul', 'N'),
(104, 'TENCENT_ZONE', '', 'N'),
(104, 'TENCENT_SPEC_ID', '', 'N'),
(104, 'TENCENT_IMAGE_ID', '', 'N'),
(104, 'TENCENT_K8S_VERSION', '', 'N'),
(104, 'IBM_REGION', 'jp-osa', 'N'),
(104, 'IBM_CONNECTION_NAME', 'ibm-jp-osa', 'N'),
(104, 'IBM_ZONE', '', 'N'),
(104, 'IBM_SPEC_ID', '', 'N'),
(104, 'IBM_IMAGE_ID', '', 'N'),
(104, 'IBM_K8S_VERSION', '', 'N');

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
(102, 1, 50, (SELECT script FROM workflow WHERE workflow_idx = 102));

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
(104, 1, 51, (SELECT script FROM workflow WHERE workflow_idx = 104));

INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage) VALUES
(105, 1, null, (SELECT script FROM workflow WHERE workflow_idx = 105));

INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage) VALUES
(106, 1, 52, (SELECT script FROM workflow WHERE workflow_idx = 106));

INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage) VALUES
(107, 1, null, (SELECT script FROM workflow WHERE workflow_idx = 107));

INSERT INTO workflow_stage_mapping (workflow_idx, stage_order, workflow_stage_idx, stage) VALUES
(108, 1, 53, (SELECT script FROM workflow WHERE workflow_idx = 108));

-- End Step 8
