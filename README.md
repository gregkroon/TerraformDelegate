# TerraformDelegate

### Introduction 
MVP Terraform manifest for provisioning a delegate , cloud provider and infrastructure .
Purpose is to ease and automate onboarding through configuration as code .


### Requirements 

The terraform manifest uses the official kubernetes provider from Hashicorp . It is set to read your kubeconfig file 
you will need to provide path and context . Alteratively use what ever credential helper or auth configuration that suits you .

https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs

#### Input parameters required for provisioning 

harness_api_key = Create one in the Harness UI , Security->Access management->API keys 

harness_account_id = You can find this in your harness url or in the UI at Setup->Overview->Account id 

harness_account_secret = In the delegate kubernetes yaml 

application_name = Existing application name 

environment_name = Existing environment name

delegate_name = provided by you 

cloud_provider_name = provided by you

infrastructure_name = provided by you


