FROM ubuntu:20.04

SHELL ["/bin/bash", "-c"]

ENV USER=wally

WORKDIR /home/$USER

COPY . /home/$USER/cvw

WORKDIR /home/$USER/cvw

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y \
    && apt-get install -y sudo git \
    && ./bin/wally-tool-chain-install.sh --clean \
    && sudo apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN source setup.sh \
    && gcc --version \
    && which python \
    && git config --global --add safe.directory '*' \
    && make riscof

CMD ["bash", "-c", "source setup.sh && exec /bin/bash"]
