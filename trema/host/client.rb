#!/usr/bin/ruby
require 'socket'
require "./myname"
require "./icn_socket"

name_bak = "/sample/test"

icn_socket = IcnSocket.new()

while true do
  ## Ask Content Name
  print 'Enter content name : /'
  name = gets.chop

  if name.empty?
    name = name_bak
  else
    name_bak = name
  end

  puts( icn_socket.send(name) )

  ipaddr = Ipv4Name.get_ipaddr(name)
  p "send content /#{name} ( #{ipaddr} )"
end
