FROM ubuntu:16.04

ENV ELECTRUM_VERSION 3.1.1
ENV RPCPORT 8443
ENV RPCHOST 0.0.0.0
ENV RPCUSER admin1
ENV RPCPASSWORD admin1

LABEL version="1.0"
LABEL maintainer="shindu666@gmail.com"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
 apt-get install --yes wget software-properties-common python-qt4 python3-setuptools python3-pyqt5 python3-pip

COPY launch_electrum .

CMD bash

# ENTRYPOINT "./launch_electrum"

