# Reads how many lines there are in the whole project

with_comments = 0
without_comments = 0

Dir["flask/*.rb"].each do |file|
  File.open(file).each_line do |line|
    without_comments += 1 unless line =~ /\s*#/
    with_comments += 1
  end
end

puts "With comments: #{with_comments}"
puts "Without comments: #{without_comments}"