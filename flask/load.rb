require 'yaml'

module Flask
  
  def self.load_config(dir = 'config/')
    dir = dir + '/' unless dir.slice(-1, 1) == '/'
    Load.items dir + 'items.yaml'
    Load.rooms dir + 'rooms.yaml'
  end
  
  class Load
    ROOM_RESERVED_KEYS = %w(exits items)
    ROOM_DIRECTIONS = %w(north east south west)
    
    def self.items(path)
      items = YAML.load_file(path)
      items.each_pair do |name, hash|
        #puts name
      end
    end
    
    def self.rooms(path)
      rooms = YAML.load_file(path)
      rooms.each_pair do |name, hash|
        data = {}
        reserved = {}

        # Collect data
        hash.each_pair do |key, value|
          if ROOM_RESERVED_KEYS.include? key
            reserved[key] = value
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

        # Add exits
        if exits = reserved['exits']
          exits.each_pair do |direction, info|
            # Do something with the exit
          end
        end

        # Create class
        room_class = Class.new(Room) do
          @data = data
        end

        Object.const_set(name, room_class)
      end
    end
  end
  
end