require 'fileutils'
require 'ostruct'

class Folder

  attr_accessor :folder, :artist, :album, :complete, :tracks, :errors, :artist_list

  def initialize(folder, runner)
    self.folder = folder
    self.tracks = Array.new
    self.artist_list = runner.all_artists
    self.errors = OpenStruct.new({
      :unknown_tag        => MPErrorSet.new('unknown_tag', 'has an unknown tag'),
      :nonuniform_artists => MPErrorSet.new('nonuniform_artists', 'has nonuniform artists'),
      :nonuniform_albums  => MPErrorSet.new('nonuniform_albums', 'has nonuniform albums'),
      :already_files      => MPErrorSet.new('already_files', 'already has files in it'),
      :incomplete_tracks  => MPErrorSet.new('incomplete_tracks', "doesn't have as many tracks as the tags think ..."),
    })
    map_music
    if uniform_album? && uniform_artist?
      find_album
      find_artist
      self.complete = true
    end
  end

  def complete?
    !!complete
  end

  def migrate_to(destination)
    #Check if the artist folder exists
    #Check if the album folder exists
    #Check if the album folder is populated
    #Move the music
    if !File.directory?(File.join(destination, artist))
      Dir.mkdir(File.join(destination, artist))
    end

    if !File.directory?(File.join(destination, artist, album))
      Dir.mkdir(File.join(destination, artist, album))
    end

    if Dir.glob(File.join(destination, artist, album, "*.mp3")).empty?
      FileUtils.mv(Dir.glob(File.join(folder, "*.mp3")), File.join(destination, artist, album))
      puts "#{artist} - #{album} Files moved"
    else
      errors.already_files << folder
      puts = "Audio files already exist in the destination folder for #{artist}: #{album}"
    end


  end

  private
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

    if (artist.uniq.length > 1) || (artist.length == 0) || (artist.first.nil?)
      errors.nonuniform_artists << folder
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

    if (album.uniq.length > 1) || (album.length == 0) || (album.first.nil?)
      errors.nonuniform_albums << folder
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
      errors.incomplete_tracks << folder
      return false
    end
    return true
  end
  
  def lev_artist_name(artist)
    distance_array = Array.new
    artist_list.each do |old_artist|
      distance = Levenshtein.normalized_distance(old_artist, artist)
      distance_array << distance
    end

    dist_min = distance_array.min
    if dist_min
      if dist_min <= 0.15 && dist_min > 0
        #We have a slightly duplicated artist
        puts "#{artist} wants to be called #{artist_list[distance_array.index(dist_min)]}"
        return artist_list[distance_array.index(dist_min)]
      elsif dist_min > 0.15
        #We have a unique artist
        artist_list << artist
        return artist
      else
        #We have already seen this artist exactly
        return artist
      end
    else
      artist_list << artist
      return artist
    end
    return nil
  end


  def find_album
    music = File.join(folder, "*.mp3")
    file = Dir.glob(music).first
    return nil if file.nil?
    mp3 = Mp3Info.new(file)
    errors.unknown_tag << folder if mp3.tag.album.match(/[^a-zA-Z0-9\_\ \.\-\(\)\:\,\\\+\?\!]/)
    
    self.album = cleanASCII(mp3.tag.album)
  end

  def find_artist
    music = File.join(folder, "*.mp3")
    file = Dir.glob(music).first
    mp3 = Mp3Info.new(file)
    errors.unknown_tag << file if mp3.tag.artist.match(/[^a-zA-Z0-9\_\ \.\-\(\)\:\,\\\+\?\!]/)
    self.artist = lev_artist_name(cleanASCII( mp3.tag.artist ))
  end
  
  def cleanASCII(thing)
    thing = Iconv.conv('utf-8','ISO-8859-1', thing)
    thing.strip
  end
  
end
