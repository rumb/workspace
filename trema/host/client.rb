#!/usr/bin/ruby
require "socket"
require 'openssl'

def get_hashed_bin_ip prefix
digest = OpenSSL::Digest.new("MD5", prefix)
i = digest.hexdigest.to_i(16) % (2 ** 16)
sprintf("%016b", i)
end

while true do
## Ask Content Name
p 'Content Name'
print '/'
name = gets.chop

prefixs = name.split("/")

ip_bin = get_hashed_bin_ip(prefixs[0]) + get_hashed_bin_ip(prefixs[1])
ip_octets = ip_bin.scan(/.{1,#{8}}/)

p ip_addr = ip_octets.flat_map{|i| i.to_i(2)}.join(".")

udp = UDPSocket.open()

sockaddr = Socket.pack_sockaddr_in(5002, ip_addr)
udp.send(name, 0, sockaddr)
udp.close

end
