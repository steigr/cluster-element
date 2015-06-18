require "installer"
require "fileutils"
Installer::Package::Apk.new("ruby-json").install
Installer::Package::Gem.new("toml-rb").install
Installer::Package::Gem.new("thor").install
require "toml"
require "thor"
require "json"

module ClusterElement
  class Config
    class Config < Thor
      desc "show","print the configuration"
      def show
        ap ClusterElement::Config.sub(ClusterElement::Config.dump.to_json
        # ap JSON.parse(ClusterElement::Config.sub(ClusterElement::Config.dump.to_json),symbolize_names: true)
      end
      desc "reset","(re)set config to defaults"
      def reset
        ClusterElement::Config.store ClusterElement::Config.reset
      end
    end
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
          gems: %w{toml-rb pry thor awesome_print httparty activesupport},
          apks: %w{git docker bash ruby-dev rsync ruby-json},
        },
        serf: {
          version: "0.6.4",
          discover: "%private_ipv4_net_hash",
          query_timeout: "5s",
          initial_tags: {
            coreos: "true",
          },
          event_handlers: %w{/opt/bin/serf-event},
          log_level: :debug,
          snapshot_path: "/var/lib/serf",
          leave_on_terminate: true,
          rejoin_after_leave: true,
        },
        etcd: {
          master: "/cetk/etcd/master",
          sizes: (0..4).collect{|x|x*2+1},
          ballot_size: 2,
          discovery: nil,
          peer_urls: %w{%private_ipv4:2380},
          client_urls: %w{%localhost:2379 %localhost:4001 %private_ipv4:2379}
        },
        fleet: {
          metadata: %w{cetk=true}
        },
        locksmith:{
          endpoint:"%etcd_self",
        },
        update:{
          reboot_strategy: "etcd-lock",
          server: "%etcd_self",
          group: "%cluster"
        },
        flannel: {
          etcd_endpoints: %w{%etcd_self},
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
          token: "etcd://%etcd_self/cetk/swarm/nodes",
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
          hostname: "registry.%cluster",
        },
        ssl: {
          ca: %w{ca.%cluster},
          certificates: %w{registry.%cluster interlock.%cluster}
        },
        zookeeper: {
          master: "/cetk/zookeeper/master",
          sizes: (0..4).collect{|x|x*2+1},
          data_dir: "/var/lib/zookeeper",
          expose: {
            etcd: "%localhost/cetk/zookeeper/nodes"
          }
        },
        dokku: {
          sizes: (1..3).to_a,
          authorized_keys: {
            file: "/home/core/.ssh/authorized_keys",
            etcd: "etcd://%localhost/cetk/dokku/ssh/authorized_keys"
          },
          nerve: {
            zk_hosts: "%localhost:2181",
            zk_path: "/cetk/dokku/ssh/services",
          }
        },
        router: {
          dokku: {
            image: "steigr/dokku",
            public: 22,
            synapse: {
              zk_hosts: "%localhost:2181",
              zk_path: "/cetk/dokku/ssh/services",
            }
          }
        },
        postgres: {
          image: "steigr/postgres",
          nerve: {
            zk_hosts: "%localhost:2181",
            zk_path: "/cetk/postgres/postgres/services",
          }
        },
        pgpool2: {
          image: "steigr/pgpool2",
          synapse: {
            zk_hosts: "%localhost:2181",
            zk_path: "/cetk/postgres/postgres/services",
          },
          nerve: {
            zk_hosts: "%localhost:2181",
            zk_path: "/cetk/pgpool2/pgpool2/services",
          },
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
    def sub str
      sub_strings = %w{%localhost %private_ipv4 %public_ipv4 %private_ipv4_net_hash %public_ipv4_net_hash %cluster %etcd_self}
      sub_strings.each do |sub_string|
        str = str.gsub(sub_string,var_of(sub_string)) rescue sub_string
      end
      str
    end
    def var_of var
      case var
      when "%localhost" then "127.0.0.1"
      when "%private_ipv4" then ClusterElement::Network.private_ipv4
      when "%public_ipv4"  then ClusterElement::Network.public_ipv4
      else var
      end
    end
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
      JSON.parse(sub(@config[method].to_json),symbolize_names:true) if @config.keys.include? method
    end
  end
end