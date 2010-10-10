module MusicCache
  class Album
    
    attr_accessor :name, :tracks
    def initialize(name)
      @name = name
      @tracks = []
    end
    
    def add_track(track)
      @tracks << track
    end
    
  end
end