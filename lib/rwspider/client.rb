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


require 'net/http'
require 'openssl'
require 'uri'
require 'robotstxt'
require 'rwspider/document'
require 'rwspider/queue'
require 'rwspider/version'
require 'hpricot'


module Rwspider
	class Client
		
    # Hash of options for the spider job
		attr_accessor :opts
		
		
		# DEFAULT_OPTIONS properties
		#
		# useragent: The User Agent that RW Spider must apply in HTTP requests
		#
		# robot_name: The Robot name that RW Spider must apply in HTTP requests
		#
		# scan_documents_limit: The limit of the documents that RW Spider can download,
		# set as <tt>nil</tt> for start the indexing job without restriction on the number of the download
		#
		# scan_domain_limit: Set to restrict the indexing job to the current domain name
		#
    # scan_images -Set as <tt>true</tt> to enable the download of the image files
		#
		# scan_other_files: Set as <tt>true</tt> to enable the download of the other files as javascript and css
		#
    # follow_robotstxt_directive: Set as <tt>true</tt> to enable the analysis of the Robots.txt rules to check the accessibility of URLs 
		#
		# follow_HTTP_redirection: Set as <tt>true</tt> to follow the HTTP redirections
		#
		# timeout: The timeout of single URL analysis

    DEFAULT_OPTIONS = {
      :useragent => 'RW Spider/' + Rwspider::VERSION,
      :robot_name => 'rwspider',
		  :scan_documents_limit => 100,
      :scan_domain_limit => nil,
      :scan_images => false,
      :scan_other_files => false,
      :follow_robotstxt_directive => true,
      :follow_HTTP_redirection => true,
			:timeout => 5
    }
		
	# Inizialize a new Rwspider::Client instance, accept an <tt>Hash</tt> of options. 
	# RW Spider apply the Rwspider::Client::DEFAULT_OPTIONS indexing options if you don't customize them
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
  #  spider = Rwspider::Client::new(opts)
  #	
		def initialize (options = {})
			
      load_options options			
			@robotstxt_cache = Hash.new()			
      @main_hostname = ''
      @scanned_documents = 0
			@queue = Rwspider::Queue.new
			
		end
		
  # Start the crawling from the <tt>URL</tt>. 
  #
  # Rwspider::Client::start yield an instance of Rwspider::Document Class for each page downloaded.
  # At the end of execution returns an <tt>Array</tt> of Rwspider::Document instances.
  #     
  #  Rwspider::Client::start('http://www.rwspider.com') {do |d|
  #     puts 'Current URL ' + d.url.normalize.to_s
  #  }
  #  
  #  arr = Rwspider::Client::start('http://www.rwspider.com') 
  #  arr.each{do |d|
  #     puts 'Current URL ' + d.url.normalize.to_s
  #  }
  #
		def start (start_url)
						
			@queue << Rwspider::Document.new(start_url)
			
			@queue.each do |link|
				@main_url = link.url
				if @opts[:scan_documents_limit].nil? || @scanned_documents < @opts[:scan_documents_limit]
					set_as_visited link
					@main_hostname = link.url.host.downcase if @main_hostname.length == 0
					
					t = Thread.new(link) { |link|
						begin
							
							Timeout::timeout(@opts[:timeout]){	
								beginning = Time.now
								response = get_uri(link.url)
							  link.download_time = Time.now - beginning
								link.as_downloaded = true
								link.http_response = response
								
								case response
									when Net::HTTPSuccess then
									
									if  response.content_type == 'text/html' && (@opts[:scan_domain_limit].nil? || link.url.host.downcase.match(@opts[:scan_domain_limit]) )
										
										link.get_links
										link.get_images if @opts[:scan_images]
										link.get_other_files if @opts[:scan_other_files]
										
									  link.documents.each do |doc|
											add_to_queue doc
										end
									end
									
									when Net::HTTPRedirection then
									add_to_queue(Document.new(link.normalize_url(Document.new(response['location']).url))) if @opts[:follow_HTTP_redirection] 
								
								end
							}
						rescue Timeout::Error => e
								link.as_downloaded = false
						rescue StandardError => e
								link.as_downloaded = false
						end
						yield link if block_given?
					} 
					t.join					
				end
			end
			
			return @queue
			
		end
		
		
		
		private
		
		def add_to_queue (document)
			
			if follow?(document)
				@queue.each do |link|
					if link.url.normalize == document.url.normalize
						document.as_visited = true
						link.inbound_links << @main_url.normalize.to_s if !link.inbound_links.include?(@main_url.normalize.to_s)						
						break
					end
				end
				
				document.inbound_links << @main_url.normalize.to_s 
				@queue << document if !document.as_visited 
			end
		end
		
		def load_options(opts)
       @opts = DEFAULT_OPTIONS.merge opts   
    end
		
		def get_uri(url)		
			@ehttp = true
			begin				
				http = Net::HTTP.new(url.host, url.port)
				if url.scheme == 'https'
					http.verify_mode = OpenSSL::SSL::VERIFY_NONE
					http.use_ssl = true 
				end
				
				r =  http.request(Net::HTTP::Get.new(url.request_uri, {'User-Agent' => @opts[:useragent]}))
				return r
				
				rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError => e
				if @ehttp
					@ettp = false
					retry 
				end
			end
			
    end
		
    
		
		def set_as_visited(var)
			@scanned_documents = @scanned_documents + 1
			var.as_visited = true
		end
		
		
		
		def follow?(document)
			follow = true
			if @opts[:follow_robotstxt_directive]
				if @robotstxt_cache.include?(document.url.host)
					r = @robotstxt_cache[document.url.host]
					else
					r = Robotstxt::Parser.new(@opts[:robot_name])
					
					r.get(document.url.scheme + '://' + document.url.host)
					@robotstxt_cache[document.url.host] = r
				end 
				follow = r.allowed?(document.url.normalize.to_s)
			end
			follow
		end
		
		
		
	end
	
end