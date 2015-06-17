module ClusterElement
  class Cli < Thor
    desc "update","Update Cluster Toolkit from Github"
    def update
      t=SecureRandom.hex(8)
      repo="https://github.com/steigr/cluster-element.git"
      puts `git clone #{repo} #{t}; rsync -rv #{t}/docker/files/ /; rm -rf #{t}`.strip
    end
    desc "cmd","Command Management"
    def cmd
      puts "Doing cmd stuff"
    end
    desc "serf","Serf Cluster Discovery"
    def serf
    end
    desc "etcd","Etcd Key-Value-Store"
    def etcd
    end
    desc "fleet","Fleet CoreOS Cluster Scheduler"
    def fleet
    end
    desc "start","Start Cluster Element Services"
    def start
    end
    desc "stop","Stop Cluster Element Services"
    def stop
    end
  end
end

