require 'yaml'

module Flask
  
  def self.load(const, path)
    Load.context = const
    Load.config(path)
  end
  
  # Loads config files.
  class Load
    ROOM_RESERVED_KEYS = %w(exits items)
    
    def self.config(constant, path = nil)
      @constant = constant
      @path = path || 'config/'
      items
      rooms
    end
    
  private  
    
    # Return the right constant in order to load something. The optional
    # second argument allows you to specify a module (like :rooms), which
    # would cause the classes to be loaded into SomeConstant::Rooms.
    #
    # If the module doesn't exist, it will be created for you.
    
    def self.constant(mod = nil)
      constant = @constant
      if mod
        begin
          mod = Inflector.camelize(mod)
          unless constant.const_defined?(mod)
            constant.const_set(mod, Module.new {})
          end
          constant = constant.const_get(mod)
        rescue
          raise LoadError, 'no constant supplied'
        end
      end
      constant
    end
    
    # Loads Item classes as defined in items.yaml
    
    def self.items
      return unless items = YAML.load_file("#{@path}items.yaml")
      items.each_pair do |name, hash|
        
        # Turn string names into lowercase symbols
        hash.each_pair do |key, value|
          hash.delete(key)
          sym = key.to_s.downcase.to_sym
          hash[sym] = value
        end
        
        item_class = item_class(name)
        item_class.data = hash
      end
    end
    
    # Loads Room classes as defined in rooms.yaml
    
    def self.rooms
      return unless items = YAML.load_file("#{@path}rooms.yaml")
      items.each_pair do |name, hash|
        data = {}
        reserved = {}
        
        # Collect data
        hash.each_pair do |key, value|
          if ROOM_RESERVED_KEYS.include? key
            reserved[key.downcase] = value
          else
            data[key.downcase.to_sym] = value.chomp
          end
        end
        
        # If the room class does not exist, create it
        room_class = room_class(name)
        
        # Set data
        room_class.data = data
        
        # Add exits
        if exits = reserved['exits']
          exits.each_pair do |direction, details|
            two_way = true
            opposite_direction = nil
            
            if details.is_a?(String)
              destination_room  = details
            else
              destination_room   = details['room']
              two_way            = details['two_way']
              opposite_direction = details['opposite_direction']
            end
            
            return unless destination_room
            room_class.new_door(direction, destination_room, two_way, opposite_direction)
          end
        end
        
        # Add items
        if items = reserved['items']
          items.each do |item|
            room_class.add_item(item)
          end
        end
      end
    end
    
  public
  
    # Get a class, or create it if it does not exist
    
    def self.get_or_create_class(name, superclass = nil, mod = nil)
      name = Inflector.camelize(name)
      
      begin
        unless constant(mod).const_defined?(name)
          room_class = if superclass
            Class.new(superclass) {}
          else
            Class.new {}
          end
          constant(mod).const_set(name, room_class)
        else
          constant(mod).const_get(name)
        end
      rescue ArgumentError
        raise LoadError, 'class name must not be empty'
      end
    end
    
    # Get or create a Room class
    
    def self.room_class(name)
      get_or_create_class(name, Room, :rooms)
    end
    
    # Get or create an Item class
    
    def self.item_class(name)
      get_or_create_class(name, Item, :items)
    end
  end
  
end