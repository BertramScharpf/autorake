#!/usr/bin/ruby

#
#  autorake.rb  --  Installation Configuration Tool
#

require "fileutils"
require "yaml"

module Rake

  module Configure

    class <<self
      def extended obj
        obj.load_config
      end
    end


    def residence sym, *args
      a = File.join *args
      File.expand_path a, @dirs[ sym]
    end

    def destination *args
      args = args.flatten
      case args.first
        when Symbol then
          sym = args.shift
          File.join @destroot, @dirs[ sym], *args
        else
          File.join @destroot, *args
      end
    end

    AUTO_CONFIGURE, MKRF_CONF = "configure", "mkrf_conf"
    CONFIG_FILE = ".configure"
    DESTDIR = "$DESTDIR"

    attr_reader :destroot, :arch, :dirs, :env

    def load_config file = nil
      @verbose = RakeFileUtils.verbose_flag
      begin
        file ||= CONFIG_FILE
        @destroot, @arch, @dirs, @env,
          @params, @incdirs, @libdirs = YAML.load_file file
        @destroot ||= ENV[ DESTDIR[ /\$(\w+)/, 1]] || ""
        @env.each { |k,v|
          ENV[ k] ||= v
        }
        begin
          task :distclean => :clean do
            rm_f file
          end
        rescue
        end
        @warn = nil
      rescue Errno::ENOENT
        $stderr.puts <<-EOT
Missing configuraton file: `#{file}'. Run `autorake' first.
Eventually it is provided as `./#{AUTO_CONFIGURE}' or `./#{MKRF_CONF}'.
        EOT
        @warn = true
      end
    end

    attr_reader :params, :incdirs, :libdirs

    def macro_defs
      @params.map { |k,v|
        next unless v
        d = "-D#{k.to_s.upcase}"
        d << "=#{v}" if String === v
        d
      }.compact
    end

    def have_header param
      @params[ :"have_header_#{param}"]
    end

    def have_func param
      @params[ :"have_func_#{param}"]
    end

    def opt_incdirs
      r = @incdirs.map { |k,v|
        "-I#{residence :include, v}" if v.any?
      }
      r.unshift "-I#{@dirs[ :include]}"
      r
    end

    def opt_libdirs
      @libdirs.map { |k,v| "-Wl,-L#{v}" if v.any? }
    end

    def opt_libs
      @params.map { |k,v|
        if v and k.to_s =~ /\Ahave_library_/ then
          "-Wl,-l#$'"
        end
      }.compact
    end

    def cc o, c, *args
      e = ENV[ "CFLAGS"]
      cc_cmd macro_defs, opt_incdirs, (e.split if e), args, "-o", o, "-c", c
    end

    def ld x, os, *args
      e = ENV[ "LDFLAGS"]
      cc_cmd opt_libdirs, opt_libs, (e.split if e), args,
              Config::CONFIG[ "LIBRUBYARG"].split, "-o", x, os
    end

    def cc_cmd *args
      args.flatten!
      args.compact!
      quiet = args.delete :quiet
      args.unshift ENV[ "CC"] || "cc"
      if @verbose then
        l = args.map { |a| a =~ / / ? a.inspect : a }.join " "
        puts l
      end
      Process.waitpid fork {
        $stderr.reopen "/dev/null" if quiet
        exec *args
      }
      yield if block_given? and $?.success?
      $?.success?
    end

    def undirectory dir
      if File.directory? dir and
          (Dir.entries( dir) - %w(. ..)).empty? then
        rmdir dir
        if dir != File.basename( dir) then
          undirectory File.dirname( dir)
        end
      end
    end

    def installer files, destdir, *params
      if @warn then
        puts <<EOT
Warning: install/uninstalling targets not built due to missing configuration.
EOT
        @warn = false
      end
      return unless @warn.nil?

      params = params.inject( {}) { |h,p| h.update p if p ; h }

      dir = destination *destdir
      directory dir
      task :install => dir
      files.each { |file|
        dest = File.join dir, File.basename( file)

        if params[ :dir] || File.directory?( file) then
          task :install   do cp_dir file, dest end
          task :uninstall do undirectory dest end
        else
          shb, sep = params[ :shebang], params[ :filter]
          if shb or sep then
            task :install do cp_filtered file, dest, shb, sep end
          else
            task :install do cp file, dest end
          end
          task :uninstall do rm dest end
        end
        mode = params[ :mode]
        user, group = [:user, :group].map { |x| params[ x] }
        task :install do
          chmod mode, dest if mode
          chown user, group, dest if user or group
        end
      }
      task :uninstall do
        undirectory dir
      end
    end

    def cp_dir src, dest
      mkdir dest unless File.directory? dest
    end

    def cp_filtered src, dest, shb, sep
      # nowrite is a Rake flag
      nowrite or File.open src do |f|
        create_file dest do |d|
          if sep then
            puts "Creating '#{dest}' through filter." if @verbose
            f = Filter.new f, sep, self
          end
          if shb then
            puts "Creating '#{dest}' with appropriate shebang." if @verbose
            f = Shebang.new f, d
          end
          f
        end
      end
    end

    private

    def create_file dest
      File.open dest, "w" do |d|
        src = yield d
        src.each { |l| d.puts l }
      end
    end

    class Shebang
      class <<self
        def shebang ; @shebang ||= `which ruby`.chomp ; end
      end
      def initialize src, dest
        @src = src
        dest.chmod 0755
      end
      def each
        inside = false
        @src.each { |l|
          if inside then
            yield l
          else
            if l =~ /^#!/ then
              l.sub! %r{(/[^/]+)*/ruby\w*}, Shebang.shebang
            else
              yield "#!#{Shebang.shebang}"
            end
            yield l
            inside = true
          end
        }
      end
    end

    class Filter
      def initialize src, sep, config
        @src = src
        @re_sep = case sep
          when Regexp then sep
          when String then /#{Regexp.quote sep}/
          else             /---/
        end
        @config = config
      end
      def each
        sections = {}
        active = true
        @src.each { |l|
          if l =~ @re_sep then
            sect, val = $'.split.map { |x| x.strip }
            sections[ sect] = val == "*" || (
              e = @config.env[ sect]
              if e then
                val == e
              else
                not sections.has_key? sect  # first is default
              end
            )
            active = sections.values.inject { |a,v| a && v }
          else
            if active then
              l.gsub! %r{@/(.*?)/@} do @config.dirs[ $1.intern] end
              yield l
            end
          end
        }
      end
    end

  end

end

