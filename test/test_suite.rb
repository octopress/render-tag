require 'colorator'
require 'find'
require 'safe_yaml'

def run_tests(options={})
  @diffs ||= {}
  @failures = []

  test_file = options[:file]  || '_tests.yml'
  test_list = default_array(options[:tests])
  tests = default_array(SafeYAML.load_file(test_file))

  if !test_list.empty?
    list = []
    test_list.each do |t|
      list << tests[t - 1] if tests[t - 1]
    end
    tests = list
  end

  tests.each do |test, index|
    compare = default_array(test['compare'])
    missing = default_array(test['missing'])
    before  = default_array(test['before'])
    after   = default_array(test['after'])

    before.each {|cmd| system(cmd) }

    if test['build']
      system("jekyll build --trace")
    end

    compare.each do |files|
      f = files.split(',')
      diff(f[0].strip, f[1].strip)
    end

    missing.each {|file| dont_find(file) }

    after.each {|cmd| system(cmd) }

  end
  
  print_results
end

def default_array(option)
  o = option || []
  o = [o] unless o.is_a?(Array)
  o
end

def diff(a, b)
  if File.directory?(a)
    diff_dirs(a, b)
  else
    exists = true

    [a,b].each do |f|
      if !File.exists?(f)
        @failures << "File not found: #{f}"
        exists = false
        pout 'F'.red
      end
    end

    if exists
      file_diff = `diff #{a} #{b}`
      if !file_diff.empty?
        @diffs["Compared #{a.green} to #{b.red}"] = file_diff 
        pout 'F'.red
      else
        pout '.'.green
      end
    end
  end
end

def format_diff(diff)
  "#{diff.gsub(/\A.+?\n/,'').gsub(/^[^><].+/,'---').gsub(/^>.+/){|m| 
    m.green
  }.gsub(/^(<.+?)$/){ |m| 
    m.red
  }}"
end

def check_diffs
  @diffs.each do |title, diff|
    @failures << "Failed - #{title}\n#{format_diff(diff)}\n"
  end
end

# Find all files in a given directory
#
def dir_files(dir)
  Find.find(dir).to_a.reject!{|f| File.directory?(f) }
end

# Recursively diff two directories
#
# This will walk through dir1 and diff matching paths in dir2
#
def diff_dirs(dir1, dir2)
  common_dir_files(dir1, dir2).each do |file|
    a = File.join(dir1, file)
    b = File.join(dir2, file)
    diff(a,b)
  end
end

# Return files that exist in both directories (without dir names)
#
def common_dir_files(dir1, dir2)
  dir1_files = dir_files(dir1).map {|f| f.sub(dir1,'') }
  dir2_files = dir_files(dir2).map {|f| f.sub(dir2,'') }

  common = dir1_files & dir2_files
  check_missing(dir1, dir1_files, common)
  check_missing(dir2, dir2_files, common)

  common
end

def check_missing(dir, files, common)
  dir_missing = files - common
  if !dir_missing.empty?
    @failures << "Files missing from #{dir}/".red
    dir_missing.each {|f| @failures << "- #{f}"}
    pout "F".red
  end
end

def dont_find(file)
  if File.exists?(file)
    @failures << "File #{file} shouldn't exist."
    pout "F".red
  else
    pout ".".green
  end
end

# Print a single character without a newline
#
def pout(str)
  print str
  $stdout.flush
end


def print_results
  puts "" # line break
  check_diffs
  if !@failures.empty?
    abort @failures.join("\n")
  else
    puts "passed".green
  end
end
