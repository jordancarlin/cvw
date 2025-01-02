# CVW Dockerfile
# Jordan Carlin jcarlin@hmc.edu  July 2024
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

ARG BUILD_TESTS=true

# Use latest Ubuntu 22.04 LTS release as base for image
FROM ubuntu:22.04

# Allow execution of more complex bash commands
SHELL ["/bin/bash", "-c"]
ARG DEBIAN_FRONTEND=noninteractive

# Create a user (wally) with sudo privileges
ARG USERNAME=wally
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN apt-get update && \
    apt-get install -y sudo && \
    groupadd -f --gid $USER_GID $USERNAME && \
    useradd -m -u $USER_UID -g $USER_GID -s /bin/bash $USERNAME \
    && usermod -aG sudo $USERNAME \
    && echo '%sudo ALL=(ALL) NOPASSWD: ALL' | EDITOR='tee -a' visudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Change to the new user
USER $USERNAME

# Set $RISCV directory
ENV RISCV=/opt/riscv

# Add CVW directory to image
COPY . /home/$USERNAME/cvw
WORKDIR /home/$USERNAME/cvw

# Install dependencies
RUN sudo ./bin/wally-package-install.sh \
    && sudo apt-get clean \
    && sudo rm -rf /var/lib/apt/lists/*

# Install main tools
RUN sudo ./bin/wally-tool-chain-install.sh --clean \
    && sudo rm -rf $RISCV/buildroot/output/build

# Build tests
RUN if [ "$BUILD_TESTS" == "true" ]; then \
    source setup.sh \
    && make --jobs $(nproc); \
    fi

# Set default command to already have setup script sourced
CMD ["bash", "-c", "source setup.sh && exec /bin/bash"]
