# CVW Dockerfile
# Jordan Carlin jcarlin@hmc.edu  July 2024
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

# Use 
FROM ubuntu:22.04

SHELL ["/bin/bash", "-c"]

# Create a user with sudo privileges
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

ENV RISCV=/opt/riscv

COPY . /home/$USERNAME/cvw

WORKDIR /home/$USERNAME/cvw

ARG DEBIAN_FRONTEND=noninteractive

RUN sudo ./bin/wally-package-install.sh \
    && sudo apt-get clean \
    && sudo rm -rf /var/lib/apt/lists/*

RUN sudo ./bin/wally-tool-chain-install.sh --clean \
    && sudo rm -rf $RISCV/buildroot/output/build

RUN source setup.sh \
    && git config --global --add safe.directory '*' \
    && make -j$(nproc)

CMD ["bash", "-c", "source setup.sh && exec /bin/bash"]
