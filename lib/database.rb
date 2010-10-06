require 'redis'

module MusicParser
  class Database
    # stats
    REDIS_ERRORS_KEY = 'errors'
    REDIS_LOG_TIMES_KEY = 'log_times'
    REDIS_COMPLETE_FOLDERS_KEY = 'complete_folders'
    REDIS_FOLDERS_KEY = 'folders'
    # collections
    REDIS_COLLECTIONS_KEY = 'collections'
    REDIS_ARTISTS_KEY = 'artists'
    REDIS_ALBUMS_KEY = 'albums'
    REDIS_TRACKS_KEY = 'tracks'
    
    def initialize
      begin
        @db = Redis.new
        @db.info
      rescue Exception => e
        puts 'WHOAH! You must run the redis server first!'
        exit
      end
      
      @now = nil
    end
    
    def store(thing, now)
      @now = now
      if thing.instance_of? Collection
        store_collection(thing)
      elsif thing.instance_of? ErrorSet
        key = keyify(Database::REDIS_ERRORS_KEY, now, thing.error_type)
        thing.error_folders.each do |folder|
          @db.lpush(key,"#{folder}")
        end
      else
        raise "Don't know how to store a #{thing.class.to_s}"
      end
    end
    
    # collections are named, everything is stored in a Redis set, except for track tags
    # which are a hash.
    # KEY SCHEMA: collections:<collection name>:<artist>:<album>:<path>:[id3 tags hash]
    # TODO: <name> represents hash(name), so that we have a unique (and guaranteed short)
    # track id that can be constructed from other lists
    def store_collection(collection)
      collections_key = Database::REDIS_COLLECTIONS_KEY
      @db.keys("collections:@{collection.name}").each do |old_key|
        @db.del(old_key)
      end
      @db.sadd(collections_key, collection.name)
      collection_part = keyify(collections_key, collection.name)
      
      collection.artists.each do |artist|
        artists_key = keyify(collection_part, Database::REDIS_ARTISTS_KEY)
        @db.sadd(artists_key, artist.name)
        artist_part = keyify(collection_part, artist.name)
        
        artist.albums.each do |album|
          albums_key = keyify(artist_part, Database::REDIS_ALBUMS_KEY)
          @db.sadd(albums_key, album.name)
          album_part = keyify(artist_part, album.name)
          
          album.tracks.each do |track|
            tracks_key = keyify(album_part, Database::REDIS_TRACKS_KEY)
            @db.sadd(tracks_key, track.path)
            
            track_key = keyify(album_part, track.path)
            puts track_key + ' : ' + track_key.size.to_s
            track.tags.each do |tag_name, tag_val|
              @db.hset(track_key, tag_name, tag_val)
            end
          end
          
        end
      end
    end
    
    # redis passthrough
    
    def lindex(*args)
      @db.lindex(*args)
    end
    
    def llen(*args)
      @db.llen(*args)
    end
    
    def lrange(*args)
      @db.lrange(*args)
    end
    
    def rpush(*args)
      @db.rpush(*args)
    end
    
  private
    def keyify(*fields)
      fields.join(':')
    end
  end
end
