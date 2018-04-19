#!/bin/sh

ODP_VER='master'
ODP_CONF_OPTS='--enable-debug --enable-debug-print --prefix=./install'

git clone https://github.com/Linaro/odp.git && cd odp && git checkout master
# terminate LAVA job if download failed
[ $? -ne 0 ] && dpdk_lava_result 'ODP_DOWNLOAD' 'FAILED' 'yes'

# we usually run on Xeon/Thunderx, aadjust accordingly for future archs
arch=$(arch)
case $arch in
	aarch64)
		cjobs=98
		;;
	x86_64)
		cjobs=24
		;;
	*) 
		dpdk_lava_result 'BUILD_ARCH' 'UNKNOWN_ARCH' 'yes'
esac

# already cd'ed in
./bootstrap
autoreconf -i
./configure --enable-debug --enable-debug-print --prefix=$BUILD_DIR
make -j $cjobs install
