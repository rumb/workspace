#!/usr/bin/ruby

class IfStatics

  def initialize (ifname)
    @interface = ifname
    @init_send_bytes = get_send_bytes
    @init_recv_bytes = get_recv_bytes
    @start = Time.now
  end

  def show_send_bytes
    byte = count_send_bytes
    interval = Time.now - @start
    byte_readable = byte.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse
    puts "Send " + byte_readable + " byte" + " ( " + interval.to_s + "s )"
  end

  def show_recv_bytes
    byte = count_recv_bytes
    interval = Time.now - @start
    byte_readable = byte.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse
    puts "Received " + byte_readable + " byte" + " ( " + interval.to_s + "s )"
  end

  def count_send_bytes
    get_send_bytes - @init_send_bytes
  end

  def count_recv_bytes
    get_recv_bytes - @init_recv_bytes
  end

  private

  def get_send_bytes
    count = `ip -s link show #{@interface} | tail -n 1`
    count.split(" ").at(0).to_i
  end

  def get_recv_bytes
    count = `ip -s link show #{@interface} | tail -n 3 | head -n 1`
    count.split(" ").at(0).to_i
  end

end
