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
                            provided_path = options['path']
                            chosen_path = options['new_name']
                            if provided_path == nil then
                                Jekyll.logger.error 'No provided path (-p).'
                                Jekyll.logger.warn 'Usage: rename -p <PATH> -n <NEW_PATH>.'
                                raise Errors::FatalException,
                                    "No provided path (-p)."
                            end
                            if chosen_path == nil then
                                Jekyll.logger.error 'No output path (-n).'
                                Jekyll.logger.warn 'Usage: rename -p <PATH> -n <NEW_PATH>.'
                                raise Errors::FatalException,
                                    "No output path (-n)."
                            end
                            file_path = source_path + '/' + provided_path
                            new_path = source_path + '/' + chosen_path
                            # Jekyll.logger.info 'Looking to rename/move ' + file_path + ' to ' + new_path

                            if not File.exists?(file_path)
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
                            if File.exists?(string_dir_path + "/" + file_name)
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
                                if page.include? '_site/' then next end
                                instances = 0
                                lines = IO.readlines(page).map do |line|
                                    if line.include? provided_path
                                        line = line.sub(provided_path, chosen_path)
                                        instances += 1
                                    end
                                    line
                                end
                                File.open(page, 'w') do |file|
                                    file.puts lines
                                end
                                if not instances == 0 then Jekyll.logger.info 'Corrected %d occurances in %s.' % [instances, page] end
                            end
                        end
                    end
                end
            end
        end
    end
end