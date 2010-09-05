class Runner
  
  def initialize
    @all_artists = Array.new
    @root_dir = File.expand_path(File.dirname($0))
    @folders = Array.new
  end
  
  def migrate_files
    path = ARGV[0]
    @destination = ARGV[1] || "/Volumes/Music/"
    @enact = (ARGV[2] == "enact")

    files = File.join(path, "**", "*")
    Dir.glob(files).each do |folder|
      if File.directory?(folder)
        begin
          puts "Opening: #{folder}"
          music_folder = Folder.new(folder, @all_artists)
          @folders << music_folder
          if music_folder.complete?
            music_folder.migrate_to(@destination, @enact)
          end
        rescue Mp3InfoError => e
          puts "Mp3InfoError: #{e} in #{folder}"
        end
      end
    end

    if ARGV.length == 0
      puts "No file given"
    end
  end
  
  def record_logs
    puts "*** Scan complete ***"
    now = Time.now.strftime('%Y-%m-%d-%H%M%S')
    error_types = [
      :unknown_tag,
      :nonuniform_artists, 
      :nonuniform_albums, 
      :already_files,
      :incomplete_tracks]
      
    @folders.each do |folder|
      error_types.each do |error_type|
        error_set = folder.errors.send(error_type)
        if error_set.length > 0
          error_file = File.join(@root_dir, now + '.' + error_set.name)
          File.open(error_file, 'a') do |f|
            error_set.errors.each do |item|
              msg = "#{item} #{error_set.msg}"
              f.puts msg
              puts msg
            end
          end
        end
      end
    end
    
  end
  
  def run
    migrate_files
    record_logs
  end
  
end