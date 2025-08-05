#!/bin/bash

# 외부 IP 가져오기
EXTERNAL_IP=$(curl -s ifconfig.me)
export CB_WORKFLOW_MANAGER_EXTERNAL_IP=$EXTERNAL_IP

echo "Detected external IP: $CB_WORKFLOW_MANAGER_EXTERNAL_IP"

# PostgreSQL INSERT 쿼리 실행
psql "host=$DB_HOST port=$DB_PORT dbname=$DB_NAME user=$DB_USER password=$DB_PASS" <<EOF
INSERT INTO oss (
    oss_idx, oss_type_idx, oss_name, oss_desc, oss_url, oss_username, oss_password
) VALUES (
    1, 1, 'SampleOss', 'Sample Description',
    'http://${CB_WORKFLOW_MANAGER_EXTERNAL_IP}:9880', 'admin', 123456
);
EOF

# 애플리케이션 실행
exec java -jar /mc-workflow-manager-0.2.1.jar
