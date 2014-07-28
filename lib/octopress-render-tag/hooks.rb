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
      pre_render
      do_layout(payload, { no_layout: nil })
      post_render
    end

    def hooks
      if self.site.respond_to? :page_hooks
        self.site.page_hooks
      else
        []
      end
    end

    def pre_render
      self.hooks.each do |hook|
        hook.pre_render(self)
      end
    end

    def post_render
      self.hooks.each do |hook|
        hook.post_render(self)
      end
    end
  end
end
