require 'net/dav'
require 'fileutils'
module EmmaHelper
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
    %x[java emma merge #{test_string} -out coverage.es]
  end

  def generate_report
    %x[java emma report -r txt,html -in coverage.es]
  end

  def fetch_files url, username, password
    dav = Net::DAV.new(url)
    dav.verify_server = false
    dav.credentials(username, password)
    urls = []
    #TODO: when writing test cases check that times ending with emma are copied (not all files)
    dav.find('.',:recursive => true, :suppress_errors => false, :filename => /\.(em|ec)\z/) do | item |
      urls << item.url.to_s
    end
    urls.each do |url|
      File.open("tmp/#{Time.now.strftime('%s')}_#{url.split('/').last}", 'w+'){|f| f.write(dav.get(url)) }
    end
  end

  def delete_folder name
    FileUtils.rm_rf(name)
  end
end
