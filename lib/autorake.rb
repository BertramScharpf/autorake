#
#  autorake.rb  --  Autorake module
#

require "autorake/configure"
require "autorake/compile"

module Autorake

  module Rakefile

    class <<self
      def extended obj
        obj.load_autorake ENV[ "AUTORAKE_CONFIGURE"]
        Builder.verbose = true
      end
    end

    def method_missing sym, *args, &block
      case sym
        when /\Ahas_(.*?)\??\z/ then has? $1
        when /\Aparm_/          then parm[ $'.to_sym]
        when /\Aexpand_/        then expand $'.upcase
        else                         super
      end
    end

    def has? name
      @autorake.features[ name.to_sym]
    end

    def parm
      @autorake.parameters
    end

    def expand dir
      @autorake.directories.expand dir
    end

    def compiler *args
      Compiler.new @autorake.incdirs, @autorake.macros, *args
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
      p = {}
      p.update params if params
      @autorake_install.push [ under, files, destdir, p]
    end

    def load_autorake filename = nil
      @autorake = YAML.load_file filename||Configuration::CONFIG_FILE
      @autorake.do_env
    end

    private

    def install_targets
      @autorake_install.each { |under,files,destdir,params|
        File.directory? destdir or mkdir_p destdir
        files.each { |f| install under, f, destdir, params, 0 }
      }
    end

    def uninstall_targets
      @autorake_install.reverse.each { |under,files,destdir,params|
        files.each { |f| uninstall under, f, destdir, params, 0 }
      }
    end

    def paths_for_install under, src, dir, depth
      dst = File.join dir, src
      here = under ? (File.join under, src) : src
      if depth.zero? then
        there, = File.split src
        there = nil if there == "."
      end
      yield dst, here, there
    end

    def dir_entries dir
      (Dir.entries dir) - %w(. ..)
    end

    def install under, src, dir, params, depth
      paths_for_install under, src, dir, depth do |dst,here,there|
        install under, there, dir, params, 0 if there
        if File.directory? here or not File.exists? here then
          mkdir dst unless File.directory? dst
          if params[ :recursive] then
            (dir_entries here).each { |e|
              install under, (File.join src, e), dir, params, depth+1
            }
          end
        elsif File.symlink? here then
          rm dst if File.exists? dst
          rdl = File.readlink here
          ln_s rdl, dst
        else
          cp here, dst
        end
        u = params[ :user]
        g = params[ :group]
        u, g = u.split ":" if u and not g
        chown u, g, dst if u or g
        m = params[ :mode]
        s = params[ :umask]
        m ||= s && (File.stat dst).mode & ~s & 0777
        chmod m, dst if m
      end
    end

    def uninstall under, src, dir, params, depth
      paths_for_install under, src, dir, depth do |dst,here,there|
        if File.directory? dst then
          if params[ :recursive] then
            (dir_entries dst).each { |e|
              uninstall under, (File.join src, e), dir, params, depth+1
            }
          end
          rmdir dst
        elsif File.exists? dst or File.symlink? dst then
          rm dst
        end
        if there and (dir_entries there).empty? then
          uninstall under, there, dir, params, 0
        end
      end
    end

  end

end

# When we're loaded from a Rakefile, include the extensions to it.
module Rake ; @application ; end and extend Autorake::Rakefile

