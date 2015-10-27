require "socket"
require 'randomext'
require "./icn_socket"
require "./interface_statics"

# stop buffering
STDOUT.sync = true

data_name = ["/sensor", "/control"]
ratio = 10
interval = 1.0 # ms
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
no = 0

while true
  udps = UDPSocket.open()
  udps.bind("0.0.0.0", 10000)
  while true
    if udps.recv(65535) == "START"
      break
    end
  end
  udps.close

  starttime = Time.now()
  for i in 1..packets do
    time = Time.now.instance_eval { self.to_i * 1000 + (usec/1000) }
    if random.rand(ratio) == 1
      data = "Name:#{data_name[1]}\nTime:#{time}\nData:" + payload
      count[1] += 1
      bytes[1] += data.bytesize
      icn_socket.send(data_name[1], data)
    else
      data = "Name:#{data_name[0]}\nTime:#{time}\nData:" + payload
      count[0] += 1
      bytes[0] += data.bytesize
      icn_socket.send(data_name[0], data)
    end
    next_send = random.exponential(interval).ceil
    sleep( next_send / 1000.0 )
  end
  endtime = Time.now

  avg = packets / ( endtime - starttime ) / 1000.0
  puts "#{no}, #{Time.now}, #{count[0]}, #{bytes[0]}, #{count[1]}, #{bytes[1]}, #{avg}, #{ratio}, #{interval}, #{packets}"


  count = [0,0]
  bytes = [0,0]
  no += 1

  interval *= 1.1
  if interval > 1000
    interval = 1.0
  end

end
