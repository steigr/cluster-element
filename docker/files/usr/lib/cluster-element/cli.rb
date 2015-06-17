require "thor"

module ClusterElement
  class Cli < Thor
    desc "cmd","Command Management"
    def cmd
      puts "Doing cmd stuff"
    end
  end
end