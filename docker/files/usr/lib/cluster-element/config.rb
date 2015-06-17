require "installer"
require "fileutils"
Installer::Package::Gem.new("toml-rb").install
require "toml"

module ClusterElement
  class Config
    class << self
      private
      def method_missing method, *args, &block
        instance.send method, *args, &block
      end
      def instance
        @instance ||= self.new
      end
    end
    def initialize
      @config ||= load 
      @config ||= reset
    end
    def reset
      {
        packages: {
          gems: %w{toml-rb pry thor awesome_print},
          apks: %w{git docker bash ruby-dev rsync},
        },
        serf: {
          cluster: "cluster",
          query_timeout: "5s",
          initial_tags: {
            coreos: "true",
          }
        },
        etcd: {
          discovery: nil,
          peer_urls: %w{%private_ipv4:2380},
          client_urls: %w{%localhost:2379 %localhost:4001 %private_ipv4:2379}
        },
        fleet: {
          metadata: %w{cetk=true}
        },
        locksmith:{
          endpoint:"%self",
        },
        update:{
          reboot_strategy: "etcd-lock",
          server: "%self",
          group: "%serf"
        },
        flannel: {
          etcd_endpoints: %w{%self},
          etcd_prefix: "/cetk/flannel/network/config",
          interface: "%private_ipv4",
          network: "10.10.0.0/16",
          subnet_len: 24,
          subnet_min: nil,
          subnet_max: nil,
          backend: {
            type: :vxlan,
            vni: 1,
          }
        },
        ssh: {
          port: 2220,
        },
        docker: {
          tcp: 4375,
        },
        bee: {
          image: "swarm",
          announce: "%private_ipv4:4375"
        },
        swarm: {
          token: "etcd://%self/cetk/swarm/nodes",
          image: "swarm",
          port: 2375
        },
        interlock:{
          swarm: "%localhost:2375",
          plugin: "nginx",
          ports: %w{%public_ipv4:80 %public_ipv4:443},
          ssl: {
            dir: "/ssl"
          }
        },
        registry: {
          image: "registry:2",
          hostname: "registry.%serf",
        },
        ssl: {
          ca: %w{ca.%serf},
          certificates: %w{registry.%serf interlock.%serf}
        },
        zookeeper: {
          data_dir: "/var/lib/zookeeper",
          expose: {
            etcd: "%localhost/cetk/zookeeper/nodes"
          }
        },
        dokku: {
          authorized_keys: {
            file: "/home/core/.ssh/authorized_keys",
            etcd: "etcd://%localhost/cetk/dokku/ssh/authorized_keys"
          }
        },
        router: {
          dokku: {
            public: 22
          }
        }
      }
    end
    def store config=nil
      config ||= @config
      FileUtils.mkdir_p(File.basename(cfg_file))
      File.write(cfg_file,TOML.parse(config))
    end
    def load
      TOML.load_file(cfg_file,symbolize_keys: true) if File.exists?(cfg_file)
    end
    def dump
      @config
    end
    private
    def cfg_file
      "/etc/cetk/config.tml"
    end
    def gems
      @config[:packages][:gems].collect{|name| Installer::Package::Gem.new name}
    end
    def apks
      @config[:packages][:apks].collect{|name| Installer::Package::Apk.new name}
    end
    def method_missing method, *args, &block
      @config[method] if @config.keys.include? method
    end
  end
end