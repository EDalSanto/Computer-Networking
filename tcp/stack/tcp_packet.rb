require "packetfu"

class TCPPacket
  attr_accessor :pkt

  # take ifconfig and tcp/ip config and dry up config for number of packets to be created with less effort
  def initialize(flags:, ip_daddr:, tcp_dst:, config:, src_port:)
    @pkt = PacketFu::TCPPacket.new(config: config)
    set_flags(flags)
    @pkt.ip_daddr = ip_daddr
    @pkt.tcp_dst = tcp_dst
    @pkt.tcp_sport = tcp_sports
    @pkt.recalc
  end

  def put_on_wire
    @pkt.to_w
  end
  private

  def set_flags(flags)
    flags.each { |flag| @pkt.tcp_flags.send("#{flag}=", 1) }
  end
end
