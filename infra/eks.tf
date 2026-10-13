resource "aws_eks_cluster" "travel" {
  name     = "travel-eks"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.35"

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  upgrade_policy {
    support_type = "STANDARD"
  }

  vpc_config {
    subnet_ids = [
      aws_subnet.travel_a.id,
      aws_subnet.travel_b.id
    ]

    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["3.106.58.74/32"]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster
  ]
}
