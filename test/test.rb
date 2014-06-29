require 'colorator'
has_failed = false

system('rm -rf _site')
system('jekyll build')

diff1 = `diff _site/index.html expected/index.html`
diff2 = `diff _site/license.html expected/license.html`

abort "Failed with diff: #{diff1}" if diff1.size > 0
abort "Failed with diff: #{diff2}" if diff2.size > 0

puts "passed".green
