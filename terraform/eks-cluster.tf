module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.19.1"

  cluster_name    = local.cluster_name
  cluster_version = "1.27"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 3
    }
  }
}

# Adding an inbound rule to the EKS security group
resource "aws_security_group_rule" "allow_http" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = "sg-0d38232bdeda92bc9"

  security_group_id = module.eks.cluster_security_group_id
}

# Attach specific permissions to the EKS node group IAM role
resource "aws_iam_policy" "node_group_permissions" {
  name        = "NodeGroupPermissions"
  description = "Permissions for EKS node group to manage auto-scaling and EKS actions"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Statement1"
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:UpdateAutoScalingGroup",
          "autoscaling:AttachInstances",
          "autoscaling:DetachInstances",
          "autoscaling:SetDesiredCapacity",
          "ec2:DescribeLaunchTemplateVersions",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach the specific permissions policy to the EKS node group IAM role
resource "aws_iam_role_policy_attachment" "node_group_permissions_attachment" {
  role       = module.eks.node_groups["one"].iam_role_arn
  policy_arn = aws_iam_policy.node_group_permissions.arn
}

# Attach the AmazonEKSClusterPolicy to the EKS node group IAM role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = module.eks.node_groups["one"].iam_role_arn
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
