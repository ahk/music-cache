require 'mp3info'
module MusicParser
  class Runner
  
    attr_accessor :all_artists, :root_dir, :folders, :scan_path, :destination
  
    def initialize
      @all_artists = Array.new
      @root_dir = File.expand_path(File.dirname($0))
      @folders = Array.new
      @scan_path = ARGV[0]
      @destination = ARGV[1]
      @dry_run = (ARGV[2] != "enact")
      raise "Must specify a scan path and destination" unless @scan_path && @destination
    end
  
    def run
      scan
      log
      migrate
    end
  
  private
  
    def scan
      files = File.join(@scan_path, "**", "*")
      Dir.glob(files).each do |folder|
        if File.directory?(folder)
          puts "*** Scanning: #{folder} ***"
          @folders << Folder.new(folder, self)
        end
      end
    end
  
    def migrate
      @folders.each do |music_folder|
        music_folder.migrate_to(@destination) if music_folder.complete? && !@dry_run
      end
    end
  
    def log
      puts "*** Scan complete ***"
      now = Time.now.strftime('%Y-%m-%d-%H%M%S')
      
      @folders.each do |folder|
        Folder::ERROR_TYPES.each do |error_type|
          error_set = folder.errors.send(error_type)
          if error_set.length > 0
            error_set.persist(now)
            error_set.error_folders.each do |item|
              puts "#{item} #{error_set.msg}"
            end
          end
        end
      end
    
    end
  
  end
end