require "installer"

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

    end
    private
    def load
    end
    def gems
      @_gems = @_config[:packages][:gems]
    end
  end
end