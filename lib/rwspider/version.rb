#
# = Ruby RW Spider
#
# RW Spider is an multithreading spider client written in Ruby.
#
#
# Category::    Net
# Package::     RWSpider
# Author::      Simone Rinzivillo <srinzivillo@gmail.com>
# License::     MIT License
#
#--
#
#++

module Rwspider 

	module Version
    MAJOR = 0
    MINOR = 4
    TINY = 2
    ALPHA = nil
 
    STRING = [MAJOR, MINOR, TINY, ALPHA].compact.join('.')
  end
 
  VERSION = Version::STRING
 
end