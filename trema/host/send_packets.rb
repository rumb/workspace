require "socket"
require 'randomext'
require "./icn_socket"
require "./interface_statics"

udps = UDPSocket.open()
udps.bind("0.0.0.0", 10000)
while true
  udps.recv(65535) == "START"
  break
end
udps.close
puts "########## START ##########"

data_name = ["/sensor", "/control"]
ratio = 100
interval = 4.0 # ms
packets = 1000

random = Random.new
icn_socket = IcnSocket.new()

## 1Kbyte text data
payload=""
for num in 1..1000 do
  i = num % 10
  payload+="#{i}"
end

count = [0,0]
bytes = [0,0]
statics = IfStatics.new("eth0")

starttime = Time.now()
for i in 1..packets do
  time = Time.now.instance_eval { self.to_i * 1000 + (usec/1000) }
  if random.rand(ratio) == 1
    count[1] += 1
    data = "Name:#{data_name[1]}\nTime:#{time}\nData:" + payload
    icn_socket.send(data_name[1], data)
  else
    count[0] += 1
    data = "Name:#{data_name[0]}\nTime:#{time}\nData:" + payload
    icn_socket.send(data_name[0], data)
  end
  next_send = random.exponential(interval).ceil
  sleep( next_send / 1000.0 )
end
endtime = Time.now

puts "########## RESULT ##########"
puts "Send /sensor Packets: #{count[0]}"
puts "Send /control Packets: #{count[1]}"
avg = ( count[0] + count[1] ) / ( endtime - starttime ) / 1000.0
puts "AVG: #{avg}"
statics.show_send_bytes
