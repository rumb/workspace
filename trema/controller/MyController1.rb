#My Controlelr
$LOAD_PATH.unshift __dir__
require 'pio'
require 'myfib'

class MyController < Trema::Controller
  ARP_REPLY_MAC="fe:54:00:11:00:00"

  def start (_args)
    logger.info 'My controller started.'

    load "fib1.conf"
    @fib = {}
    @fib["0x110"] = MyFIB.new( $fib_110 )
    @fib["0x120"] = MyFIB.new( $fib_120 )
    @fib["0x130"] = MyFIB.new( $fib_130 )
  end

  def switch_ready (datapath_id)
    logger.info "#{datapath_id.to_hex} is connected"
    init_flow(datapath_id)
    set_default_flow(datapath_id)

    fib = @fib[datapath_id.to_hex]
    if fib.nil?
      return
    else
      fib.list.each { |entry|
        set_fib_entry(datapath_id, entry)
      }
    end
  end

  def packet_in (datapath_id, message)
    data = message.data
    case data
    when Arp::Request
      handle_arp_request(datapath_id, message)
    when Arp::Reply
    when Parser::IPv4Packet
      puts "Unexpected Ipv4packet message from #{datapath_id.to_hex} port #{message.in_port}"
      puts message.data
    else
      puts "Unexpected Packet_in message from #{datapath_id.to_hex} port #{message.in_port}"
      puts Parser::EtherTypeParser.read(message.raw_data)
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

  def set_fib_entry (datapath_id, entry)
    options = {
      ether_type: 2048,
      ip_protocol: 17,
      ip_destination_address: entry.ipaddr,
      transport_destination_port: 5002
    }
    send_flow_mod_add(datapath_id,
                      priority: entry.priority,
                      match: Match.new( options ),
                      actions: [SetEtherDestinationAddress.new(entry.hwaddr),
                        SendOutPort.new(entry.port)]
                     )

  end

  def set_default_flow ( datapath_id )
    options = {
      ether_type: 2048,
      ip_protocol: 17,
      transport_destination_port: 5002
    }
    send_flow_mod_add(datapath_id,
                      priority: 1,
                      match: Match.new( options ),
                     )
    send_flow_mod_add(datapath_id,
                      priority: 0,
                      match: Match.new({}),
                      actions: SendOutPort.new(:flood)
                     )
  end

end
