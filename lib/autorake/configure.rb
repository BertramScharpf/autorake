#
#  autorake/configure.rb  --  Configure scripts
#

require "autorake/directories"
require "yaml"

module Autorake

  class Configure

    attr_reader :environment, :directories, :features
    def incpath ; @paths[ :inc] ; end
    def libpath ; @paths[ :lib] ; end

    def initialize
      @environment = {}
      @directories = Directories.new
      @features = {}
      @paths = { :inc => {}, :lib => {}, }
    end

    def dump
      puts "Environment:"
      @environment.each { |k,v| puts "  #{k}=#{v}" }
      puts "Directories:"
      @directories.keys.each { |k| puts "  #{k}=#{@directories.expanded k}" }
      puts "Features:"
      @features.each { |k,v| puts "  #{k}=#{v}" }
      puts "Paths:"
      @paths.each { |t,p|
        puts "  #{t}:"
        @paths[ t].each { |k,v| puts "    #{k}=#{v}" }
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
    def with name, &block
      feature name, true, &block
    end
    def without name, &block
      feature name, false, &block
    end

    def incdir name, dir ; pathdir :inc, name, dir ; end
    def libdir name, dir ; pathdir :lib, name, dir ; end

    def have_header name
    end

    private

    def pathdir type, name, dir
      return unless dir
      dir.chomp!
      return if dir.empty?
      @paths[ type][ name] = dir
    end

  end

end

