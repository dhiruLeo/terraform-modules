Terraform template for API Resource
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
|parent_path| Parent path of api resource | String
|path_part|  last path segment of this API resource| String

### Use as Standalone TF template

```
$ terraform init
$ terraform plan
$ terraform apply
```

**Note**: It uses Default Variables to create API Resource

### Use as a Module

```
module "api_gateway_resource"{
    source = "git::https://github.com/srijanaravali/tf-aws-modules.git//modules/api-gateway/resource"
    shared_credentials_file = "${var.cred_file}"
    profile = ${var.profile} # Default
    region = "${var.region}"
    name = "Test API"
    parent_path = "/test" # it should pe full path
    path_part = "${var.path_part}"
}
```

### Output variables
|   Name    |   Descriptio  |
|-----------|---------------|
|id         | resource's id |
|path       | path for the API resource|

#### Limitations
* While running as standalone template, we are not saving tf states file in backend