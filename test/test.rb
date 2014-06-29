require 'colorator'
has_failed = false

system('rm -rf _site')
system('jekyll build')

diff = `diff _site/index.html expected.html`

abort "Failed with diff: #{diff}" if diff.size > 0

puts "passed".green
