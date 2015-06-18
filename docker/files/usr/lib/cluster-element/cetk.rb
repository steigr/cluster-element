module ClusterElement
  class Cetk
    class Cetk < Thor
      desc "service","Install Systemd Unit File"
      method_option :output, type: :string
      def service
        ClusterElement::Cetk.service output:options[:output]
      end
    end
    ClusterElement::Cli.register Cetk, "cetk", "cetk [COMMAND]","Cluster Element toolkit commands"
    class << self
      private def method_missing method, *args, &block; instance.send method, *args, &block; end
      private def instance; @instance ||= self.new; end
    end
    def service output:nil
      service = <<-EO_CETK_SERVICE.strip_heredoc
        [Unit]
        Description=Cluster Element toolkit (CEtk)
        [Service]
        ExecStartPre=/opt/bin/cetk cmd link
        ExecStartPre=/opt/bin/cetk serf config --output /run/serf/serf.json
        ExecStartPre=/opt/bin/cetk serf service --output /etc/systemd/system/serf.service
        ExecStartPre=/usr/bin/systemctl start serf
        ExecStart=/usr/bin/true
        [Install]
        WantedBy=multi-user.target
      EO_CETK_SERVICE
      if output
        FileUtils.mkdir_p File.dirname output
        File.write output, service
      else
        puts service
      end
    end
  end
end
