require 'net/dav'
require 'file_helper'
include FileHelper

class EmmaHelper
  attr_accessor :url, :username, :password
  TEMP_FOLDER = 'tmp'

  def initialize(url, username, password)
    @url = url
    @username = username
    @password = password
  end

  def merge
    dir = Dir.new(TEMP_FOLDER)
    merge_files = ''
    dir.each do |file|
      next if (['.', '..'].include?(file))
      merge_files = "#{merge_files} -in #{TEMP_FOLDER}/#{file}"
    end
    %x[java emma merge #{merge_files} -out coverage.es]
  end

  def generate_report
    %x[java emma report -r txt,html -in coverage.es]
  end

  def fetch_files url, username, password
    create_directory TEMP_FOLDER
    dav = Net::DAV.new(url)
    dav.verify_server = false
    dav.credentials(username, password)
    urls = []
    dav.find('.',:recursive => true, :suppress_errors => false, :filename => /\.(em|ec)\z/) do | item |
      urls << item.url.to_s
    end
    urls.each do |url|
      File.open("#{TEMP_FOLDER}/#{Time.now.strftime('%s')}_#{url.split('/').last}", 'w+'){|f| f.write(dav.get(url)) }
    end
  end

  def clean_temporary_data 
    delete_directory TEMP_FOLDER
  end

end
