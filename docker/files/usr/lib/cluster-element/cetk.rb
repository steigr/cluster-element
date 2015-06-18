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
        Descrption=Cluster Element toolkit (CEtk)
        [Service]
        ExecStart=/opt/bin/cetk cmd link
        ExecStartPost=/opt/bin/cetk serf config --output /run/serf/serf.json
        ExecStartPost=/opt/bin/cetk serf service --output /etc/systemd/system/serf.service
        ExecStartPost=/usr/bin/systemctl start serf
      EO_CETK_SERVICE
      if output
        FileUtils.mkdir_p File.dirname output
        File.write output, service
      else
        ap service
      end
    end
  end
end
