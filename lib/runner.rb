require 'mp3info'
module MusicParser
  class Runner
    REDIS_ERRORS_KEY = 'errors'
    REDIS_LOG_TIMES_KEY = 'log_times'
    REDIS_COMPLETE_FOLDERS_KEY = 'complete_folders'
    REDIS_FOLDERS_KEY = 'folders'
  
    attr_accessor :all_artists, :root_dir, :folders, :scan_path, :destination, :redis
  
    def initialize
      begin
        @redis = Redis.new
      rescue Exception => e
        puts e.class
        puts 'you must run the redis server first!'
        exit
      end
      
      @root_dir = File.expand_path(File.dirname($0))
      @all_artists = []
      @folders = []
      @command = ARGV[0]
      @scan_path = ARGV[1]
      @destination = ARGV[2]
      @dry_run = (ARGV[3] != "enact")
      raise "Must specify a scan path and destination" unless @scan_path && @destination
    end
    
    def run
      self.send("run_#{@command}")
    end
  
  private
    def run_migration
      scan
      log
      migrate
    end
  
    def run_analyze
      analyze
    end
  
    def run_scan
      scan
      log
    end
  
    def scan
      files = File.join(@scan_path, "**", "*")
      Dir.glob(files).each do |folder|
        if File.directory?(folder)
          puts "*** Scanning: #{folder} ***"
          @folders << Folder.new(folder, self)
        end
      end
      puts "*** Scan complete ***"
    end
  
    def log
      now = Time.now.strftime('%Y-%m-%d-%H%M%S')
      puts "*** Logging: #{now} ***"
      @redis.rpush(REDIS_LOG_TIMES_KEY,now)
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
        @redis.rpush("#{REDIS_FOLDERS_KEY}:#{now}", folder.folder)
        @redis.rpush("#{REDIS_COMPLETE_FOLDERS_KEY}:#{now}", folder.folder) if folder.complete?
      end
      puts "*** Logging complete ***"
    end
    
    def analyze
      last_run = @redis.lindex(REDIS_LOG_TIMES_KEY,-1)
      total_folders = @redis.llen("#{REDIS_FOLDERS_KEY}:#{last_run}")
      completed = @redis.llen("#{REDIS_COMPLETE_FOLDERS_KEY}:#{last_run}")
      
      puts "Analyzing last run: #{last_run}"
      puts "#{completed} folders complete of #{total_folders}"
      
      Folder::ERROR_TYPES.each do |error_type|
        error_set = @redis.lrange("#{REDIS_ERRORS_KEY}:#{last_run}:#{error_type}", 0, -1)
        puts "\t#{error_type}: #{error_set.size} folders"
      end
    end
    
    def migrate
      @folders.each do |music_folder|
        music_folder.migrate_to(@destination) if music_folder.complete? && !@dry_run
      end
    end
  
  end
end