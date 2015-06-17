require "installer"
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
      @config ||= {
        packages: {
          gems: %w{toml-rb pry thor},
          apks: %w{git docker bash ruby-dev rsync}
        }
      }
    end
    private
    def load

    end
    def store
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