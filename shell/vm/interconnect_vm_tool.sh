#!/bin/bash
#set -x

#pair_num=3
#pair=("vnet2" "vnet4")
#pair+=("vnet1" "vnet5")
#pair+=("vnet7" "vnet6")

pair=("vnet13" "vnet4")
pair+=("vnet2" "vnet19")
pair+=("vnet3" "vnet22")
pair+=("vnet12" "vnet21")
pair+=("vnet15" "vnet20")
pair+=("vnet11" "vnet23")
pair+=("vnet24" "vnet10")
pair_num=`expr ${#pair[*]} / 2`
br_offset=100

if [ $# -ne 1 ]; then
  echo "cmd <mode>" 1>&2
  echo "<mode>" 1>&2
  echo "a : add ovs" 1>&2
  echo "d : del ovs" 1>&2
  exit 1
fi

case $1 in
  "m")
    for i in `seq 1 ${pair_num}`
    do
      br_name=`printf "virbr%03d" $i`
      ovs-vsctl add-br ${br_name}
      sudo virsh attach-interface --type bridge --source ${br_name} --target ens$i --model virtio ${pair[ $(( 2*i - 2 ))]}
      sudo virsh attach-interface --type bridge --source ${br_name} --target ens$i --model virtio ${pair[ $(( 2*i - 1 ))]}
    done
    ;;
  "a")
    service openvswitch-switch restart

    for i in "${pair[@]}"
    do
      brctl delif virbr0 $i
    done

    for i in `seq 1 ${pair_num}`
    do
      br_name=`printf "br%03d" $((i + br_offset))`
      ovs-vsctl add-br ${br_name}
      ovs-vsctl add-port ${br_name} ${pair[ $(( 2*i - 2 )) ]}
      ovs-vsctl add-port ${br_name} ${pair[ $(( 2*i - 1 )) ]}
      ifconfig ${br_name} up

      ovs-ofctl del-flows ${br_name}
      ovs-ofctl add-flow ${br_name} action=flood
      ovs-ofctl show ${br_name}
    done
    ;;

  "d")
    for i in `seq 1 ${pair_num}`
    do
      br_name=`printf "br%03d" $((i + br_offset))`
      ovs-vsctl del-port ${br_name} ${pair[ $(( 2*i - 2 )) ]}
      ovs-vsctl del-port ${br_name} ${pair[ $(( 2*i - 1 )) ]}
      ovs-vsctl del-br ${br_name}
    done
    for i in "${pair[@]}"
    do
      brctl addif virbr0 $i
    done
    ;;
esac
