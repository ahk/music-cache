module MusicParser
  class Logger
    def initialize(db, folders, collection)
      @db = db
      @folders = folders
      @collection = collection
      @now = nil
    end
    
    def log
      @now = Time.now.strftime('%Y-%m-%d-%H%M%S')
      puts "*** Logging: #{@now} ***"
      @db.rpush(Database::REDIS_LOG_TIMES_KEY, @now)
      log_folders
      log_collection
      puts "*** Logging complete ***"
    end
    
    def log_folders
      @folders.each do |folder|
        Folder::ERROR_TYPES.each do |error_type|
          error_set = folder.errors.send(error_type)
          if error_set.length > 0
            @db.store(error_set, @now)
            error_set.error_folders.each do |item|
              puts "#{item} #{error_set.msg}"
            end
          end
        end
        @db.rpush("#{Database::REDIS_FOLDERS_KEY}:#{@now}", folder.folder)
        @db.rpush("#{Database::REDIS_COMPLETE_FOLDERS_KEY}:#{@now}", folder.folder) if folder.complete?
      end
    end
    
    def log_collection
      @db.store(@collection, @now)
    end
  end
end