#
#  autorake/compile.rb  --  C compiler
#

module Autorake

  class Builder

    class Error < StandardError ; end

    class <<self
      attr_accessor :verbose, :quiet
    end

    def cc *a
      command "CC", "cc" do build *a end
    end

    def cxx *a
      command "CXX", "c++" do build *a end
    end
    alias cpp cxx

    private

    def command env, default
      @cmd = ENV[ env] || default
      yield
    ensure
      @cmd = nil
    end

    def build *a
      a.flatten!
      a.compact!
      a.unshift @cmd
      if Builder.verbose then
        m = a.join " "
        puts m
      end
      f = fork do
        $stderr.reopen "/dev/null" if Builder.quiet
        exec *a
      end
      Process.waitpid f
      $?.success? or raise Error, "#{self.class} failed."
    end

  end

  class Preprocessor < Builder

    def initialize incdirs, macros, *args
      @incdirs = incdirs.map { |d| "-I#{d}" }
      @macros = macros.map { |k,v|
        next unless v
        m = "-D#{k}"
        m << "=#{v}" if String === v
        m
      }
      @args = args
      e = ENV[ "CFLAGS"]
      @cflags = e.split if e
    end

    def build obj, src
      io = [ "-o", obj.to_s, "-c", src.to_s]
      super @cflags, @macros, @incdirs, @args, opt_E, io
    end

    private

    def opt_E
      "-E"
    end

  end

  class Compiler < Preprocessor

    private

    def opt_E ; end

  end

  class Linker < Builder

    def initialize libdirs, libs, *args
      @libdirs = libdirs.map { |d| "-Wl,-L#{d}" }
      @libs = libs.map { |d| "-Wl,-l#{d}" }
      @args = args
      e = ENV[ "LDFLAGS"]
      @ldflags = e.split if e
    end

    def build bin, *objs
      io = [ "-o", bin.to_s, objs]
      super @ldflags, @libdirs, @libs, @args, io
    end

  end


  class TmpFiles

    class <<self
      def open source
        i = new source
        yield i
      ensure
        i.cleanup
      end
      private :new
    end

    attr_reader :src

    def initialize source
      @plain = "tmp-0001"
      begin
        @src = "#@plain.c"
        File.open @src, File::WRONLY|File::CREAT|File::EXCL do |c|
          c.puts source
        end
      rescue Errno::EEXIST
        @plain.succ!
        retry
      end
    end

    def cpp ; @cpp = "#@plain.cpp" ; end
    def obj ; @obj = "#@plain.o"   ; end
    def bin ; @bin = "#@plain"     ; end

    def cleanup
      File.delete @bin if @bin and File.exists? @bin
      File.delete @obj if @obj and File.exists? @obj
      File.delete @cpp if @cpp and File.exists? @cpp
      File.delete @src
    end

  end

end

