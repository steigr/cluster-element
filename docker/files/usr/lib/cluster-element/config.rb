require "installer"
require "fileutils"
Installer::Package::Gem.new("toml-rb").install
require "toml"

module ClusterElement
  class Config
    class << self
      private
      def method_missing method, *args, &block
        instance.send method, *args, &block
      end
      def instance
        @instance ||= self.new
      end
    end
    def initialize
      @config ||= load 
      @config ||= reset
    end
    def reset
      {
        packages: {
          gems: %w{toml-rb pry thor awesome_print},
          apks: %w{git docker bash ruby-dev rsync}
        }
      }
    end
    def store config=nil
      config ||= @config
      FileUtils.mkdir_p(File.basename(cfg_file))
      File.write(cfg_file,TOML.parse(config))
    end
    def load
      TOML.load_file(cfg_file,symbolize_keys: true) if File.exists?(cfg_file)
    end
    def dump
      @config
    end
    private
    def cfg_file
      "/etc/cetk/config.tml"
    end
    def gems
      @config[:packages][:gems].collect{|name| Installer::Package::Gem.new name}
    end
    def apks
      @config[:packages][:apks].collect{|name| Installer::Package::Apk.new name}
    end
    def method_missing method, *args, &block
      @config[method] if @config.keys.include? method
    end
  end
end