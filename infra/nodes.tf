resource "aws_eks_node_group" "travel" {
  cluster_name    = aws_eks_cluster.travel.name
  node_group_name = "travel-workers"
  node_role_arn   = aws_iam_role.eks_nodes.arn

  subnet_ids = [
    aws_subnet.travel_a.id,
    aws_subnet.travel_b.id
  ]

  instance_types = ["c7i-flex.large"]
  ami_type       = "AL2023_x86_64_STANDARD"
  disk_size      = 20

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker,
    aws_iam_role_policy_attachment.node_ecr,
    aws_iam_role_policy_attachment.node_cni,
    aws_route_table_association.travel_a,
    aws_route_table_association.travel_b
  ]
}
