require "thor"

module ClusterElement
  class Etcd < Thor
    desc "cloudinit","Build Cloud-Init Drop-In"
    def cloudinit
    end
  end
  Cli.register Etcd, 'etcd','etcd <command>','Etcd DKV-Store'
end