module MusicCache
  class Artist
    
    attr_accessor :name, :albums
    def initialize(name)
      @name = name
      @albums = []
    end
    
    def add_track(track)
      album = get_or_make_album(track.tags.album)
      album.add_track(track)
    end
    
  private
    def get_or_make_album(name)
      album = @albums.detect do |album_to_be_named|
        album_to_be_named.name == name
      end
      unless album
        album = Album.new(name)
        @albums << album
      end
      album
    end
    
  end
end