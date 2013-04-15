#
#  autorake/application.rb  --  Parse commandline arguments
#

module Autorake

  class Application

    class Option
      class <<self ; def [] *args ; new *args ; end ; end
      attr_reader :desc, :arg
      def initialize *args
        @desc, @arg, *@call = *args
      end
      def call
        @call.dup
      end
    end

    class Done < Exception ; end

    class <<self

      def attr_bang *syms
        syms.each { |sym|
          define_method :"#{sym}!" do
            instance_variable_set :"@#{sym}", true
          end
        }
        nil
      end

    end

    def run
      process_options do
        while (arg = $*.shift) do
          case arg
            when /\A--/ then
              a, val = $'.split "=", 2
              do_option a do val end
            when /\A-/ then
              arg = $'
              until (a = arg.slice! 0, 1).empty? do
                do_option a do
                  arg.slice! 0, arg.length unless arg.empty?
                end
              end
            else
              n, v = arg.split "="
              environ n, v
          end
        end
      end
      execute
    rescue Done
    end

    private

    def define_options
      add_option %w(h help),    "display this help",           nil, :help
      add_option %w(V version), "display version information", nil, :version
    end

    def add_option names, *desc_arg_call
      o = Option[ *desc_arg_call]
      names.each { |n| @options[ n] = o }
    end

    def process_options
      @options = {}
      define_options
      @rest = @options.values.uniq
      yield
      @rest.each { |o|
        if o.arg then
          c = o.call
          c.push o.arg
          send *c
        end
      }
    ensure
      @options = @rest = nil
    end

    def do_option a
      o = @options[ a]
      o or raise "Unknown option: #{a}"
      c = o.call
      if o.arg then
        g = yield || $*.shift
        c.push g
      end
      send *c
      @rest.delete o
    end

    def environ nam, val
      raise "Define your own environment setter."
    end

    def help
      puts "  %-16s  %-16s  %-40s" % %w(Option Argument Description)
      prev = nil
      @options.each { |k,v|
        k = (k.length>1 ? "--" : "-") + k
        l = "  %-16s" % k
        unless v == prev then
          l << "  %-16s   %-40s" % [ v.arg, v.desc]
        end
        puts l
        prev = v
      }
      raise Done
    end

    def version
      require "autorake/version"
      puts <<-EOT
#{NAME} #{VERSION}  --  #{SUMMARY}

Copyright: #{COPYRIGHT}
License:   #{LICENSE}

#{HOMEPAGE}
      EOT
      raise Done
    end

  end

end

