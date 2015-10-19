require 'socket'
require 'pio'

include Pio
ETH_P_ALL    = 0x0300

socket = Socket.open(Socket::AF_PACKET, Socket::SOCK_PACKET, ETH_P_ALL)

count = 0
bytes = 0

while (true)
  msg = socket.recvfrom(1024*8)
  raw_data = msg[0]

  ethernet_header = Parser::EtherTypeParser.read(raw_data)
  case ethernet_header.ether_type
  when Parser::EthernetHeader::EtherType::IPV4

    packet = Parser::IPv4Packet.read(raw_data)
    case packet.ip_protocol
    when IPv4Header::ProtocolNumber::UDP
      udp_packet = Udp.read(raw_data)
      puts count += 1
      puts bytes += udp_packet.udp_payload.size
    end
  end
end
