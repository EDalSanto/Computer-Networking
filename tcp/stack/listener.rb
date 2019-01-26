require "packetfu"
require "./tcp"

class Listener
  def initialize(conn, config, ip_daddr)
    @conn = conn
    # setup capturing of packets
    # filter only tcp packets send from my ip or received from ip_daddr
    # filter syntax meaning http://biot.com/capstats/bpf.html
    @cap = PacketFu::Capture.new(
      iface: config[:iface],
      start: true,
      filter: "tcp and dst #{config[:ip_saddr]} and src #{ip_daddr}"
    )
  end

  # parse pkt and decide what to do next
  def listen
    @cap.stream.each do |pkt|
      state = @conn.handle(PacketFu::Packet.parse(pkt))
      # TODO: TCPClient should tell this listener to stop listening
      return if state == TCPClient::CLOSED_STATE
    end
  end
end
