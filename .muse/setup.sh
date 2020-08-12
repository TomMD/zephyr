#!/usr/bin/env bash

WEST=$HOME/.local/bin/west

install_system_deps() {
    apt update
    apt install -y --no-install-recommends git cmake ninja-build gperf \
      ccache dfu-util device-tree-compiler wget \
      python3-dev python3-pip python3-setuptools python3-tk python3-wheel xz-utils file \
      make gcc gcc-multilib g++-multilib libsdl2-dev
}

install_west() {
    pip3 install --user -U west
    echo "export PATH=$HOME/.local/bin:$PATH" >> ~/.bashrc
    source ~/.bashrc
}

init_west_in_zephyr() {
    $WEST init $(pwd)
    $WEST update
}

install_sdk() {
    sdkfile=zephyr-sdk-0.11.3-setup.run
    if [[ ! -f "$sdkfile" ]] ; then
        curl -LO "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.11.3/$sdkfile"
    fi
    chmod +x zephyr-sdk-0.11.3-setup.run
    ./$sdkfile -- -d ~/zephyr-sdk-0.11.3 -y
}

all_zephyr_setup() {
    install_system_deps
    install_west
    init_west_in_zephyr
    $WEST zephyr-export
    pip3 install --user -r scripts/requirements.txt
    if [[ ! -d "$HOME/zephyr-sdk-0.11.3" ]] ; then
        install_sdk
    fi
    source zephyr-env.sh
}

zephyr_build_sample() {
    $WEST build -b reel_board samples/hello_world -- -DCMAKE_EXPORT_COMPILE_COMMANDS=1
    cp build/compile_commands.json .
}

all_zephyr_setup
zephyr_build_sample
