# MicroK8s RayCluster deployment

This folder contains scaffolding for deploying the `gh200-vllm-ray` container image as a 3-node GH200 Ray cluster on MicroK8s using 400GbE fabric.

## Prerequisites

- MicroK8s installed and running in a multi-node cluster
- `microk8s` CLI available on PATH
- Three GH200-capable nodes labeled for the 400GbE fabric
- Access to the image registry used by the cluster image

### Node labeling

Ensure the S7G nodes are labeled so the RayCluster can schedule on the correct hardware:

```bash
microk8s kubectl label node <node1> node-role=s7g network=400gbe
microk8s kubectl label node <node2> node-role=s7g network=400gbe
microk8s kubectl label node <node3> node-role=s7g network=400gbe
```

## Deploy

1. Ensure the image is available to the cluster.

   If you publish to GitHub Container Registry:
   ```bash
   docker build -t ghcr.io/alarmed-ground/gh200-vllm-ray:nightly-x86_64 .
   docker push ghcr.io/alarmed-ground/gh200-vllm-ray:nightly-x86_64

   docker build -t ghcr.io/alarmed-ground/gh200-vllm-ray:nightly-arm64 .
   docker push ghcr.io/alarmed-ground/gh200-vllm-ray:nightly-arm64
   ```

   If you want to load a local image into MicroK8s instead:
   ```bash
   docker build -t gh200-vllm-ray:test .
   microk8s ctr image import $(docker save gh200-vllm-ray:test -o /tmp/gh200-vllm-ray.tar && echo /tmp/gh200-vllm-ray.tar)
   ```

2. Create the placeholder PVCs for the RayCluster:
   ```bash
   microk8s kubectl apply -f k8s/microk8s/pvc-claims.yaml
   ```
   The manifest uses placeholder claim names (`placeholder-hf-cache-pvc` and `placeholder-vllm-model-storage-pvc`). Replace these names in `k8s/microk8s/ray-cluster.yaml` if you have existing PVCs.

3. Run the deploy helper script:
   ```bash
   chmod +x scripts/deploy-raycluster-microk8s.sh
   ./scripts/deploy-raycluster-microk8s.sh
   ```

4. Verify cluster state:
   ```bash
   microk8s kubectl get raycluster -n vllm
   microk8s kubectl get pods -n vllm
   ```

The deployment manifest creates a RayCluster in namespace `vllm` with one head pod and three worker pods, using S7G nodes and 400GbE labels.

5. Port-forward the Ray dashboard:
   ```bash
   microk8s kubectl port-forward -n vllm svc/vllm-gh200-ray-head-svc 8265:8265
   ```

## Customization

- Update `k8s/microk8s/ray-cluster.yaml` to change the image tag or sizing.
- If your built image includes a different Ray version, adjust `rayVersion` in the manifest.
