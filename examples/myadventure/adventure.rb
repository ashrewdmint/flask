require File.dirname(__FILE__) + '/../../lib/flask'

class MyAdventure < Flask::Adventure
  @config_path = File.dirname(__FILE__) + '/'
  
  def setup
    enter :welcome
  end
  
  def create_responders
    first.listen '(exit|quit)' do
      first.collection :quitprompt do |c|
        c.listen '*' do
          'Please type yes or no.'
        end
        
        c.listen 'yes' do
          stop
        end
        
        c.listen 'no' do
          first.delete_at :quitprompt
        end
      end
      'Are you sure you want to quit? (yes, no)'
    end
    
    first.listen 'help' do
      enter :help
    end
    
    first.listen 'inv(entory)?' do
      unless player.inventory.show
        puts "You got nothin'"
      end
    end
  end
end

module MyAdventure::Rooms
  
  class Help < Flask::Room
    def enter
      respond :look
      travel_to :start
    end
  end

  class Welcome < Flask::Room
    def enter
      respond :look
      travel_to :name
    end
  end

  class Name < Flask::Room
    def create_responders
      first = parent.first
  
      first.listen '*' do |name|
        name = name.to_s
    
        if name.length > 0
          parent.player.name = name.capitalize
          first.pop
      
          puts data[:success].gsub(/#name/, name)
          parent.enter :start
        else
          data[:error]
        end
      end
    end
  end
  
  class Start < Flask::Room
    def create_responders
      listen '(take|get) object' do
        unless parent.player.inventory[:flashlight]
          puts data[:search_for_object]
          parent.respond 'get flashlight'
          parent.respond 'look'
        else
          :pass_through
        end
      end
      
      listen '(go )?south|go .*' do
        unless parent.player.inventory[:flashlight]
          data[:travel_without_flashlight]
        else
          :pass_through
        end
      end
    end
    
    def description
      if parent.player.inventory[:flashlight]
        data[:description_with_flashlight]
      else
        data[:description]
      end
    end
  end
  
end

adv = MyAdventure.new
adv.play_in_terminal