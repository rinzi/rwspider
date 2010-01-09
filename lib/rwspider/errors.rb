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

	# The base error class for all RW Spider error classes.
  class Error < StandardError
  end
  
  # Generic Parser exception class.
  class ParserError < Error
  end
  
  # Raised when the class hasn't been able to parse the URL.
  class UrlParserError < ParserError
  end
	
	# Raised when the class hasn't been able to normalize the URL.
  class UrlNormalizeError < ParserError
  end
 
  # Raised when the URI request times out.
  class TimeoutError < Error
  end
 
end