require 'yaml'

module Flask
  
  def self.load_config(dir = 'config/')
    dir = dir + '/' unless dir.slice(-1, 1) == '/'
    Load.items dir + 'items.yaml'
    Load.rooms dir + 'rooms.yaml'
  end
  
  class Load
    def self.items(path)
      items = YAML.load_file(path)
      items.each_pair do |name, hash|
        #puts name
      end
    end
    
    def self.rooms(path)
      rooms = YAML.load_file(path)
      rooms.each_pair do |name, hash|
        #puts name
      end
    end
  end
  
end