#
#  autorake.gemspec  --  Autorake Gem specification
#

require "rubygems"

$:.unshift "./lib"
require "autorake/version"

Gem::Specification.new do |s|
  s.name              = Autorake::NAME
  s.rubyforge_project = "NONE"
  s.version           = Autorake::VERSION
  s.summary           = Autorake::SUMMARY
  s.description       = Autorake::DESCRIPTION
  s.license           = Autorake::LICENSE
  s.authors           = Autorake::TEAM
  s.email             = Autorake::AUTHOR
  s.homepage          = Autorake::HOMEPAGE

  s.requirements      = "Rake"
  s.add_dependency      "rake", ">=0.8.7"

  s.files             = %w(
                          lib/autorake.rb
                          lib/autorake/application.rb
                          lib/autorake/configure.rb
                          lib/autorake/directories.rb
                          lib/autorake/mkconfig.rb
                          lib/autorake/version.rb
                          samples/plainc/mkrf_conf
                          samples/plainc/hello.c
                        )
  s.executables       = %w()
  s.extra_rdoc_files  = %w(
                          README
                          LICENSE
                        )
end

