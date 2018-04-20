#!/bin/sh -e

rm -rf odp
git clone https://github.com/Linaro/odp.git
pushd odp
git reset --hard ${ghprbActualCommit}

./bootstrap

DPDK_DIR='dpdk_source'
./configure --prefix=$BUILD_DIR \
	--with-dpdk-path=${DPDK_DIR}/install
make install -j ${nproc}
