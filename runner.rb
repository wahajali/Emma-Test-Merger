require 'rubygems'
require 'net/dav'
require 'ruby-debug'

def create_or_open_directory
  #TODO should the directory be empty when it is created, or is it okay for it to have previous data?
  Dir::mkdir('tmp') unless FileTest::directory?('tmp')
end

def merge
  dir = Dir.new('tmp')
  test_string = ''
  dir.each do |file|
    next if (['.', '..'].include?(file))
    test_string = "#{test_string} -in tmp/#{file}"
  end
  puts "test string = #{test_string}"
  %x[java emma merge #{test_string} -out coverage.es]
end

def generate_report
  %x[java emma report -r txt,html -in coverage.es]
end

dav = Net::DAV.new("http://localhost/webdav/")
dav.verify_server = true
dav.credentials('test', 'testing')

urls = []
#TODO: when writing test cases check that times ending with emma are copied (not all files)
dav.find('.',:recursive => true, :suppress_errors => false, :filename => /\.(em|ec)\z/) do | item |
#dav.find('.',:recursive => true, :suppress_errors => false, :filename => /\.(emma)\z/) do | item |
  urls << item.url.to_s
end

puts urls

create_or_open_directory

urls.each do |url|
  #File.open("tmp/#{Time.now.strftime('%s')}_#{url.split('/').last}", 'w+'){|f| f.write(dav.get(url)) }
  File.open("tmp/#{url.split('/').last}", 'w+'){|f| f.write(dav.get(url)) }
end

merge

generate_report

