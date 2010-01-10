require 'helper'

class LoadTest < Test::Unit::TestCase
  should "throw LoadError when no constant is supplied" do
    error_raised = false
    
    begin
      Flask::Load.config('I am not a constant')
    rescue Flask::LoadError
      error_raised = true
    end
    
    assert error_raised
  end
end