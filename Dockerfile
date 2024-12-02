# CVW Dockerfile
# Jordan Carlin jcarlin@hmc.edu  July 2024
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

FROM ubuntu:24.04

SHELL ["/bin/bash", "-c"]

# Create a user with sudo privileges
ARG USERNAME=wally
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Change to the new user
USER $USERNAME

COPY . /home/$USERNAME/cvw

WORKDIR /home/$USERNAME/cvw

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y \
    && apt-get install -y sudo git \
    && ./bin/wally-package-install.sh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN sudo ./bin/wally-tool-chain-install.sh --clean

RUN source setup.sh \
    && git config --global --add safe.directory '*' \
    && make -j$(nproc)

CMD ["bash", "-c", "source setup.sh && exec /bin/bash"]
