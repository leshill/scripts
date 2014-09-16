gems = `gem list`.split("\n")
gems.each do |gem_and_ver|
  gem_name = gem_and_ver.split.first
  if !%w(bigdecimal io-console json minitest psych rake rdoc test-unit).include?(gem_name)
    puts "Uninstalling #{gem_name}"
    `gem uninstall -a -I -x --force --no-abort-on-dependent #{gem_name}`
  else
    puts "Skipping default gem #{gem_name}"
  end
end

puts 'Adding bundler...'
`gem install bundler`

puts 'Rebundling...'
`bundle`

puts 'Done.'
