#!/usr/bin/env ruby

$:.unshift("lib/")

#require 'rubygems'
#require 'ruby-debug'
require "lib/mp3info"
require "lib/levenshtein"
require "lib/transforms"
require "lib/folder"

class MPErrorSet
  attr_accessor :errors, :name, :msg
  
  def initialize(name, msg = nil)
    self.msg = msg
    self.name = name
    self.errors = []
  end
  
  def length
    self.errors.length
  end
  
  def <<(thing)
    self.errors << thing
  end
end

@@all_artists        = Array.new

@@unknown_tag        = MPErrorSet.new('unknown_tag', 'has an unknown tag')
@@nonuniform_artists = MPErrorSet.new('nonuniform_artists', 'has nonuniform artists')
@@nonuniform_albums  = MPErrorSet.new('nonuniform_albums', 'has nonuniform albums')
@@already_files      = MPErrorSet.new('already_files', 'already has files in it')
@@incomplete_tracks  = MPErrorSet.new('incomplete_tracks', "doesn't have as many tracks as the tags think ...")

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
  now = Time.now.strftime('%Y-%m-%d-%H%M%S')
  errors = [@@unknown_tag,@@nonuniform_artists, @@nonuniform_albums, @@already_files, @@incomplete_tracks]
  errors.each do |error_set|
    if error_set.length > 0
      File.open(now + '.' + error_set.name, 'w+') do |f|
        error_set.errors.each do |item|
          msg = "#{item} #{error_set.msg}"
          f.puts msg
          puts msg
        end
      end
    end
  end
end

