require "thor"
module ClusterElement
  class Serf
    desc "service","Build Systemd Service File"
    def service
    end
  end
  Cli.register Serf, 'serf','serf <command>','Serf Cluster Discovery'
end