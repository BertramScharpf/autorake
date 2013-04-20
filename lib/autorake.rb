#
#  autorake.rb  --  Autorake module
#

require "autorake/configure"
require "autorake/compile"

module Autorake

  module Rakefile

    class <<self
      def extended obj
        obj.load_autorake
        Compiler.verbose = true
      end
    end

    def has? name
      @autorake.features[ name]
    end

    def parm
      @autorake.parameters
    end

    def compiler *args
      CompilerC.new @autorake.incdirs, @autorake.macros, *args
    end

    def linker *args
      Linker.new @autorake.libdirs, @autorake.libs, *args
    end

  
    def installer files, destdir, params = nil
      destdir = @autorake.directories.expand destdir
      d = ENV[ "DESTDIR"]
      if d
        d = File.expand_path d
        destdir = File.join d, destdir
      end
      files = case files
        when Array then files
        else            [ files]
      end
      task :install do
        File.directory? destdir or mkdir_p destdir
        files.each { |f| install f, destdir, params }
      end
      task :uninstall do
        files.each { |f| uninstall f, destdir }
      end
    end


    def load_autorake filename = nil
      @autorake = YAML.load_file filename||Configuration::CONFIG_FILE
      @autorake.do_env
    end

    private

    def install src, dir, ugm
      d, = File.split src
      d = nil if d == "."
      install d, dir, ugm if d
      dst = File.join dir, src
      if File.directory? src or not File.exists? src then
        return if File.directory? dst
        mkdir dst
      else
        cp src, dst
      end
      if ugm then
        u, g = ugm[ :user], ugm[ :group]
        u = nil if u and u.empty?
        g = nil if g and g.empty?
        chown u, g, dst if u or g
        m = ugm[ :mode]
        if m and not m.empty? then
          m = Integer m
          chmod m, dst
        end
      end
    end

    def uninstall src, dir
      dst = File.join dir, src
      if File.directory? src or not File.exists? src then
        Dir.rmdir dst rescue return
      else
        rm dst
      end
      d, = File.split src
      d = nil if d == "."
      uninstall d, dir if d
    end

  end

end

# When we're loaded from a Rakefile, include the extensions to it.
module Rake ; @application ; end and extend Autorake::Rakefile

