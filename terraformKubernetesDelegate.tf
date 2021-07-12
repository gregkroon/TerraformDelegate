terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.52.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = ""
}



variable "harness_account_id" {
  type = string
  description = "Harness SAAS account id"
}

variable "harness_account_secret" {
  type = string
  description = "Harness SAAS account secret"
}

variable "delegate_name" {
  type = string
  description = "The name by which to identify the delegate in Harness"
}

variable "cloud_provider_name" {
  type = string
   description = "The name of the cloud provider that will be created and associated with the delegate"
}

variable "application_name" {
  type = string
  description = "The application name that will associate its environment infrastructure with the cloud provider"
}

variable "environment_name" {
  type = string
  description = "The application environment name that will associate its infrastructure with the cloud provider"
}

variable "infrastructure_name" {
  type = string
  description = "The infrastructure name that will associate itself with the cloud provider"
}

variable "harness_api_key" {
  type = string
  description = "The harness api key for making rest calls to the harness api"
}

resource "kubernetes_namespace" "delegatenamespace" {
  metadata {
    annotations = {
      name = ""
    }

    labels = {
      mylabel = ""
    }

    name = "harness-delegate"
  }
}

resource "kubernetes_cluster_role_binding" "delegateclusterrolebinding" {
  metadata {
    name = "harness-delegate-cluster-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "harness-delegate"
  }
}

resource "kubernetes_secret" "delegatesecret" {
  metadata {
    name = "terraform-proxy"
    namespace = "harness-delegate"
  }

  data = {
    PROXY_USER = ""
    PROXY_PASSWORD = ""
  }

  type = "Opaque"
}

resource "kubernetes_stateful_set" "delegatesatefulset" {
  metadata {
    annotations = {
    }

    labels = {
      "harness.io/app" = "harness-delegate"
      "harness.io/account" = "keefxs"
      "harness.io/name" = var.delegate_name
    }

    name = "${var.delegate_name}-keefxs"
    namespace = "harness-delegate"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "harness.io/app" = "harness-delegate"
        "harness.io/account" = "keefxs"
        "harness.io/name" = var.delegate_name
      }
    }

    service_name = ""

    template {
      metadata {
        labels = {
          "harness.io/app" = "harness-delegate"
          "harness.io/account" = "keefxs"
          "harness.io/name" = var.delegate_name
        }
        
      }

      spec {

        container {
          name              = "harness-delegate-instance"
          image             = "harness/delegate:latest"
          image_pull_policy = "Always"

         
          resources {
            limits = {
              cpu    = "1"
              memory = "8Gi"
            }
          }
           readiness_probe {
            exec {
              command = ["test","-s","delegate.log"]
            }

            initial_delay_seconds = 20
            timeout_seconds       = 10
          }

          liveness_probe {
            exec {
              command = ["bash","-c","'[[ -e /opt/harness-delegate/msg/data/watcher-data && $(($(date +%s000) - $(grep heartbeat /opt/harness-delegate/msg/data/watcher-data | cut -d : -f 2 | cut -d "," -f 1))) -lt 300000 ]]'"]
            }

            initial_delay_seconds = 240
            timeout_seconds       = 10
            failure_threshold      = 2
          }
         
          env {
              name = "ACCOUNT_ID"
              value = var.harness_account_id
            }
          
          env {
              name = "ACCOUNT_SECRET"
              value = var.harness_account_secret
            }

          env {
           name = "MANAGER_HOST_AND_PORT"
           value = "https://app.harness.io/gratis"
           }
          env {
           name = "WATCHER_STORAGE_URL"
           value = "https://app.harness.io/public/free/freemium/watchers"
          }
          env{
           name = "WATCHER_CHECK_LOCATION"
           value = "current.version"
          }
          env{
           name = "REMOTE_WATCHER_URL_CDN"
           value = "https://app.harness.io/public/shared/watchers/builds"
          }
          env {
           name = "DELEGATE_CHECK_LOCATION"
           value = "delegatefree.txt"
          }
          env {
            name = "DEPLOY_MODE"
           value = "KUBERNETES"   
          }
          env {
           name = "DELEGATE_NAME"
           value = var.delegate_name
          }
        env {
           name = "DELEGATE_PROFILE"
           value = "B3RBC7YQRFOcdnqYUz-8uA"
         }

         env {
           name = "DELEGATE_TYPE"
           value = "KUBERNETES"
         }

         env {
           name = "PROXY_HOST"
           value = ""
         }
         env {
           name = "PROXY_PORT"
           value = ""
         }
         env {
           name = "PROXY_SCHEME"
           value = ""
         }
         env {
           name = "NO_PROXY"
           value = ""
         }
         env {
           name = "PROXY_MANAGER"
           value = "true"
         }
         env {
           name = "PROXY_USER"
           value_from {
            secret_key_ref {
              name = "terraform-proxy"
              key = "PROXY_USER"
            }
           }
         }
         env {
          name = "PROXY_PASSWORD"
          value_from {
            secret_key_ref {
              name = "terraform-proxy"
              key = "PROXY_PASSWORD"
            }
          }
         }
         env {
          name = "POLL_FOR_TASKS"
          value = "false"
         }
         env {
          name = "HELM_DESIRED_VERSION"
          value = ""
         }
         env {
          name = "CF_PLUGIN_HOME"
          value = ""
         }
         env {
          name = "USE_CDN"
          value = "true"
         }
         env {
          name = "CDN_URL"
          value = "https://app.harness.io"
         }
         env {
          name = "JRE_VERSION"
          value = "1.8.0_242"
         }
         env {
          name = "HELM3_PATH"
          value = ""
         }
         env {
          name = "HELM_PATH"
          value = ""
         }
         env {
          name = "CF_CLI6_PATH"
          value = ""
         }
         env {
          name = "CF_CLI7_PATH"
          value = ""
         }
         env {
          name = "KUSTOMIZE_PATH"
          value = ""
         }
         env {
          name = "OC_PATH"
          value = ""
         }
         env {
          name = "KUBECTL_PATH"
          value = ""
         }
         env {
          name = "ENABlE_CE"
          value = "false"
         }
         env {
          name = "GRPC_SERVICE_ENABLED"
          value = "false"
         }
         env {
          name = "GRPC_SERVICE_CONNECTOR_PORT"
          value = "0"
         }
         env {
          name = "CLIENT_TOOLS_DOWNLOAD_DISABLED"
          value = "false"
         }
         env {
          name = "DELEGATE_NAMESPACE"
          value_from {
            field_ref {
              field_path = "metadata.namespace"
            }
          }
         }

        
   
    }
    restart_policy = "Always"
  }
}
  }
}

