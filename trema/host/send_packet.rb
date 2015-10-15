require "socket"

count = `ip -s link show eth0 | tail -n 1`
a = count.split(" ").at(0).to_i

byte = 0

udp = UDPSocket.open()
sockaddr = Socket.pack_sockaddr_in(10000, "192.168.122.20")

Signal.trap(:INT){
  p byte.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse + "byte"
  udp.close
  exit(0)
}

## 1Kbyte text data
text=""
for num in 1..1000 do
text+="a"
end

starttime = Time.now

for j in 1..300 do
for i in 1..30 do
udp.send(text, 0, sockaddr)
byte += text.bytesize
end
sleep(0.01)
end
endtime = Time.now


p byte.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse + "byte"
bps = byte/(endtime-starttime).to_f
p bps.to_s + "bps"

count = `ip -s link show eth0 | tail -n 1`
b = count.split(" ").at(0).to_i

p (b-a).to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse + "byte"

udp.close
