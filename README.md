# Terraform code 

## Maintain vpc & eks with terraform for vprofile project

## Tools required
Terraform version 1.9.5

### Steps
* terraform init
* terraform fmt -check
* terraform validate
* terraform plan
* terraform apply

##### Items Created
1. VPC, 3 Public, 3 Private subnets, NAT gateway
2. EKS cluster, 1 node group (t3.small)

###### Important notes
- To save cost, only destroy EKS cluster after project is done and keep the VPCs/public/private subnets as Jenkins server share the same public subnet.
terraform destroy -target=module.eks

- To further save costs, delete the NAT gateway by modifying vpc.tf (enable_nat_gateway   = false) then use terraform apply

