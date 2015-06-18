module ClusterElement
  class Cli < Thor
    desc "update","Update Cluster Toolkit from Github"
    def update
      t=SecureRandom.hex(8)
      repo="https://github.com/steigr/cluster-element.git"
      puts `git clone #{repo} #{t}; rsync -rv #{t}/docker/files/ /; rm -rf #{t}`.strip
    end
    desc "info","Toolkit Info"
    def info
      puts "Cluster Element toolkit, Version 0.0.1b1"
    end
  end
end

ClusterElement::Cli.register ClusterElement::Config::Config, "config","config [COMMAND]","Toolkit Configuration"