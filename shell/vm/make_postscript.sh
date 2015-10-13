#!/bin/bash

PWD=$(pwd)
DIR=$(cd $(dirname $0) && pwd)

usage(){
  echo "`basename $0` <base script> <output>"
}

if [ $# -lt 2 ]; then
  usage
  exit 1
fi

base_script=${PWD}/$1
output=${PWD}/$2

cp ${base_script} ${output}

match=`grep -c "# # # # #" ${output}`
while [ ${match} -ne 0 ]
do
  echo ${match}
  line=`grep -m 1 "# # # # #" ${output}`
  filename=`echo ${line} | sed -e "s/^# # # # # \(.*\) # # # # #$/\1/"`
  file=`cat ${DIR}/${filename}`

  head=`sed -e "/^# # # # # .* # # # # #$/,$ d" ${output}`
  foot=`sed -e "1,/^# # # # # .* # # # # #$/ d" ${output}`
  echo -e "${head}\n${file}\n${foot}" > ${output}

  match=`grep -c "# # # # #" ${output}`
done
