#
#  autorake/mkconfig.rb  --  Make configuration
#

require "autorake/configure"
require "autorake/application"

module Autorake

  class <<self
    def configure &block
      c = Definitions.new
      c.instance_eval &block
      p = MkConfig.new c
      p.run
      nil
    end
  end


  class MkConfig < Application

    CONFIG_FILE = ".configure"

    attr_accessor :outfile
    attr_bang :clean, :verbose

    def initialize configure
      @configure = configure
    end

    private

    def define_options
      add_option %w(o outfile), "specify output file",  CONFIG_FILE, :outfile=
      add_option %w(c clean),   "delete config file resp. -o outfile",
                                                        nil, :clean!
      add_option %w(d dump),    "just dump the results", nil, :dump
      add_option %w(v verbose), "lots of ubly debugging information",
                                                        nil, :verbose!
      super
      @configure.directories.each { |k,v|
        add_option %W(dir-#{k}), "set directory #{k}", v, :set_dir, k
      }
      @configure.features.each { |k,v|
        de, dd = "[default]", nil
        de, dd = dd, de unless v
        add_option %W(enable-#{k}),  "enable  #{k} #{de}", nil,
                                                        :set_feature, k, true
        add_option %W(disable-#{k}), "disable #{k} #{dd}", nil,
                                                        :set_feature, k, false
      }
      @configure.parameters.each { |k,v|
        add_option %W(with-#{k}), "define a parameter and C macro #{k}", v,
                                                                :set_parm, k
      }
      @configure.incpath.each { |k,v|
        add_option %W(incdir-#{k}), "include directory #{k}", v, :set_incdir, k
      }
      @configure.libpath.each { |k,v|
        add_option %W(libdir-#{k}), "library directory #{k}", v, :set_libdir, k
      }
    end

    def set_dir name, val
      @configure.directories[ name] = val
    end

    def set_feature name, val
      @configure.features[ name] = val
    end

    def set_parm name, val
      @configure.parameters[ name] = val
    end

    def set_incdir name, val
      @configure.incpath[ name] = val
    end

    def set_libdir name, val
      @configure.libpath[ name] = val
    end

    def dump
      @configure.dump
      raise Done
    end

    def environ name, val
      @configure.environment[ name] = val
    end

    def execute
      if @clean then
        File.unlink @outfile if File.file? @outfile
      else
        File.open @outfile, "w" do |f|
          f.write @configure.to_yaml
        end
      end
    end

  end

end

