module MusicParser
  class Scanner
    def initialize(scan_path, folders, collection)
      @scan_path = scan_path
      @folders = folders
      @collection = collection
      @all_artists = []
    end
    
    def scan
      puts "*** Beginning scan ***"
      
      files = File.join(@scan_path, "**", "*")
      Dir.glob(files).each do |folder|
        if File.directory?(folder)
          puts "*** Scanning: #{folder} ***"
          @folders << Folder.new(folder, @all_artists)
        end
      end
      
      @folders.each do |folder|
        folder.tracks.each do |track|
          puts track.path
          @collection.add_track(track)
        end
      end
      puts "*** Scan complete ***"
    end
  end
end