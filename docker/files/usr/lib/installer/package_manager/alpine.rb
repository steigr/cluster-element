require "installer/package_manager/manager"
require "installer/package/apk"

class Installer
  module PackageManager
    class Alpine < Manager
      self.package = Installer::Package::Apk
      self.package.installer = self
      def install_package name
        unless is_installed? name
          `apk add #{name}`.strip
          packages << name
        end
        package.new name
      end
      def is_installed? name
        packages.include? name
      end
      def packages
        @packags ||= `apk info`.strip.split("\n")
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