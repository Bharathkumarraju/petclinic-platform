#!/bin/bash
## update /etc/teleport.yaml
export LOCAL_IPV4=`hostname -I`
export TELEPORT_PROXY_SERVER="https://abaxx.teleport.sh:443"

cat >/etc/teleport.yaml <<EOF
#
# Teleport database agent configuration file.
# Configuration reference: https://goteleport.com/docs/database-access/reference/configuration/
#
version: v3
teleport:
  nodename: $HOSTNAME
  advertise_ip: $LOCAL_IPV4
  diag_addr: 0.0.0.0:3000
  data_dir: "/var/lib/teleport"
  proxy_server: $TELEPORT_PROXY_SERVER
  join_params:
    token_name: teleport-db
    method: iam 
  log:
    output: /var/log/teleport.log
    severity: INFO
    format:
      output: json 

auth_service:
  enabled: "no"
ssh_service:
  enabled: "yes"
proxy_service:
  enabled: "no"

db_service:
  enabled: true
  databases:
  - name: "exchange-aps1-proxy-staging"
    description: Static AWS RDS Proxy endpoint
    protocol: "mysql"
    uri: "exchange-aps1-proxy-staging.proxy-c44gvwoi9fu4.ap-southeast-1.rds.amazonaws.com:3306"
    static_labels:
      env: "staging"
      name: "exchange-aps1-proxy-staging"
      endpoint-type: "READ_WRITE"
  - name: "exchange-aps1-proxy-staging-exchange-aps1-staging-r-endpoint"
    description: Static AWS Readonly RDS Proxy endpoint
    protocol: "mysql"
    uri: "exchange-aps1-staging-r-endpoint.endpoint.proxy-c44gvwoi9fu4.ap-southeast-1.rds.amazonaws.com:3306"
    static_labels:
      env: "staging"
      name: "exchange-aps1-proxy-staging-exchange-aps1-staging-r-endpoint.endpoint"
      endpoint-type: "READ_ONLY"
  - name: "riskdb-aps1-proxy-staging-risk"
    description: Static AWS RDS Proxy endpoint
    protocol: "mysql"
    uri: "riskdb-aps1-proxy-staging-risk.proxy-c44gvwoi9fu4.ap-southeast-1.rds.amazonaws.com:3306"
    static_labels:
      env: "staging"
      name: "riskdb-aps1-proxy-staging-risk"
      endpoint-type: "READ_WRITE"
  - name: "riskdb-aps1-proxy-staging-risk-riskdb-aps1-staging-r-endpoint"
    description: Static AWS RDS Readonly Proxy endpoint
    protocol: "mysql"
    uri: "riskdb-aps1-staging-r-endpoint.endpoint.proxy-c44gvwoi9fu4.ap-southeast-1.rds.amazonaws.com:3306"
    static_labels:
      env: "staging"
      name: "riskdb-aps1-proxy-staging-risk-riskdb-aps1-staging-r-endpoint"
      endpoint-type: "READ_ONLY"

EOF

## restart services
systemctl enable teleport
systemctl restart teleport

# setup elastic fleet 
sudo apt-get install jq -y

SSM_ELASTIC_ENROLLMENT_TOKEN=$(aws ssm get-parameter --region ap-southeast-1 --with-decryption --name "/elastic/staging-ec2" | jq -r ".Parameter.Value") 

curl -L -O https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-8.18.0-linux-x86_64.tar.gz 
tar xzvf elastic-agent-8.18.0-linux-x86_64.tar.gz
cd elastic-agent-8.18.0-linux-x86_64
sudo ./elastic-agent install --url=https://ce8efea464849a22a8161a6c3a06e2e3.fleet.vpce.ap-southeast-1.aws.elastic-cloud.com:443 --enrollment-token=$${SSM_ELASTIC_ENROLLMENT_TOKEN} --tag "staging-ec2" --force
