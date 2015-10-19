#!/bin/bash

function yes_or_no_select(){
PS3="Answer? "
while true;do
  echo "Type 1 or 2."
  select answer in yes no;do
    case $answer in
      yes)
        echo -e "tyeped yes.\n"
        return 0
        ;;
      no)
        echo -e "tyeped no.\n"
        return 1
        ;;
      *)
        echo -e "cannot understand your answer.\n"
        ;;
    esac
  done
done
}

if [ $# -ne 2 ]; then
  echo "cmd <mode> <vm number>" 1>&2
  echo "<mode>" 1>&2
  echo "c : create vm" 1>&2
  echo "d : destory vm" 1>&2
  exit 1
fi
if [ "$UID" -ne 0 ];then
  echo "non-root user!"
  exit 1
fi

DIR=`dirname ${0}`

os_image="CentOS-7-x86_64-Minimal-1503-01.iso"

vm_num=$2
vm_name=`printf "vm%03d" ${vm_num}`
vm_dev=`printf "vmdev%03d" ${vm_num}`
mac=`printf "52:54:00:11:00:%02X" ${vm_num}`
echo ${vm_name}; echo ${mac}

image_dir="/home/sunaga/workspace/images"
image="${image_dir}/${vm_name}.img"
disk_size=10 ## Giga byte

case $1 in
  "d")
    if yes_or_no_select ; then
      virsh destroy ${vm_name}
      virsh undefine ${vm_name}
      rm -f ${image}
    fi
    ;;
  "c")
    ks_name=`printf "vm%03d.ks.cfg" ${vm_num}`
    ks_cfg="${DIR}/ks_cfg/${ks_name}"
    if [ ! -d ${DIR}/ks_cfg ]; then
      mkdir ${DIR}/ks_cfg
    fi
    if [ "${vm_num}" != "0" ] ; then
      sed "s/vm000/${vm_name}/g" centos7.ks.cfg > ${ks_cfg}
    fi

    if [ ! -e ${image} ] ; then
      sudo qemu-img create -f qcow2 ${image} ${disk_size}G
      sudo virt-install --connect qemu:///system \
        --name ${vm_name} \
        --ram 512 \
        --vcpus 1 \
        --location ${os_image} \
        --os-type linux \
        --disk path=${image},size=${disk_size},format=qcow2 \
        --network bridge=virbr0,model=e1000,mac=${mac} \
        --graphics none\
        --serial pty \
        --console pty \
        --hvm \
        --virt-type kvm \
        --arch x86_64 \
        --initrd-inject ${ks_cfg} \
        --extra-args "ks=file:/${ks_name} console=tty0 console=ttyS0,115200"
    fi
    ;;
esac
