#
#  autorake/compile.rb  --  C compiler
#

module Autorake

  class Compiler

    def cc *args
      args.flatten!
      args.compact!
      args.unshift ENV[ "CC"] || "cc"
      system *args
      if block_given? then
        yield if $?.success?
      else
        $?.success?
      end
    end

  end

  class CompilerPP < Compiler

    def initialize *args
      @args = args
      @incdirs = []
      @macros = []
      e = ENV[ "CFLAGS"]
      @cflags = e.split if e
    end

    def incdir d
      @incdirs.push "-I#{d}"
    end

    def macro name, val
      m = "-D#{name}"
      m << "=#{val}" if val
      @macros.push m
    end

    def cc obj, src
      io = [ "-o", obj.to_s, "-c", src.to_s]
      super @cflags, @macros, @incdirs, @args, opt_E, io
    end

    private

    def opt_E
      "-E"
    end

  end

  class CompilerC < CompilerPP

    private

    def opt_E ; end

  end

  class Linker < Compiler

    def initialize *args
      @args = args
      @libs = []
      @libdirs = []
      e = ENV[ "LDFLAGS"]
      @ldflags = e.split if e
    end

    def incdir d
      @libdirs.push "-Wl,-L#{d}"
    end

    def library lib
      @libs.push "-Wl,-l#{lib}"
    end

    def cc bin, *objs
      io = [ "-o", bin.to_s, objs]
      super @ldflags, @libdirs, @libs, @args, io
    end

  end


  class OldCompilers

    def compile name, source, only_pp = nil
      filename = tmp_filename name
      objname  = filename.sub /(\.\w+)?\z/, ".o" if block_given?
      File.open filename, "w" do |c| c.puts source end
      begin
        @config.cc_cmd :quiet, ("-E" if only_pp),
                "-c", filename, "-o", objname||"/dev/null",
                @config.opt_incdirs do
          yield objname if objname
        end
      ensure
        File.delete objname if objname
        File.delete filename
      end
    end

    def link name, library
      source = "int main( int argc, char *argv[]) { return 0; }"
      compile name, source do |objname|
        @config.cc_cmd :quiet, objname, "-o", "/dev/null",
                @config.opt_libdirs, "-Wl,-l#{library}"
      end
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

