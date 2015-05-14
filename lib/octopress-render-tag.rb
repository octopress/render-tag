require "octopress-render-tag/version"
require "octopress-render-tag/hooks"
require "octopress-tag-helpers"
require "jekyll"

module Octopress
  module Tags
    module Render
      class Tag < Liquid::Tag
        SYNTAX = /(\S+)(.+)?/

        attr_reader :tag_markup
        attr_reader :tag_name
        attr_reader :raw
        attr_accessor :filters

        def initialize(tag_name, markup, tokens)
          super

          @tag_markup = markup
          @tag_name = tag_name

          if matched = markup.strip.match(/^(\s*raw\s)?(.+?)(\sraw\s*)?$/)
            @tag_markup = $2
            @raw = true unless $1.nil? and $3.nil?
          end
        end

        def render(context)
          return unless @markup = parse_markup(context)

          content = read(@markup, context)

          if matched = content.match(/\A-{3}(?<vars>.+[^\A])-{3}\n(?<content>.+)/m)
            local_vars = SafeYAML.load(matched['vars'].strip)
            content = matched['content'].strip
          end

          if raw
            content
          else

            content = strip_raw(content)

            partial = Liquid::Template.parse(content)
            content = context.stack {
              context['include'] = parse_params(context)
              if local_vars
                context['page'] = Jekyll::Utils.deep_merge_hashes(context['page'], local_vars)
              end
              partial.render!(context)
            }.strip

            content = replace_raw(content)
            content = parse_convertible(content, context).strip

            unless content.nil? || filters.nil?
              content = TagHelpers::Var.render_filters(content, filters, context)
            end

            content
          end
        end

        def parse_params(context)
          if Jekyll::Tags::IncludeTag.respond_to?(:parse)
            include_tag = Jekyll::Tags::IncludeTag.parse('include', @markup, [], {})
          else
            include_tag = Jekyll::Tags::IncludeTag.new('include', @markup, [])
          end
          include_tag.parse_params(context)
        end

        # Parses special markup, handling vars, conditions, and filters
        # Returns:
        #  - render tag path or nil if markup conditionals evaluate false
        #
        def parse_markup(context)
          # If conditional statements are present, only continue if they are true
          #
          return unless markup = TagHelpers::Conditional.parse(tag_markup, context)

          # If there are filters, store them for use later and strip them out of markup
          #
          if matched = markup.match(TagHelpers::Var::HAS_FILTERS)
            markup = matched['markup']
            @filters = matched['filters']
          end

          # If there is a ternary expression, replace it with the true result
          #
          markup = TagHelpers::Var.evaluate_ternary(markup, context)

          # Paths may be variables, check context to retrieve proper path
          #
          markup = TagHelpers::Path.parse(markup, context)

          markup
        end

        def strip_raw(content)
          @raw_content = {}
          content.gsub /{%\s*raw\s*%}(.+?){% endraw %}/m do
            data = $1
            key = Digest::MD5.hexdigest(data)
            @raw_content[key] = "{% raw %}#{data}{% endraw %}"
            key
          end
        end

        def replace_raw(content)
          @raw_content.each { |k, v| content.sub!(k, v) }
          content
        end

        def read(markup, context)
          path = markup.match(SYNTAX)[1]
          @path = TagHelpers::Path.expand(path, context)
          begin
            File.open(@path).read
          rescue
            raise IOError.new "Render failed: {% #{@tag_name} #{@og_markup}%}. The file '#{path}' could not be found at #{@path}."
          end
        end
        
        def parse_convertible(content, context)
          page = Partial.new(context.registers[:site], @path, content)
          page.render({})
          page.output.strip
        end
        
      end
    end
  end
end

Liquid::Template.register_tag('render', Octopress::Tags::Render::Tag)
Liquid::Template.register_tag('render_partial', Octopress::Tags::Render::Tag)

if defined? Octopress::Docs
  Octopress::Docs.add({
    name:        "Octopress Render Tag",
    gem_name:    "octopress-render-tag",
    description: "Embed files directly from the file system. This tag also supports conditional rendering, in-line filters.",
    path:        File.expand_path(File.join(File.dirname(__FILE__), "../")),
    type:        "tag",
    source_url:  "https://github.com/octopress/render-tag",
    version:     Octopress::Tags::Render::VERSION
  })
end
