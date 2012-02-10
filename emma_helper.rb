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
      #TODO check that file name ends in em or ec
    end
    %x[java emma merge #{merge_files} -out coverage.es]
  end

  def generate_report
    %x[java emma report -r txt,html -in coverage.es]
  end

  def list_files(suppress_output = false, dav = nil)
    dav ||= connect
    urls = []
    dav.find('.',:recursive => true, :suppress_errors => false, :filename => /\.(em|ec)\z/) do | item |
      urls << item.url.to_s
      puts item.url.to_s unless suppress_output
    end
    urls
  end

  def fetch_files
    dav = connect
    urls = list_files(true, dav)
    create_directory TEMP_FOLDER
    urls.each do |url|
      File.open("#{TEMP_FOLDER}/#{Time.now.strftime('%s')}_#{url.split('/').last}", 'w+'){|f| f.write(dav.get(url)) }
    end
  end

  def clear_temporary_data 
    delete_directory TEMP_FOLDER
  end

  private 

  def connect
    dav = Net::DAV.new(@url)
    dav.verify_server = false
    dav.credentials(@username, @password)
    dav
  end

end
