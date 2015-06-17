require "thor"
require "securerandom"
require "fileutils"

module ClusterElement
  class Cli < Thor
    desc "cmd","Command Management"
    def update
      t=SecureRandom.hex(8)
      repo="https://github.com/steigr/cluster-element.git"
      puts `git clone #{repo} #{t}; rsync -r #{t}/docker/files /`.strip
    end
    def cmd
      puts "Doing cmd stuff"
    end
  end
end