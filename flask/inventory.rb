module Flask
  
  # A game item. Extend this to create different types of items
  # such as "FlashlightItem" or "BaubleItem".
  
  class Item
    include Nameable
    
    def initialize
      self.name = self.class
    end
    
    def description
      data[:description]
    end
    
    def take_message
      data[:take_message]
    end
    
    def data
      self.class.data
    end
    
    def self.data
      @data || {}
    end
    
    def self.data=(hash)
      @data = hash if hash.is_a?(Hash)
    end
  end
  
  # A group of Items. Room and Player both posess an Inventory.
  
  class Inventory
    attr_reader :items

    def initialize
      @items = []
    end

    def <<(item)
      if item.is_a?(Item)
        @items << item
      else
        false
      end
    end

    def push(item)
      self << item
    end

    def [](name)
      @items.each do |i|
        return i if i.name_matches? name
      end
      nil
    end

    def find(name)
      self[name]
    end

    def delete_at(*names)
      names.each do |name|
        @items.delete_if do |i|
          i.name_matches? name
        end
      end
    end
    
    # Removes the item from this inventory and adds it to another inventory
    def give(name, inventory)
      if item = self[name] and inventory.is_a?(Inventory)
        delete_at(name)
        inventory << item
      end
    end
    
    # Prints the inventory out
    def show
      return false if @items.length == 0
      @items.each do |item|
        puts "#{item.name}: #{item.description}"
      end
    end
  end

end