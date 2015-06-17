require "installer"
Installer.gem.install("toml-rb")
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
      @_config ||= {
        packages: {
          gems: %w{toml-rb pry thor},
          apks: %w{git docker bash ruby-dev}
        }
      }
    end
    private
    def load
    end
    def gems
      @_config[:packages][:gems].collect{|name| Installer::Package::Gem.new name}
    end
    def apks
      @_config[:packages][:apks].collect{|name| Installer::Package::Apk.new name}
    end
  end
end