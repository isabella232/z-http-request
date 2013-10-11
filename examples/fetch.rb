require 'rubygems'
require 'ZMachine'
require '../lib/z-http'

urls = ARGV
if urls.size < 1
  puts "Usage: #{$0} <url> <url> <...>"
  exit
end

pending = urls.size

ZMachine.run do
  urls.each do |url|
    http = ZMachine::HttpRequest.new(url).get
    http.callback {
      puts "#{url}\n#{http.response_header.status} - #{http.response.length} bytes\n"
      puts http.response

      pending -= 1
      ZMachine.stop if pending < 1
    }
    http.errback {
      puts "#{url}\n" + http.error

      pending -= 1
      ZMachine.stop if pending < 1
    }
  end
end
