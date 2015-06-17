class Installer
  class PackageManager
    def install name
      install_package name unless is_installed? name
    end
  end
  class Alpine < PackageManager
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
  class Gem < PackageManager
    def install_package name
      `#{cmd :install} #{name}`.strip
    end
    def is_installed? name
      not `gem list -q #{name}`.strip.empty?
    end
    private
    def command op
      "gem #{op} --no-ri --no-rdoc"
    end
    def update
      `#{cmd :update} --system`.strip
      @up_to_date = true
    end
  end
  module Packages
    class Package
      def install
        self.class.installer self.name
      end
    end
    class Gem < Package
      installer = Installer::Gem
    end
    class Apk < Package
      installer = Installer::Alpine
    end
  end
  class << self
    private
    def method_missing method, *args, &block
      instance.send method, *args, &block
    end
    def instance
      @instance ||= self.new
    end
  end
  def apk
    @apk ||= Installer::Alpine.new
  end
  def gem
    @gem ||= Installer::Gem.new
  end
end