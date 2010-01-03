module Flask
  
  # Extend Flask::Adventure to create your own game!
  # If you have a custom config folder path, define @config_path in the class body
  
  class Adventure < Hallway
    attr_reader :player, :first, :last
    class << self; attr_reader :config_path end
    
    def initialize
      super

      @first = ResponderCollection.new
      @last = ResponderCollection.new
      @player = Player.new
      @in_progress = true
      
      load_config
      default_responders
      create_responders
      setup
    end
    
    # KEEP? Use setup to run any code that wouldn't go in create_responders.
    def setup; end
    
    # Use create_resonders to first or last responders.
    def create_responders; end
    
    # KEEP?
    def default_responders
      last.listen '*' do |input|
        "I don't know how to respond to '#{input}'"
      end
      
      last.listen('go .*', :go) do
        "You can't go there."
      end
      
      last.listen'(take|get) .*' do
        "You can't take that."
      end
      
      last.listen "(get|take) (.*)" do |matches|
        name = matches[2]
        
        if item = current_room.inventory[name]
          current_room.inventory.give(name, player.inventory)
          item.take_message
        else
          :pass_through
        end
      end
    end
    
    # Takes the input and tries to get a response from the first, current room, or last ResponderCollections.
    def respond(input)
      return unless in_progress?
      unless first.respond(input)
        unless @current_room and @current_room.respond(input)
          last.respond(input)
        end
      end
    end
    
    # Stops the game
    def stop
      @in_progress = false
    end
    
    # Whether or not the game is running
    def in_progress?
      @in_progress
    end
    
    # Allows you to play the game with terminal input
    def play_in_terminal
      print '> '
      while input = gets.chomp and in_progress?
        respond(input)
        break unless in_progress?
        print '> '
      end
    end
    
  private
    
    def load_config
      Flask.load(self.class.config_path)
    end
  end
  
end