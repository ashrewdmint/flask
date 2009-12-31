class Responder
  attr_reader :name, :trigger, :block
  
  def self.regexify(var)
    unless var.is_a?(Regexp)
      var = '.*' if var == '*'
      var = "^#{var}$" unless var =~ /^\^|\$$/
      var = Regexp.new(var)
    end
    var
  end

  def initialize(trigger, &block)
    @name = trigger.is_a?(Regexp) ? trigger.inspect.to_sym : trigger.to_s.to_sym
    @trigger = Responder.regexify(trigger)
    @block = block
  end

  def respond(input)
    input = input.to_s.strip
    if @trigger =~ input
      unless (response = @block.call(input)) == :pass_through
        puts response if response.is_a?(String)
        return true
      end
    else
      false
    end
  end
end

class ResponderCollection
  attr_reader :name, :responders

  def initialize(name = nil, *responders)
    @responders = []
    @name = name and name.to_s.length > 0 ? name.to_s.to_sym : nil
  
    if responders.length > 1
      @responders = responders
    end
  end

  def <<(responder)
    if responder.is_a?(Responder) or responder.is_a?(ResponderCollection)
      @responders << responder
    end
  end

  def push(responder)
    self << responder
  end

  def pop
    @responders.pop
  end
  
  def delete_at(*names)
    names.each do |name|
      @responders = @responders.delete_if do |r|
        r.name == name.to_sym
      end
    end
  end

  def listen(trigger = nil, &block)
    self.<< Responder.new(trigger, &block)
  end
  
  def collection(name, &block)
    collection = ResponderCollection.new(name)
    block.call(collection)
    self << collection
  end

  def respond(input)
    responders.reverse.each do |responder|
      return true if responder.respond(input)
    end
    false
  end
end

class Room < ResponderCollection
  attr_reader :description, :exits
  
  def initialize(parent = nil)
    @responders = []
    @parent = parent if parent.is_a?(Hallway)
    @visited = false
    
    default_responders
    setup
  end
  
  def default_responders
    listen 'look' do
      puts @description
    end
    
    listen 'exits' do
      puts @exits
    end
  end
  
  def setup
    @intro = 'This will run the first time'
    @description = 'Room description'
    @exits = 'There is no way out of here'
  end
  
  def enter
    unless @visited or ! @intro
      @intro
    end
    
    respond :look
    @visited = true
  end
  
  def leave
  end
  
  def go(location, room = nil, &block)
    return unless @parent
    trigger = "(go( to)? )?#{location}"
    
    if room
      listen trigger do
        @parent.enter room
      end
    elsif block
      listen trigger do
        block.call
      end
    end
  end
end

class Hallway
  attr_reader :rooms, :current_room
  
  def initialize()
    @rooms = {}
  end
  
  def <<(sym)
    return unless sym.is_a?(Symbol)
    room = Hallway.sym_to_class(sym).new(self)
    if (room.is_a?(Room))
      @rooms[sym]= room
    end
  end
  
  def push(room)
    self << room
  end
  
  def [](name)
    @rooms.each_pair do |key, value|
      return value if key == name
    end
    false
  end
  
  def find(name)
    self[name]
  end
  
  def enter(name)
    @current_room.leave if @current_room
    @current_room = find(name) ? find(name) : self << name
    @current_room.enter
  end
  
  def self.sym_to_class(sym)
    return sym unless sym.is_a?(Symbol)
    constant = sym.to_s.split('_').collect { |word| word.capitalize }.join
    Kernel.const_get(constant)
  end
end

class Adventure < Hallway
  attr_reader :player
  
  def initialize
    super
    
    @first = ResponderCollection.new
    @last = ResponderCollection.new
    @player = nil
    @in_progress = true
    
    default_responders
    setup
  end
  
  def default_responders
    @last.listen '*' do |input|
      "I don't know how to respond to '#{input}'"
    end
  end
  
  def setup
  end
  
  def respond(input)
    return unless in_progress?
    unless @first.respond(input)
      unless @current_room and @current_room.respond(input)
        @last.respond(input)
      end
    end
  end

  def stop
    @in_progress = false
  end
  
  def room
    @rooms[@room]
  end
  
  def room=(constant_name)
    constant_name.to_s.split('_').collection { |word| word.capitalize }.join
    @current_room = Kernel.const_get(constant).new
  end
  
  def in_progress?
    @in_progress
  end
  
  def play_in_terminal
    print '> '
    while input = gets.chomp and in_progress?
      respond(input)
      break unless in_progress?
      print '> '
    end
  end
end