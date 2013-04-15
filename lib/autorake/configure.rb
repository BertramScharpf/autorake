#
#  autorake/configure.rb  --  Configure scripts
#

require "autorake/directories"
require "yaml"

module Autorake

  class Configure

    attr_reader :environment, :directories

    def initialize
      @environment = {}
      @directories = Directories.new
    end

    def dump
      puts "Environment:"
      @environment.each { |k,v| puts "  #{k}=#{v}" }
      puts "Directories:"
      @directories.keys.each { |k| puts "  #{k}=#{@directories.expanded k}" }
    end

    private

    def feature name, enabled = nil
    end
    def with name
      feature name, true
    end
    def without name
      feature name, false
    end

    def have_header name
    end

  end

end

