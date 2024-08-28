-- Step 1: Insert into oss_type
INSERT INTO oss_type (oss_type_idx, oss_type_name, oss_type_desc) VALUES (1, 'JENKINS', 'init');

-- Step 2: Insert into oss
INSERT INTO oss (oss_idx, oss_type_idx, oss_name, oss_desc, oss_url, oss_username, oss_password) VALUES (1, 1, 'SampleOss', 'Sample Description', 'http://sample.com', 'root', null);

-- Step 3: Insert into workflow_stage_type (assuming this table exists and 1 is valid)
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (1, 'SPIDER INFO CHECK', 'SPIDER INFO CHECK');
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (2, 'INFRASTRUCTURE CREATE', 'INFRASTRUCTURE CREATE');
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (3, 'INFRASTRUCTURE RUNNING STATUS', 'INFRASTRUCTURE RUNNING STATUS');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (4, 'START', 'START');
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (5, 'RUN JENKINS JOB', 'RUN JENKINS JOB');
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (6, 'END', 'END');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (7, 'VM ACCESS INFO', 'VM ACCESS INFO');
INSERT INTO workflow_stage_type (workflow_stage_type_idx, workflow_stage_type_name, workflow_stage_type_desc) VALUES (8, 'ACCESS VM AND SH(MCIS VM)', 'ACCESS VM AND SH(MCIS VM)');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------



