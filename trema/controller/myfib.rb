require "pio"

class MyFIB_Entry
  attr_reader :port
  attr_reader :hwaddr
  attr_reader :ipaddr
  attr_reader :masklen
  attr_reader :priority
  attr_reader :name

  def initialize options
    @port = options[ :port ]
    @hwaddr = Pio::Mac.new( options[ :hwaddr ] )
    addr = "#{options[ :ipaddr ]}/#{ options[ :masklen ]}"
    @ipaddr = Pio::IPv4Address.new( addr )
    @masklen = options[ :masklen ]
    @priority = options[ :priority ]
  end

  def has? mac
    mac == hwaddr
  end
end

class MyFIB
  attr_reader :list

  def initialize fib = []
    @list = []
    fib.each do | each |
      @list << MyFIB_Entry.new( each )
    end
  end

  def find_by_ipaddr( ipaddr )
    @list.find do | each |
      each.ipaddr == ipaddr
    end
  end

  def find_by_prefix( ipaddr )
    @list.find do | each |
      masklen = each.masklen
      each.ipaddr.mask( masklen ) == ipaddr.mask( masklen )
    end
  end

end
