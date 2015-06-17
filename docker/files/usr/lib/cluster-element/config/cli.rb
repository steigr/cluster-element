module ClusterElement
  class Config
    class Cli < Thor
    end
  end
  Cli.register Config::Cli, "config","config [COMMAND]","Toolkit Configuration"
end