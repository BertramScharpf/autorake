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
      :localstate  => "/var",
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
      super key.to_sym
    end

    def []= key, value
      super key.to_sym, value
    end

    def expanded key
      expand self[ key]
    end

    def expand dir
      case dir
        when /\A[A-Z_]+/ then
          (expand self[ $&.downcase]) + $'
        when /\A:(\w+)/ then
          (expand self[ $1]) + $'
        else
          dir
      end
    end

  end

end

