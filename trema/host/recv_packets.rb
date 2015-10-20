require 'socket'
require 'pio'
require "./myname"
require "./interface_statics"

include Pio
include Ipv4Name

name = ["/sensor", "/control"]

ETH_P_ALL = 0x0300

socket = Socket.open(Socket::AF_PACKET, Socket::SOCK_PACKET, ETH_P_ALL)

count = [0,0]
bytes = [0,0]
delay = 0

statics = IfStatics.new("eth0")
def info (c,b)
  puts "Receive /sensor Packets: #{c[0]} Bytes: #{b[0]}"
  puts "Receive /control Packets: #{c[1]} Bytes: #{b[1]}"
end
Signal.trap(:INT){
  puts "########## RESULT ##########"
  info(count,bytes)
  statics.show_recv_bytes
  puts "Delay: #{delay/count[1]} ms"
  exit(0)
}

while (true)
  msg = socket.recvfrom(1024*8)
  recv_time = Time.now.instance_eval { self.to_i * 1000 + (usec/1000) }
  raw_data = msg[0]

  next if raw_data.length < 47

  ethernet_header = Parser::EtherTypeParser.read(raw_data)
  case ethernet_header.ether_type
  when Parser::EthernetHeader::EtherType::IPV4

    packet = Parser::IPv4Packet.read(raw_data)
    case packet.ip_protocol
    when IPv4Header::ProtocolNumber::UDP
      udp_packet = Udp.read(raw_data)
      case udp_packet.ip_destination_address.to_s
      when Ipv4Name.get_ipaddr(name[0])
        count[0] += 1
        bytes[0] += udp_packet.udp_payload.size
      when Ipv4Name.get_ipaddr(name[1])
        send_time = udp_packet.udp_payload.match(/Time:(\w+?)\n/)[1].to_i
        delay += recv_time - send_time
        count[1] += 1
        bytes[1] += udp_packet.udp_payload.size
      when "255.255.255.255"
        if udp_packet.udp_payload == "FINISH"
          puts "#{Time.now},#{count[1]},#{bytes[1]},#{delay/count[1]}"
          break
        end
      end
    end

  end

end
