module ClusterElement
  class Network
    class << self
      private def method_missing method, *args, &block; instance.send method, *args, &block; end
      private def instance; @instance ||= self.new; end
    end
    PRIVATE_RE = /(^127\.)|(^192\.168\.)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^::1$)|(^[fF][cCdD])/
    def interfaces
      Socket.getifaddrs.collect{|iface| iface.name }.uniq
    end
    def getaddrs iface
      Socket.getifaddrs.select{|aiface|  aiface.name == iface }.collect{|aiface| aiface.addr }
    end
    def localhost
      "127.0.0.1"
    end
    def ipv4_addresses
      getaddrs(interfaces).select{|addr| addr.ipv4? }
    end
    def private_ipv4_addresses
      ipv4_addresses.select{|addr| addr.ipv4_private? }
    end
    def public_ipv4_addresses
      ipv4_addresses.select{|addr| not addr.ipv4_private? }
    end
    def private_ipv4
      private_ipv4_addresses.first
    end
    def public_ipv4
      public_ipv4_addresses.first
    end
  end
end