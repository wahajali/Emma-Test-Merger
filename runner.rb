require 'rubygems'
require 'ruby-debug'
require 'emma_helper'

url = "http://localhost/webdav/"
username = "test"
password = "testing"

helper = EmmaHelper.new(url, username, password)
helper.fetch_files
helper.merge
helper.generate_report
helper.clear_temporary_data
