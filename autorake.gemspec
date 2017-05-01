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
  s.add_dependency      "rake", ">=11"

  s.files             = %w(
                          lib/autorake.rb
                          lib/autorake/application.rb
                          lib/autorake/configure.rb
                          lib/autorake/compile.rb
                          lib/autorake/definition.rb
                          lib/autorake/directories.rb
                          lib/autorake/mkconfig.rb
                          lib/autorake/version.rb

                          examples/dlcpp/Rakefile
                          examples/dlcpp/mkrf_conf
                          examples/dlcpp/dl.cpp
                          examples/dlcpp/dl.h
                          examples/dlcpp/hello.cpp
                          examples/dlcpp/hello.h
                          examples/dlcpp/main.cpp
                          examples/justinst/Rakefile
                          examples/justinst/mkrf_conf
                          examples/justinst/plugin/dial.vim
                          examples/justinst/plugin/ruby.vim
                          examples/justinst/plugin/yesno.vim
                          examples/plainc/Rakefile
                          examples/plainc/mkrf_conf
                          examples/plainc/hello.c
                          examples/rbextend/Rakefile
                          examples/rbextend/mkrf_conf
                          examples/rbextend/hello.c
                          examples/rbextend/hello.h
                          examples/rbextend/rbhello
                        )
  s.executables       = %w()

  s.has_rdoc          = true
  s.rdoc_options.concat %w(--charset utf-8 --main README)
  s.extra_rdoc_files  = %w(
                          README
                          LICENSE
                        )
end

