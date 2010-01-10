require 'helper'

class ResponderTest < Test::Unit::TestCase
  should "store a block of code alongside a regex" do
    responder = Flask::Responder.new 'test' do; end
    
    assert responder.trigger.class == Regexp
    assert responder.block.class == Proc
    
  end
  
  should "allow you to pass a regex instead of a string for the trigger" do
    responder = Flask::Responder.new /test/ do; end
    assert responder.trigger == /test/
  end
end