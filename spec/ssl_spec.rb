require 'helper'

requires_connection do

  describe ZMachine::HttpRequest do

    it "should initiate SSL/TLS on HTTPS connections" do
      ZMachine.run {
        http = ZMachine::HttpRequest.new('https://mail.google.com:443/mail/').get

        http.errback { failed(http) }
        http.callback {
          http.response_header.status.should == 302
          ZMachine.stop
        }
      }
    end
  end

end
