FROM nvidia/cuda:12.8.1-devel-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    git \
    curl \
    wget \
    vim \
    build-essential \
    net-tools \
    iproute2 \
    rdma-core \
    infiniband-diags \
    ibverbs-utils \
    libibverbs-dev \
    pciutils \
    && rm -rf /var/lib/apt/lists/*

RUN ln -sf /usr/bin/python3 /usr/bin/python

# Create virtualenv
RUN python3 -m venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

RUN pip install --upgrade \
    pip \
    setuptools \
    wheel

# PyTorch CUDA 12.8
RUN pip install \
    torch \
    torchvision \
    torchaudio \
    --index-url https://download.pytorch.org/whl/cu128

# Latest Ray
RUN pip install "ray[all]"

# Latest vLLM
RUN pip install vllm

# Recommended extras
RUN pip install \
    flashinfer-python \
    hf-transfer \
    sentencepiece \
    ninja

ENV HF_HUB_ENABLE_HF_TRANSFER=1

# NCCL tuning
ENV NCCL_DEBUG=INFO
ENV NCCL_IB_DISABLE=0
ENV NCCL_SOCKET_IFNAME=enp
ENV NCCL_NET_GDR_LEVEL=2
ENV NCCL_P2P_LEVEL=SYS
ENV NCCL_CROSS_NIC=1
ENV NCCL_IB_GID_INDEX=3

# vLLM optimization
ENV VLLM_USE_V1=1

WORKDIR /workspace

CMD ["/bin/bash"]