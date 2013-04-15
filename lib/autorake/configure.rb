#
#  autorake/configure.rb  --  Configure scripts
#

require "autorake/directories"
require "yaml"

module Autorake

  class Configure

    attr_reader :environment, :directories, :features

    def initialize
      @environment = {}
      @directories = Directories.new
      @features = {}
    end

    def dump
      puts "Environment:"
      @environment.each { |k,v| puts "  #{k}=#{v}" }
      puts "Directories:"
      @directories.keys.each { |k| puts "  #{k}=#{@directories.expanded k}" }
      puts "Features:"
      @features.each { |k,v| puts "  #{k}=#{v}" }
    end

    private

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

    def have_header name
    end

  end

end

