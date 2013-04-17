#
#  autorake/configure.rb  --  Configure scripts
#

require "yaml"

module Autorake

  class Configuration

    attr_reader :directories
    attr_reader :features
    attr_reader :incdirs, :headers, :macros, :libdirs, :libs

    def initialize environment
      @environment = {}
      environment.each { |k,v| @environment[ k] = v }
      @directories = {}
      @features = {}
      @incdirs = []
      @headers = []
      @macros = {}
      @libdirs = []
      @libs = []
    end

    def do_env
      @environment.each { |k,v| ENV[ k] = v }
    end

  end

end

