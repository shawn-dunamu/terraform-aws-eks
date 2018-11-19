# locals

locals {
  full_name  = "${var.city}-${var.stage}-${var.name}"
  lower_name = "${lower(local.full_name)}"
  upper_name = "${upper(local.full_name)}"
}

locals {
  userdata = <<EOF
#!/bin/bash -xe
/etc/eks/bootstrap.sh \
  --apiserver-endpoint '${aws_eks_cluster.cluster.endpoint}' \
  --b64-cluster-ca '${aws_eks_cluster.cluster.certificate_authority.0.data}' \
  '${local.lower_name}'
EOF
}

locals {
  config = <<EOF
# regign
aws configure set default.region ${var.region}

# kube config
mkdir -p ~/.kube && cat .output/kube_config.yaml > ~/.kube/config
kubectl config current-context

# aws auth
kubectl apply -f .output/aws_auth.yaml

# aws ebs gp2
kubectl apply -f .output/aws_ebs_gp2.yaml

# get
kubectl get node -o wide
kubectl get all --all-namespaces
EOF
}
