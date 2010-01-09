$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'rwspider'

class TestDocument < Test::Unit::TestCase
	
	def setup
	  opts = {
			:scan_documents_limit => 1,
			:scan_domain_limit => 'www.rwspider.com',
			:timeout => 10
		}
		client = Rwspider::Client.new(opts)
		@doc = client.start('http://www.rwspider.com')[0]		
	end
	
	def test_initialize
		d = Rwspider::Document.new('http://www.rwspider.com')
		assert_instance_of Rwspider::Document, d
	end	
	
	def test_normalize_relative_url
    doc = Rwspider::Document::new('http://www.rwspider.com')
		assert_equal('http://www.rwspider.com/sitemap.html', doc.normalize_url(URI.parse('/sitemap.html')))
	end
	
	def test_normalize_absolute_url
    doc = Rwspider::Document::new('http://www.rwspider.com')
		assert_equal('http://www.rwspider.com/sitemap.html', doc.normalize_url(URI.parse('http://www.rwspider.com/sitemap.html')))
	end
	
	def test_parse
    doc = Rwspider::Document::new('http://www.rwspider.com')
		doc.parse('http://www.rwspider.com/sitemap.html')
		assert_equal('http://www.rwspider.com/sitemap.html', doc.url.normalize.to_s)
	end
	
	def test_get_links
		arr = @doc.get_links
		assert_instance_of Array, arr
	end
	
	def test_get_images
		arr = @doc.get_images
		assert_instance_of Array, arr
	end
	
	def test_get_other_files
		arr = @doc.get_other_files
		assert_instance_of Array, arr
	end
	
	
end