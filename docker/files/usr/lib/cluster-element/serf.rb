module ClusterElement
  class Serf
    class Serf < Thor
      desc "install","Download and Install Serf Binary"
      method_option :output, type: :string
      def install
        ClusterElement::Serf.install output:options[:output]
      end
      desc "service","Build Systemd Service File"
      method_option :output, type: :string
      def service
        ClusterElement::Serf.service output: options[:output]
      end
      desc "config","Create Serf Configuration"
      method_option :output, type: :string
      def config
        ClusterElement::Serf.config output: options[:output]
      end
    end
    Cli.register Serf, 'serf','serf [COMMAND]','Serf Cluster Discovery'
    class << self
      private def method_missing method, *args, &block; instance.send method, *args, &block; end
      private def instance; @instance ||= self.new; end
    end
    def bin
      @bin ||= `which serf`.strip
      @bin   = "/opt/bin/serf" if @bin.empty?
      puts "Serf-Bin: #{@bin}"
      @bin
    end
    def version
      @version ||= `#{bin} version 2>/dev/null`.split("\n").select{|l|l =~ / v/}.join.scan(/v([0-9]+(\.[0-9]+)+)/).flatten.first
      @version ||= ClusterElement::Config.serf[:version]
    end
    def url
      "https://dl.bintray.com/mitchellh/serf/#{version}_linux_amd64.zip"
    end
    def install output:nil
      output ||= bin
      tz = "/tmp/#{SecureRandom.hex(4)}.zip"
      File.write(tz,HTTParty.get(url).body)
      `unzip -d #{File.dirname output} #{tz}`
    end
    def service output:nil
      unit = <<-EO_SERF_UNIT.strip_heredoc
        [Unit]
        Description=Serf Cluster Discovery
        [Service]
        ExecStartPre=/opt/bin/cetk serf config --output /etc/serf/serf.json
        ExecStart=/opt/bin/serf agent -config-file=/etc/serf/serf.json
      EO_SERF_UNIT
      if output
        FileUtils.mkdir_p File.dirname output
        File.write output, unit
      else
        ap unit
      end
    end
    def config output:nil
      config = {
        tags: ClusterElement::Config.serf[:initial_tags],
        discover: ClusterElement::Config.serf[:discover],
        event_handlers: ClusterElement::Config.serf[:event_handlers],
        log_level: ClusterElement::Config.serf[:log_level].to_s,
        snapshot_path: ClusterElement::Config.serf[:snapshot_path],
        leave_on_terminate: ClusterElement::Config.serf[:leave_on_terminate],
        rejoin_after_leave: ClusterElement::Config.serf[:rejoin_after_leave],
      }
      if output
        FileUtils.mkdir_p File.dirname output
        File.write output, config.to_json
      else
        ap config
      end
    end
    def discover
      Digest::MD5.hexdigest ClusterElement::Network.private_ipv4_net
    end
  end
end