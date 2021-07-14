#!/bin/bash

CUR_PATH=$(pwd)
VECTOR_PATH=${CUR_PATH}/vector
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
source "$HOME/.cargo/env"
cargo install cross
git clone --depth 1 --branch v0.14.0 https://github.com/timberio/vector.git
cd $VECTOR_PATH
git apply ${CUR_PATH}/loki-labels.patch
# specify packages you need
for package in `echo "package-x86_64-unknown-linux-musl"`; do
    FEATURES=default make $package
done
FEATURES=default REPO=flant/vector make release-docker
cd ${CUR_PATH}
rm -rf $VECTOR_PATH 
