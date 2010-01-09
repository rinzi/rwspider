$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'rwspider'

class TestRwspider < Test::Unit::TestCase
	
	
	def test_start
		opts = {
			:useragent => 'My user agent',
			:robot_name => 'my_spider_name',
			:scan_documents_limit => 100,
			:scan_domain_limit => nil,
			:scan_images => true,
			:scan_other_files => false,
			:follow_robotstxt_directive => true,
			:follow_HTTP_redirection => true,
			:timeout => 5
		}
		r = Rwspider.start('http://www.rwspider.com', opts) 
		assert_equal('http://www.rwspider.com/', r[0].url.normalize.to_s)
	end
	
	def test_start_without_options
		r = Rwspider.start('http://www.rwspider.com') 
		assert_equal('http://www.rwspider.com/', r[0].url.normalize.to_s)
	end
	
end