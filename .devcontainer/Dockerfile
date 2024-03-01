ARG BASE_IMAGE=debian:bookworm-slim

FROM ${BASE_IMAGE}

ARG USER=build
ARG USER_ID=1000
ARG USER_GID=1000

RUN apt-get clean \ 
 && apt-get update \
 && apt-get install -y --no-install-recommends \
        sudo \
        unzip \
        locales \
        locales-all

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV TZ Europe/Vienna

RUN groupadd --gid "$USER_GID" "$USER" && \
    useradd \
      --uid $USER_ID \
      --gid $USER_GID \
      -m --home-dir /home/$USER \
      $USER && \
    echo "$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN apt-get -y install \
        build-essential ninja-build git git-lfs libssl-dev file zip curl python3-pip && \
    curl -o "/tmp/cmake_inst.sh" "https://cmake.org/files/v3.23/cmake-3.23.0-linux-x86_64.sh" && \
    chmod +x /tmp/cmake_inst.sh && /tmp/cmake_inst.sh --skip-license --prefix=/usr && rm /tmp/cmake_inst.sh && \
    pip3 install --break-system-packages conan

ENV SHELL=/bin/bash
