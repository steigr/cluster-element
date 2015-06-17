require "thor"
require "securerandom"
require "fileutils"

require "cluster-element/config"
require "cluster-element/cli"
begin
  require "cluster-element/serf"
  require "cluster-element/etcd"
  require "cluster-element/fleet"
rescue
  puts "Subcommands cannot be loaded, run 'cetk update' to fix this issue"
end
