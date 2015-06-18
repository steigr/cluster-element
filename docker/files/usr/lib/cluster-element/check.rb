module ClusterElement
  class Check < Thor
    ClusterElement::Cli.register self, "check","check","System Checking"
    desc "health","System Health Check"
    def health
      # TODO Implement System Health Checks
      exit 0
    end
    desc "state","Print Detected System State"
    def state
      ap ClusterElement::Network.private_ipv4_addresses
      ap ClusterElement::Network.private_ipv4
      ap ClusterElement::Network.public_ipv4_addresses
      ap ClusterElement::Network.public_ipv4
    end
    default_task :state
  end
end