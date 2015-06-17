class Installer
  module Package
    class Package
      class << self
        attr_accessor :installer
      end
      def initialize name
        @name=name
      end
      def install
        self.class.installer.install @name
      end
    end
  end
end