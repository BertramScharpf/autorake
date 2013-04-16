#
#  autorake/compile.rb  --  C compiler
#

module Autorake

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

    def obj ; @obj = "#@plain.o" ; end
    def bin ; @bin = "#@plain"   ; end

    def cleanup
      File.delete @bin if @bin and File.exists? @bin
      File.delete @obj if @obj and File.exists? @obj
      File.delete @src
    end

  end

end

