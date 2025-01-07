# CVW Dockerfile
# Jordan Carlin jcarlin@hmc.edu  July 2024
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

# User options
ARG USERNAME=wally
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Use latest Ubuntu 22.04 LTS release as base for image
FROM ubuntu:22.04

# Set metadata for image
LABEL org.opencontainers.image.title="CVW Ubuntu 22.04 Image"
LABEL org.opencontainers.image.description="Ubuntu 22.04 Docker image with all tools for Core-V-Wally. Includes RISC-V toolchain, elf2hex, QEMU, Spike, Sail, Verilator, and Buildroot."
LABEL org.opencontainers.image.source="https://github.com/openhwgroup/cvw"
LABEL org.opencontainers.image.authors="Jordan Carlin <jcarlin@hmc.edu>"
LABEL org.opencontainers.image.licenses="Apache-2.0 WITH SHL-2.1"

# Allow execution of more complex bash commands
SHELL ["/bin/bash", "-c"]
ARG DEBIAN_FRONTEND=noninteractive

# Set $RISCV directory
ENV RISCV=/opt/riscv

# Add CVW directory to image
COPY --chown=$USERNAME:$USERNAME . /home/$USERNAME/cvw
WORKDIR /home/$USERNAME/cvw

# Install tools
RUN ./bin/wally-tool-chain-install.sh --clean \
    # Purge installation caches
    && pip cache purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    # Remove buildroot source code and intermediate files
    && mkdir -p $RISCV/buildroot-temp/output \
    && mv $RISCV/buildroot/output/images $RISCV/buildroot-temp/output/images \
    && rm -rf $RISCV/buildroot \
    && mv $RISCV/buildroot-temp $RISCV/buildroot \
    # Remove logs
    && rm -rf $RISCV/logs

# Create a user
RUN groupadd -f --gid "$USER_GID" "$USERNAME" && \
    useradd -l -m -u "$USER_UID" -g "$USER_GID" -s /bin/bash "$USERNAME"

# Change to the new user
USER $USERNAME

# Set default command to already have setup script sourced
CMD ["bash", "-c", "source setup.sh && exec /bin/bash"]
