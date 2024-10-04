module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.19.1"

  cluster_name    = local.cluster_name
  cluster_version = "1.27"

  vpc_id                         = "vpc-0db2d3c36979d54b5"
  subnet_ids                     = ["subnet-0b6a6776009ef281e", "subnet-0f29337ac29af18a2", "subnet-06ff299538db8fbe6"]
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }

  }
}

# Adding an inbound rule to the EKS security group
resource "aws_security_group_rule" "allow_http" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = "sg-0eec7f42b8f023828"

  lifecycle {
    prevent_destroy = true
  }

  # Reference the EKS cluster security group from the module output
  security_group_id = module.eks.cluster_security_group_id
}
