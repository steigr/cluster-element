module ClusterElement
  class Config
    class Config < Thor
      desc "show","print the configuration"
      def show
        ap ClusterElement::Config.dump
      end
      desc "reset","(re)set config to defaults"
      def reset
        ClusterElement::Config.store ClusterElement::Config.reset
      end
    end
  end
  Cli.register Config::Config, "config","config [COMMAND]","Toolkit Configuration"
end