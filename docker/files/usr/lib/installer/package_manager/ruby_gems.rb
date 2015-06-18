require "installer/package_manager/manager"
require "installer/package/gem"

class Installer
  module PackageManager
    class RubyGems < Manager
      self.package = Installer::Package::Gem
      self.package.installer = self
      def install_package name
        unless is_installed? name
          update
          `#{cmd :install} #{name}`.strip
          Gem.clear_paths
          packages << name
        end
        package.new name
      end
      def is_installed? name
        packages.include? name
      end
      def packages
        @packages ||= `gem list -q`.strip.split("\n").map{|g|g.sub(/ \(.*/,'')}
      end
      private
      def cmd op
        "gem #{op} --no-ri --no-rdoc"
      end
      def update
        return if @up_to_date
        `#{cmd :update} --system`.strip
        @up_to_date = true
      end
    end
  end
end