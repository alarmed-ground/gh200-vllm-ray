# gh200-vllm-ray

## MicroK8s RayCluster deployment

This repository includes Kubernetes scaffolding for running the image as a Ray cluster on MicroK8s.

- `k8s/microk8s/ray-cluster.yaml` — RayCluster manifest using the repository image.
- `scripts/deploy-raycluster-microk8s.sh` — helper script to enable MicroK8s addons, install KubeRay, and deploy the cluster.
- `k8s/microk8s/README.md` — detailed deploy instructions and verification steps.

See `k8s/microk8s/README.md` for usage details.
