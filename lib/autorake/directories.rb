#
#  autorake/directories.rb  --  Directory shortcuts
#

module Autorake

  class Directories < Hash

    STD = {
      :prefix      => "/usr/local",
      :eprefix     => "PREFIX",
      :cprefix     => "EPREFIX",
      :bin         => "EPREFIX/bin",
      :sbin        => "EPREFIX/sbin",
      :libexec     => "EPREFIX/libexec",
      :sysconf     => "CPREFIX/etc",
      :localstate  => "CPREFIX/var",
      :lib         => "EPREFIX/lib",
      :include     => "PREFIX/include",
      :data        => "PREFIX/share",
      :info        => "DATA/info",
      :locale      => "DATA/locale",
      :man         => "DATA/man",
    }

    def initialize
      super
      update STD
    end

    def [] key
      super key.to_sym.downcase
    end

    def []= key, value
      super key.to_sym.downcase, value
    end

    def expanded key
      expand self[ key]
    end

    def expand dir, file = nil
      if file then
        dir = expand dir
        File.join dir, file
      else
        case dir
          when /\A[A-Z_0-9]+/ then (expand self[ $&.downcase]) + $'
          when /\A:(\w+)/     then (expand self[ $1         ]) + $'
          when /\A!/          then `#$'`[ /.*/]
          when /\A~/          then File.expand_path dir
          else                     dir
        end
      end
    end

  end

end

