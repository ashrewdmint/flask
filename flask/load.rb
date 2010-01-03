require 'yaml'

module Flask
  
  def self.load(const, path)
    Load.context = const
    Load.config(path)
  end
  
  # Loads config files.
  class Load
    ROOM_RESERVED_KEYS = %w(exits items)
    
    @path = 'config/'
    
    def self.config(path = nil)
      @path = path if path
      items
      rooms
    end
    
    # Set the constant to load from.
    
    def self.context=(const)
      @context = const
    end
    
    # Find the constant to load from. Defaults to object.
    # TODO: Add error message
    
    def self.context(mod = nil)
      if @context
        context = Object.const_get(Inflector.camelize(@context))
        if mod
          mod = Inflector.camelize(mod)
          unless context.const_defined?(mod)
            context.const_set(mod, Module.new {})
          end
          context = context.const_get(mod)
        end
        context
      else
        Object
      end
    end
    
  private
    
    # Loads Item classes as defined in items.yaml
    
    def self.items
      items = YAML.load_file("#{@path}items.yaml")
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
      items = YAML.load_file("#{@path}rooms.yaml")
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
  
    # Find a class, or create it if it does not exist
    
    def self.get_or_create_class(name, superclass = nil, mod = nil)
      name = Inflector.camelize(name)
      
      unless context(mod).const_defined?(name)
        room_class = if superclass
          Class.new(superclass) {}
        else
          Class.new {}
        end
        context(mod).const_set(name, room_class)
      else
        context(mod).const_get(name)
      end
    end
    
    def self.room_class(name)
      get_or_create_class(name, Room, 'Rooms')
    end
    
    def self.item_class(name)
      get_or_create_class(name, Item, 'Items')
    end
  end
  
end