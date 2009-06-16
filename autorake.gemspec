#
#  autorake.gemspec  --  Autorake Gem specification
#

require "rubygems"


$:.unshift "lib"

module ::Rake
  class ConfigCompile ; @dont_run = true ; end
end
Kernel.load "bin/autorake"


SPEC = Gem::Specification.new do |s|
  s.name              = "autorake"
  s.rubyforge_project = "autorake"
  s.version           = Rake::ConfigCompile::VERSION
  s.summary           = "Configure project before Rake build."
  s.description       = <<EOT
This script allows you to write pretty mkrf_conf scripts
with autocmd-like functionality.
EOT
  s.authors           = "Bertram Scharpf"
  s.email             = "software@bertram-scharpf.de"
  s.homepage          = "http://www.bertram-scharpf.de"
  s.requirements      = "Rake"
  s.add_dependency      "rake", ">=0.8"
  s.files             = %w(
                          lib/rake/autorake.rb
                          example/mkrf_conf
                          example/Rakefile
                          example/notempty.c
                          example/notempty.h
                        )
  s.executables       = %w(autorake)
  s.extra_rdoc_files  = %w(
                          README
                          LICENSE
                        )
end

if $0 == __FILE__ then
  b = Gem::Builder.new SPEC
  b.build
end