-- Step 4: Insert into workflow_stage
-- INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (1, 1, 1, 'Spider Info Check', 'Spider Info Check', '');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (1, 1, 1, 'Spider Info Check', 'Spider Info Check', '
    stage(''Spider Info Check'') {
      steps {
        echo ''>>>>>STAGE: Spider Info Check''
        echo TUMBLEBUG
        echo MCIS

        script {
          // Calling a GET API using curl
          def response = sh(script: ''curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/config --user "${USER}:${USERPASS}"'', returnStdout: true).trim()
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (2, 2, 1, 'Infrastructure Create', 'Infrastructure Create', '
    stage(''Infrastructure Create''){
        steps {
            echo ''>>>>>>STAGE: Infrastructure Create''

            script {
                def payload = ''{ "description": "from w-m", "installMonAgent": "yes", "label": "workflow", "name": "'' + MCIS + ''", "vm": [ { "commonImage": "Ubuntu22.04", "commonSpec": "aws+ap-northeast-2+t2.small", "subGroupSize": "1", "name": "g1" } ] }''
                def tb_sw_url = "${TUMBLEBUG}/ns/${NAMESPACE}/mcisDynamic"
                def call = """ curl -X ''POST'' --user ''default:default'' ''${tb_sw_url}''  -H ''accept: application/json'' -H ''Content-Type: application/json''  -d ''${payload}'' """
                def postResponse = sh(script: """ ${call} """, returnStdout: true).trim()
                echo "Infrastructure create successful."
            }
        }
    }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (3, 3, 1, 'Infrastructure Running Status', 'Infrastructure Running Status', '
    stage(''Infrastructure Running Status'') {
        steps {
            echo ''>>>>>STAGE: Infrastructure Running Status''

            script {
                // Calling a GET API using curl
                def tb_sw_url = "${TUMBLEBUG}/ns/${NAMESPACE}/mcis?option=status"
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

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (4, 4, 1, 'Start', 'Start', '
        stage(''Start'') {
            steps {
                echo ''Hello''
            }
        }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (5, 5, 1, 'Run Jenkins Job', 'Run Jenkins Job', '
        stage (''run jenkins job'') {
            steps {

            }
        }');
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (6, 6, 1, 'End', 'End', '
        stage(''End'') {
            steps {
                echo ''Job completed''
            }
        }
    }
');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (7, 7, 1, 'VM GET Access Info', 'VM GET Access Info', '
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
INSERT INTO workflow_stage (workflow_stage_idx, workflow_stage_type_idx, workflow_stage_order, workflow_stage_name, workflow_stage_desc, workflow_stage_content) VALUES (8, 8, 1, 'ACCESS VM AND SH(MCIS VM)', 'ACCESS VM AND SH(MCIS VM)', '
        stage(''ACCESS VM AND SH(MCIS VM)'') {
            steps {
                echo ''>>>>>STAGE: ACCESS VM AND SH(MCIS VM)''

            }
        }
');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------




-- Step 5: Insert into workflow
-- INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (1, 'create vm', 'test', 1, '');
INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (1, 'create-vm', 'test', 1, '
import groovy.json.JsonOutput
import groovy.json.JsonSlurper
import groovy.json.JsonSlurperClassic

//Global variable
def callData = ''''
def infoObj = ''''

pipeline {
  agent any

  stages {


    stage(''Spider Info Check'') {
      steps {
        echo ''>>>>>STAGE: Spider Info Check''
        echo TUMBLEBUG
        echo MCIS

        script {
          // Calling a GET API using curl
          def response = sh(script: ''curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/config --user "${USER}:${USERPASS}"'', returnStdout: true).trim()
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
    }

    stage(''Infrastructure Create''){
        steps {
            echo ''>>>>>>STAGE: Infrastructure Create''

            script {
                def payload = ''{ "description": "from w-m", "installMonAgent": "yes", "label": "workflow", "name": "'' + MCIS + ''", "vm": [ { "commonImage": "Ubuntu22.04", "commonSpec": "aws+ap-northeast-2+t2.small", "subGroupSize": "1", "name": "g1" } ] }''
                def tb_sw_url = "${TUMBLEBUG}/ns/${NAMESPACE}/mcisDynamic"
                def call = """ curl -X ''POST'' --user ''default:default'' ''${tb_sw_url}''  -H ''accept: application/json'' -H ''Content-Type: application/json''  -d ''${payload}'' """
                def postResponse = sh(script: """ ${call} """, returnStdout: true).trim()
                echo "Infrastructure create successful."
            }
        }
    }

    stage(''Infrastructure Running Status'') {
        steps {
            echo ''>>>>>STAGE: Infrastructure Running Status''

            script {
                // Calling a GET API using curl
                def tb_sw_url = "${TUMBLEBUG}/ns/${NAMESPACE}/mcis?option=status"
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
    }



  }
}');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (2, 'wordpress-all-in-one', 'test', 1, '
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
                    string(name: ''MCIS'', value: MCIS),
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
                    string(name: ''MCIS'', value: MCIS),
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
                    string(name: ''MCIS'', value: MCIS),
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
                    string(name: ''MCIS'', value: MCIS),
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
                    string(name: ''MCIS'', value: MCIS),
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

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (3, 'install-nginx', 'test', 1, '
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


    }
}');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (4, 'install-mariadb', 'test', 1, '
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

        //=============================================================================================
        // stage template - ACCESS VM AND SH(MCIS VM)
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


    }
}');
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (5, 'mariadb-set-password', 'test', 1, '
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


    }
}');
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (6, 'php-install', 'test', 1, '
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


    }
}');
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (7, 'set-nginx', 'test', 1, '
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


    }
}');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (8, 'install-grafana', 'test', 1, '
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
        }


    }
}
');
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (9, 'install-redis', 'test', 1, '
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
        }


    }
}
');
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (10, 'install-prometheus', 'test', 1, '
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
        }


    }
}');
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow (workflow_idx, workflow_name, workflow_purpose, oss_idx, script) VALUES (11, 'install-tomcat', 'test', 1, '
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
        }


    }
}');
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------















-- Step 6: Insert into workflow_param
-- INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (1, 1, 'MCIS', '', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (1, 1, 'MCIS', 'test0823-05', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (2, 1, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (3, 1, 'TUMBLEBUG', 'http://52.78.216.116:1323/tumblebug', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (4, 1, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (5, 1, 'USERPASS', 'default', 'N');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (6, 2, 'MCIS', 'test0823-05', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (7, 2, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (8, 2, 'TUMBLEBUG', 'http://52.78.216.116:1323/tumblebug', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (9, 2, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (10, 2, 'USERPASS', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (11, 2, 'SCHEMA', 'wordpress', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (12, 2, 'DBUSER', 'mcmp', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (13, 2, 'DBPASS', 'mcmp1234', 'N');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (14, 3, 'MCIS', 'test0823-05', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (15, 3, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (16, 3, 'TUMBLEBUG', 'http://52.78.216.116:1323/tumblebug', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (17, 3, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (18, 3, 'USERPASS', 'default', 'N');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (19, 4, 'MCIS', 'test0823-05', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (20, 4, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (21, 4, 'TUMBLEBUG', 'http://52.78.216.116:1323/tumblebug', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (22, 4, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (23, 4, 'USERPASS', 'default', 'N');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (24, 5, 'MCIS', 'test0823-05', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (25, 5, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (26, 5, 'TUMBLEBUG', 'http://52.78.216.116:1323/tumblebug', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (27, 5, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (28, 5, 'USERPASS', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (29, 5, 'SCHEMA', 'wordpress', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (30, 5, 'DBUSER', 'mcmp', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (31, 5, 'DBPASS', 'mcmp1234', 'N');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (32, 6, 'MCIS', 'test0823-05', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (33, 6, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (34, 6, 'TUMBLEBUG', 'http://52.78.216.116:1323/tumblebug', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (35, 6, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (36, 6, 'USERPASS', 'default', 'N');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (37, 7, 'MCIS', 'test0823-05', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (38, 7, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (39, 7, 'TUMBLEBUG', 'http://52.78.216.116:1323/tumblebug', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (40, 7, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (41, 7, 'USERPASS', 'default', 'N');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (42, 8, 'MCIS', 'test0823-05', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (43, 8, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (44, 8, 'TUMBLEBUG', 'http://52.78.216.116:1323/tumblebug', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (45, 8, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (46, 8, 'USERPASS', 'default', 'N');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (47, 9, 'MCIS', 'test0823-05', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (48, 9, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (49, 9, 'TUMBLEBUG', 'http://52.78.216.116:1323/tumblebug', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (50, 9, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (51, 9, 'USERPASS', 'default', 'N');
-- INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (52, 9, 'defaultValue', '1234', 'N');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (52, 10, 'MCIS', 'test0823-05', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (53, 10, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (54, 10, 'TUMBLEBUG', 'http://52.78.216.116:1323/tumblebug', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (55, 10, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (56, 10, 'USERPASS', 'default', 'N');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (57, 11, 'MCIS', 'test0823-05', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (58, 11, 'NAMESPACE', 'ns01', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (59, 11, 'TUMBLEBUG', 'http://52.78.216.116:1323/tumblebug', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (60, 11, 'USER', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (61, 11, 'USERPASS', 'default', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (62, 11, 'TOMCAT_VER', '-----', 'N');
INSERT INTO workflow_param (param_idx, workflow_idx, param_key, param_value, event_listener_yn) VALUES (63, 11, 'TAR_URL', '-----', 'N');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

















-- Step 7: Insert into workflow_stage_mapping
-- INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (1, 1, 1, null, '');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (1, 1, 1, null, '
import groovy.json.JsonOutput
import groovy.json.JsonSlurper
import groovy.json.JsonSlurperClassic

//Global variable
def callData = ''''
def infoObj = ''''

pipeline {
  agent any

  stages {
');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (2, 1, 2, 1, '

    stage(''Spider Info Check'') {
      steps {
        echo ''>>>>>STAGE: Spider Info Check''
        echo TUMBLEBUG
        echo MCIS

        script {
          // Calling a GET API using curl
          def response = sh(script: ''curl -w "- Http_Status_code:%{http_code}" ${TUMBLEBUG}/config --user "${USER}:${USERPASS}"'', returnStdout: true).trim()
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (3, 1, 3, 2, '

    stage(''Infrastructure Create''){
        steps {
            echo ''>>>>>>STAGE: Infrastructure Create''

            script {
                def payload = ''{ "description": "from w-m", "installMonAgent": "yes", "label": "workflow", "name": "'' + MCIS + ''", "vm": [ { "commonImage": "Ubuntu22.04", "commonSpec": "aws+ap-northeast-2+t2.small", "subGroupSize": "1", "name": "g1" } ] }''
                def tb_sw_url = "${TUMBLEBUG}/ns/${NAMESPACE}/mcisDynamic"
                def call = """ curl -X ''POST'' --user ''default:default'' ''${tb_sw_url}''  -H ''accept: application/json'' -H ''Content-Type: application/json''  -d ''${payload}'' """
                def postResponse = sh(script: """ ${call} """, returnStdout: true).trim()
                echo "Infrastructure create successful."
            }
        }
    }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (4, 1, 4, 3, '

    stage(''Infrastructure Running Status'') {
        steps {
            echo ''>>>>>STAGE: Infrastructure Running Status''

            script {
                // Calling a GET API using curl
                def tb_sw_url = "${TUMBLEBUG}/ns/${NAMESPACE}/mcis?option=status"
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
    }
');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (5, 1, 5, null, '
  }
}');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (6, 2, 1, null, '
pipeline {
    agent any
    stages {');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (7, 2, 2, 4, '
        stage(''Start'') {
            steps {
                echo ''Hello''
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (8, 2, 3, 5, '
        //=============================================================================================
        // stage template - run jenkins job
        //=============================================================================================
        stage (''install-nginx'') {
            steps {
                build job: ''install-nginx'',
                parameters: [
                    string(name: ''MCIS'', value: MCIS),
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS)
                ]
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (9, 2, 4, 5, '
        //=============================================================================================
        // stage template - run jenkins job
        //=============================================================================================
        stage (''install-mariadb'') {
            steps {
                build job: ''install-mariadb'',
                parameters: [
                    string(name: ''MCIS'', value: MCIS),
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS)
                ]
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (10, 2, 5, 5, '
        //=============================================================================================
        // stage template - run jenkins job
        //=============================================================================================
        stage (''mariadb-set-password'') {
            steps {
                build job: ''mariadb-set-password'',
                parameters: [
                    string(name: ''MCIS'', value: MCIS),
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (11, 2, 6, 5, '
        //=============================================================================================
        // stage template - run jenkins job
        //=============================================================================================
        stage (''php-install'') {
            steps {
                build job: ''php-install'',
                parameters: [
                    string(name: ''MCIS'', value: MCIS),
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS)
                ]
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (12, 2, 7, 5, '
        //=============================================================================================
        // stage template - run jenkins job
        //=============================================================================================
        stage (''set-nginx'') {
            steps {
                build job: ''set-nginx'',
                parameters: [
                    string(name: ''MCIS'', value: MCIS),
                    string(name: ''NAMESPACE'', value: NAMESPACE),
                    string(name: ''TUMBLEBUG'', value: TUMBLEBUG),
                    string(name: ''USER'', value: USER),
                    string(name: ''USERPASS'', value: USERPASS)
                ]
            }
        } ');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (13, 2, 8, 6, '
        stage(''End'') {
            steps {
                echo ''Job completed''
            }
        }');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (14, 2, 9, null, '
        stage(''Start'') {
            steps {
                echo ''Hello''
            }
        }');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (15, 3, 1, null, '
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (16, 3, 2, 7, '
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (17, 3, 3, 8, '
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (18, 3, 4, null, '
    }
}
');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (19, 4, 1, null, '
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (20, 4, 2, 7, '
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (21, 4, 3, 8, '

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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (22, 4, 4, null, '
    }
}
');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (23, 5, 1, null, '
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (24, 5, 2, 7, '
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (25, 5, 3, 8, '
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (26, 5, 4, null, '
    }
}
');
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (27, 6, 1, null, '
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (28, 6, 2, 7, '
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (29, 6, 3, 8, '

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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (30, 6, 4, null, '
    }
}');
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (31, 7, 1, null, '
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (32, 7, 2, 7, '
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (33, 7, 3, 8, '
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (34, 7, 4, null, '
    }
}
');
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
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

    stages {
');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (36, 8, 2, 7, '
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (37, 8, 3, 8, '
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (38, 8, 4, null, '
    }
}
');
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (40, 9, 2, 7, '
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (41, 9, 3, 8, '
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (42, 9, 4, null, '
    }
}
');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

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

    stages {');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (44, 10, 2, 7, '
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (45, 10, 3, 8, '
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (46, 10, 4, null, '
    }
}');
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
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

    stages {');
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (48, 11, 2, 7, '
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (49, 11, 3, 8, '
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
INSERT INTO workflow_stage_mapping (mapping_idx, workflow_idx, stage_order, workflow_stage_idx, stage) VALUES (50, 11, 4, null, '
    }
}');
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------




