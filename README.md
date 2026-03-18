# 🚀 Configuring Production-Ready EKS Clusters with Terraform and GitHub Actions


![EKS- GitHub Actions- Terraform](assets/Presentation1.gif)

Welcome to the repository for **Configuring Production-Ready EKS Clusters with Terraform and Automating with GitHub Actions**! This repository accompanies my blog post and demonstrates the practical steps to set up and automate an EKS cluster.

## 🌟 Overview
This project covers:
- **Infrastructure as Code (IaC)**: Use Terraform to define and manage your EKS cluster.
- **CI/CD Automation**: Leverage GitHub Actions to automate deployments.

## 🌟 Comprehensive Guide
For a detailed guide, please refer to my [blog post on Medium](https://medium.com/p/c046e8d44865).

## 🤝 Contributing
Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

aws eks update-kubeconfig --name dev-ap-medium-eks-cluster

dev-ap-medium-eks-cluster-nodegroup-role-6884

export KARPENTER_NAMESPACE="karpenter"
export KARPENTER_VERSION="1.8.0"
export CLUSTER_NAME="dev-ap-medium-eks-cluster"
export AWS_REGION="ap-south-1"
export K8S_VERSION="1.34"

export AWS_PARTITION="aws"
export EKS_WORKER_NODE_ROLE="dev-ap-medium-eks-cluster-nodegroup-role-6884"
export AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
export OIDC_ENDPOINT="$(aws eks describe-cluster --name ${CLUSTER_NAME} \
    --query "cluster.identity.oidc.issuer" --output text)"
export ALIAS_VERSION="$(aws ssm get-parameter --name "/aws/service/eks/optimized-ami/${K8S_VERSION}/amazon-linux-2023/x86_64/standard/recommended/image_id" --query Parameter.Value | xargs aws ec2 describe-images --query 'Images[0].Name' --image-ids | sed -r 's/^.*(v[[:digit:]]+).*$/\1/')"


aws iam create-instance-profile --instance-profile-name "dev-ap-medium-eks-cluster-nodegroup-role-6884"

aws iam add-role-to-instance-profile \
--instance-profile-name "dev-ap-medium-eks-cluster-nodegroup-role-6884" \
--role-name "dev-ap-medium-eks-cluster-nodegroup-role-6884"

aws sqs create-queue --queue-name $CLUSTER_NAME

helm template karpenter oci://public.ecr.aws/karpenter/karpenter --version "${KARPENTER_VERSION}" --namespace "${KARPENTER_NAMESPACE}" \
    --set "settings.clusterName=${CLUSTER_NAME}" \
    --set "settings.interruptionQueue=${CLUSTER_NAME}" \
    --set "serviceAccount.annotations.eks\.amazonaws\.com/role-arn=arn:${AWS_PARTITION}:iam::${AWS_ACCOUNT_ID}:role/KarpenterControllerRole-${CLUSTER_NAME}" \
    --set controller.resources.requests.cpu=1 \
    --set controller.resources.requests.memory=1Gi \
    --set controller.resources.limits.cpu=1 \
    --set controller.resources.limits.memory=1Gi > karpenter.yaml


helm upgrade --install karpenter karpenter/karpenter \
  --namespace karpenter \
  --create-namespace \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=arn:aws:iam::877009927033:role/KarpenterControllerRole-dev-ap-medium-eks-cluster \
  --set settings.clusterName=$CLUSTER_NAME \
  --set settings.clusterEndpoint=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.endpoint" --output text) \
  --set settings.aws.defaultInstanceProfile=arn:aws:iam::877009927033:instance-profile/dev-ap-medium-eks-cluster-nodegroup-role-6884 \
  --set settings.interruptionQueueName=dev-ap-medium-eks-cluster