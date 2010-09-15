module MusicParser
  class Logger
    def initialize(redis, folders)
      @redis = redis
      @folders = folders
    end
    
    def log
      now = Time.now.strftime('%Y-%m-%d-%H%M%S')
      puts "*** Logging: #{now} ***"
      @redis.rpush(Runner::REDIS_LOG_TIMES_KEY,now)
      @folders.each do |folder|
        Folder::ERROR_TYPES.each do |error_type|
          error_set = folder.errors.send(error_type)
          if error_set.length > 0
            error_set.log(now, @redis)
            error_set.error_folders.each do |item|
              puts "#{item} #{error_set.msg}"
            end
          end
        end
        @redis.rpush("#{Runner::REDIS_FOLDERS_KEY}:#{now}", folder.folder)
        @redis.rpush("#{Runner::REDIS_COMPLETE_FOLDERS_KEY}:#{now}", folder.folder) if folder.complete?
      end
      puts "*** Logging complete ***"
    end
  end
end