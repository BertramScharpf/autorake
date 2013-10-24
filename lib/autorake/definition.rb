#
#  autorake/definition.rb  --  Definitions to produce a config
#

require "autorake/compile"
require "autorake/configure"

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
      c = perform
      c.dump
    end

    def perform
      Builder.quiet = true
      c = Configuration.new @environment, @directories
      c.do_env
      c.features.update @features
      c.incdirs.push std_incdir
      c.libdirs.push std_libdir
      af = @features.keys.map { |k| AddFeature.new k }
      am = @args[ :par].map { |k,v| AddMacro.new k, v }
      ai = @args[ :inc].map { |k,v| AddIncdir.new k, v }
      al = @args[ :lib].map { |k,v| AddLibdir.new k, v }
      [ af, am, ai, al, @checks].each { |a| a.each { |k| k.perform c } }
      c
    end

    protected

    def std_incdir ; @directories.expand "INCLUDE" ; end
    def std_libdir ; @directories.expand "LIB"     ; end

    def directory name, dir
      @directories[ name]= dir
    end

    def feature name, enabled = nil
      name = name.to_sym
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

    def extending_ruby
      if RUBY_VERSION < "1.9" then
        incdir :ruby, RbConfig::CONFIG[ "topdir"]
      else
        h = RbConfig::CONFIG[ "rubyhdrdir"]
        incdir :ruby, h
        incdir :ruby_arch, (File.join h, RbConfig::CONFIG[ "arch"])
        #incdir :ruby_backward, (File.join h, "ruby/backward")
      end
      libdir :ruby, RbConfig::CONFIG[ "libdir"]
      l = RbConfig::CONFIG[ "LIBRUBY"]
      l.slice! /\Alib/
      l.slice! /\.so(?:\..*)?\z/
      have_library l
    end

    def have_header name
      c = CheckHeader.new @current, name
      @checks.push c
    end

    def have_macro name
      c = CheckMacro.new @current, name
      @checks.push c
    end

    def have_func name
      c = CheckFunction.new @current, name
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
      name = "#@current/#{name}" if @current
      @args[ type][ name.to_sym] = dir
    end

  end


  class Add
    def initialize feature, name
      @feature, @name = feature, name
    end
    def perform config
      @config = config
      check! and set!
    ensure
      @config = nil
    end
    private
    def check!
      not @feature or
        @config.features[ @feature]
    end
    def set!
    end
    def name_upcase
      r = @name.to_s.upcase
      r.gsub! /[^A-Z_]/, "_"
      r
    end
  end

  class AddFeature < Add
    def initialize feature
      super feature, feature
    end
    def set!
      @config.macros[ "FEATURE_#{name_upcase}"] = true
    end
  end

  class AddKeyVal < Add
    def initialize key, val
      x, y = key.to_s.split "/"
      if y then
        x = x.to_sym
      else
        x, y = nil, x
      end
      super x, y.to_sym
      @val = val
    end
    private
    def expanded
      @config.directories.expand @val
    end
  end
  class AddMacro < AddKeyVal
    def set!
      @config.parameters[ @name] = @val
      @config.macros[ "WITH_#{name_upcase}"] = @val
    end
  end
  class AddIncdir < AddKeyVal
    def set!
      @config.incdirs.push expanded
    end
  end
  class AddLibdir < AddKeyVal
    def set!
      @config.libdirs.push expanded
    end
  end

  class Check < Add
    private
    def check!
      super or return
      print "Checking for #{self.class::TYPE} #@name ... "
      res = TmpFiles.open build_source do |t|
        compile t
      end
      print "yes"
      true
    rescue Builder::Error
      print "no"
      false
    ensure
      puts
    end
  end

  class CheckHeader < Check
    TYPE = "header"
    private
    def build_source
      <<-SRC
#include <#@name>
      SRC
    end
    def compile t
      c = Preprocessor.new @config.incdirs, @config.macros, "-w"
      c.cc t.cpp, t.src
    end
    def set!
      @config.macros[ "HAVE_HEADER_#{name_upcase}"] = true
      @config.headers.push @name
    end
  end

  class CheckWithHeaders < Check
    private
    def build_source
      src = ""
      @config.headers.each { |i|
        src << <<-SRC
#include <#{i}>
        SRC
      }
      src
    end
  end

  class CheckMacro < CheckWithHeaders
    TYPE = "macro"
    private
    def build_source
      super << <<-SRC
#ifndef #@name
#error not defined
#endif
      SRC
    end
    def compile t
      c = Preprocessor.new @config.incdirs, @config.macros, "-w"
      c.cc t.cpp, t.src
    end
    def check!
      super or raise "Macro not defined: #@name."
    end
  end

  class CheckFunction < CheckWithHeaders
    TYPE = "function"
    private
    def build_source
      super << <<-SRC
void dummy( void)
{
  void (*f)( void) = (void (*)( void)) #@name;
}
      SRC
    end
    def compile t
      c = Compiler.new @config.incdirs, @config.macros, "-w"
      c.cc t.obj, t.src
    end
    def set!
      @config.macros[ "HAVE_FUNC_#{name_upcase}"] = true
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
      c = Compiler.new @config.incdirs, @config.macros, "-w"
      c.cc t.obj, t.src
      l = Linker.new @config.libdirs, [ @name], "-w"
      l.cc t.bin, t.obj
    end
    def check!
      super or raise "Library missing: #@name."
    end
    def set!
      @config.libs.push @name
    end
  end

end

