# TerraformDelegate

### Introduction 
MVP Terraform manifest for provisioning a delegate , cloud provider and infrastructure .
Purpose is to ease and automate onboarding through configuration as code .


### Requirements 

The terraform manifest uses the official kubernetes provider from Hashicorp . It is set to read your kubeconfig file 
you will need to provide path and context . Alteratively use what ever credential helper or auth configuration that suits you .

https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs

#### Input parameters required for provisioning 

harness_account_id

harness_account_secret

delegate_name

cloud_provider_name

application_name

environment_name

infrastructure_name

harness_api_key
