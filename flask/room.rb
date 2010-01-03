module Flask

  class Door
    attr_accessor :direction, :destination
    
    def initialize(dir, dest)
      direction = dir
      destination = dest
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
      @inventory  = Inventory.new
      @parent     = parent if parent.is_a?(Hallway)
      @visited    = false
      self.name   = Nameable.to_underscore_case(self.class)
      
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
    
  public
    
    def default_responders
      listen 'look' do
        description
      end

      listen 'exits' do
        exits
      end
    end
  
    def description
      data[:description]
    end
  
    def exits
      data[:exits]
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
  
    def go(location, room = nil, &block)
      return unless @parent
      trigger = "(go( to)? )?#{location}"
    
      if room
        listen trigger do
          @parent.enter room
        end
      elsif block
        listen trigger do
          block.call
        end
      end
    end
  
    def new_item(name, description, take_message)
      inventory << Item.new(name, description, take_message)
      item = inventory[name]
      name = item.name
    
      listen "(get|take) #{name}" do
        if inventory[name]
          inventory.give(name, parent.player.inventory)
          item.take_message
        else
          "You already took that."
        end
      end
    end
    
    # Doorways
    
    def self.doorways
      @doorways = [] unless @doorways
      @doorways
    end
    
    def doorways
      self.class.doorways
    end

    def self.new_door(dir, dest)
      return if door_at(dir)
      doorways << Door.new(dir, dest)
    end
    
    def new_door(*args)
      self.class.new_door(*args)
    end

    def self.door_at(direction)
      doorways.each do |door|
        return door.destination if door.direction == direction
      end
      false
    end
    
    def door_at(*args)
      self.class.door_at(*args)
    end
  end
  
end