module Flask
  
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

    def setup; end
    def create_responders; end

    def default_responders
      last.listen '*' do |input|
        "I don't know how to respond to '#{input}'"
      end
    end

    def respond(input)
      return unless in_progress?
      unless first.respond(input)
        unless @current_room and @current_room.respond(input)
          last.respond(input)
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
    
  private
    
    def load_config
      if path = self.class.config_path
        Flask.load_config(path)
      else
        Flask.load_config
      end
    end
  end
  
end