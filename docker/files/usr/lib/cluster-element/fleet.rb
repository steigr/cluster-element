module ClusterElement
  class Fleet
    if Object.const_defined? "ClusterElement::Cli"
      class Fleet < Thor
        desc "dropin","Build Cloud-Init Drop-In"
        method_option :output, type: :string
        def dropin
          ClusterElement::Fleet.dropin output:options[:output]
        end
        desc "metadata","Print Fleet Machine Metadata"
        def metadata
          puts ClusterElement::Fleet.metadata
        end
      end
      Cli.register Fleet, 'fleet','fleet [COMMAND]','Fleet Cluster Scheduler'
    end
    class << self
      private def method_missing method, *args, &block; instance.send method, *args, &block; end
      private def instance; @instance ||= self.new; end
    end
    def dropin output:nil
      dropin = <<-EO_FLEET_DROPIN.strip_heredoc
      [Service]
      Environment="FLEET_PUBLIC_IP=#{ClusterElement::Network.private_ipv4}"
      Environment="FLEET_METADATA=#{metadata}"
      EO_FLEET_DROPIN
      if output
        FileUtils.mkdir_p File.dirname output
        File.write output, dropin
      else
        puts dropin
      end
    end
    def metadata
      @tags = []
      @tags << "public=true" if ClusterElement::Network.public_ipv4
      @tags.join(",")
    end
    def dropin_file
      "/run/systemd/system/fleet.service.d/20-cloudinit.conf"
    end
  end
end