#!/bin/sh

dpdk_lava_result() {
	reason=$1
	result=$2
	stop_session=$3

	lava-test-case "$reason" --result "$result"
	[ "$stop_session" = 'yes' ] && lava-test-raise "$reason" && exit 1
}
