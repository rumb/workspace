require 'openssl'
require "pio"

module Ipv4Name
  ADDR_BIT = 32
  HASH_BIT = 16
  MAX_PREFIX = 2

  def get_ipaddr ( name_str )
    prefixs = name_str.gsub(/^\//,"").split("/")
    masklen = get_masklen(name_str)

    bin = prefixs[0,MAX_PREFIX].map{|p| get_hash(p)}.join
    bin += "0" * ( ADDR_BIT - masklen )

    octets = bin.scan(/.{1,#{8}}/)
    ip_addr = octets.map{|i| i.to_i(2)}.join(".")

    return addr = "#{ip_addr}/#{masklen}"
  end

  def get_masklen ( name_str )
    prefixs = name_str.gsub(/^\//,"").split("/")
    prefixlen = prefixs.size
    return prefixlen > MAX_PREFIX ? ADDR_BIT : prefixlen * HASH_BIT
  end

  private

  def get_hash ( prefix )
    digest = OpenSSL::Digest.new("MD5", prefix)
    i = digest.hexdigest.to_i(16) % (2 ** HASH_BIT)
    sprintf("%016b", i)
  end

end

class MyName
  include Ipv4Name
  attr_reader :name

  def initialize ( name_str )
    @name = name_str
  end

  def prefixlen
    return get_prefixlen( @name )
  end

  def ipaddr
    return get_ipaddr( @name )
  end

  def masklen
    return get_masklen( @name )
  end

  private

  def get_prefixlen ( name_str )
    prefixs = name_str.gsub(/^\//,"").split("/")
    return prefixs.size
  end

end

