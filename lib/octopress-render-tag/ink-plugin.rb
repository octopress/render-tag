begin
  require 'octopress-ink'

  Octopress::Ink.add_plugin({
    name:        'Wrap Tag',
    assets_path: File.join(File.expand_path(File.dirname(__FILE__)), '../../assets' ),
    description: "Embed files directly from the file system. This tag also supports conditional rendering, in-line filters."
  })
rescue LoadError
end

