module Flask

  class Door
    attr_accessor :direction, :destination, :two_way, :opposite_direction
    
    def initialize(direction, destination, two_way = true, opposite_direction = nil)
      two_way = true if two_way == nil
      
      self.direction   = direction
      self.destination = destination
      self.two_way     = two_way
      self.opposite_direction = opposite_direction
    end
    
    def destination=(destination)
      @destination = Inflector.underscore(Inflector.get_class_name(destination)).to_sym
    end
    
    def opposite_direction
      @opposite_direction || self.class.reverse_direction(direction)
    end
    
    def self.reverse_direction(direction)
      compass = {'north' => 'south', 'west' => 'east'}
      compass[direction] || compass.invert[direction]
    end
  end
  
  class Room < ResponderCollection
    attr_reader :parent, :inventory
    
    # Data class instance variable
    class << self; attr_accessor :data end
    def self.data; @data || {} end
    def data; self.class.data end
    
    def initialize(parent)
      @responders = []
      @parent     = parent if parent.is_a?(Hallway)
      @visited    = false
      self.name   = self.class
      
      before_setup
      default_responders
      create_items
      create_responders
      setup
    end
    
  private
  
    def before_setup; end
    def create_items; end
    def create_responders; end
    def setup; end
    
    # TODO: Move :go responder into Adventure#last
    
    def default_responders
      listen 'look' do
        description
      end

      listen 'exits' do
        exits
      end
      
      listen('(go )?(.+)', :go) do |matches|
        direction = matches[2]
      
        if new_room = door_at(direction)
          travel_to(new_room)
        else
          :pass_through
        end
      end
    end
    
  public
  
    def description
      data[:description]
    end
  
    def exits
      self.class.exits.join(',')
    end
  
    def enter
      unless @visited or ! data[:intro]
        puts data[:intro]
      end
    
      respond :look
      @visited = true
    end
  
    def leave; end
    
    def travel_to(name)
      parent.enter(name)
    end
    
    # Doorways
    
    def self.doors
      @doors = [] unless @doors
      @doors
    end
    
    # Alias for self.doors
    
    def doors
      self.class.doors
    end

    # Accepts the same arguments as Room.new:
    # direction, destination, two_way, opposite_direction

    def self.new_door(*args)
      door = Door.new(*args)
      
      unless door_at(door.direction)
        doors << door
      end
      
      if door.two_way and door.opposite_direction and
        destination_room = Load.room_class(door.destination)
        
        # Safety measure to prevent an infinite loop.
        # We don't want to create this door if it's already there.
        unless destination_room.door_at(door.opposite_direction)
          destination_room.new_door(door.opposite_direction, self, false)
        end
      end
    end
    
    # Alias for self.new_door
    
    def new_door(*args)
      self.class.new_door(*args)
    end

    def self.door_at(direction)
      doors.each do |door|
        return door.destination if door.direction == direction
      end
      false
    end
    
    # Alias for self.door_at
    
    def door_at(*args)
      self.class.door_at(*args)
    end
    
    # Returns an array of exits

    def self.exits
      return data[:exits] if data[:exits]
      exits = doors
      exits.collect {|door| door.direction.capitalize }
    end
    
    # Inventory
    
    def self.inventory
      @inventory = Inventory.new unless @inventory
      @inventory
    end
    
    # Alias for self.inventory
    
    def inventory
      self.class.inventory
    end
    
    # Adds an item to the inventory
    
    def self.add_item(name)
      inventory << name
    end
    
    # Alias for self.add_item
    
    def add_item(name)
      self.class.add_item(name)
    end
  end
  
end