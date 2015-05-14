# Add support for Octopress hooks
#
module Octopress

  # Create a new page class to allow partials to trigger Octopress Hooks.
  #
  class Partial
    include Jekyll::Convertible
    
    attr_accessor :name, :content, :site, :ext, :output, :data
    
    def initialize(site, name, content)
      @site     = site
      @name     = name
      @ext      = File.extname(name)
      @content  = content
      @data     = { layout: nil } # hack
      
    end
    
    def render(payload)
      do_layout(payload, { no_layout: nil })
    end
  end
end
