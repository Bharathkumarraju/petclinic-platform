locals {
  fleet_enrollment_token_secret_key = "ELASTIC_FLEET_ENROLLMENT_TOKEN"
  fleet_enrollment_secret_name      = "elastic/abex-nonprod/kubernetes"

  elastic_helm_v2_namespace     = "obs-elastic-agent"
  elastic_helm_v2_app_name      = "elastic-agent"
  elastic_helm_v2_chart_version = "0.1.1"
}

# module "elastic-agent-secret-store" {
#   source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/k8s-secret-store?ref=feature/k8s-secret-store"

#   env          = "staging"
#   namespace    = local.elastic_helm_v2_namespace
#   secret_store = "elastic-agent"
# }

# resource "aws_secretsmanager_secret_version" "elastic_agent_v2" {
#   secret_id     = local.fleet_enrollment_secret_name
#   secret_string = jsonencode({ "${local.fleet_enrollment_token_secret_key}" = data.terraform_remote_state.elastic_agent.outputs.enrollment_tokens[local.env] })
# }

resource "helm_release" "elastic_agent_v2" {
  name      = "elastic-agent"
  namespace = local.elastic_helm_v2_namespace
  # force_update     = true
  # repository = "https://${local.gh_token}@raw.githubusercontent.com/abaxxsingapore/abex-aws-eks-base/main/charts"

  # Use the token from an environment variable
  chart   = "https://${local.github_eks_base_token}:x-oauth-basic@raw.githubusercontent.com/abaxxsingapore/abex-aws-eks-base/elastic-agent-v2/charts/elastic-agent-v2-${local.elastic_helm_v2_chart_version}.tgz"
  version = local.elastic_helm_chart_version

  values = [
    yamlencode({
      fullnameOverride : "elastic-observability-agent"
      namespace : {
        name : local.elastic_helm_v2_namespace
        create : false
      }
      fleet : {
        # url : data.terraform_remote_state.elastic_agent.outputs.fleet_integration_url
        url : "https://abex-nonprod.fleet.vpce.ap-southeast-1.aws.elastic-cloud.com:443"
        enrollmentToken : {

          valueFromSecret : {
            key : local.fleet_enrollment_token_secret_key
            externalSecret : {
              create : true
              secretStoreRef : {
                name : local.elastic_helm_v2_app_name
                kind : "SecretStore"
              },
              remoteRef : {
                key : local.fleet_enrollment_secret_name
              }
            }
          }
        }
      }
    })
  ]
}

