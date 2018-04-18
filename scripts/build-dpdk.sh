#!/bin/sh

DPDK_VER='17.11.1'
DPDK_DIR='dpdk_source'
DPDK_STATIC_TAR='dpdk.tar.xz'

arch=$(arch)

dpdk_lava_result() {
	reason=$1
	result=$2
	stop_session=$3

	lava-test-case "$reason" --result "$result"
	[ "$stop_session" = 'yes' ] && lava-test-raise "$reason" && exit 1
}

wget https://fast.dpdk.org/rel/dpdk-"$DPDK_VER".tar.xz -O "$DPDK_STATIC_TAR" && \
	mkdir "$DPDK_DIR" && tar xf "$DPDK_STATIC_TAR" --strip 1 -C "$DPDK_DIR"

# terminate LAVA job if download failed
[ $? -ne 0 ] && dpdk_lava_result 'DPDK_DOWNLOAD' 'FAILED' 'yes'

# we usually run on Xeon/Thunderx, aadjust accordingly for future archs
case $arch in
	aarch64)
		dpdk_t='arm64-armv8a-linuxapp-gcc'
		cjobs=98
		;;
	x86_64)
		dpdk_t='x86_64-native-linuxapp-gcc'
		cjobs=24
		;;
	*) 
		dpdk_lava_result 'BUILD_ARCH' 'UNKNOWN_ARCH' 'yes'
esac

cd "$DPDK_DIR"
make -j "$cjobs" install T="$dpdk_t" DESTDIR=./install
cd ..
