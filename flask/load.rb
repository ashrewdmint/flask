require 'yaml'

module Flask
  
  def self.load(*args)
    Load.all(*args)
  end
  
  # Loads config files.
  class Load
    ROOM_RESERVED_KEYS = %w(exits items)
    ROOM_DIRECTIONS = %w(north east south west)
    
    @path = 'config/'
    
    def self.all(path = nil)
      @path = path if path
      items
      rooms
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
        
        item_class = get_or_create_class(name, Item)
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
        room_class = get_or_create_class(name, Room)
        
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
  
    # TODO: This should load stuff in the context of the extended Adventure class.
    #
    # Find a class, or create it if it does not exist
    
    def self.get_or_create_class(name, superclass = nil)
      name = Inflector.camelize(name)
      unless Object.const_defined?(name.to_sym)
        room_class = if superclass
          Class.new(superclass) {}
        else
          Class.new {}
        end
        Object.const_set(name, room_class)
      else
        Object.const_get(name)
      end
    end
    
    def self.get_class(name)
      name = Inflector.camelize(name).to_sym
      Object.const_get(name.to_sym)
    end
  end
  
end