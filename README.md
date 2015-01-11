# Octopress Render Tag

Use the render tag to embed files directly from the file system. This tag also supports conditional rendering, in-line filters.

[![Build Status](https://travis-ci.org/octopress/render-tag.svg)](https://travis-ci.org/octopress/render-tag)
[![Gem Version](http://img.shields.io/gem/v/octopress-render-tag.svg)](https://rubygems.org/gems/octopress-render-tag)
[![License](http://img.shields.io/:license-mit-blue.svg)](http://octopress.mit-license.org)

## Installation

If you're using bundler add this gem to your site's Gemfile in the `:jekyll_plugins` group:

    group :jekyll_plugins do
      gem 'octopress-render-tag'
    end

Then install the gem with Bundler

    $ bundle

To install manually without bundler:

    $ gem install octopress-render-tag

Then add the gem to your Jekyll configuration.

    gems:
      -octopress-render-tag

## Usage

### How file paths work

By default paths passed to the render tag are relative to the site source directory.

```
{% render _file.html %}      // relative to site source
```

Relative paths like these are relative to the current file.

<!-- title:"A page in the directory 'some_dir'" -->
```
{% render ./_file.html %}              // renders some_dir/_file.html
{% render ../other_dir/_file.html %}   // renders other_dir/_file.html
```

You can even render files relative to system paths, however, remember that these renders will only work if
the site is rendered on your system. If these files move, your site will fail to build.

```
{% render /_file.html %}     // relative to system root
{% render ~/_file.html %}    // relative to system user
```

### Render tag features

Render partials stored as a variable.

```html
---
theme: _post_themes/feature.css
---

<style>{% render page.theme %}</style>
```

Render partials conditionally, using `if`, `unless` and ternary logic.

```
{% render ./post-footer.html if post.footer %}
{% render ./page-footer.html unless page.footer == false %}
{% render (post ? ./post-footer.html : ./page-footer.html) %}
```

Filter partials.

```
{% render ./foo.html %}            //=> Yo, what's up
{% render ./foo.html | upcase %}   //=> YO, WHAT'S UP
```

Automatic template processing. Markdown and textile files can be embedded in HTML files.

```
{% render _test.md %}   // renders as html
```

If you want, you can disable template processing.

```
{% render raw _test.md %}  // Markdown is not processed
```

## Contributing

1. Fork it ( https://github.com/octopress/render-tag/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
