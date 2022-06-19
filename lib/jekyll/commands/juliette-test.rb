require 'fileutils'
require 'jekyll/juliette/juliette-dummy-build.rb'

module Jekyll
    module Commands
        class Test < Jekyll::Command
            class << self
                def init_with_program(prog)
                    prog.command(:test) do |c|
                        c.syntax "test [options]"
                        c.description 'Run test/generic/one-off code.'
                
                        c.option 'path', '-p PATH', 'Relative path from site source to file to rename.'
                        add_build_options(c)

                        c.action do |args, options|
                            # Test code goes here!
                            # Reference classes in the lib/jekyll/juliette folder by `Juliette::<class name>`
                            dummy1 = Juliette::DummyBuild.new(options)
                            Jekyll.logger.warn 'have site object now?'
                            puts dummy1.instance_variable_get(:@page_relative_paths)
                        end
                    end
                end
            end
        end
    end
end