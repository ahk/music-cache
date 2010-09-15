module MusicParser
  class ErrorSet
    
    attr_accessor :error_folders, :error_type, :msg
  
    def initialize(error_type, msg = nil)
      @msg = msg
      @error_type = error_type
      @error_folders = []
    end
  
    def length
      @error_folders.length
    end
  
    def <<(thing)
      @error_folders << thing
    end
    
    def log(time_stamp, redis)
      key = keyify(Runner::REDIS_ERRORS_KEY, time_stamp, @error_type)
      @error_folders.each do |folder|
        redis.lpush(key,"#{folder}")
      end
    end
    
    private
    def keyify(*fields)
      fields.join(':')
    end
    
  end
end