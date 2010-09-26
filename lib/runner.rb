module MusicParser
  class Runner
    attr_accessor :root_dir, :folders, :scan_path, :destination
  
    def initialize
      @db = Database.new
      @root_dir = File.expand_path(File.dirname($0))
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
      Scanner.new(@scan_path, @folders).scan
    end
  
    def log
      Logger.new(@db, @folders).log
    end
    
    def analyze
      Analyzer.new(@db).puts_stdout
    end
    
    def migrate
      @folders.each do |music_folder|
        music_folder.migrate_to(@destination) if music_folder.complete? && !@dry_run
      end
    end
  
  end
end