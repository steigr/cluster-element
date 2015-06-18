module ClusterElement
  class Ssh
    class Ssh < Thor
      desc "socket","CoreOS Systemd SSHd.socket"
      method_option :output, type: :string
      def socket
        output = options[:output]
        socket = <<-EO_SSHD_SOCKET.strip_heredoc
        [Socket]
        ListenStream=2220
        Accept=yes
        EO_SSHD_SOCKET
        if output
          FileUtils.mkdir_p File.dirname output
          File.write output, socket
        else
          puts socket
        end
      end
    end
    ClusterElement::Cli.register Ssh, "ssh","ssh [COMMAND]","ssh management"
  end
end