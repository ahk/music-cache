
module MusicParser
  class Collection
    
    attr_accessor :name, :artists
    def initialize(name)
      @name = name
      @artists = []
    end
    
    def add_track(track)
      artist = get_or_make_artist(track.tags.artist)
      artist.add_track(track)
    end
    
  private
    def get_or_make_artist(name)
      artist = @artists.detect do |artist|
        artist.name == name
      end
      
      unless artist
        artist = Artist.new(name)
        @artists << artist
      end
      artist
    end
    
  end
end