require "installer/package_manager/manager"
require "installer/package/apk"

class Installer
  module PackageManager
    class Alpine < Manager
      package = Installer::Package::Apk
      package.installer = self
      def install_package name
        update unless @up_to_date
        `apk add #{name}`.strip
      end
      def is_installed? name
        `apk info` =~ /^#{name}$/
      end
      private
      def update
        `apk update`.strip
        @up_to_date = true
      end
    end
  end
end