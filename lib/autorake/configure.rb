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

end

