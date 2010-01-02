module Nameable
  def name
    @name
  end
  
  def name=(new_name)
    return unless new_name
    
    if new_name.is_a?(Regexp)
      new_name = new_name.inspect
    end
    
    @name = new_name.to_s
  end
  
  def name_matches?(string)
    @name.downcase == string.to_s.downcase
  end
  
  def self.to_underscore_case(string)
    string.to_s.split(/(?=[A-Z0-9])/).join('_').downcase
  end
end

class Responder
  attr_reader :name, :trigger, :block
  include Nameable
  
  def self.regexify(var)
    unless var.is_a?(Regexp)
      var = '.*' if var == '*'
      var = "^#{var}$" unless var =~ /^\^|\$$/
      var = Regexp.new(var, true)
    end
    var
  end

  def initialize(trigger, &block)
    self.name = trigger
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
  include Nameable

  def initialize(name = nil)
    @responders = []
    self.name = name
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
  
  def [](name)
    @responders.each do |r|
      return r if r.name_matches? name
    end
    nil
  end
  
  def find(name)
    self[name]
  end
  
  def delete_at(*names)
    names.each do |name|
      @responders = @responders.delete_if do |r|
        r.name_matches? name
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
  attr_reader :parent, :data, :inventory
  class << self; attr_reader :data end
  
  def initialize(parent)
    @responders = []
    @inventory  = Inventory.new
    @parent     = parent if parent.is_a?(Hallway)
    @data       = self.class.data || {}
    @visited    = false
    self.name   = Nameable.to_underscore_case(self.class)
    
    before_setup
    default_responders
    create_items
    create_responders
    setup
  end
  
  def before_setup; end
  def create_items; end
  def create_responders; end
  def setup; end
  
  def default_responders
    listen 'look' do
      description
    end

    listen 'exits' do
      exits
    end
  end
  
  def description
    data[:description]
  end
  
  def exits
    data[:exits]
  end
  
  def enter
    unless @visited or ! data[:intro]
      puts data[:intro]
    end
    
    respond :look
    @visited = true
  end
  
  def leave; end
  
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
  
  def new_item(name, description, take_message)
    inventory << Item.new(name, description, take_message)
    item = inventory[name]
    name = item.name
    
    listen "(get|take) #{name}" do
      if inventory[name]
        inventory.give(name, parent.player.inventory)
        item.take_message
      else
        "You already took that."
      end
    end
  end
end

class Hallway
  attr_reader :rooms, :current_room
  
  def initialize()
    @rooms = []
  end
  
  def <<(sym)
    room = Hallway.sym_to_class(sym).new(self)
    @rooms << room if room.is_a?(Room)
  end
  
  def push(room)
    self << room
  end
  
  def [](name)
    @rooms.each do |r|
      return r if r.name_matches? name
    end
    nil
  end
  
  def find(name)
    self[name]
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

class Adventure < Hallway
  attr_reader :player, :first, :last
  
  def initialize
    super
    
    @first = ResponderCollection.new
    @last = ResponderCollection.new
    @player = Player.new
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

class Item
  attr_reader :name, :description, :take_message
  include Nameable
  
  def initialize(name, description, take_message)
    self.name = name.to_s
    @description = description
    @take_message = take_message
  end
end

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
  
  def give(name, inventory)
    if item = self[name] and inventory.is_a?(Inventory)
      delete_at(name)
      inventory << item
    end
  end
  
  def show
    return false if @items.length == 0
    @items.each do |item|
      puts "#{item.name}: #{item.description}"
    end
  end
end

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