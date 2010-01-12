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

require 'uri/generic'
require 'hpricot'

module Rwspider
	class Document 
		include URI

    # instance of <tt>URI</tt>
		attr_accessor :url
		
		# Returns <tt>true</tt> if the Rwspider::Document::url was request
		attr_accessor :as_visited
		
		# An instance of Net::HTTPResponse that contains the response returned from the web server
		attr_accessor :http_response
		
		# An <tt>Array</tt> of Rwspider::Document found in the HTML code of the current Rwspider::Document
		attr_accessor :documents
		
		# The time spent to download the Rwspider::Document
		attr_accessor :download_time
		
		# Returns <tt>true</tt> if the Rwspider::Document::url was downloaded correctly
		attr_accessor :as_downloaded
		
		# An <tt>Array</tt> of <tt>String</tt> hat contains the URLs of the documents where was found an link at the current Rwspider::Document
		attr_reader :inbound_links
		
		
	# Inizialize a new Rwspider::Document instance with the <tt>url</tt>
	#
  #  doc = Rwspider::Document::new('http://www.rwspider.com')
  #	
		def initialize (url)
			parse(url)
			@tag_type = Array.new
			@tag_type << ['a','href']
			@tag_type << ['img','src']
			@tag_type << ['link','href']
			@inbound_links = []
			@documents = []
			@as_visited = false
		end
		
	# Rwspider::Document::parse load or replace the Rwspider::Document.url with the new <tt>url</tt>
	#
	#  doc = Rwspider::Document::new('http://www.rwspider.com')
  #  doc.parse('http://www.rwspider.com/sitemap.html')
  #	
		def parse (url)
			begin				
				@url = URI.parse(url.gsub(/\\/,'/'))				
				rescue Exception  => e
				nil		
			end
		end
		
	# Analyze the HTML code of the current Rwspider::Document to extract the links at other documents.
  #
  #  doc = Rwspider::Document::new('http://www.rwspider.com')
	#  http = Net::HTTP.new(doc.url.host, doc.url.port)
	#  doc.http_response = http.request(Net::HTTP::Get.new(doc.url.request_uri))
	#  arr = doc.get_links
	# 
	# This method returns an <tt>Array</tt> of instances of Rwspider::Document 
	# and append the Array at the documents attribute.
  # Returns <tt>nil</tt> if the <tt>content-type</tt> returned in the <tt>http_response</tt> attribute
	# was different from 'text/html'. 
	#
		def get_links()
			get_document(@tag_type[0])
		end	
		
	# Analyze the HTML code of the current Rwspider::Document to extract the links at images.
  #
  #  doc = Rwspider::Document::new('http://www.rwspider.com')
	#  http = Net::HTTP.new(doc.url.host, doc.url.port)
	#  doc.http_response = http.request(Net::HTTP::Get.new(doc.url.request_uri))
	#  arr = doc.get_images
	# 
	# This method returns an <tt>Array</tt> of instances of Rwspider::Document 
	# and append the Array at the documents attribute.
  # Returns <tt>nil</tt> if the <tt>content-type</tt> returned in the <tt>http_response</tt> attribute
	# was different from 'text/html'. 
	#
		def get_images()
			get_document(@tag_type[1])
		end	
			
	# Analyze the HTML code of the current Rwspider::Document to extract the links at other files
	# as javascript and css.
  #
  #  doc = Rwspider::Document::new('http://www.rwspider.com')
	#  http = Net::HTTP.new(doc.url.host, doc.url.port)
	#  doc.http_response = http.request(Net::HTTP::Get.new(doc.url.request_uri))
	#  arr = doc.get_other_files
	# 
	# This method returns an <tt>Array</tt> of instances of Rwspider::Document 
	# and append the Array at the documents attribute.
  # Returns <tt>nil</tt> if the <tt>content-type</tt> returned in the <tt>http_response</tt> attribute
	# was different from 'text/html'. 
	#			
		def get_other_files() 
			get_document(@tag_type[2])
		end
		
  # Normalize the url if the path is relative and returns an <tt>String</tt> with the absolute version.
  #
  #  doc = Rwspider::Document::new('http://www.rwspider.com')
	#  doc.normalize_url(URI.parse('/sitemap.html'))
	# 
		def normalize_url(var)
			querystring = (!var.query.nil?) ? '?' + var.query : ''
			if  var.scheme.nil? || (var.scheme.downcase != "mailto" && var.scheme != "javascript")
				if var.relative?
					path = var.path
					if url.path.nil? 
						main_path = url.path.slice(0..url.path.rindex('/')) 
						else
						main_path = '/'
					end					
					
					if path.match('^\/')
						path = url.scheme + '://' + url.host  + path + querystring
						else						
						path = url.scheme + '://'  + url.host + main_path + path + querystring
					end
					else
					path = var.scheme + '://'  + var.host + var.path + querystring
				end
			end
			
			return path
		end
		
		private
		
		def get_document(tag)
		  return unless !@http_response.nil? && @http_response.content_type == 'text/html' 
					sourcecode = Hpricot(@http_response.body)
					lnks = sourcecode.search("//" + tag[0])
					docs = []
					lnks.each { |link| 
						
						url = link.attributes[tag[1]].strip
						doc = Document.new(url) if !url.nil?
						
						if !doc.nil? && !doc.url.nil? 
							path = normalize_url(doc.url) 					
							
							if !path.nil?
								doc.parse path
								docs << doc 
								
							end
							
						end
						
					}
					@documents = @documents + docs
					docs
		end
		

		
		
	end
end 