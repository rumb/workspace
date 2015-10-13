#!/bin/bash
case $1 in
  "n")
    host_name="vm000"
    num=${host_name#vm}

    systemctl restart NetworkManager
    systemctl restart network
    nmcli connection delete eth0
    nmcli connection add type ethernet ifname eth0 con-name eth0
    nmcli connection modify eth0 ipv4.method manual ipv4.addresses 192.168.122.${num}/24
    nmcli c modify eth0 ipv4.ingore-auto-dns "yes"
    nmcli connection modify eth0 ipv4.gateway 192.168.122.1
    nmcli connection down eth0
    nmcli connection up eth0
    ;;
  "d")
    nmcli con del "Wired connection $2"
    nmcli c s
    ;;
  "o")
    if [ "$2" = "d" ]; then
      ovs-vsctl del-br ovs
      service openvswitch stop
    else
      service openvswitch restart
      ovs-vsctl add-br ovs
      ovs-vsctl set bridge ovs protocols=OpenFlow10 other-config:datapath-id=0000000000000abc
      ovs-vsctl set-controller ovs tcp:$2:6653 -- set controller ovs connection-mode=out-of-band
      ovs-vsctl set-fail-mode ovs secure
      ifconfig ovs up
      ovs-ofctl show ovs
    fi
    ovs-vsctl show
    ;;
  "f")
    if [ "$2" = "a" ]; then
      ovs-ofctl add-flow ovs in_port=1,action=output:2
      ovs-ofctl add-flow ovs in_port=2,action=output:1
    fi
    ovs-ofctl dump-flows ovs
    ;;
  "p")
    case $2 in
      "a")
        ovs-vsctl add-port ovs $3
        ;;
      "d")
        ovs-vsctl del-port ovs $3
        ;;
    esac
    ovs-ofctl show ovs
    nmcli d s
    ;;
  *)
    ;;
esac
