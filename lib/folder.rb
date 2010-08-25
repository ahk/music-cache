class Folder
  require 'fileutils'

  attr_accessor :folder, :artist, :album, :complete, :tracks

  def initialize(folder)
    self.folder = folder
    self.tracks = Array.new
    map_music
    if uniform_album? && uniform_artist?
      find_album
      find_artist
      self.complete = true
    end
  end

  def map_music
    music = File.join(folder, "*.mp3")
    Dir.glob(music).each do |file|
      Mp3Info.open(file) do |mp3|
        tracks << mp3.tag
      end
    end
  end

  def uniform_artist?
    artist = Array.new
    music = File.join(folder, "*.mp3")
    Dir.glob(music).each do |file|
      Mp3Info.open(file) do |mp3|
        artist << mp3.tag.artist
      end
    end

    if artist.uniq.length > 1 || artist.length == 0 || artist.first.nil?
      @@nonuniform_artists << folder
      return false
    end
    return true
  end

  def uniform_album?
    album = Array.new
    music = File.join(folder, "*.mp3")
    Dir.glob(music).each do |file|
      Mp3Info.open(file) do |mp3|
        album << mp3.tag.album
      end
    end

    if album.uniq.length > 1 || album.length == 0 || album.first.nil?
      @@nonuniform_albums << folder
      return false
    end
    return true
  end

  def has_all_tracks?
    album = Array.new
    music = File.join(folder, "*.mp3")
    Dir.glob(music).each do |file|
      Mp3Info.open(file) do |mp3|
        album << mp3.tag.tracknum
      end
    end

    if album.length != album.last.to_i || album.length == 0
      @@incomplete_tracks << folder
      return false
    end
    return true
  end

  def complete?
    return true if complete
    return false
  end

  def migrate_to(destination, enact=nil)
    #Check if the artist folder exists
    #Check if the album folder exists
    #Check if the album folder is populated
    #Move the music
    if !File.directory?(File.join(destination, artist))
      Dir.mkdir(File.join(destination, artist)) if enact == true
    end

    if !File.directory?(File.join(destination, artist, album))
      Dir.mkdir(File.join(destination, artist, album)) if enact == true
    end

    if Dir.glob(File.join(destination, artist, album, "*.mp3")).empty?
      FileUtils.mv(Dir.glob(File.join(folder, "*.mp3")), File.join(destination, artist, album)) if enact == true
      puts "#{artist} - #{album} Files moved"
    else
      @@already_files << folder
      puts = "Audio files already exist in the destination folder for #{artist}: #{album}"
    end


  end

  private
  def lev_artist_name(artist)
    distance_array = Array.new
    @@all_artists.each do |old_artist|
      distance = Levenshtein.normalized_distance(old_artist, artist)
      distance_array << distance
    end

    dist_min = distance_array.min
    if dist_min
      if dist_min <= 0.15 && dist_min > 0
        #We have a slightly duplicated artist
        puts "#{artist} wants to be called #{@@all_artists[distance_array.index(dist_min)]}"
        return @@all_artists[distance_array.index(dist_min)]
      elsif dist_min > 0.15
        #We have a unique artist
        @@all_artists << artist
        return artist
      else
        #We have already seen this artist exactly
        return artist
      end
    else
      @@all_artists << artist
      return artist
    end
    return nil
  end


  def find_album
    music = File.join(folder, "*.mp3")
    file = Dir.glob(music).first
    return nil if file.nil?
    mp3 = Mp3Info.new(file)
    @@unknown_tag << folder if mp3.tag.album.match(/[^a-zA-Z0-9\_\ \.\-\(\)\:\,\\\+\?\!]/)
    self.album = mp3.tag.album.strip
  end

  def find_artist
    music = File.join(folder, "*.mp3")
    file = Dir.glob(music).first
    mp3 = Mp3Info.new(file)
    @@unknown_tag << folder if mp3.tag.artist.match(/[^a-zA-Z0-9\_\ \.\-\(\)\:\,\\\+\?\!]/)
    self.artist = lev_artist_name(mp3.tag.artist.strip)
  end
end
