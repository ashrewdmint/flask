require '../../flask'

class MyAdventure < Flask::Adventure
  @config_path = File.dirname(__FILE__) + '/'
  
  def setup
    enter :welcome_room
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
      enter :help_room
    end
  end
end

class HelpRoom < Flask::Room
  def enter
    respond :look
    travel_to :start_room
  end
end

class WelcomeRoom < Flask::Room
  def enter
    respond :look
    travel_to :name_room
  end
end

class NameRoom < Flask::Room
  def create_responders
    first = parent.first
    
    first.listen '*' do |name|
      if name.length > 0
        parent.player.name = name.capitalize
        first.pop
        
        puts data[:success].gsub(/#name/, name)
        parent.enter :start_room
      else
        data[:error]
      end
    end
  end
end

adv = MyAdventure.new
adv.play_in_terminal