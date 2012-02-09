require 'rubygems'
require 'net/dav'
require 'ruby-debug'
require 'emma_helper'
include EmmaHelper

create_or_open_directory

fetch_files "http://localhost/webdav/", "test", "testing"

merge

generate_report

