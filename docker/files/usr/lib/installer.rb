require "installer/package_manager/alpine"
require "installer/package_manager/ruby_gems"

class Installer
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
    @apk ||= Installer::PackageManager::Alpine.new
  end
  def gem
    @gem ||= Installer::PackageManager::RubyGems.new
  end
end