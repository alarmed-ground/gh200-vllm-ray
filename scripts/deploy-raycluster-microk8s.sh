#!/usr/bin/env bash
set -euo pipefail

if ! command -v microk8s >/dev/null 2>&1; then
  echo "microk8s CLI not found. Install MicroK8s and retry."
  exit 1
fi

echo "Enabling MicroK8s addons..."
microk8s enable dns storage

echo "Creating vllm namespace..."
microk8s kubectl create namespace vllm --dry-run=client -o yaml | microk8s kubectl apply -f -

echo "Applying placeholder PVC claims..."
microk8s kubectl apply -f k8s/microk8s/pvc-claims.yaml

echo "Installing KubeRay operator..."
microk8s kubectl apply -f https://raw.githubusercontent.com/ray-project/kuberay/master/manifests/ray-operator.yaml

echo "Waiting for KubeRay operator to become ready..."
microk8s kubectl wait --for=condition=available deployment/ray-operator -n ray-system --timeout=180s || true

echo "Deploying RayCluster manifest..."
microk8s kubectl apply -f k8s/microk8s/ray-cluster.yaml

echo "RayCluster deploy triggered."
microk8s kubectl get raycluster -n vllm
