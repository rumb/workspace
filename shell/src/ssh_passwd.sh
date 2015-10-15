#!/bin/bash
if [ -n "$PASSWORD" ]; then
  cat <<< "$PASSWORD"
  exit 0
fi
read PASSWORD
export SSH_ASKPASS=$0
export PASSWORD
export DISPLAY=dummy:0
exec setsid "$@"

##### usage
# $echo password | ./ssh_pass.sh ssh user@example.com "ls -a"

##### reference
# http://yyatsuo.com/?p=959
