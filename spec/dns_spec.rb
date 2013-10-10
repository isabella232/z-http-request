require 'helper'

describe ZMachine::HttpRequest do

  it "should fail gracefully on an invalid host in Location header" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/redirect/badhost', :connect_timeout => 0.1).get :redirects => 1
      http.callback { failed(http) }
      http.errback {
        http.error.should match('unable to resolve server address')
        ZMachine.stop
      }
    }
  end

  it "should fail GET on DNS timeout" do
    ZMachine.run {
      ZMachine.heartbeat_interval = 0.1
      http = ZMachine::HttpRequest.new('http://127.1.1.1/', :connect_timeout => 0.1).get
      http.callback { failed(http) }
      http.errback {
        http.response_header.status.should == 0
        ZMachine.stop
      }
    }
  end

  it "should fail GET on invalid host" do
    ZMachine.run {
      ZMachine.heartbeat_interval = 0.1
      http = ZMachine::HttpRequest.new('http://somethinglocal/', :connect_timeout => 0.1).get
      http.callback { failed(http) }
      http.errback {
        http.error.should match(/unable to resolve server address/)
        http.response_header.status.should == 0
        ZMachine.stop
      }
    }
  end

end
