#!/usr/bin/ruby

require "socket"

count = `ip -s link show eth0 | tail -n 3 | head -n 1`
a = count.split(" ").at(0).to_i

udps = UDPSocket.open()
udps.bind("0.0.0.0", 10000)

byte = 0

Signal.trap(:INT){
  p byte.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse + "byte"

  count = `ip -s link show eth0 | tail -n 3 | head -n 1`
  b = count.split(" ").at(0).to_i
  p (b-a).to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse + "byte"

  udps.close
  exit(0)
}

