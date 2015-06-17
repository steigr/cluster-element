class Installer
  module PackageManager
    class Manager
      class << self
        private
        def method_missing method, *args, &block
          instance.send method, *args, &block
        end
        def instance
          @instance ||= self.new
        end
      end
      def package= package
        @package = package
      end
      def package name
        @package.new name
      end
      def install name
        return if is_installed? name
        install_package name
        self.class.package name
      end
    end
  end
end