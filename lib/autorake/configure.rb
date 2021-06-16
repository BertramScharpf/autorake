#
#  autorake/configure.rb  --  Configure scripts
#

require "autorake/directories"
require "yaml"

module Autorake

  class Configuration

    CONFIG_FILE = ".configure"

    attr_reader :directories
    attr_reader :features, :parameters
    attr_reader :incdirs, :headers, :macros, :libdirs, :libs

    def initialize environment, directories
      @environment = {}
      @environment.update environment
      @directories = directories
      @features = {}
      @parameters = {}
      @incdirs = []
      @headers = []
      @macros = {}
      @libdirs = []
      @libs = []
    end

    def do_env
      @environment.each { |k,v| ENV[ k] = v }
    end

    def dump
      puts "Environment:"
      @environment.each { |k,v| puts "  #{k}=#{v}" }
      puts "Directories:"
      @directories.keys.each { |k| puts "  #{k}=#{@directories.expanded k}" }
      puts "Features:"
      @features.each { |k,v| puts "  #{k}=#{v}" }
      puts "Parameters:"
      @parameters.each { |k,v| puts "  #{k}=#{v}" }
      puts "Include directories:"
      @incdirs.each { |d| puts "  #{d}" }
      puts "Header files:"
      @headers.each { |h| puts "  #{h}" }
      puts "C Macros:"
      @macros.each { |k,v| puts "  #{k}=#{v}" }
      puts "Library directories:"
      @libdirs.each { |d| puts "  #{d}" }
      puts "Libraries:"
      @libs.each { |l| puts "  #{l}" }
    end

  end

end

