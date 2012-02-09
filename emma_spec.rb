require 'rspec'
require 'webmock/rspec'
require 'net/dav'

describe 'Emma' do
  
  before(:all) do
    WebMock.allow_net_connect!(:net_http_connect_on_start => true)
    @url = "http://192.168.1.109/webdav/"
    @dav = Net::DAV.new(@url)
    @dav.verify_server = false
    @dav.credentials('test', 'testing')
  end

  it 'generate get request' do
    stub_request(:any, @url)
    @dav.get(@url)
    assert_requested :get, @url
  end

  it 'should return only em | ec files' do
    WebMock.disable!
    @urls = []
    @dav.find('.',:recursive => true, :suppress_errors => false, :filename => /\.(em|ec)\z/) do | item |
      @urls << item.url.to_s
    end
    @urls.each do |url|
      url.should match /\.(em|ec)\z/
    end
  end
end
