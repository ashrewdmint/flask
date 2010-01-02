require 'yaml'

module Flask
  
  def self.load(*args)
    Load.all(*args)
  end
  
  class Load
    ROOM_RESERVED_KEYS = %w(exits items)
    ROOM_DIRECTIONS = %w(north east south west)
    
    @path = 'config/'
    
    def self.all(mod, path = nil)
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
        
        block = Proc.new do
          @data = data
        end
        
        # Create class
        room_class = Class.new(Room, &block)
        
        # If the class already exists, add stuff to it
        if Object.const_defined?(name.to_sym)
          Object.const_get(name).class_eval(&block)
        else
          # If not, create the class
          Object.const_set(name, room_class)
        end
      end
    end
  end
  
end