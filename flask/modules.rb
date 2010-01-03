module Flask
  
  # Gives things a name which can be referenced as a string or a symbol
  
  module Nameable
    def name
      @name
    end

    # Names are always stored as strings, but it doesn't matter
    # if you supply a symbol or a string here.
    
    def name=(new_name)
      return unless new_name

      if new_name.is_a?(Regexp)
        new_name = new_name.inspect
      end

      @name = new_name.to_s
    end
    
    # For a name of "bojangles", this will return true for both
    # :bojangles and "bojangles".
    
    def name_matches?(string)
      @name.downcase == string.to_s.downcase
    end
  end
  
  module Inflector
    def self.camelize(string)
      split = string.to_s.split(/_/)
      split.collect! {|word| word.capitalize} if split.length > 1
      split.join
    end
    
    def self.underscore(string)
      string.to_s.split(/(?=[A-Z0-9])/).join('_').downcase
    end 
  end
  
end