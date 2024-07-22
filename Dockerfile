FROM ubuntu:20.04

ENV USER=wally

WORKDIR /opt/riscv

COPY bin/wally* scripts/

RUN apt-get update && apt-get upgrade -y && apt-get install -y sudo git
    # dnf install curl -y --allowerasing || true

RUN ./scripts/wally-tool-chain-install.sh --clean

WORKDIR /home/$USER

CMD ["/bin/bash"]