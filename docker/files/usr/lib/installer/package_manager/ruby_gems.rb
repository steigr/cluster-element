require "installer/package_manager/manager"
require "installer/package/gem"

class Installer
  module PackageManager
    class RubyGems < Manager
      package = Installer::Package::Gem
      package.installer = self
      def install_package name
        `#{cmd :install} #{name}`.strip
      end
      def is_installed? name
        not `gem list -q #{name}`.strip.empty?
      end
      private
      def cmd op
        "gem #{op} --no-ri --no-rdoc"
      end
      def update
        `#{cmd :update} --system`.strip
        @up_to_date = true
      end
    end
  end
end