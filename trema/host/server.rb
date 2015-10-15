require 'socket'

ETH_P_ALL    = 0x0300
ETH_P_IP    = 0x800

class MacAddr
  def initialize(addr)
    @addr = addr
  end

  def to_s
    @addr.map {|v| v.to_s(16).rjust(2, '0')} .join(':')
  end
end

class IPAddr
  def initialize(addr)
    @addr = addr
  end

  def to_s
    @addr.join('.')
  end
end

class EtherHeader
  attr_reader :ether_dhost
  attr_reader :ether_shost
  attr_reader :ether_type

  def initialize(frame, ptr = 0)
    @frame = frame
    @ptr = ptr

    @ether_dhost = MacAddr.new uint8_arr(6)
    @ether_shost = MacAddr.new uint8_arr(6)
    @ether_type = uint16
  end

  def uint8_arr(size)
    r = @frame[@ptr...@ptr+size].split('').map {|c| c.ord}
    @ptr += size
    r
  end

  def uint16
    r = (@frame[@ptr].ord << 8) + @frame[@ptr+1].ord
    @ptr += 2
    r
  end


  def uint8                                                                                                                                                                [17/1947]
    r = @frame[@ptr].ord
    @ptr += 1
    r
  end

  def size
    @ptr
  end
end

class IPHeader < EtherHeader
  attr_reader :version
  attr_reader :ip_hl
  attr_reader :ip_tos
  attr_reader :ip_len
  attr_reader :ip_id
  attr_reader :ip_off
  attr_reader :ip_ttl
  attr_reader :ip_p
  attr_reader :ip_sum
  attr_reader :ip_src
  attr_reader :ip_dst

  def initialize(frame, ptr)
    @frame = frame
    @ptr = ptr

    @version = (@frame[@ptr].ord >> 4) & 0xF
    @ip_hl = @frame[@ptr].ord & 0xF
    @ptr +=1

    @ip_tos = uint8
    @ip_len = uint16
    @ip_id = uint16
    @ip_off = uint16
    @ip_ttl = uint8
    @ip_p = uint8
    @ip_sum = uint16
    @ip_src = IPAddr.new uint8_arr(4)
    @ip_dst = IPAddr.new uint8_arr(4)
  end
end

socket = Socket.open(Socket::AF_PACKET, Socket::SOCK_PACKET, ETH_P_ALL)


def proto(n)
  case n
  when 6
    'TCP'
  when 17
    'UDP'
  else
    'Other'
  end
end

while (true)
  mesg = socket.recvfrom(1024*8)
  frame = mesg[0]

  ether_header = EtherHeader.new(frame)
  puts "ETHER  dst: #{ether_header.ether_dhost} | src: #{ether_header.ether_shost} | type: 0x#{ether_header.ether_type.to_s(16)}"
  if (ether_header.ether_type == ETH_P_IP)
    ip_header = IPHeader.new(frame, ether_header.size)
    puts "IP  dst: #{ip_header.ip_dst} | src: #{ip_header.ip_src} | proto: #{proto(ip_header.ip_p)}"
  end
end

