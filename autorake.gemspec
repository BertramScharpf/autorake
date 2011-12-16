#
#  autorake.gemspec  --  Autorake Gem specification
#

require "rubygems"

$:.unshift "./lib"
require "rake/autorake"

Gem::Specification.new do |s|
  s.name              = "autorake"
  s.rubyforge_project = "autorake"
  s.version           = Rake::Configure::VERSION
  s.summary           = "Configure project before Rake build."
  s.description       = <<EOT
This script allows you to write pretty mkrf_conf scripts
with autocmd-like functionality.
EOT
  s.authors           = "Bertram Scharpf"
  s.email             = "software@bertram-scharpf.de"
  s.homepage          = "http://www.bertram-scharpf.de"

  s.requirements      = "Rake"
  s.add_dependency      "rake", ">=0.8.7"

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

