#
#  autorake/configure.rb  --  Configure scripts
#

require "autorake/directories"
require "yaml"

module Autorake

  class Definitions

    attr_reader :environment, :directories, :features
    def parameters ; @args[ :par] ; end
    def incpath    ; @args[ :inc] ; end
    def libpath    ; @args[ :lib] ; end

    def initialize
      @environment = {}
      @directories = Directories.new
      @features = {}
      @args = { :par => {}, :inc => {}, :lib => {}, }
      @checks = []
    end

    def dump
      puts "Environment:"
      @environment.each { |k,v| puts "  #{k}=#{v}" }
      puts "Directories:"
      @directories.keys.each { |k| puts "  #{k}=#{@directories.expanded k}" }
      puts "Features:"
      @features.each { |k,v| puts "  #{k}=#{v}" }
      puts "Arguments:"
      @args.each { |t,p|
        puts "  #{t}:"
        @args[ t].each { |k,v| puts "    #{k}=#{v}" }
      }
    end

    protected

    def feature name, enabled = nil
      @current and raise "Features may not be nested."
      @current = name
      @features[ name] = enabled
      yield if block_given?
    ensure
      @current = nil
    end
    def enable name, &block
      feature name, true, &block
    end
    def disable name, &block
      feature name, false, &block
    end

    def with   name, val ; argdef :par, name, val ; end

    def incdir name, dir ; argdef :inc, name, dir ; end
    def libdir name, dir ; argdef :lib, name, dir ; end


    def have_header name
      c = CheckHeader.new @current, name
      @checks.push c
    end

    def have_macro name, *headers
      c = CheckMacro.new @current, name, *headers
      @checks.push c
    end

    def have_func name, *headers
      c = CheckFunction.new @current, name, *headers
      @checks.push c
    end

    def have_library name
      c = CheckLibrary.new @current, name
      @checks.push c
    end

    private

    def argdef type, name, dir
      return unless dir
      dir.chomp!
      return if dir.empty?
      if @current then
        name = "#@current/#{name}"
        name = name.to_sym if name.is_a? Symbol
      end
      @args[ type][ name] = dir
    end

  end


  class Check
    def initialize feature, name, *args
      @feature, @name = feature, name
    end
    def perform src
      print "Checking for #{self.class::TYPE} #@name ... "
      res = TmpFiles.open build_source do |t|
        compile t
      end
      puts res ? "yes" : "no"
      res
    end
  end

  class CheckHeader < Check
    TYPE = "header"
    def build_source
      <<-SRC
#include <#@name>
      SRC
    end
    def compile t
      c = CompilerPP.new
      c.incdir "..."
      c.cc t.cpp, t.src
    end
  end

  class CheckWithHeaders < Check
    def initialize feature, name, *headers
      super
      @headers = headers
    end
    def build_source
      src = ""
      @headers.each { |i|
        src << <<-SRC
#include <#{i}>
        SRC
      }
      src
    end
  end

  class CheckMacro < CheckWithHeaders
    TYPE = "macro"
    def build_source
      super << <<-SRC
#ifndef #@name
#error not defined
#endif
      SRC
    end
    def compile t
      c = CompilerPP.new
      c.incdir "..."
      c.cc t.cpp, t.src
    end
  end

  class CheckFunction < CheckWithHeaders
    def build_source
      super << <<-SRC
void dummy( void)
{
  void (*f)( void) = (void (*)( void)) #@name;
}
      SRC
    end
    def compile t
      c = Compiler.new
      c.incdir "..."
      c.cc t.obj, t.src
    end
  end

  class CheckLibrary < Check
    TYPE = "library"
    def build_source
      <<-SRC
int main( int argc, char *argv[]) { return 0; }
      SRC
    end
    def compile t
      c =Compiler.new
      c.cc t.obj, t.src
      l = Linker.new
      l.libdir "..."
      l.lib @name
      l.cc t.bin, t.obj
    end
    def perform
      super or raise "Library missing: #@name."
      true
    end
  end

end

