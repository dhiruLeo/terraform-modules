# Standalone Module for creating API Gateway(root resource)
Terraform template for API(Root) Gateway
## Prerequisites 
* Terraform
* aws cli
### Input variables

|   Name   |    Descriptio  |   Type    |
|----------|----------------|-----------|
|shared_credentials_file| Path to AWS credentails file| String|
|profile| AWS Profile used to create API Gateway| String|
|region| Region you want to create | String
|name| Name of API | String
|description| Description of your API | String
|endpoint_type| EDGE/REGIONAL/PRIVATE| List(only support 1 item in list)

### Use as Standalone TF template

```
$ terraform init
$ terraform plan
$ terraform apply
```

**Note**: It uses Default Variables to create API

### Use as a Module

```
module "api_gateway"{
    source = "git::https://github.com/srijanaravali/tf-aws-modules.git//modules/api-gateway/api"
    shared_credentials_file = "${var.cred_file}"
    profile = ${var.profile} # Default
    region = "${var.region}"
    name = "Test API"
    description = "Example API"
    endpoint_type = ["REGIONAL"]
}
```

### Output variables
|   Name    |   Descriptio  |
|-----------|---------------|
|id| ID of the REST API|
|root_resource_id| Resource ID of the REST API's root|
|created_date| Creation date|

#### Limitations
* While running as standalone template, we are not saving tf states file in backend
