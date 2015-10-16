#!/usr/bin/ruby
require 'socket'
require 'openssl'
require "./myname"

name_bak = "/sample/test"

while true do
## Ask Content Name
print 'Enter content name : /'
name = gets.chop

if name.empty?
  name = name_bak
else
  name_bak = name
end

ipaddr = Ipv4Name.get_ipaddr(name)
udp = UDPSocket.open()

sockaddr = Socket.pack_sockaddr_in(5002, ipaddr)
udp.send(name, 0, sockaddr)
udp.close

puts "send content /#{name} ( #{ipaddr} )"

end
