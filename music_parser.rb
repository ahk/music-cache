#!/usr/bin/env ruby

$:.unshift("lib/")

#require 'rubygems'
#require 'ruby-debug'
require "lib/mp3info"
require "lib/levenshtein"
require "lib/transforms"
require "lib/folder"

@@unknown_tag = Array.new
@@all_artists = Array.new

def find_or_create_new_folder(folder, artist, album)
  artist_path = File.join(@destination, artist)
  if File.directory?(artist_path)
    album_path = File.join(artist_path, album)
    if File.directory?(album_path)
      puts "#{artist} - #{album} already exist"
    else
      #puts "Need to create #{album} for #{artist}"
      if @enact == true
        Dir.mkdir(album_path)
        File.move(folder, album_path, true)
      else
      end
      puts "#{folder} -> #{album_path}"
    end
  else
    #puts "Folder #{artist_path} needs to be created"
      album_path = File.join(artist_path, album)
    if @enact == true
      Dir.mkdir(artist_path)
      Dir.mkdir(album_path)
      File.move(folder, album_path, true)
    else
    end
    puts "#{folder} -> #{album_path}"
  end

end

if $0 == __FILE__
  path = ARGV[0]
  @destination = ARGV[1] || "/Volumes/Music/"
  @enact = (ARGV[2] == "enact")

  #ARGV.each do |path|
    files = File.join(path, "**", "*")
    Dir.glob(files).each do |folder|
      if File.directory?(folder)
        begin
          puts "Opening: #{folder}"
          music_folder = Folder.new(folder)
          if music_folder.complete?
            music_folder.migrate_to(@destination, @enact)
          end
        end rescue Mp3InfoError
      end
    end
  #end

  if ARGV.length == 0
    puts "No file given"
  end

  puts "*** Scan complete ***"
  if @@unknown_tag.length > 0
    @@unknown_tag.each do |folder|
      puts "#{folder} has unknown characters. You should look into that"
    end
  end
end

