module ClusterElement
  class Network
    class << self
      private def method_missing method, *args, &block; instance.send method, *args, &block; end
      private def instance; @instance ||= self.new; end
    end
    def interfaces
      Socket.getifaddrs.collect{|iface| iface.name }.uniq
    end
    def getaddrs *ifaces
      Socket.getifaddrs.select{|iface| ifaces.flatten.include? iface.name }.collect{|iface| iface.addr }
    end
    def getiface addr
      Socket.getifaddrs.select{|aiface| aiface.addr.ip_address == addr rescue false }.first
    end
    def localhost
      "127.0.0.1"
    end
    def ipv4_addresses
      getaddrs(interfaces).select{|addr| addr.ipv4? }
    end
    def private_ipv4_addresses
      ipv4_addresses.select{|addr| addr.ipv4_private? }.map{|addr| addr.ip_address }
    end
    def public_ipv4_addresses
      ipv4_addresses.select{|addr| not ( addr.ipv4_private? or addr.ipv4_loopback? )}.map{|addr| addr.ip_address }
    end
    def private_ipv4
      private_ipv4_addresses.first
    end
    def public_ipv4
      public_ipv4_addresses.first
    end
    def net addr
      "#{addr.network.address}/#{addr.network.prefix}"
    end
    def public_ipv4_net
      net(IPAddress("#{public_ipv4}/#{getiface(public_ipv4).netmask.ip_address}"))
    end
    def private_ipv4_net
      net(IPAddress("#{private_ipv4}/#{getiface(private_ipv4).netmask.ip_address}"))
    end
  end
end