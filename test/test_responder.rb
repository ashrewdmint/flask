require 'helper'

class ResponderTest < Test::Unit::TestCase
  context "Responder" do
    should "store a block of code alongside a regex" do
      responder = Flask::Responder.new 'test' do; end
    
      assert responder.trigger.class == Regexp
      assert responder.block.class == Proc
    end
  
    should "allow you to pass a regex instead of a string for the trigger" do
      responder = Flask::Responder.new /test/ do; end
      assert responder.trigger == /test/
    end
  
    should "respond to a string or symbol that matches the trigger" do
      responder = Flask::Responder.new 'test' do; true end
      assert responder.respond 'test'
      assert responder.respond :test
    end
  end
  
  context "ResponderCollection" do
    setup do
      @collection = Flask::ResponderCollection.new
      @collection.listen 'something' do; end
    end
    
    should "store an array of Responders or ResponderCollections" do
      @collection.responders.each do |responder|
        assert responder.is_a?(Flask::Responder) or responder.is_a?(Flask::ResponderCollection)
      end
    end
    
    should "add new Responders" do
      new_responder = Flask::Responder.new('another thing') do; end
      @collection << new_responder
      assert @collection.responders.last == new_responder
    end
    
    should "easily add new Responders" do
      @collection.listen 'another thing' do; end
      assert @collection.responders.last.trigger =~ 'another thing'
    end
    
    should "add new ResponderCollections" do
      new_collection = Flask::ResponderCollection.new
      @collection << new_collection
      assert @collection.responders.last == new_collection
    end
    
    should "easily add new ResponderCollections" do
      @collection.collection :collection do |c|
        c.listen 'why hello there' do; end
      end
      
      assert @collection.listen 'why hello there'
    end
    
    should "find Responders by name" do
      assert @collection[:something].is_a?(Flask::Responder)
    end
    
    should "delete Responders by name" do
      @collection.listen 'something else' do; end
      @collection.listen 'yet another thing' do; end
      @collection.delete_at :something_else, 'yet another thing'
      
      assert ! @collection[:yet_another_thing]
      assert ! @collection['something else']
    end
    
    should "remove the most recent Responder or ResponderCollection" do
      length = @collection.responders.length
      @collection.pop
      assert @collection.responders.length == length - 1
    end
    
    should "get a response from newest to oldest" do
      response = nil
      
      @collection.listen('*') { response = 2 }
      @collection.listen('*') { response = 1 }
      @collection.respond 'anything'
      
      assert response == 1
    end
    
    should "continue finding responses if a responder returns :pass_through" do
      responses = []
      
      @collection.listen('*') { responses << 3; :pass_through }
      @collection.listen('*') { responses << 2; :pass_through }
      @collection.listen('*') { responses << 1; :pass_through }
      @collection.respond 'anything'
      
      assert responses == [1, 2, 3]
    end
  end
end