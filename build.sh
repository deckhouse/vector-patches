#!/bin/bash

CUR_PATH=$(pwd)
VECTOR_PATH=${CUR_PATH}/vector
DOCKERREPO=${REPO:-flant/vector}
if [ ! -e $HOME/.cargo/env ]; then
  echo "Installing rust toolchain"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
fi
source "$HOME/.cargo/env"
cargo install cross
if [ ! -e $VECTOR_PATH ]; then
  git clone --depth 1 --branch v0.16.1 https://github.com/timberio/vector.git
  cd $VECTOR_PATH
else
  cd $VECTOR_PATH
  git checkout .
fi
git apply ${CUR_PATH}/loki-labels.patch
git apply ${CUR_PATH}/kubernetes_logs-lib.patch
git apply ${CUR_PATH}/kubernetes_logs-owner-ref.patch
# specify packages you need
for package in `echo "package-x86_64-unknown-linux-musl"`; do
    FEATURES=default make $package
done
FEATURES=default REPO=${DOCKERREPO} make release-docker
cd ${CUR_PATH}
#rm -rf $VECTOR_PATH
