#!/bin/bash -ex

mode=$1

if [ "$mode" = "client" ]; then
	LOCAL_IP=${LOCAL_IP:-"192.168.100.2"}
	REMOTE_IP=${REMOTE_IP:-"192.168.100.1"}
elif [ "$mode" = "server" ]; then
	LOCAL_IP=${LOCAL_IP:-"192.168.100.1"}
	REMOTE_IP=${REMOTE_IP:-"192.168.100.2"}
else
	echo "wrong mode"
	exit 1
fi


# name of the VLAND used
VLAND_NAME=${VLAND_NAME:-vlan_one}

function what_vland_entry {
        lava-vland-names | grep "^$1" | cut -d , -f 2
}

function what_vland_sys_path {
	lava-vland-self | grep "$(what_vland_entry $1)" | cut -d , -f 3 | cut -d / -f 8
}

function what_vland_MAC {
        lava-vland-self | grep "$(what_vland_entry $1)" | cut -d , -f 2
}

function what_vland_interface {
        ls $(what_vland_sys_path $1)
}

ifconfig -a


VLAND_SELF=`lava-vland-self | grep ${VLAND_NAME}`
echo "VLAND_SELF = ${VLAND_SELF}"
MAC=`echo ${VLAND_SELF} | cut -d , -f 2`
echo "MAC = ${MAC}"

fgrep -r ${MAC} /sys 2> /dev/null

lava-vland-names
lava-vland-names | grep "^$1" | cut -d , -f 2
lava-vland-self 
what_vland_interface ${VLAND_NAME}

if ! which lava-wait &>/dev/null; then
        echo "This script must be executed in LAVA"
        exit
fi

# Setup network interface
dev=$(what_vland_interface ${VLAND_NAME})
echo "dev = ${dev}"
ifconfig $dev ${LOCAL_IP} up

lava-send client_ready
lava-wait server_ready

ping -c 10 -i $dev ${REMOTE_IP} 

lava-send client_done
lava-wait server_done
