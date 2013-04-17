#
#  autorake.rb  --  Autorake module
#

require "autorake/configure"

module Autorake

  module Rakefile

    class <<self
      def extended obj
        obj.load_autorake
      end
    end

    def parameter par
      @autorake.parameters[ par]
    end

    def compiler *args
      CompilerC.new @autorake.incdirs, @autorake.macros, *args
    end

    def linker *args
      Linker.new @autorake.libdirs, @autorake.libs, *args
    end

    def load_autorake filename = nil
      @autorake = YAML.load_file filename||Configuration::CONFIG_FILE
      @autorake.do_env
    end

  end

end

# When we're loaded from a Rakefile, include the extensions to it.
module Rake ; @application ; end and extend Autorake::Rakefile

