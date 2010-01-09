$:.unshift(File.dirname(__FILE__) + "/lib")

require 'rubygems'
require 'rake'
require 'echoe'
require 'rwspider'


# Common package properties
PKG_NAME    = 'rwspider'
PKG_VERSION = Rwspider::VERSION
RUBYFORGE_PROJECT = 'rwspider'

if ENV['SNAPSHOT'].to_i == 1
  PKG_VERSION << "." << Time.now.utc.strftime("%Y%m%d%H%M%S")
end
 
 
Echoe.new(PKG_NAME, PKG_VERSION) do |p|
  p.author        = "Simone Rinzivillo"
  p.email         = "srinzivillo@gmail.com"
  p.summary       = "RW Spider is an multithreading spider client written in Ruby"
  p.url           = "http://www.rwspider.com"
  p.project       = RUBYFORGE_PROJECT
  p.description   = <<-EOD
    RW Spider is an multithreading spider client written in Ruby designed to make easy \
		the development of programs that spider the web.
  EOD

  p.need_zip      = true

  p.development_dependencies += ["rake  ~>0.8",
																 "hpricot  ~>0.8.2",
																 "robotstxt  ~>0.5.2",
                                 "echoe ~>3.1"]

  p.rcov_options  = ["-Itest -x mocha,rcov,Rakefile"]
end


desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -I lib -r rwspider.rb"
end

begin
  require 'code_statistics'
  desc "Show library's code statistics"
  task :stats do
    CodeStatistics.new(["Rwspider", "lib"],
                       ["Tests", "test"]).to_s
  end
rescue LoadError
  puts "CodeStatistics (Rails) is not available"
end

Dir["tasks/**/*.rake"].each do |file|
  load(file)
end
