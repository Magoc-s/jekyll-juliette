require 'fileutils'

module Jekyll
    module Commands
        class Details < Jekyll::Command
            class << self
                def init_with_program(prog)
                    prog.command(:details) do |c|
                        c.syntax "details [OPTIONS]"
                        c.description 'Get details on the overall health of your website repo/directory.'
                        c.option 'build_options', '-b OPTIONS', 'Build options for dummy build.'
                        add_build_options(c)

                        c.action do |args, options|
                            Jekyll.logger.info 'Building site object to reference against... (this may take a bit)'
                            site_ref = Juliette::DummyBuild.new(options)
                            referenced_images = []
                            unreferenced_pages = []
                            bad_image_locations = []
                            all_page_files = Dir.glob('**/*.{md,MD,html,HTML}')
                            site_ref_pages = site_ref.instance_variable_get(:@page_relative_paths)
                            all_image_files = Dir.glob('**/*.{jpg,jpeg,png,PNG,JPG,JPEG}')

                            Jekyll.logger.info 'Checking pages...'
                            for page in all_page_files do
                                if page.include? '_site/' or page.include? 'vendor/' then next end
                                if not site_ref_pages.include? page then unreferenced_pages.append page end
                            end

                            # @site_hash["site"]["pages"]
                            Jekyll.logger.info 'Checking image references... (this may take a while)'
                            for page in site_ref.instance_variable_get(:@site_hash)["site"]["pages"] do
                                page_content = page.content
                                for image in all_image_files do
                                    if image.include? '_site' or image.include? 'vendor' then next end
                                    image_bn = File.basename(image)
                                    if not File.dirname(image).include? 'assets' and not bad_image_locations.include? image then 
                                        bad_image_locations.append(image) 
                                    end
                                    if not referenced_images.include? image and page_content.include? image_bn then 
                                        referenced_images.append image 
                                    end
                                end
                            end
                            unreferenced_images = []
                            all_image_files.map { |image| if not referenced_images.include? image and not (image.include? '_site' or image.include? 'vendor') then unreferenced_images.append image end}
                            
                            Jekyll.logger.info '----------------------' 
                            Jekyll.logger.warn 'Results:' 
                            unreferenced_pages.map { |page| Jekyll.logger.info "Unlisted page #{page}, archive?" }
                            unreferenced_images.map { |image| Jekyll.logger.info "Unlisted image #{image}, remove?" }
                            bad_image_locations.map { |bad_img| Jekyll.logger.warn "Image #{bad_img} is not in assets dir, move?" }
                        end
                    end
                end
            end
        end
    end
end