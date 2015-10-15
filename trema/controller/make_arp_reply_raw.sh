require "pio"

filename="arp_reply.raw"

arp_reply = Pio::ARP::Reply.new(
                                 source_mac: "11:11:11:11:11:11",
                                 destination_mac: "22:22:22:22:22:22",
                                 sender_protocol_address: "192.168.0.1",
                                 target_protocol_address: "192.168.0.2")

packet_in = Pio::OpenFlow10::PacketIn.new(
                                         in_port: 1,
                                         raw_data: arp_reply.to_binary
                                         )

File.open(filename, 'w+b') do |file|
  file.write(bin)
end