resource "time_sleep" "sleepfordelegaetcreation" {
  depends_on = [kubernetes_stateful_set.delegatesatefulset]

  create_duration = "3m"
}


resource "null_resource" "createprovider" {

 triggers = {
  harness_account_id =  var.harness_account_id
  cloud_provider_name = var.cloud_provider_name
  harness_api_key = var.harness_api_key
  application_name = var.application_name
  environment_name =  var.environment_name
  infrastructure_name = var.infrastructure_name
  delegate_name = var.delegate_name

}
  depends_on = [time_sleep.sleepfordelegaetcreation]
  provisioner "local-exec" {
      command = <<EOT
        curl --location --request POST 'https://app.harness.io/gateway/api/setup-as-code/yaml/upsert-entity?accountId=${self.triggers.harness_account_id}&yamlFilePath=Setup/Cloud%20Providers/${self.triggers.cloud_provider_name}.yaml' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-api-key: ${self.triggers.harness_api_key}' \
--form 'yamlContent="harnessApiVersion: '1.0'
type: KUBERNETES_CLUSTER
delegateSelectors:
- ${self.triggers.delegate_name}-keefxs-0
skipValidation: false
usageRestrictions:
  appEnvRestrictions:
  - appFilter:
      filterType: ALL
    envFilter:
      filterTypes:
      - PROD
  - appFilter:
      filterType: ALL
    envFilter:
      filterTypes:
      - NON_PROD
useKubernetesDelegate: true"'
EOT
  }
  provisioner "local-exec" {
    when = destroy
      command = <<EOT
        curl -v --request DELETE 'https://app.harness.io/gateway/api/setup-as-code/yaml/delete-entities?accountId=${self.triggers.harness_account_id}&filePaths=Setup/Cloud%20Providers/${self.triggers.cloud_provider_name}.yaml' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-api-key: ${self.triggers.harness_api_key}'
EOT
  }

}



resource "null_resource" "associateproviderwihinfra" {

  triggers = {
  harness_account_id = var.harness_account_id
  cloud_provider_name = var.cloud_provider_name
  harness_api_key = var.harness_api_key
  application_name = var.application_name
  environment_name =  var.environment_name
  infrastructure_name = var.infrastructure_name

}
  
  depends_on = [null_resource.createprovider]
  provisioner "local-exec" {
      command = <<EOT
        curl --location --request POST 'https://app.harness.io/gateway/api/setup-as-code/yaml/upsert-entity?accountId=${self.triggers.harness_account_id}&yamlFilePath=Setup/Applications/${self.triggers.application_name}/Environments/${self.triggers.environment_name}/Infrastructure%20Definitions/${self.triggers.infrastructure_name}.yaml' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-api-key: ${self.triggers.harness_api_key}' \
--form 'yamlContent="harnessApiVersion: '1.0'
type: INFRA_DEFINITION
cloudProviderType: KUBERNETES_CLUSTER
deploymentType: KUBERNETES
infrastructure:
- type: DIRECT_KUBERNETES
  cloudProviderName: ${self.triggers.cloud_provider_name}
  namespace: default
  releaseName: release-$${infra.kubernetes.infraId}"'
EOT
  }
  provisioner "local-exec" {
    when = destroy
      command = <<EOT
        curl -v --request DELETE 'https://app.harness.io/gateway/api/setup-as-code/yaml/delete-entities?accountId=${self.triggers.harness_account_id}&filePaths=Setup/Applications/${self.triggers.application_name}/Environments/${self.triggers.environment_name}/Infrastructure%20Definitions/${self.triggers.infrastructure_name}.yaml' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-api-key: ${self.triggers.harness_api_key}'
EOT
  }
}
