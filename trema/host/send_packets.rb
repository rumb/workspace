require "socket"
require "./icn_socket"
require "./interface_statics"

sensor_num = 30
loop_num = 300
interval = 0.01

icn_socket = IcnSocket.new()

## 1Kbyte text data
data=""
for num in 1..1000 do
  data+="w"
end

statics = IfStatics.new("eth0")
Signal.trap(:INT){
  statics.show_send_bytes
  exit(0)
}

for j in 1..loop_num do
  for i in 1..sensor_num do
    icn_socket.send("/sensor", data)
  end
  sleep(interval)
end

statics.show_send_bytes
