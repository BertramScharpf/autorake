#
#  autorake.gemspec  --  Autorake Gem specification
#

require "./lib/autorake/version"

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
                          lib/autorake/compile.rb
                          lib/autorake/definition.rb
                          lib/autorake/directories.rb
                          lib/autorake/mkconfig.rb
                          lib/autorake/version.rb

                          samples/plainc/Rakefile
                          samples/plainc/mkrf_conf
                          samples/plainc/hello.c
                          samples/rbextend/Rakefile
                          samples/rbextend/mkrf_conf
                          samples/rbextend/hello.c
                          samples/rbextend/hello.h
                          samples/rbextend/rbhello
                          samples/justinst/Rakefile
                          samples/justinst/mkrf_conf
                          samples/justinst/plugin/dial.vim
                          samples/justinst/plugin/ruby.vim
                          samples/justinst/plugin/yesno.vim
                        )
  s.executables       = %w()

  s.has_rdoc          = true
  s.rdoc_options.concat %w(--charset utf-8 --main README)
  s.extra_rdoc_files  = %w(
                          README
                          LICENSE
                        )
end

