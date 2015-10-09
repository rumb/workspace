#!/bin/bash
. ./src/mark.sh

ls -1 -F /etc | grep "release$\|version$" | while read line
do
  header_mark /etc/${line}
  cat /etc/${line}
done
