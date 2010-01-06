module Flask
  
  class Exception < RuntimeError
    def message(default = nil)
      self.class::ErrorMessage
    end
  end
  
end