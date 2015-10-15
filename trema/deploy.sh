#/bin/bash

DIR=$(cd $(dirname $0) && pwd)

CONTROLLER_DIR="${DIR}/controller"
HOST_DIR="${DIR}/host"

USERNAME="root"
PASSWORD="0000"

CONTROLLER="192.168.122.2"
SWITCH=("192.168.122.110")
SWITCH+=("192.168.122.120")
SWITCH+=("192.168.122.130")

HOST=("192.168.122.140")
HOST+=("192.168.122.150")
HOST+=("192.168.122.160")
HOST+=("192.168.122.170")
HOST+=("192.168.122.180")

expect -c "
set timeout -1
spawn ssh ${USERNAME}@${SWITCH}
expect \"(yes/no)?\" {
send \"yes\n\"
expect \"${USERNAME}@${SWITCH}'s password:\"
send \"${PASSWORD}\n\"
} \"${USERNAME}@${SWITCH}'s password:\" {
send \"${PASSWORD}\n\"
}
expect \"#\"
send \"ovs-vsctl add-port ovs eth4\n\"
send \"exit\n\"
interact
"

for i in "${SWITCH[@]}"
do
  expect -c "
  set timeout -1
  spawn ssh ${USERNAME}@$i
  expect \"(yes/no)?\" {
  send \"yes\n\"
  expect \"${USERNAME}@$i's password:\"
  send \"${PASSWORD}\n\"
} \"${USERNAME}@$i's password:\" {
send \"${PASSWORD}\n\"
}
expect \"#\"
send \"ovs-ofctl del-flows ovs\n\"
send \"ovs-ofctl add-flow ovs action=all\n\"
send \"exit\n\"
interact
"
done

expect -c "
set timeout -1
spawn scp -r ${CONTROLLER_DIR} ${USERNAME}@${CONTROLLER}:~/
expect \"(yes/no)?\" {
send \"yes\n\"
expect \"${USERNAME}@${CONTROLLER}'s password:\"
send \"${PASSWORD}\n\"
} \"${USERNAME}@${CONTROLLER}'s password:\" {
send \"${PASSWORD}\n\"
}
interact
"

for i in "${HOST[@]}"
do
  expect -c "
  set timeout -1
  spawn scp -r ${HOST_DIR} ${USERNAME}@${i}:~/
  expect \"(yes/no)?\" {
  send \"yes\n\"
  expect \"${USERNAME}@${i}'s password:\"
  send \"${PASSWORD}\n\"
} \"${USERNAME}@${i}'s password:\" {
send \"${PASSWORD}\n\"
}
interact
"
done

expect -c "
set timeout -1
spawn ssh -l ${USERNAME} ${SWITCH}
expect \"(yes/no)?\" {
send \"yes\n\"
expect \"${USERNAME}@${SWITCH}'s password:\"
send \"${PASSWORD}\n\"
} \"${USERNAME}@${SWITCH}'s password:\" {
send \"${PASSWORD}\n\"
}
expect \"#\"
send \"ovs-vsctl del-port ovs eth4\n\"
send \"exit\n\"
interact
"
