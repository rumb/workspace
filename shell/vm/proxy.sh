#!/bin/bash

MY_PROXY_URL="http://hoge.huga:8080/"

export HTTP_PROXY=$MY_PROXY_URL
export HTTPS_PROXY=$MY_PROXY_URL
export FTP_PROXY=$MY_PROXY_URL
export http_proxy=$MY_PROXY_URL
export https_proxy=$MY_PROXY_URL
export ftp_proxy=$MY_PROXY_URL

# /etc/resolv.conf
{
  echo "##### created by /root/proxy.sh  #####"
  echo "nameserver 192.168.0.1"
  echo ""
  echo "##### note"
  echo "# this file can be overwritten by DHCP"
} > /etc/resolv.conf
