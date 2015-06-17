module ClusterElement
  class Fleet < Thor
    desc "cloudinit","Build Cloud-Init Drop-In"
    def cloudinit
    end
  end
  Cli.register Fleet, 'fleet','fleet [COMMAND]','Fleet Cluster Scheduler'
end