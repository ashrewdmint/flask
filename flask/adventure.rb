module Flask
  
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
  
end