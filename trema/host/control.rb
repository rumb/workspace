#!/usr/bin/ruby
require "socket"

packets = 1000
interval = 1.0
no = 0

system( "rm -rf /tmp/*" )
cmd = "trema run /root/controller/MyController1.rb"
pid = Process.spawn cmd, STDOUT=>STDOUT
puts "current process: #{pid}"

sleep(60)

while true
  puts "No.#{no} interval = #{interval}"

  udp = UDPSocket.open()
  sockaddr = Socket.pack_sockaddr_in(10000, "255.255.255.255")
  udp.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, 1)
  udp.send("START", 0, sockaddr)
  udp.close

  sleep( 1.1 * packets * interval / 1000.0 + 60)

  udp = UDPSocket.open()
  sockaddr = Socket.pack_sockaddr_in(10000, "255.255.255.255")
  udp.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, 1)
  udp.send("FINISH", 0, sockaddr)
  udp.close

  no += 1
  interval *= 1.1
  if interval > 1000
    interval = 1.0

    Process.kill 9, pid.to_i
    sleep (60)

    system( "rm -rf /tmp/*" )
    cmd = "trema run /root/controller/MyController2.rb"
    pid = Process.spawn cmd, STDOUT=>STDOUT
    puts "current process: #{pid}"

    sleep(60)
  end

  sleep(60)
end
