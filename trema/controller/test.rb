#my controlelr
$LOAD_PATH.unshift __dir__
require "fdb"
require 'pio/open_flow10/match'
require 'pio/parser'

class MyController < Trema::Controller
  ARP_REPLY_MAC="11:22:33:44:55:66"
  timer_event :age_fdbs, interval: 5.sec

  def start (_args)
    logger.info 'My controller started.'
    @switches =[]
    @fdbs ={}
  end

  def switch_ready (datapath_id)
    logger.info "Hello #{datapath_id.to_hex}!"
    @switches << datapath_id
    @fdbs[datapath_id] = FDB.new
    init_flow(datapath_id)
  end

  def packet_in (datapath_id, message)
    data = message.data
    case data
    when Pio::Arp::Request
      send_arp_reply(datapath_id, message)
    when Pio::Parser::IPv4Packet
      p data.ip_destination_address
      # learning_mac(datapath_id, message)
      if message.destination_mac.to_s == ARP_REPLY_MAC
      end
      if data.ip_destination_address.to_s == "38.97.38.97"
        options = {
          in_port: message.in_port,
          ether_source_address: message.source_mac,
          ether_destination_address: message.destination_mac,
          vlan_vid: data.vlan_vid,
          vlan_priority: data.vlan_pcp,
          ether_type: data.ether_type,
          ip_tos: data.ip_type_of_service,
          ip_protocol: data.ip_protocol,
          ip_source_address: data.ip_source_address,
          ip_destination_address: data.ip_destination_address,
          transport_source_port: 0,
          transport_destination_port: 5002
        }
        send_packet_out(datapath_id,
                        packet_in: message,
                        actions: [SetEtherDestinationAddress.new("52:54:00:11:00:14"),
                                  SendOutPort.new(2)]
                       )
        send_flow_mod_add(message.datapath_id,
                          match: Pio::Match.new( options ),
                          actions: [SetEtherDestinationAddress.new("52:54:00:11:00:14"),
                                    SendOutPort.new(2)]
                         )
      end
      if data.ip_destination_address.to_s == "87.143.87.143"
        options = {
          in_port: message.in_port,
          ether_source_address: message.source_mac,
          ether_destination_address: message.destination_mac,
          vlan_vid: data.vlan_vid,
          vlan_priority: data.vlan_pcp,
          ether_type: data.ether_type,
          ip_tos: data.ip_type_of_service,
          ip_protocol: data.ip_protocol,
          ip_source_address: data.ip_source_address,
          ip_destination_address: data.ip_destination_address,
          transport_source_port: 0,
          transport_destination_port: 5002
        }
        send_packet_out(datapath_id,
                        packet_in: message,
                        actions: [SetEtherDestinationAddress.new("52:54:00:11:00:3C"),
                                  SendOutPort.new(3)]
                       )
        send_flow_mod_add(message.datapath_id,
                          match: Match.new( options ),
                          actions: [SetEtherDestinationAddress.new("52:54:00:11:00:3C"),
                                    SendOutPort.new(3)]
                         )
      end
    else
      p "else da yo"
    end
  end

  def age_fdbs
    @fdbs.each_value(&:show)
    #@fdbs.each_value(&:age)
  end

  private

  ## スイッチのフローの初期化(全フローの消去)
  def init_flow (datapath_id)
    send_flow_mod_delete(datapath_id, match: Match.new())
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

  ###### 使っていない
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
