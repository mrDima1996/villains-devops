module "eks_managed_node_group" {
  source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"

  name            = "eks-managed-node-group"
  cluster_name    = module.eks.cluster_name
  cluster_version = module.eks.cluster_version

  vpc_id                            = aws_vpc.vpc.id
  subnet_ids                        = ["${element(aws_subnet.private_subnet.*.id, 0)}", "${element(aws_subnet.private_subnet.*.id, 1)}", "${element(aws_subnet.private_subnet.*.id, 2)}", ]
  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
  vpc_security_group_ids = [
    module.eks.cluster_security_group_id,
  ]

  ami_type = "BOTTLEROCKET_x86_64"
  platform = "bottlerocket"

  # this will get added to what AWS provides
  bootstrap_extra_args = <<-EOT
    # extra args added
    [settings.kernel]
    lockdown = "integrity"
    [settings.kubernetes.node-labels]
    "label1" = "foo"
    "label2" = "bar"
  EOT

  tags = merge(local.tags, { Separate = "eks-managed-node-group" })
}