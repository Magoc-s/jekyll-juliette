require 'fileutils'

module Jekyll
    module Commands
        class SmartRename < Jekyll::Command
            class << self
                def init_with_program(prog)
                    site = Jekyll.sites.first
                    prog.command(:rename) do |c|
                        c.syntax "rename [options]"
                        c.description 'Rename a file in a Jekyll Site and modify all references.'
                
                        c.option 'path', '-p PATH', 'Relative path from site source to file to rename.'
                        c.option 'new_name', '-n NAME', 'New name for file (including path!). Will create directories if needed.'
                
                        c.action do |args, options|
                            source_path = FileUtils.pwd
                            file_path = source_path + options['path']
                            new_path = source_path + options['new_name']
                            Jekyll.logger.info 'Looking to rename/move ' + file_path

                            if not File.exists?(file_path) do
                                raise Errors::FatalException,
                                    "File not found."
                            end

                            Jekyll.logger.info 'Found file.'

                            sub_dirs = new_path.split('/')
                            file_name = sub_dirs.last()
                            length = sub_dirs.length()
                            string_dir_path = sub_dirs.first(length-1).join("/")

                            FileUtils.mkdir_p string_dir_path unless Dir.exists?(string_dir_path)
                            FileUtils.cp(file_path, string_dir_path + "/" + file_name)
                            if File.exists?(string_dir_path + "/" + file_name) do
                                FileUtils.rm file_path
                            else
                                raise Errors::FatalException,
                                    "New file creation failed or did not behave as expected."
                            end

                            Jekyll.logger.info 'Renamed/moved file.'
                            
                            # Time consuming! Has to iterate over every line of every page!
                            # Only picks md or html pages!
                            pages = Dir.glob('**/*.{md,html}')
                            for page in pages do
                                instances = 0
                                lines = IO.readlines(page).map do |line|
                                    if line.include? options['path'] do
                                        line.sub(options['path'], options['new_path'])
                                        instances += 1
                                    else
                                        line
                                    end
                                    Jekyll.logger.info 'Corrected %d occurances in %s.' % [instances, page] unless (instances == 0) end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end