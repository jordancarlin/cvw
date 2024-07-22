FROM ubuntu:20.04

ENV USER=wally

WORKDIR /home/$USER

COPY . /home/$USER/cvw

WORKDIR /home/$USER/cvw

RUN DEBIAN_FRONTEND=noninteractive apt-get update -y \
    && apt-get install -y sudo git \
    && ./bin/wally-tool-chain-install.sh --clean \
    && sudo apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# RUN bash -c "source setup.sh && make riscof"

CMD ["bash", "-c", "source setup.sh && exec /bin/bash"]
