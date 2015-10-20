#!/usr/bin/ruby
require 'socket'
require "./myname"

class IcnSocket
  include Ipv4Name

  Port = 5002

  def send ( name, data = "" )
    ipaddr = get_ipaddr( name )

    udp = UDPSocket.open()
    sockaddr = Socket.pack_sockaddr_in(Port, ipaddr)
    udp.send(data, 0, sockaddr)
    udp.close

  end

end
