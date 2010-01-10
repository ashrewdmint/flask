module Flask
  
  class Player
    attr_reader :inventory
    attr_accessor :name

    def initialize
      @inventory = Inventory.new
    end

    def has?(item)
      !! inventory[item]
    end

    def give(name, inventory)
      inventory.give(name, inventory)
    end
  end
  
end