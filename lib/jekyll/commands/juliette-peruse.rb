require 'fileutils'

module Jekyll
    module Commands
        class SmartRename < Jekyll::Command
            class << self
                def init_with_program(prog)
                    prog.command(:peruse) do |c|
                        c.syntax "peruse [OPTIONS]"
                        c.description 'Peruse the files in your site for needlessly large files. Optionally provide a target directory.'
                
                        c.option 'path', '-p PATH', 'Relative path from site source to peruse. All if not provided.'
                        add_build_options(c)
                
                        c.action do |args, options|
                            provided_path = options['path']
                            all_files = false
                            if provided_path == nil then
                                Jekyll.logger.warn 'No chosen path, search all folders. May take a while!'
                                all_files = true
                            end
                            
                            # Jekyll.logger.info 'Looking to rename/move ' + file_path + ' to ' + new_path

                            if provided_path != nil and not Dir.exists?(provided_path)
                                raise Errors::FatalException,
                                    "Directory not found."
                            end
                            file_data = Hash.new
                            files = []
                            if all_files then
                                files = Dir.glob('**/*.*')
                            else
                                files = Dir.glob(provided_path + '/**/*.*')
                            end
                            for file in files do
                                if file.include? 'vendor' or file.include? '_site' then next end
                                file_data[file] = File.size(file)
                            end
                            to_output = []
                            git_issues = []
                            file_data.each_with_index do |(key, value), index|
                                if value > 1_000_000 then
                                    to_output.append('File %s greater than 1MB (%d B). Consider necessity.' % [key, value])
                                end
                                if key.include? '.png' or key.include? '.PNG' then 
                                    to_output.append('File %s is a PNG. Consider converting/replacing with JPEG.' % [key])
                                end
                                if value > 9_000_000 then
                                    git_issues.append('File %s greater than 9MB (%d B). Please remove.' % [key, value])
                                end
                            end
                            if to_output.length > 0 then
                                Jekyll.logger.warn 'Optimal image/asset size for websites is < 400kb.'
                                Jekyll.logger.warn 'Files larger than this can severely impact user experience.'
                                Jekyll.logger.warn 'Downloadable assets (PDFs, ZIPs, Tars, etc...) larger than this but below the Git threshold are okay.'
                                for warning in to_output do
                                    Jekyll.logger.info warning
                                end
                            end
                            if git_issues.length > 0 then
                                Jekyll.logger.error 'Single files ~>= 10MB severely impact the performance of your Git repo.'
                                Jekyll.logger.error 'If you need to host a file larger than this, consider hosting it elsewhere and not in your Git repo.'
                                for warning in git_issues do
                                    Jekyll.logger.info warning
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end