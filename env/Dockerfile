FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive

# Base OS packages required to build PyTorch CUDA extensions
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      curl \
      ca-certificates \
      git \
      build-essential \
      cmake \
      ninja-build \
      pkg-config \
      bzip2 \
      libx11-6 \
      libxext6 \
      libxi6 \
      libgl1 \
      libglib2.0-0 && \
    rm -rf /var/lib/apt/lists/*

# Install Miniconda (conda CLI available in container)
ENV CONDA_DIR=/opt/conda
RUN curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p $CONDA_DIR && \
    rm /tmp/miniconda.sh
ENV PATH=$CONDA_DIR/bin:$PATH

# Ensure CUDA toolchain is discoverable and set CUDA arch list for PyTorch extensions
ENV CUDA_HOME=/usr/local/cuda
ENV TORCH_CUDA_ARCH_LIST="7.5;8.0;8.6;8.9"

WORKDIR /workspace

# Bring the project into the image to run install.py during build
COPY . /workspace

# Create the conda environment and install CUDA extensions during build
# Accept Anaconda Terms of Service non-interactively during build
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# Create env (non-interactive) and install CUDA extensions
RUN python install.py

# Verify that the sugar environment exists and is usable (fail fast if not)
RUN conda env list && conda run -n sugar python -V

# Install CUDA extensions in editable mode within the sugar environment
RUN conda run -n sugar bash -lc "\
  cd /workspace/gaussian_splatting/submodules/diff-gaussian-rasterization && \
  pip install -e . && \
  cd /workspace/gaussian_splatting/submodules/simple-knn && \
  pip install -e . \
"

# Initialize conda for bash and ensure the sugar env is auto-activated
RUN conda init bash && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> /root/.bashrc && \
    echo "conda activate sugar" >> /root/.bashrc

# Also place sugar env bin at the front of PATH for non-interactive commands
ENV PATH=/opt/conda/envs/sugar/bin:$PATH

# Ensure bash is the default shell for RUN commands
SHELL ["/bin/bash", "-lc"]

# Default to an interactive shell; users will run `python install.py` then `conda activate sugar`
CMD ["bash"]


