#!/bin/bash
. ./src/mark.sh

ls -1 -F /etc | grep "release$\|version$" | while read line
do
  header_mark /etc/${line}
  cat /etc/${line}
done

###### reference
# http://blog.layer8.sh/ja/2011/12/23/linux%e3%82%b5%e3%83%bc%e3%83%90%e3%83%bc%e3%81%ae%e3%83%90%e3%83%bc%e3%82%b8%e3%83%a7%e3%83%b3%e3%82%84os%e5%90%8d%e3%82%92%e8%aa%bf%e3%81%b9%e3%82%8b%e3%82%b3%e3%83%9e%e3%83%b3%e3%83%89linux/
