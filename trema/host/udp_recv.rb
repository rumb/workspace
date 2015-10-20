#!/usr/bin/ruby

require "socket"

udps = UDPSocket.open()

udps.bind("0.0.0.0", 10000)

p udps.recv(65535)

udps.close
