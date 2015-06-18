require "thor"
require "securerandom"
require "fileutils"
require "awesome_print"
require "httparty"
require "active_support/core_ext/string/strip"
require "ipaddress"

require "cluster-element/config"
require "cluster-element/cli"

begin
  require "cluster-element/cmd"
  require "cluster-element/serf"
  require "cluster-element/etcd"
  require "cluster-element/fleet"
  require "cluster-element/network"
  require "cluster-element/check"
rescue
  puts "Subcommands cannot be loaded, run 'cetk update' to fix this issue"
end
