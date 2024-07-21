FROM rockylinux:8

ENV USER=wally

WORKDIR /opt/riscv

COPY bin/wally* scripts/

RUN ./scripts/wally-tool-chain-install.sh --clean

WORKDIR /home/$USER

CMD ["/bin/bash"]