module MusicParser
  class MP3ErrorSet
    
    attr_accessor :errors, :name, :msg
  
    def initialize(name, msg = nil)
      self.msg = msg
      self.name = name
      self.errors = []
    end
  
    def length
      self.errors.length
    end
  
    def <<(thing)
      self.errors << thing
    end
    
  end
end