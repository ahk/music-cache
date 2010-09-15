module MusicParser
  class Scanner
    def initialize(scan_path, folders)
      @scan_path = scan_path
      @folders = folders
      @all_artists = []
    end
    
    def scan
      files = File.join(@scan_path, "**", "*")
      Dir.glob(files).each do |folder|
        if File.directory?(folder)
          puts "*** Scanning: #{folder} ***"
          @folders << Folder.new(folder, @all_artists)
        end
      end
      puts "*** Scan complete ***"
    end
  end
end