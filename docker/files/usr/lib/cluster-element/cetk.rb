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
        ExecStart=/usr/bin/systemctl daemon-reload
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
      exec >  >(systemd-cat -t "cetk")
      exec 2>&1
      echo "Set Hostname"
      /opt/bin/cetk machine uuid > /etc/hostname
      /usr/bin/hostname -F /etc/hostname
      echo "Remap SSHd"
      /opt/bin/cetk ssh socket --output /etc/systemd/system/sshd.socket
      /usr/bin/systemctl daemon-reload
      /usr/bin/systemctl enable sshd.socket
      /usr/bin/systemctl stop sshd.service
      /usr/bin/systemctl daemon-reload
      /usr/bin/systemctl start sshd.service
      /usr/bin/kill $(lsof -i :22 -Fp | cut -b2-) 2>/dev/null
      echo "Link embedded tools"
      /opt/bin/cetk cmd link
      echo "Start Serf"
      /opt/bin/cetk serf install --output #{ClusterElement::Serf.bin_file}
      /opt/bin/cetk serf config --output #{ClusterElement::Serf.config_file}
      /opt/bin/cetk serf service --output #{ClusterElement::Serf.service_file}
      /usr/bin/systemctl start serf
      echo "Start Etcd"
      /opt/bin/cetk etcd dropin --output #{ClusterElement::Etcd.dropin_file}
      /usr/bin/systemctl daemon-reload
      /usr/bin/systemctl start etcd2
      echo "Start Fleet"
      /opt/bin/cetk fleet dropin --output #{ClusterElement::Fleet.dropin_file}
      /usr/bin/systemctl daemon-reload
      /usr/bin/systemctl start fleet
      /opt/bin/cetk flanneld config | /usr/bin/etcdctl set #{ClusterElement::Flanneld.etcd_prefix}
      /opt/bin/cetk flanneld service --output #{ClusterElement::Flanneld.service_file}
      /usr/bin/fleetctl start #{ClusterElement::Flanneld.service_file}
      EO_CETK_BOOT_SCRIPT
      if output
        FileUtils.mkdir_p File.dirname output
        File.write output, script        
        File.chmod 0755, output
      else
        puts script
      end
    end
    def service_file
      "/etc/systemd/system/cetk.service"
    end
  end
end
