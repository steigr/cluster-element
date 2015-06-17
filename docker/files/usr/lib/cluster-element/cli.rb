require "thor"
require "securerandom"
require "fileutils"

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
  end
end