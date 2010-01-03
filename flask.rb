# Load all flask files, in the correct order

files = %w(modules modules responder inventory room hallway player adventure)

files.each do |file|
  require File.dirname(__FILE__) + '/flask/' + file
end