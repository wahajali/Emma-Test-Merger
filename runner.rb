require 'rubygems'
require 'ruby-debug'
require 'emma_helper'
include EmmaHelper

url = "http://localhost/webdav/"
username = "test"
password = "testing"

create_or_open_directory

fetch_files url, username, password

merge

generate_report

delete_folder 'tmp'
