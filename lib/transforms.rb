# Utilities for string transformations.
# This File is borrowed from the Typo 2.6.0 source code
#

class String

  # Converts a string with space to its-title-using-dashes
  # All special chars are stripped in the process.
  # Accents are also replaced.


  def to_readable_english
    return if self.nil?

    accents = { 
      ['à','â','ä','ã','å','á'] => 'a',
      ['é','è','ê','ë',] => 'e',
      ['ï','î','ì'] => 'i',
      ['ò','ö', 'ô','õ','ó','ö','ø'] => 'o',
      ['ù','û','ü', 'µ','ú'] => 'u',
      ['À','Â','Ä','Ã','Å','Á'] => 'A',
      ['É','È','Ê','Ë',] => 'E',
      ['Ï','Î','Ì'] => 'I',
      ['Ò','Ö','Ô','Õ','Ó','Ö','Ø'] => 'O',
      ['Ù','Û','Ü','Μ','Ú'] => 'U',
      ['ñ'] => 'n',
      ['ç'] => 'c',
      ['°'] => 'o',
      ['€'] => 'euro',
      ['$'] => 'dollar',
      ['£'] => 'pound',
      ['§'] => 'sect',
      ['&'] => 'and',
      ['*', '/', '%','^','¨','@','~','#'] => ''
    }

    result = self

    # accents.each do |ac,rep|
    #   ac.each do |s|
    #     result.gsub!(s, rep)
    #   end
    # end

    # replace quotes by nothing
    result.gsub!(/['"]/, '')

    # strip all non word chars
    #result.gsub!(/\W/, ' ')

    # replace all white space sections with a underscore
    #result.gsub!(/\ +/, '_')

    # trim dashes
    #result.gsub!(/(-)$/, '')
    #result.gsub!(/^(-)/, '')

    result
  end
end
