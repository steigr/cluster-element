module ClusterElement
  class Cmd
    class Cmd < Thor
      desc "link","Link CETK Commands"
      def link
        ClusterElement::Cmd.link
      end
    end
    ClusterElement::Cli.register Cmd, "cmd","cmd [command]","cetk Commands management"
    class << self
      private def method_missing method, *args, &block; instance.send method, *args, &block; end
      private def instance; @instance ||= self.new; end
    end
    def link
      trgt="#{basedir}/cetk"
      exit 1 unless File.exists? trgt
      %w{ruby pry gem irb serf-event}.each do |src|
        unless File.exists? "#{basedir}/#{src}"
          puts "Provide #{basedir}/#{src}"
          FileUtils.symlink trgt, "#{basedir}/#{src}"
        end
      end
    end
    def basedir
      "/opt/bin"
    end
  end
end