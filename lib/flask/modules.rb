module Flask
  
  # Has the ability to store a hash in a Class. All instances of
  # the class automatically have the hash. Subclasses will not.
    
  module ShareableData
    self.class.send(:define_method, 'set_data') do |hash|
      @data = hash if hash.is_a?(Hash)
    end
    
    def data
      @data || self.class.instance_variable_get(:@data) || {}
    end
  end
  
  # Has a name which can be referenced as a string or a symbol
  
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

      @name = Inflector.underscore(Inflector.get_class_name(new_name.to_s))
    end
    
    # For a name of "bojangles", this will return true for both
    # :bojangles and "bojangles".
    
    def name_matches?(string)
      @name.downcase == Inflector.underscore(string.to_s.downcase)
    end
  end
  
  module Inflector
    
    # Converts to camel case
    
    def self.camelize(string)
      split = string.to_s.split(/_|\s+/)
      split.collect! {|word| word.capitalize} if split.length > 1
      string = split.join.gsub(/^./) {|first| first.capitalize }
    end
    
    # Converts to underscore case
    
    def self.underscore(string)
      string.to_s.split(/(?=[A-Z0-9])|\s+/).join('_').downcase
    end
    
    # Returns the last constant from a string like Module::Class
    
    def self.get_class_name(string)
      camelize(string).gsub(/.*::(.*)/, '\1')
    end
  end
  
end