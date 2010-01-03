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
    
    def self.items
      items = YAML.load_file("#{@path}items.yaml")
      items.each_pair do |name, hash|
        #puts name
      end
    end
    
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
        
        # Add items to room
        if items = reserved['items']
          items.each do |item|
            # Do something with the item
          end
        end
        
        # If the room class does not exist, create it
        room_class = find_or_create_class(name, Room)
        
        # Set data
        room_class.data = data
        
        # Add exits
        if exits = reserved['exits']
          exits.each_pair do |direction, details|
            if details.is_a?(String)
              destination_room = details
              two_way = true
            else
              destination_room = details['room']
              two_way = details['two_way']
            end
            
            return unless destination_room
            room_class.new_door(direction, destination_room)
          end
        end
      end
    end
    
    # Find a class, or create it if it does not exist
    def self.find_or_create_class(name, superclass = nil)
      unless Object.const_defined?(name.to_sym)
        room_class = if superclass
          Class.new(superclass) do; end
        else
          Class.new do; end
        end
        Object.const_set(name, room_class)
      else
        Object.const_get(name)
      end
    end
  end
  
end