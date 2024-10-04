# Terraform code 

## Maintain vpc & eks with terraform for vprofile project

## Tools required
Terraform version 1.6.3

### Steps
* terraform init
* terraform fmt -check
* terraform validate
* terraform plan -out planfile
* terraform apply -auto-approve -input=false -parallelism=1 planfile

##### Items Created
1. VPC, 3 Public, 3 Private subnets
2. EKS cluster, 1 node group (t3.small)

###### Important notes
* only destroy EKS cluster, keep the public/private subnets as Jenkins server share the same public subnet.
terraform destroy -target=module.eks -target=aws_security_group_rule.allow_http

