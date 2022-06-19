module Jekyll
    module Juliette
        class DummyBuild
            def initialize(options)
                Jekyll.logger.adjust_verbosity(options)

                options = Jekyll::Command.configuration_from_options(options)
                site = Jekyll::Site.new(options)

                if options.fetch("skip_initial_build", false)
                    Jekyll.logger.warn "Build Warning:", "Skipping the initial build." \
                                    " This may result in an out-of-date site."
                else
                    t = Time.now
                    source      = File.expand_path(options["source"])
                    destination = File.expand_path(options["destination"])
                    incremental = options["incremental"]
                    Jekyll.logger.info "Source:", source
                    Jekyll.logger.info "Destination:", destination
                    Jekyll.logger.info "Generating..."
                    Jekyll::Command.process_site(site)

                    Jekyll.logger.info "", "done in #{(Time.now - t).round(3)} seconds."
                end

                if options.fetch("watch", false)
                    External.require_with_graceful_fail "jekyll-watch"
                    Jekyll::Watcher.watch(options, site)
                end
                @dummy_site = site
                @site_hash = site.site_payload
                @page_relative_paths = @site_hash["site"]["pages"].map { |page| page.relative_path }
            end
        end
    end
end