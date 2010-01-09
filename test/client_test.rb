$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'rwspider'

class TestClient < Test::Unit::TestCase
	
	def setup
	  opts = {
			:useragent => 'My user agent',
			:robot_name => 'my_spider_name',
			:scan_documents_limit => 10,
			:scan_domain_limit => nil,
			:scan_images => true,
			:scan_other_files => false,
			:follow_robotstxt_directive => true,
			:follow_HTTP_redirection => true,
			:timeout => 5
		}
		@client = Rwspider::Client.new(opts)		
	end
	
	def test_initialize
		client = Rwspider::Client.new
		assert_instance_of Rwspider::Client, client
	end	
	
	def test_start
		r = @client.start('http://www.rwspider.com')
		assert_equal('http://www.rwspider.com/', r[0].url.normalize.to_s)
		assert_instance_of Rwspider::Queue, r
  end
	
end