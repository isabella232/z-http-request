$: << 'lib' << '../lib'

require 'z-http'
require 'z-http/middleware/oauth'
require 'z-http/middleware/json_response'

require 'pp'

OAuthConfig = {
  :consumer_key     => '',
  :consumer_secret  => '',
  :access_token     => '',
  :access_token_secret => ''
}

EM.run do
  # automatically parse the JSON response into a Ruby object
  ZMachine::HttpRequest.use ZMachine::Middleware::JSONResponse

  # sign the request with OAuth credentials
  conn = ZMachine::HttpRequest.new('http://api.twitter.com/1/statuses/home_timeline.json')
  conn.use ZMachine::Middleware::OAuth, OAuthConfig

  http = conn.get
  http.callback do
    pp http.response
    EM.stop
  end

  http.errback do
    puts "Failed retrieving user stream."
    pp http.response
    EM.stop
  end
end
