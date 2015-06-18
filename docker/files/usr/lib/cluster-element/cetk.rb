module ClusterElement
  class Cetk
    class Cetk < Thor
      desc "service","Install Systemd Unit File"
      method_option :output, type: :string
      def service
        ClusterElement::Cetk.service output:options[:output]
      end
      desc "bootscript","CEtk Boot Script"
      method_option :output, type: :string
      def bootscript
        ClusterElement::Cetk.bootscript output:options[:output]
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
        ExecStartPre=/opt/bin/cetk serf install --output /opt/bin/serf
        ExecStartPre=/opt/bin/cetk serf config --output /run/serf/serf.json
        ExecStartPre=/opt/bin/cetk serf service --output /etc/systemd/system/serf.service
        ExecStart=/usr/bin/systemctl daemon-reload
        ExecStartPost=/usr/bin/systemctl start serf
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
    def bootscript output:nil
      script = <<-EO_CETK_BOOT_SCRIPT.strip_heredoc
      #!/bin/bash
      /opt/bin/cetk cetk service --output /etc/systemd/system/cetk.service
      /usr/bin/systemctl daemon-reload
      /usr/bin/systemctl start cetk
      EO_CETK_BOOT_SCRIPT
      if output
        FileUtils.mkdir_p File.dirname output
        File.write output, script        
        File.chmod 0755, output
      else
        puts script
      end
    end
  end
end
