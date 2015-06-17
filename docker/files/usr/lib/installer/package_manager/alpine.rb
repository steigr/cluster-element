require "installer/package_manager/manager"
require "installer/package/apk"

class Installer
  module PackageManager
    class Alpine < Manager
      self.package = Installer::Package::Apk
      self.package.installer = self
      def install_package name
        `apk add #{name}`.strip  unless is_installed? name
        package.new name
      end
      def is_installed? name
        `apk info` =~ /^#{name}$/
      end
      private
      def update
        return if @up_to_date
        `apk update`.strip
        @up_to_date = true
      end
    end
  end
end