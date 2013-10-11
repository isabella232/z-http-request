require 'helper'

class RedirectMiddleware
  attr_reader :call_count

  def initialize
    @call_count = 0
  end

  def request(c, h, r)
    @call_count += 1
    [h.merge({'EM-Middleware' => @call_count.to_s}), r]
  end
end

class PickyRedirectMiddleware < RedirectMiddleware
  def response(r)
    if r.redirect? && r.response_header['LOCATION'][-1].chr == '3'
      # set redirects to 0 to avoid further processing
      r.req.redirects = 0
    end
  end
end

describe ZMachine::HttpRequest do

  it "should follow location redirects" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/redirect').get :redirects => 1
      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 200
        http.response_header["CONTENT_ENCODING"].should == "gzip"
        http.response.should == "compressed"
        http.last_effective_url.to_s.should == 'http://127.0.0.1:8090/gzip'
        http.redirects.should == 1

        ZMachine.stop
      }
    }
  end

  it "should not follow redirects on created" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/redirect/created').get :redirects => 1
      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 201
        http.response.should match(/Hello/)
        ZMachine.stop
      }
    }
  end

  it "should not forward cookies across domains with http redirect" do

    expires  = (Date.today + 2).strftime('%a, %d %b %Y %T GMT')
    response =<<-HTTP.gsub(/^ +/, '')
      HTTP/1.1 301 MOVED PERMANENTLY
      Location: http://localhost:8071/
      Set-Cookie: foo=bar; expires=#{expires}; path=/; HttpOnly

    HTTP

    ZMachine.run do
      @stub = StubServer.new(:host => '127.0.0.1', :port => 8070, :response => response)
      @echo = StubServer.new(:host => 'localhost', :port => 8071, :echo     => true)

      http = ZMachine::HttpRequest.new('http://127.0.0.1:8070/').get :redirects => 1

      http.errback  { failed(http) }
      http.callback do
        http.response.should_not match(/Cookie/)
        @stub.stop
        @echo.stop
        ZMachine.stop
      end
    end
  end

  it "should forward valid cookies across domains with http redirect" do

    expires  = (Date.today + 2).strftime('%a, %d %b %Y %T GMT')
    response =<<-HTTP.gsub(/^ +/, '')
      HTTP/1.1 301 MOVED PERMANENTLY
      Location: http://127.0.0.1:8071/
      Set-Cookie: foo=bar; expires=#{expires}; path=/; HttpOnly

    HTTP

    ZMachine.run do
      @stub = StubServer.new(:host => '127.0.0.1', :port => 8070, :response => response)
      @echo = StubServer.new(:host => '127.0.0.1', :port => 8071, :echo     => true)

      http = ZMachine::HttpRequest.new('http://127.0.0.1:8070/').get :redirects => 1

      http.errback  { failed(http) }
      http.callback do
        http.response.should match(/Cookie/)
        @stub.stop
        @echo.stop
        ZMachine.stop
      end
    end
  end


  it "should normalize path and forward valid cookies across domains" do

    expires  = (Date.today + 2).strftime('%a, %d %b %Y %T GMT')
    response =<<-HTTP.gsub(/^ +/, '')
      HTTP/1.1 301 MOVED PERMANENTLY
      Location: http://127.0.0.1:8071?omg=ponies
      Set-Cookie: foo=bar; expires=#{expires}; path=/; HttpOnly

    HTTP

    ZMachine.run do
      @stub = StubServer.new(:host => '127.0.0.1', :port => 8070, :response => response)
      @echo = StubServer.new(:host => '127.0.0.1', :port => 8071, :echo     => true)

      http = ZMachine::HttpRequest.new('http://127.0.0.1:8070/').get :redirects => 1

      http.errback  { failed(http) }
      http.callback do
        http.response.should match(/Cookie/)
        @stub.stop
        @echo.stop
        ZMachine.stop
      end
    end
  end

  it "should redirect with missing content-length" do
    ZMachine.run {
      response = "HTTP/1.0 301 MOVED PERMANENTLY\r\nlocation: http://127.0.0.1:8090/redirect\r\n\r\n"
      @stub = StubServer.new(:host => '127.0.0.1', :port => 8070, :response => response)

      http = ZMachine::HttpRequest.new('http://127.0.0.1:8070/').get :redirects => 3
      http.errback { failed(http) }

      http.callback {
        http.response_header.status.should == 200
        http.response_header["CONTENT_ENCODING"].should == "gzip"
        http.response.should == "compressed"
        http.last_effective_url.to_s.should == 'http://127.0.0.1:8090/gzip'
        http.redirects.should == 3

        @stub.stop
        ZMachine.stop
      }
    }
  end

  it "should follow redirects on HEAD method" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/redirect/head').head :redirects => 1
      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 200
        http.last_effective_url.to_s.should == 'http://127.0.0.1:8090/'
        ZMachine.stop
      }
    }
  end

  it "should report last_effective_url" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/').get
      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 200
        http.last_effective_url.to_s.should == 'http://127.0.0.1:8090/'

        ZMachine.stop
      }
    }
  end

  it "should default to 0 redirects" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/redirect').get
      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 301
        http.last_effective_url.to_s.should == 'http://127.0.0.1:8090/redirect'
        http.redirects.should == 0

        ZMachine.stop
      }
    }
  end

  it "should not invoke redirect logic on failed(http) connections" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8070/', :connect_timeout => 0.1).get :redirects => 5
      http.callback { failed(http) }
      http.errback {
        http.redirects.should == 0
        ZMachine.stop
      }
    }
  end

  it "should normalize redirect urls" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/redirect/bad').get :redirects => 1
      http.errback { failed(http) }
      http.callback {
        http.last_effective_url.to_s.should match('http://127.0.0.1:8090/')
        http.response.should match('Hello, World!')
        ZMachine.stop
      }
    }
  end

  it "should fail gracefully on a missing host in absolute Location header" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/redirect/nohost').get :redirects => 1
      http.callback { failed(http) }
      http.errback {
        http.error.should == 'Location header format error'
        ZMachine.stop
      }
    }
  end

  it "should apply timeout settings on redirects" do
    ZMachine.run {
      t = Time.now.to_i
      ZMachine.heartbeat_interval = 0.1

      conn = ZMachine::HttpRequest.new('http://127.0.0.1:8090/redirect/timeout', :inactivity_timeout => 0.1)
      http = conn.get :redirects => 1
      http.callback { failed(http) }
      http.errback {
        (Time.now.to_i - t).should <= 1
        ZMachine.stop
      }
    }
  end

  it "should capture and pass cookies on redirect and pass_cookies by default" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/redirect/multiple-with-cookie').get :redirects => 2, :head => {'cookie' => 'id=2;'}
      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 200
        http.response_header["CONTENT_ENCODING"].should == "gzip"
        http.response.should == "compressed"
        http.last_effective_url.to_s.should == 'http://127.0.0.1:8090/gzip'
        http.redirects.should == 2
        http.cookies.should include("id=2;")
        http.cookies.should include("another_id=1")

        ZMachine.stop
      }
    }
  end

  it "should capture and not pass cookies on redirect if passing is disabled via pass_cookies" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/redirect/multiple-with-cookie').get :redirects => 2, :pass_cookies => false, :head => {'cookie' => 'id=2;'}
      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 200
        http.response_header["CONTENT_ENCODING"].should == "gzip"
        http.response.should == "compressed"
        http.last_effective_url.to_s.should == 'http://127.0.0.1:8090/gzip'
        http.redirects.should == 2
        http.cookies.should include("id=2;")
        http.cookies.should_not include("another_id=1; expires=Sat, 09 Aug 2031 17:53:39 GMT; path=/;")

        ZMachine.stop
      }
    }
  end

  it "should follow location redirects with path" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/redirect').get :path => '/redirect', :redirects => 1
      http.errback { failed(http) }
      http.callback {
        http.last_effective_url.to_s.should == 'http://127.0.0.1:8090/gzip'
        http.response_header.status.should == 200
        http.redirects.should == 1

        ZMachine.stop
      }
    }
  end

  it "should call middleware each time it redirects" do
    ZMachine.run {
      conn = ZMachine::HttpRequest.new('http://127.0.0.1:8090/redirect/middleware_redirects_1')
      conn.use RedirectMiddleware
      http = conn.get :redirects => 3
      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 200
        http.response_header['EM_MIDDLEWARE'].to_i.should == 3
        ZMachine.stop
      }
    }
  end

  it "should call middleware which may reject a redirection" do
    ZMachine.run {
      conn = ZMachine::HttpRequest.new('http://127.0.0.1:8090/redirect/middleware_redirects_1')
      conn.use PickyRedirectMiddleware
      http = conn.get :redirects => 3
      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 301
        http.last_effective_url.to_s.should == 'http://127.0.0.1:8090/redirect/middleware_redirects_2'
        ZMachine.stop
      }
    }
  end

end
