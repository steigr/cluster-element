module ClusterElement
  class Etcd
    class Etcd < Thor
      desc "dropin","Build Cloud-Init Drop-In"
      method_option :output, type: :string
      def dropin
        ClusterElement::Etcd.dropin output:options[:output]
      end
      desc "discover","Print Cluster Discover Token"
      def discover
        ClusterElement::Etcd.token
      end
    end
    Cli.register Etcd, 'etcd','etcd [COMMAND]','Etcd DKV-Store'
    class << self
      private def method_missing method, *args, &block; instance.send method, *args, &block; end
      private def instance; @instance ||= self.new; end
    end
    def private_ipv4
      ClusterElement::Network.private_ipv4
    end
    def etcd_peer_url
      "http://#{private_ipv4}:2379"
    end
    def dropin output:nil
      dropin = <<-EO_ETCD_DROPIN.strip_heredoc
        [Service]
        Environment="ETCD_NAME=#{Socket.gethostname}"
        Environment="ETCD_DISCOVERY=#{token}"
        Environment="ETCD_ADVERTISE_CLIENT_URLS=http://#{private_ipv4}:2379"
        Environment="ETCD_INITIAL_ADVERTISE_PEER_URLS=http://#{private_ipv4}:2380"
        Environment="ETCD_LISTEN_CLIENT_URLS=#{etcd_peer_url},http://127.0.0.1:2379,http://#{private_ipv4}:4001,http://127.0.0.1:4001"
        Environment="ETCD_LISTEN_PEERS_URLS=http://#{private_ipv4}:2380,http://127.0.0.1:2380,http://127.0.0.1:7001"
      EO_ETCD_DROPIN
      if output
        FileUtils.mkdir_p File.dirname output
        File.write output, dropin
      else
        puts dropin
      end
    end
    def token
      @token ||= cluster_token
      @token ||= local_token
      @token ||= create_token
    end
    def cluster_token
      response = JSON.parse(`/opt/bin/serf query -format=json etcd-discover-token`,symbolize_names:true)
      return if response[:Responses].empty?
      response[:Responses].to_a.first.last
    end
    def local_token
      token_file = "/run/etcd/discover-token"
      File.read token_file if File.exists? token_file
    end
    def create_token
      HTTParty.get "https://discovery.etcd.io/new?size=1"
    end
    def dropin_file
      "/run/systemd/system/etcd2.service.d/20-cloudinit.conf"
    end
  end
end