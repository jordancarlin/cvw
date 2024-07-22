FROM ubuntu:20.04

ENV USER=wally
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /home/$USER

COPY . /home/$USER/cvw

WORKDIR /home/$USER/cvw

RUN apt-get update && apt-get upgrade -y && apt-get install -y sudo git

RUN ./bin/wally-tool-chain-install.sh --clean

RUN source setup.sh && make riscof

CMD "source setup.sh && /bin/bash"
