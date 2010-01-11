require 'helper'

class RoomTest < Test::Unit::TestCase
  context 'Door' do
    setup do
      @door = Flask::Door.new('north', :some_room, true)
    end
    
    should "have direction, destination, two_way, and opposite_direction properties" do
      methods = %w(direction destination two_way opposite_direction)
      methods = methods + methods.collect {|item| item + '='}
      assert (@door.methods & methods).sort == methods.sort
    end
    
    should "never have a destination with :: syntax in it" do
      @door.destination = 'Some::Other::Thing'
      assert @door.destination == :thing
    end
    
    should "automatically reverse cardinal directions" do
      compass = {'north' => 'south', 'east' => 'west'}
      compass = compass.merge(compass.invert)
      
      @door.opposite_direction = nil
      
      compass.each_pair do |direction, opposite|
        @door.direction = direction
        assert @door.opposite_direction == opposite
      end
    end
    
    should "allow custom directions and custom opposite directions" do
      @door.direction = 'orange'
      @door.opposite_direction = 'cyan'
      
      assert @door.direction == 'orange'
      assert @door.opposite_direction == 'cyan'
    end
  end
  
  context 'Room' do
    setup do
      @room = Flask::Room.new(Flask::Adventure.new)
    end
    
    should "be a ResponderCollection" do
      assert @room.class.superclass == Flask::ResponderCollection
    end
    
    should "have a parent" do
      assert @room.parent.is_a?(Flask::Adventure)
    end
    
    should "have doors" do
      assert @room.doors
    end
    
    should "have an inventory" do
      assert @room.inventory.is_a?(Flask::Inventory)
    end
    
    should "add items" do
    end
    
    should "give items" do
    end
  end
end