#!/bin/bash

case $1 in
  "s")
    sudo virsh domifstat $2 $3
    ;;
  "a")
    dev_name=`printf "vnet%03d" $3`
    mac=`printf "52:54:00:22:00:%02X" $3`
    sudo virsh attach-interface $2 --type bridge --source virbr0 --model virtio --target ${dev_name} --mac ${mac}
    ;;
  "d")
    mac=`printf "52:54:00:22:00:%02X" $3`
    sudo virsh detach-interface $2 bridge --mac ${mac}
    ;;
esac
