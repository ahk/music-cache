require 'redis'

module MusicParser
  
  class MP3ErrorSet
    REDIS_ERRORS_KEY = 'errors'
    
    attr_accessor :error_folders, :name, :msg
  
    def initialize(name, msg = nil)
      begin
        @redis = Redis.new
      rescue => e
        puts e.class
        puts 'you must run the redis server first!'
        exit
      end
      @msg = msg
      @name = name
      @error_folders = []
    end
  
    def length
      @error_folders.length
    end
  
    def <<(thing)
      @error_folders << thing
    end
    
    def persist(time_stamp)
      key = keyify(time_stamp, REDIS_ERRORS_KEY, @name)
      @error_folders.each do |folder|
        @redis.lpush(key,"#{folder}")
      end
    end
    
    private
    def keyify(*fields)
      fields.join(':')
    end
    
  end
end