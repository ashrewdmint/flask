require 'helper'

class LoadTest < Test::Unit::TestCase
  should "let you specify where to load config files" do
    error_raised = false
    begin
      Flask::Load.config(TestAdventure, 'some/other/path/')
    rescue Exception => e
      error_raised = true
      assert e.to_s =~ /no such file/i
    end
    assert error_raised
  end
  
  should "throw LoadError when no constant is supplied" do
    error_raised = false
    begin
      Flask::Load.config('I am not a constant')
    rescue Flask::LoadError
      error_raised = true
    end
    assert error_raised
  end
  
  should "load classes inside an extended Adventure class" do
    TestAdventure.new
    assert TestAdventure::Rooms::Test
  end
  
  should "extend already loaded classes" do
    room = Class.new(Flask::Room) do
      def self.hello
        true
      end
    end
    
    TestAdventure.const_set('Rooms', Module.new {})
    TestAdventure::Rooms.const_set('Test', room)
    TestAdventure.new
    
    assert TestAdventure::Rooms::Test.hello
    assert TestAdventure::Rooms::Test.data.length > 0
  end
end