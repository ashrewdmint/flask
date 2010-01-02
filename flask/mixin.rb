module Flask
  
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
  
end