module MusicParser
  class Track
    
    attr_accessor :path, :tags
    def initialize(path, tags)
      @path = path
      @tags = tags
    end
  end
end