module ClusterElement
  class Flanneld
    if Object.const_defined? "ClusterElement::Cli"
      class Flanneld < Thor
        desc "service","Fleet Service File"
        method_option :output, type: :string
        def service
          ClusterElement::Flanneld.service output:options[:output]
        end
        desc "config","Flanneld Configuration"
        def config
          puts ClusterElement::Flanneld.config
        end
      end
      Cli.register Flanneld, 'flanneld','flanneld [COMMAND]','Network fabric for containers'
    end
    class << self
      private def method_missing method, *args, &block; instance.send method, *args, &block; end
      private def instance; @instance ||= self.new; end
    end
    def etcd_prefix
      "/cetk/flanneld/network"
    end
    def config
      {

      }
    end
  end
end