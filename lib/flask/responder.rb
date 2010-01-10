module Flask
  
  # A block of code stored alongside a regex.
  
  class Responder
    attr_reader :name, :trigger, :block
    include Nameable
    
    # Takes a string and turns it into a case-insensitive regex.
    # If a regex is supplied, it will be returned unchanged.
    
    def self.regexify(var)
      unless var.is_a?(Regexp)
        var = '.*' if var == '*'
        var = "^#{var}$" unless var =~ /^\^|\$$/
        var = Regexp.new(var, true)
      end
      var
    end
    
    # Trigger can be a string or a regex. Name is an optional string
    # or symbol which you can use to refer to this responder once it
    # has been added to a ResponderCollection.

    def initialize(trigger, name = nil, &block)
      self.name = name || trigger
      @trigger = self.class.regexify(trigger)
      @block = block
    end
    
    # If input matches the trigger, it will run the block of code.

    def respond(input)
      input = input.to_s.strip
      matches = input.match(@trigger)
      
      if matches = input.match(@trigger)
        unless (response = @block.call(matches)) == :pass_through
          puts response if response.is_a?(String)
          return true
        end
      else
        false
      end
    end
  end
  
  # A group of responders.
  
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

    def listen(*args, &block)
      self.<< Responder.new(*args, &block)
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
  
end