#
#  autorake/mkconfig.rb  --  Make configuration
#

require "autorake/definition"
require "autorake/application"

module Autorake

  class <<self
    def configure &block
      d = Definitions.new
      d.instance_eval &block
      p = MkConfig.new d
      p.run
      nil
    end
  end


  class MkConfig < Application

    attr_accessor :outfile
    attr_bang :clean, :verbose

    def initialize definition
      @definition = definition
    end

    private

    def define_options
      add_option %w(o outfile), "specify output file",
                                    Configuration::CONFIG_FILE, :outfile=
      add_option %w(c clean),   "delete config file resp. -o outfile",
                                                        nil, :clean!
      add_option %w(d dump),    "just dump the results", nil, :dump
      add_option %w(v verbose), "lots of ubly debugging information",
                                                        nil, :verbose!
      super
      @definition.directories.each { |k,v|
        add_option %W(dir-#{k}), "set directory #{k}", v, :set_dir, k
      }
      @definition.features.each { |k,v|
        de, dd = "[default]", nil
        de, dd = dd, de unless v
        add_option %W(enable-#{k}),  "enable  #{k} #{de}", nil,
                                                        :set_feature, k, true
        add_option %W(disable-#{k}), "disable #{k} #{dd}", nil,
                                                        :set_feature, k, false
      }
      @definition.parameters.each { |k,v|
        add_option %W(with-#{k}), "define a parameter and C macro #{k}", v,
                                                                :set_parm, k
      }
      @definition.incpath.each { |k,v|
        add_option %W(incdir-#{k}), "include directory #{k}", v, :set_incdir, k
      }
      @definition.libpath.each { |k,v|
        add_option %W(libdir-#{k}), "library directory #{k}", v, :set_libdir, k
      }
    end

    def set_dir name, val
      @definition.directories[ name] = val
    end

    def set_feature name, val
      @definition.features[ name.to_sym] = val
    end

    def set_parm name, val
      @definition.parameters[ name.to_sym] = val
    end

    def set_incdir name, val
      @definition.incpath[ name.to_sym] = val
    end

    def set_libdir name, val
      @definition.libpath[ name.to_sym] = val
    end

    def dump
      @definition.dump
      raise Done
    end

    def environ name, val
      @definition.environment[ name] = val
    end

    def execute
      if @clean then
        File.unlink @outfile if File.file? @outfile
      else
        cfg = @definition.perform
        File.open @outfile, "w" do |f|
          f.write cfg.to_yaml
        end
      end
    end

  end

end

