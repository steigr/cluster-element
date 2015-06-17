class Installer
  module PackageManager
    class Manager
      class << self
        attr_accessor :package
        private
        def method_missing method, *args, &block
          instance.send method, *args, &block
        end
        def instance
          @instance ||= self.new
        end
      end
      def package
        self.class.package
      end
      def install name
        update
        install_package name
      end
    end
  end
end