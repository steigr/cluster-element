module ClusterElement
  class Serf < Thor
    desc "service","Build Systemd Service File"
    def service
    end
  end
  Cli.register Serf, 'serf','serf [COMMAND]','Serf Cluster Discovery'
end