#!/usr/bin/env bash

install_system_deps() {
    apt update
    apt install -y --no-install-recommends git cmake ninja-build gperf \
      ccache dfu-util device-tree-compiler wget \
      python3-dev python3-pip python3-setuptools python3-tk python3-wheel xz-utils file \
      make gcc gcc-multilib g++-multilib libsdl2-dev
}

install_west() {
    pip3 install --user -U west
    echo 'export PATH=~/.local/bin:"$PATH"' >> ~/.bashrc
    source ~/.bashrc
}

init_west_in_zephyr() {
    west init $(pwd)
    west update
}

install_sdk() {
    sdkfile=zephyr-sdk-0.11.3-setup.run
    if [[ ! -f "$sdkfile" ]] ; then
        curl -LO "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.11.3/$sdkfile"
    fi
    chmod +x zephyr-sdk-0.11.3-setup.run
    ./$sdkfile -- -d ~/zephyr-sdk-0.11.3
}

all_zephyr_setup() {
    install_system_deps
    install_west
    init_west_in_zephyr
    west zephyr-export
    pip3 install --user -r scripts/requirements.txt
    install_sdk
}

zephyr_build_sample() {
    cmake -B build -GNinja -DBOARD=reel_board samples/hello_world
    ninja -C build -t compdb
}

all_zephyr_setup
zephyr_build_sample
