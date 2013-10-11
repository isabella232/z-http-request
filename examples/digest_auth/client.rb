$: << 'lib' << '../../lib'

require 'z-http'
require 'z-http/middleware/digest_auth'

digest_config = {
  :username => 'digest_username',
  :password => 'digest_password'
}

ZMachine.run do

  conn_handshake = ZMachine::HttpRequest.new('http://localhost:3000')
  http_handshake = conn_handshake.get

  http_handshake.callback do
    conn = ZMachine::HttpRequest.new('http://localhost:3000')
    conn.use ZMachine::Middleware::DigestAuth, http_handshake.response_header['WWW_AUTHENTICATE'], digest_config
    http = conn.get
    http.callback do
      puts http.response
      ZMachine.stop
    end
  end
end
