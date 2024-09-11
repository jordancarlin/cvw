FROM ubuntu:24.04

SHELL ["/bin/bash", "-c"]

ENV USER=wally

WORKDIR /home/$USER

COPY . /home/$USER/cvw

WORKDIR /home/$USER/cvw

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y \
    && apt-get install -y sudo git \
    && ./bin/wally-package-install.sh \
    && sudo apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN ./bin/wally-tool-chain-install.sh --clean

RUN source setup.sh \
    && git config --global --add safe.directory '*' \
    && make -j$(nproc)

CMD ["bash", "-c", "source setup.sh && exec /bin/bash"]
