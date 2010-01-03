module Flask

  # A collection of Rooms.
  
  class Hallway
    attr_reader :rooms, :current_room
    
    def initialize
      @rooms = []
    end

    def <<(sym)
      room = Hallway.sym_to_class(sym).new(self)
      @rooms << room if room.is_a?(Room)
    end

    def [](name)
      @rooms.each do |r|
        return r if r.name_matches? name
      end
      nil
    end

    def enter(name)
      @current_room.leave if @current_room
  
      unless @current_room = self[name]
        self << name
        @current_room = @rooms.last
      end
  
      @current_room.enter
    end

    def self.sym_to_class(sym)
      constant = sym.to_s.split('_').collect { |word| word.capitalize }.join
      Object.const_get(constant)
    end
  end
  
end