module MusicCache
  class ErrorSet
    
    attr_accessor :error_folders, :error_type, :msg
  
    def initialize(error_type, msg = nil)
      @error_type = error_type
      @msg = msg
      @error_folders = []
    end
  
    def length
      @error_folders.length
    end
  
    def <<(thing)
      @error_folders << thing
    end
    
  end
end