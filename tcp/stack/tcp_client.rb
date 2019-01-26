require "packetfu"
require "uri"
require "resolv"
require "pry"

class Listener
  def initialize(conn, config, dst_ip)
    @conn = conn
    # setup capturing of packets
    @cap = PacketFu::Capture.new(
      iface: config[:iface],
      start: true,
      filter: "tcp and dst #{config[:ip_saddr]} and src #{dst_ip}"
      # filter only tcp packets send from my ip or received from dst_ip
      # filter syntax meaning http://biot.com/capstats/bpf.html
    )
  end

  def listen
    @cap.stream.each do |pkt|

      #state = @conn.handle(pkt)
      # parse pkt and decide what to do next
      puts pkt
    end
  end
end

class TCPClient
  attr_accessor :state, :dst_ip, :dst_port, :src_port, :server_ack_seq, :client_next_seq, :recv_buffer

  # TCP Finite State Machine
  # http://www.tcpipguide.com/free/t_TCPOperationalOverviewandtheTCPFiniteStateMachineF-2.htm
  CLOSED_STATE      = "CLOSED".freeze
  SYN_SENT_STATE    = "SYN-SENT".freeze
  ESTABLISHED_STATE = "ESTABLISHED".freeze
  FIN_WAIT_1_STATE  = "FIN-WAIT-1".freeze
  LAST_ACK_STATE    = "LAST-ACK".freeze

  def initialize(url:)
    @uri = URI.parse(url)
    @host = @uri.host

    @src_port = Random.rand(12345..50000)
    @dst_ip = Resolv.getaddress(@host)
    @dst_port = @uri.port
    @state = CLOSED_STATE # starts in closed state

    @config = PacketFu::Utils.whoami?
    # add fake ip address to config?

    # store what server has acked
    @server_ack_seq = 0
    # store what client expects next
    @client_next_seq = 0
    @recv_buffer = ""

    # setup lisenter
    @listener = Listener.new(self, @config, @dst_ip)
    @listener_thread = Thread.new { @listener.listen }

    puts "Destination IP #{@dst_ip}"
  end

  def connect
    perform_handshake
  end

  def handshake
    # send syn packet
    send(syn_packet)
    # receive synack packet
    # send ack
    send(ack_packet)
  end

  def send
    packet.to_w
  end

  def recv(buffer_size)

  end

  private

  def syn_packet
    TCPPacket.new(flags: ["syn"], ip_daddr: @ip_daddr, tcp_dst: @tcp_dst)
  end

  def ack_packet
    TCPPacket.new(flags: ["awk", "psh"], ip_daddr: @ip_daddr, tcp_dst: @tcp_dst)
  end
end

class TCPPacket
  def initialize(flags:, ip_daddr:, tcp_dst:)
    @pkt = PacketFu::TCPPacket.new(config: CONFIG)
    set_flags(flags)
    @pkt.ip_daddr = ip_daddr
    @pkt.tcp_dst = tcp_dst
    @pkt.recalc
  end

  private

  def set_flags(flags)
    flags.each { |flag| @pkt.send("#{flag}=", 1) }
  end
end
