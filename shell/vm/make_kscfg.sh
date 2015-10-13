#!/bin/bash

PWD=$(pwd)
DIR=$(cd $(dirname $0) && pwd)

usage(){
  echo "`basename $0` <hostname> <ks file> {<postscript file>}"
}

if [ $# -lt 2 ]; then
  usage
  exit 1
fi

ks_template=${DIR}/"template.ks.cfg"
hostname=$1
ks_file=${PWD}/$2

cp ${ks_template} ${ks_file}

sed -i -e "s/localhost/${hostname}/g" ${ks_file}

if [ $# -eq 3 ]; then
postscript=${PWD}/$3
sed -i -e '$d' ${ks_file}
echo "########## ${postscript} begin" >> ${ks_file}
cat ${postscript} >> ${ks_file}
echo "########## ${postscript} end" >> ${ks_file}
echo '%end' >> ${ks_file}
fi
