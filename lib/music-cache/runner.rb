module MusicCache
  class Runner
    attr_accessor :root_dir, :folders, :scan_path, :destination
  
    def initialize
      @db = Database.new
      @root_dir = File.expand_path(File.dirname($0))
      @folders = []
      @command = ARGV[0]
      @collection = Collection.new(ARGV[1])
      @scan_path = ARGV[2]
      @destination = ARGV[3]
      @dry_run = (ARGV[4] != "enact")
    end
    
    def run
      self.send("run_#{@command}")
    end
  
  private
    def run_migration
      raise "Must specify a scan path and destination to migrate to" unless @scan_path && @destination
      scan
      log
      migrate
    end
  
    def run_analyze
      raise "Must specify a collection name to analyze" unless @collection
      analyze
    end
  
    def run_scan
      raise "Must specify a collection name and scan path to scan" unless @scan_path && @collection
      scan
      log
    end
    
    def run_query
      query
    end
  
    def scan
      Scanner.new(@scan_path, @folders, @collection).scan
    end
  
    def log
      Logger.new(@db, @folders, @collection).log
    end
    
    def analyze
      Analyzer.new(@db).puts_stdout
    end
    
    def query
      coll = 'test'
      artist = 'Animal Collective'
      album = 'Sung Tongs'
      puts "ARTISTS: #{coll}"
      puts @db.get_artists(coll)
      puts "ALBUMS: #{artist}"
      puts @db.get_albums(coll, artist)
      puts "TRACKS: #{artist}, #{album}"
      puts @db.get_tracks(coll, artist, album)
    end
    
    def migrate
      @folders.each do |music_folder|
        music_folder.migrate_to(@destination) if music_folder.complete? && !@dry_run
      end
    end
  
  end
end
