module Flask
  
  # A simple game object.
  class Item
    attr_reader :name, :description, :take_message
    include Nameable
    
    # "take_message" is shown to the user when the player gets the item.
    def initialize(name, description, take_message)
      self.name = name.to_s
      @description = description
      @take_message = take_message
    end
  end
  
  # A group of Items
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