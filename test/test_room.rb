require 'helper'

class RoomTest < Test::Unit::TestCase
  context 'Door' do
    setup do
      @door = Flask::Door.new('north', :some_room, true)
    end
    
    should "have direction, destination, two way, and opposite direction methods" do
      methods = %w(direction destination two_way opposite_direction)
      assert (@door.methods & methods).sort == methods.sort
    end
  end
end