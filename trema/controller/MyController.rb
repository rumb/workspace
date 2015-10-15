#my controlelr
$LOAD_PATH.unshift __dir__
require 'pio/open_flow10/match'
require 'pio/parser'

require 'myfib'

class MyController < Trema::Controller
  ARP_REPLY_MAC="11:22:33:44:55:66"

  def start (_args)
    logger.info 'My controller started.'

    load "fib.conf"
    @fib = {}
    @fib["0x110"] = MyFIB.new( $fib_110 )
    @fib["0x120"] = MyFIB.new( $fib_120 )
    @fib["0x130"] = MyFIB.new( $fib_130 )
  end

  def switch_ready (datapath_id)

    logger.info "#{datapath_id.to_hex} is connected"
    init_flow(datapath_id)

    fib = @fib.fetch(datapath_id.to_hex)
    fib.list.each { |entry|
      p entry.ipaddr
      options = {
        ether_type: 2048,
        ip_protocol: 17,
        ip_destination_address: entry.ipaddr,
        transport_destination_port: 5002
      }
      send_flow_mod_add(datapath_id,
                        match: Match.new( options ),
                        actions: [SetEtherDestinationAddress.new(entry.hwaddr),
                          SendOutPort.new(entry.port)]
                       )
    }
  end

  def packet_in (datapath_id, message)
    data = message.data
    case data
    when Arp::Request
      handle_arp_request(datapath_id, message)
    when Arp::Reply
    when Pio::Parser::IPv4Packet
      fib = @fib.fetch(datapath_id.to_hex)
      next_hop = fib.find_by_prefix( data.ip_destination_address )
      send_packet_out(datapath_id,
                      packet_in: message,
                      actions: [SetEtherDestinationAddress.new(next_hop.hwaddr),
                        SendOutPort.new(next_hop.port)]
                     )
                     logger.info "#{datapath_id.to_hex} send packet"
    else
      puts "Unexpected Packet_in message"
      puts message
      puts ""
    end
  end

  private

  def init_flow (datapath_id)
    send_flow_mod_delete(datapath_id, match: Match.new({}))
  end

  def handle_arp_request (datapath_id, arp_request)
    data = arp_request.data
    port = arp_request.in_port
    arp_reply = Arp::Reply.new(
      destination_mac: data.source_mac,
      source_mac: ARP_REPLY_MAC,
      sender_protocol_address: data.target_protocol_address,
      target_protocol_address: data.sender_protocol_address
    )
    send_packet_out(datapath_id,
                    raw_data: arp_reply.to_binary,
                    actions: SendOutPort.new(port)
                   )
  end

  def flow_mod (message, port_no)
    send_flow_mod_add(message.datapath_id,
                      match: ExactMatch.new(message),
                      actions: SendOutPort.new(port_no)
                     )
  end

end
