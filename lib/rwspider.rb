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


require 'rwspider/client'
require 'uri'



module Rwspider

  NAME            = 'Rwspider'
  GEM             = 'rwspider'
  AUTHORS         = ['Simone Rinzivillo <srinzivillo@gmail.com>']

  # Start the crawling from the <tt>URL</tt> with the personalized <tt>options</tt>.
	# RW Spider apply the Rwspider::Client::DEFAULT_OPTIONS indexing options if you don't customize them
  # Rwspider::start yield an instance of Rwspider::Document Class for each page downloaded.
  # 
	#  opts = { 
  #    :useragent => 'My user agent',
  #    :robot_name => 'my_spider_name',
  #    :scan_documents_limit => 100,
  #    :scan_domain_limit => nil,
  #    :scan_images => true,
  #    :scan_other_files => false,
  #    :follow_robotstxt_directive => true,		
  #    :follow_HTTP_redirection => true,
	#    :timeout => 5
	#  }    
  #  Rwspider.start('http://www.rwspider.com', opts) {do |d|
  #     puts 'Current URL ' + d.url.normalize.to_s
  #  }
  #
  
  def self.start(url, options = {})
	
		@client = Rwspider::Client.new(options)
		@client.start(url)do |doc| 	
			yield doc if block_given?
		end	
	    
  end

end