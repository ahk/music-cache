module MusicParser
  class Analyzer
    def initialize(db)
      @db = db
    end
    
    def puts_stdout
      last_run = @db.lindex(Database::REDIS_LOG_TIMES_KEY,-1)
      total_folders = @db.llen("#{Database::REDIS_FOLDERS_KEY}:#{last_run}")
      completed = @db.llen("#{Database::REDIS_COMPLETE_FOLDERS_KEY}:#{last_run}")
      
      puts "Analyzing last run: #{last_run}"
      puts "#{completed} folders complete of #{total_folders}"
      
      Folder::ERROR_TYPES.each do |error_type|
        error_set = @db.lrange("#{Database::REDIS_ERRORS_KEY}:#{last_run}:#{error_type}", 0, -1)
        puts "\t#{error_type}: #{error_set.size} folders"
      end
    end
  end
end