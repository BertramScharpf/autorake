"
"  ruby.vim --  Shortcuts for Ruby evaluation
"

function s:Ruby() range
  exec a:lastline
  ruby <<
    begin
      _ = eval(VIM.evaluate("getline(a:firstline,a:lastline)").join $/)
      _.nil? or append "#=> " + _.inspect
    rescue Exception
      append "#!! #$! (#{$!.class})"
    end
.
endfunction

function s:RubySum() range
  " Build sum of expressions.
  " Everything before :(colon) and after #(hash) is treated as a comment.
  exec a:lastline
ruby <<
  begin
    VIM.kfm = true
    _ = eval VIM.evaluate("getline(a:firstline,a:lastline)").map { |l|
      VIM.numbers_of l
    }.join( " + ")
    append "-"*32, (VIM.ntos _)
  rescue Exception
    append "-"*32, "#!! #$! (#{$!.class})"
  end
.
endfunction

function s:RubySums() range
ruby <<
  f, l = VIM.evaluate("a:firstline").to_i, VIM.evaluate("a:lastline").to_i
  c = VIM::Buffer.current
  _ = 0
  VIM.kfm = true
  f.upto l do |i|
    begin
      _ += eval VIM.numbers_of( c[i])
      c[i] += "  #=> " + (VIM.ntos _)
    rescue Exception
      c[i] += "  #!! #$! (#{$!.class})"
      break
    end
  end
.
endfunction


ruby <<
  require "rubygems"

  module VIM
    class <<self
      attr_accessor :kfm  # Kaufmännische Zahlen
      def numbers_of line
        line.chomp!
        line.gsub! /#.*?$/, ""
        line.gsub! /^.*?[:=]/, ""
        line.gsub! /\d(\.\d{3})+,\d/ do |x|
          x.delete "."
        end
        line.gsub! /(\d+,)-/, "\\100"
        line.gsub! /(\d+),(\d+)(-)?/, "\\3\\1.\\2"
        @kfm &&= line !~ /(^|[^0-9.])\d+(\.(\d|\d{3,}))?([^0-9.]|$)/
        line =~ /\S/ ? line : "0"
      end
      def ntos n
        @kfm ? "%.2f" % n : n.to_s
      end
    end
  end
  def append *s
    s.any? or s.push nil
    c = VIM::Buffer.current
    s.each { |e|
      e.to_s.each_line { |l|
        l.chomp!
        n = c.line_number
        c.append n, l
        n += 1
        Vim.command n.to_s
      }
    }
    nil
  end
  def pp s
    append s.pretty_inspect
  rescue NoMethodError
    require "pp" and retry
    raise
  end
.

command -bar -nargs=0 -range=% Ruby     <line1>,<line2>call s:Ruby()
command -bar -nargs=0 -range=% RubySum  <line1>,<line2>call s:RubySum()
command -bar -nargs=0 -range=% RubySums <line1>,<line2>call s:RubySums()

