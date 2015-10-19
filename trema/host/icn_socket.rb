#!/usr/bin/ruby
require 'socket'
require "./myname"

class IcnSocket
  include Ipv4Name

  Port = 5002

  def send ( name, data = "" )
    ipaddr = get_ipaddr( name )
    data += ipaddr
    payload = "Name: " + name + "\n"
    payload += "Data: "+ data

    udp = UDPSocket.open()
    sockaddr = Socket.pack_sockaddr_in(Port, ipaddr)
    udp.send(payload, 0, sockaddr)
    udp.close

    payload
  end

end
