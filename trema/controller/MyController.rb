#my controlelr
$LOAD_PATH.unshift __dir__
require 'pio/open_flow10/match'
require 'pio/parser'

require "arp-table.rb"
require "routing-table.rb"

class MyController < Trema::Controller
  ARP_REPLY_MAC="11:22:33:44:55:66"

  def start (_args)
    logger.info 'My controller started.'
    @arp_table = ARPTable.new
    @routing_table = RoutingTable.new()
  end

  def switch_ready (datapath_id)
    logger.info "Hello #{datapath_id.to_hex}!"
    @switche = datapath_id
    init_flow(datapath_id)
  end

  def packet_in (datapath_id, message)
    p message
    p message.body
    p message.header
    data = message.data
    case data
    when Arp::Request
      @arp_table.update(message.in_port,
                        message.source_mac,
                        message.data.sender_protocol_address)
      send_arp_reply(datapath_id, message)
    when Arp::Reply
    when Pio::Parser::IPv4Packet
      # learning_mac(datapath_id, message)
      if message.destination_mac.to_s == ARP_REPLY_MAC
        # send_packet_out(datapath_id,
        #                 packet_in: message,
        #                 actions: [SetEtherDestinationAddress.new("52:54:00:11:00:14"),
        #                           SendOutPort.new(:flood)]

        #                )
      else
        p message
      end
    end
  end

  def age_fdbs
    @fdbs.each_value(&:show)
    #@fdbs.each_value(&:age)
  end

  private

  ## スイッチのフローの初期化(全フローの消去)
  def init_flow (datapath_id)
    send_flow_mod_delete(datapath_id, match: Match.new({}))
  end

  def send_arp_reply (datapath_id, message)
    data = message.data
    port = message.in_port
    arp_reply = Arp::Reply.new(destination_mac: data.source_mac,
                               source_mac: ARP_REPLY_MAC,
                               sender_protocol_address: data.target_protocol_address,
                               target_protocol_address: data.sender_protocol_address
                              )
    send_packet_out(datapath_id,
                    raw_data: arp_reply.to_binary,
                    actions: SendOutPort.new(port)
                   )
  end

  def learning_mac(datapath_id, message)
    @fdbs.fetch(datapath_id).learn(message.source_mac, message.in_port)
    port_no = @fdbs.fetch(datapath_id).lookup(message.destination_mac)
    flow_mod(message, port_no) if port_no
    packet_out(message, port_no || :flood)
  end

  def flow_mod (message, port_no)
    send_flow_mod_add(message.datapath_id,
                      match: ExactMatch.new(message),
                      actions: SendOutPort.new(port_no)
                     )
  end

  def packet_out(message, port_no)
    send_packet_out(
      message.datapath_id,
      packet_in: message,
      actions: SendOutPort.new(port_no)
    )

  end
end
