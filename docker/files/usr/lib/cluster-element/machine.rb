module ClusterElement
  class Machine
    class Machine < Thor
      desc "uuid","Print system uuid"
      def uuid
        uuid_file="/sys/devices/virtual/dmi/id/product_uuid"
        File.exists? uuid_file
        puts File.read(uuid_file).strip.downcase.gsub(/-/,'')
      end
    end
    ClusterElement::Cli.register Machine, "machine","machine [COMMAND]","Machine Information"
  end
end