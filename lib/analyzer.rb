module MusicParser
  class Analyzer
    def initialize(redis)
      @redis = redis
    end
    
    def puts_stdout
      last_run = @redis.lindex(Runner::REDIS_LOG_TIMES_KEY,-1)
      total_folders = @redis.llen("#{Runner::REDIS_FOLDERS_KEY}:#{last_run}")
      completed = @redis.llen("#{Runner::REDIS_COMPLETE_FOLDERS_KEY}:#{last_run}")
      
      puts "Analyzing last run: #{last_run}"
      puts "#{completed} folders complete of #{total_folders}"
      
      Folder::ERROR_TYPES.each do |error_type|
        error_set = @redis.lrange("#{Runner::REDIS_ERRORS_KEY}:#{last_run}:#{error_type}", 0, -1)
        puts "\t#{error_type}: #{error_set.size} folders"
      end
    end
  end
end