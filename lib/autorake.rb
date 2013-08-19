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


    def installer under, files, destdir = nil, params = nil
      not params and case destdir
        when nil, Hash then
          under, files, destdir, params = nil, under, files, destdir
      end
      destdir = @autorake.directories.expand destdir
      d = ENV[ "DESTDIR"]
      if d then
        d = File.expand_path d
        destdir = File.join d, destdir
      end
      files = case files
        when Array then files
        else            [ files]
      end
      unless @autorake_install then
        task :install   do install_targets   end
        task :uninstall do uninstall_targets end
        @autorake_install = []
      end
      @autorake_install.push [ under, files, destdir, params]
    end

    def load_autorake filename = nil
      @autorake = YAML.load_file filename||Configuration::CONFIG_FILE
      @autorake.do_env
    end

    private

    def install_targets
      @autorake_install.each { |under,files,destdir,params|
        File.directory? destdir or mkdir_p destdir
        files.each { |f| install under, f, destdir, params }
      }
    end

    def uninstall_targets
      @autorake_install.reverse.each { |under,files,destdir,|
        files.each { |f| uninstall under, f, destdir }
      }
    end

    def paths_for_install under, src, dir
      dst = File.join dir, src
      here = under ? (File.join under, src) : src
      there, = File.split src
      there = nil if there == "."
      yield dst, here, there
    end

    def install under, src, dir, ugm
      paths_for_install under, src, dir do |dst,here,there|
        install under, there, dir, ugm if there
        if File.directory? here or not File.exists? here then
          return if File.directory? dst
          mkdir dst
        elsif File.symlink? here then
          rm dst if File.exists? dst
          rdl = File.readlink here
          ln_s rdl, dst
        else
          cp here, dst
        end
        if ugm then
          u, g = [ :user, :group].map { |x| y = ugm[ x] ; y unless y.empty? }
          chown u, g, dst if u or g
          m = ugm[ :mode]
          if m and not m.empty? then
            m = Integer m
            chmod m, dst
          end
        end
      end
    end

    def uninstall under, src, dir
      paths_for_install under, src, dir do |dst,here,there|
        if File.directory? here or not File.exists? here then
          rmdir dst rescue return
        else
          rm dst if File.exists? dst or File.symlink? dst
        end
        uninstall under, there, dir if there
      end
    end

  end

end

# When we're loaded from a Rakefile, include the extensions to it.
module Rake ; @application ; end and extend Autorake::Rakefile

