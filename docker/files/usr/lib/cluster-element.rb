require "thor"
require "securerandom"
require "fileutils"
require "awesome_print"
require "httparty"
require "active_support/core_ext/string/strip"
require "ipaddress"
require "macaddr"

require "cluster-element/config"
require "cluster-element/cli"

begin
  require "cluster-element/network"
  require "cluster-element/machine"
  require "cluster-element/cetk"
  require "cluster-element/cmd"

  require "cluster-element/ssh"
  require "cluster-element/serf"
  require "cluster-element/etcd"
  require "cluster-element/fleet"
  require "cluster-element/flanneld"

  require "cluster-element/check"
rescue
  puts "Subcommands cannot be loaded, run 'cetk update' to fix this issue"
end
