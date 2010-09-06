require 'fileutils'
require 'ostruct'
require 'rubygems'
require 'unicode'

class Folder
  
  ERROR_TYPES = [
    :non_music_folder  ,
    :unknown_tag       ,
    :nonuniform_artists,
    :nonuniform_albums ,
    :already_files     ,
    :incomplete_tracks ,
  ]
  
  BAD_TAG = /[^a-zA-Z0-9\_\ \.\-\(\)\:\,\\\+\?\!]/

  attr_accessor :folder, :artist, :album, :complete, :tracks, :errors

  def initialize(folder, runner)
    @folder = folder
    @tracks = Array.new
    @artist_list = runner.all_artists
    @errors = OpenStruct.new({
      :non_music_folder   => MPErrorSet.new('non_music_folder', 'has no music files as direct children'),
      :unknown_tag        => MPErrorSet.new('unknown_tag', 'has an unknown tag in it'),
      :nonuniform_artists => MPErrorSet.new('nonuniform_artists', 'has nonuniform artists'),
      :nonuniform_albums  => MPErrorSet.new('nonuniform_albums', 'has nonuniform albums'),
      :already_files      => MPErrorSet.new('already_files', 'already has files in it'),
      :incomplete_tracks  => MPErrorSet.new('incomplete_tracks', "doesn't have as many tracks as the tags think ..."),
    })
    
    map_tracks
    
    @album     = find_album
    @artist    = find_artist
    @has_music = true if @artist || @album
      
    if uniform_album? && uniform_artist? && has_all_tracks?
      @complete = true
    end
    
  end
  
  def has_music?
    !!has_music
  end

  def complete?
    !!complete
  end

  def migrate_to(destination)
    #Check if the artist folder exists
    #Check if the album folder exists
    #Check if the album folder is populated
    #Move the music
    if !File.directory?(File.join(destination, @artist, @album))
      FileUtils.mkdir_p(File.join(destination, @artist, @album))
    end

    if Dir.glob(File.join(destination, @artist, @album, "*.mp3")).empty?
      FileUtils.mv(Dir.glob(File.join(folder, "*.mp3")), File.join(destination, @artist, @album))
      puts "#{@artist} - #{@album} Files moved"
    else
      errors.already_files << folder
      puts = "Audio files already exist in the destination folder for #{@artist}: #{@album}"
    end
  end

private
  
  def map_tracks
    music = @folder
    # escape for Dir globbing
    needs_escape = music.scan(/([\\\?\{\}\[\]\*])/)
    needs_escape.flatten.uniq.each do |str|
      music.gsub!(str, "\\#{str}")
    end
    
    Dir.glob(File.join(music, "*.mp3")).each do |file|
      begin
        Mp3Info.open(file) do |mp3|
          @tracks << mp3.tag
        end
      rescue Mp3InfoError, NoMethodError => e
        puts "#{e.class}:#{e} in #{file}"
      end
    end
    
  end

  def uniform_artist?
    artists = Array.new

    @tracks.each do |tag|
      artists << tag.artist
    end

    if (artists.uniq.length > 1) || (artists.length == 0) || (artists.first.nil?)
      errors.nonuniform_artists << folder
      return false
    end
    return true
  end

  def uniform_album?
    uniform = false
    albums = Array.new

    @tracks.each do |tag|
      albums << tag.album
    end

    if (albums.uniq.length > 1)
      errors.nonuniform_albums << folder
    elsif (albums.length == 0) || (albums.uniq.first.nil?)
      errors.non_music_folder << folder
    else
      uniform = true
    end
    
    uniform
  end

  def has_all_tracks?
    has_all_tracks = false
    albums = Array.new
    
    @tracks.each do |tag|
      albums << tag.tracknum
    end

    if (albums.length != albums.last.to_i) || (albums.length == 0)
      errors.incomplete_tracks << folder
    else
      has_all_tracks = true
    end
    
    has_all_tracks
  end
  
  def lev_artist_name(artist)
    distance_array = Array.new
    @artist_list.each do |old_artist|
      distance = Levenshtein.normalized_distance(old_artist, artist)
      distance_array << distance
    end

    dist_min = distance_array.min
    if dist_min
      if (dist_min <= 0.15) && (dist_min > 0)
        #We have a slightly duplicated artist
        canonical_name = @artist_list[distance_array.index(dist_min)]
        puts "#{artist} wants to be called #{canonical_name}"
        return canonical_name
      elsif dist_min > 0.15
        #We have a unique artist
        @artist_list << artist
        return artist
      else
        #We have already seen this artist exactly
        return artist
      end
    else
      @artist_list << artist
      return artist
    end
    return nil
  end

  def find_album
    tag = @tracks.first
    return nil if tag.nil?
    album = tag.album
    
    if album
      album = cleanASCII(album)
      @errors.unknown_tag << @folder if album.match(BAD_TAG)
    end
    album
  end

  def find_artist
    tag = @tracks.first
    return nil if tag.nil?
    artist = tag.artist
    if artist
      artist = cleanASCII(artist)
      @errors.unknown_tag << @folder if artist.match(BAD_TAG)
      artist = lev_artist_name(artist)
    end
    artist
  end
  
  def cleanASCII(text)
    text = Iconv.conv('UTF-8','ISO-8859-1', text).strip
    # this normalizing may be entirely unecessary.
    # I don't really understand how to represent ç or ã
    # as a single utf8 codepoint when written to a file.
    # it probably doesn't matter. readline seems fine with it?
    Unicode.normalize_C(text)
  end
  
end
