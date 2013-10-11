require 'helper'

describe ZMachine::HttpRequest do

  def failed(http=nil)
    ZMachine.stop
    http ? fail(http.error) : fail
  end

  it "should perform successful GET" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/').get

      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 200
        http.response.should match(/Hello/)
        ZMachine.stop
      }
    }
  end

  it "should perform successful GET with a URI passed as argument" do
    ZMachine.run {
      uri = URI.parse('http://127.0.0.1:8090/')
      http = ZMachine::HttpRequest.new(uri).get

      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 200
        http.response.should match(/Hello/)
        ZMachine.stop
      }
    }
  end

  it "should succeed GET on missing path" do
    ZMachine.run {
      lambda {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090').get
      http.callback {
        http.response.should match(/Hello/)
        ZMachine.stop
      }
    }.should_not raise_error(ArgumentError)

    }
  end

  it "should raise error on invalid URL" do
    ZMachine.run {
      lambda {
      ZMachine::HttpRequest.new('random?text').get
    }.should raise_error

    ZMachine.stop
    }
  end

  it "should perform successful HEAD with a URI passed as argument" do
    ZMachine.run {
      uri = URI.parse('http://127.0.0.1:8090/')
      http = ZMachine::HttpRequest.new(uri).head

      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 200
        http.response.should == ""
        ZMachine.stop
      }
    }
  end

  it "should perform successful DELETE with a URI passed as argument" do
    ZMachine.run {
      uri = URI.parse('http://127.0.0.1:8090/')
      http = ZMachine::HttpRequest.new(uri).delete

      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 200
        http.response.should == ""
        ZMachine.stop
      }
    }
  end

  it "should return 404 on invalid path" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/fail').get

      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 404
        ZMachine.stop
      }
    }
  end

  it "should return HTTP reason" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/fail').get

      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 404
        http.response_header.http_reason.should == 'Not Found'
        ZMachine.stop
      }
    }
  end

  it "should return HTTP reason 'unknown' on a non-standard status code" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/fail_with_nonstandard_response').get

      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 420
        http.response_header.http_reason.should == 'unknown'
        ZMachine.stop
      }
    }
  end

  it "should build query parameters from Hash" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/').get :query => {:q => 'test'}

      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 200
        http.response.should match(/test/)
        ZMachine.stop
      }
    }
  end

  it "should pass query parameters string" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/').get :query => "q=test"

      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 200
        http.response.should match(/test/)
        ZMachine.stop
      }
    }
  end

  it "should encode an array of query parameters" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/echo_query').get :query => {:hash =>['value1','value2']}

      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 200
        http.response.should match(/hash\[\]=value1&hash\[\]=value2/)
        ZMachine.stop
      }
    }
  end

  it "should perform successful PUT" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/').put :body => "data"

      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 200
        http.response.should match(/data/)
        ZMachine.stop
      }
    }
  end

  it "should perform successful POST" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/').post :body => "data"

      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 200
        http.response.should match(/data/)
        ZMachine.stop
      }
    }
  end

  it "should perform successful PATCH" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/').patch :body => "data"

      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 200
        http.response.should match(/data/)
        ZMachine.stop
      }
    }
  end

  it "should escape body on POST" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/').post :body => {:stuff => 'string&string'}

      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 200
        http.response.should == "stuff=string%26string"
        ZMachine.stop
      }
    }
  end

  it "should perform successful POST with Ruby Hash/Array as params" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/').post :body => {"key1" => 1, "key2" => [2,3]}

      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 200

        http.response.should match(/key1=1&key2\[0\]=2&key2\[1\]=3/)
        ZMachine.stop
      }
    }
  end

  it "should set content-length to 0 on posts with empty bodies" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/echo_content_length_from_header').post

      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 200

        http.response.strip.split(':')[1].should == '0'
        ZMachine.stop
      }
    }
  end

  it "should perform successful POST with Ruby Hash/Array as params and with the correct content length" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/echo_content_length').post :body => {"key1" => "data1"}

      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 200

        http.response.to_i.should == 10
        ZMachine.stop
      }
    }
  end

  it "should perform successful GET with custom header" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/').get :head => {'if-none-match' => 'evar!'}

      http.errback { p http; failed(http) }
      http.callback {
        http.response_header.status.should == 304
        ZMachine.stop
      }
    }
  end

  it "should perform basic auth" do
    ZMachine.run {

      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/authtest').get :head => {'authorization' => ['user', 'pass']}

      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 200
        ZMachine.stop
      }
    }
  end

  it "should perform basic auth via the URL" do
    ZMachine.run {

      http = ZMachine::HttpRequest.new('http://user:pass@127.0.0.1:8090/authtest').get

      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 200
        ZMachine.stop
      }
    }
  end

  it "should return peer's IP address" do
     ZMachine.run {

       conn = ZMachine::HttpRequest.new('http://127.0.0.1:8090/')
       conn.peer.should be_nil

       http = conn.get
       http.peer.should be_nil

       http.errback { failed(http) }
       http.callback {
         conn.peer.should == '127.0.0.1'
         http.peer.should == '127.0.0.1'

         ZMachine.stop
       }
     }
   end

  it "should remove all newlines from long basic auth header" do
    ZMachine.run {
      auth = {'authorization' => ['aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 'zzzzzzzzzzzzzzzzzzzzzzzzzzzzzz']}
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/auth').get :head => auth
      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 200
        http.response.should == "Basic YWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhOnp6enp6enp6enp6enp6enp6enp6enp6enp6enp6eg=="
        ZMachine.stop
      }
    }
  end

  it "should send proper OAuth auth header" do
    ZMachine.run {
      oauth_header = 'OAuth oauth_nonce="oqwgSYFUD87MHmJJDv7bQqOF2EPnVus7Wkqj5duNByU", b=c, d=e'
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/auth').get :head => {
        'authorization' => oauth_header
      }

      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 200
        http.response.should == oauth_header
        ZMachine.stop
      }
    }
  end

  it "should return ETag and Last-Modified headers" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/echo_query').get

      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 200
        http.response_header.etag.should match('abcdefg')
        http.response_header.last_modified.should match('Fri, 13 Aug 2010 17:31:21 GMT')
        ZMachine.stop
      }
    }
  end

  it "should return raw headers in a hash" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/echo_headers').get

      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 200
        http.response_header.raw['Set-Cookie'].should match('test=yes')
        http.response_header.raw['X-Forward-Host'].should match('proxy.local')
        ZMachine.stop
      }
    }
  end

  it "should detect deflate encoding" do
    ZMachine.run {

      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/deflate').get :head => {"accept-encoding" => "deflate"}

      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 200
        http.response_header["CONTENT_ENCODING"].should == "deflate"
        http.response.should == "compressed"

        ZMachine.stop
      }
    }
  end

  # it "should detect gzip encoding" do
  #   ZMachine.run {

  #     http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/gzip').get :head => {"accept-encoding" => "gzip, compressed"}

  #     http.errback { failed(http) }
  #     http.callback {
  #       http.response_header.status.should == 200
  #       http.response_header["CONTENT_ENCODING"].should == "gzip"
  #       http.response.should == "compressed"

  #       ZMachine.stop
  #     }
  #   }
  # end

  it "should stream gzip responses" do
    expected_response = Zlib::GzipReader.open(File.dirname(__FILE__) + "/fixtures/gzip-sample.gz") { |f| f.read }
    actual_response = ''

    ZMachine.run {

      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/gzip-large').get :head => {"accept-encoding" => "gzip, compressed"}

      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 200
        http.response_header["CONTENT_ENCODING"].should == "gzip"
        http.response.should == ''

        actual_response.should == expected_response

        ZMachine.stop
      }
      http.stream do |chunk|
        actual_response << chunk
      end
    }
  end

  it "should not decode the response when configured so" do
    ZMachine.run {

      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/gzip').get :head => {
        "accept-encoding" => "gzip, compressed"
      }, :decoding => false

      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 200
        http.response_header["CONTENT_ENCODING"].should == "gzip"

        raw = http.response
        Zlib::GzipReader.new(StringIO.new(raw)).read.should == "compressed"

        ZMachine.stop
      }
    }
  end

  it "should timeout after 0.1 seconds of inactivity" do
    ZMachine.run {
      t = Time.now.to_i
      ZMachine.heartbeat_interval = 0.1
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/timeout', :inactivity_timeout => 0.1).get

      http.errback {
        http.error.should == Errno::ETIMEDOUT
        (Time.now.to_i - t).should <= 1
        ZMachine.stop
      }
      http.callback { failed(http) }
    }
  end

  it "should complete a Location: with a relative path" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/relative-location').get

      http.errback { failed(http) }
      http.callback {
        http.response_header['LOCATION'].should == 'http://127.0.0.1:8090/forwarded'
        ZMachine.stop
      }
    }
  end

  context "body content-type encoding" do
    it "should not set content type on string in body" do
      ZMachine.run {
        http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/echo_content_type').post :body => "data"

        http.errback { failed(http) }
        http.callback {
          http.response_header.status.should == 200
          http.response.should be_empty
          ZMachine.stop
        }
      }
    end

    # does not work with puma - see issue #63
    # it "should set content-type automatically when passed a ruby hash/array for body" do
    #   ZMachine.run {
    #     http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/echo_content_type').post :body => {:a => :b}

    #     http.errback { failed(http) }
    #     http.callback {
    #       http.response_header.status.should == 200
    #       http.response.should match("application/x-www-form-urlencoded")
    #       ZMachine.stop
    #     }
    #   }
    # end

    it "should not override content-type when passing in ruby hash/array for body" do
      ZMachine.run {
        ct = 'text; charset=utf-8'
        http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/echo_content_type').post({
          :body => {:a => :b}, :head => {'content-type' => ct}})

          http.errback { failed(http) }
          http.callback {
            http.response_header.status.should == 200
            http.content_charset.should == Encoding.find('utf-8') if defined? Encoding
            http.response_header["CONTENT_TYPE"].should == ct
            ZMachine.stop
          }
      }
    end

    it "should default to external encoding on invalid encoding" do
      ZMachine.run {
        ct = 'text/html; charset=utf-8lias'
        http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/echo_content_type').post({
          :body => {:a => :b}, :head => {'content-type' => ct}})

          http.errback { failed(http) }
          http.callback {
            http.response_header.status.should == 200
            http.content_charset.should == Encoding.find('utf-8') if defined? Encoding
            http.response_header["CONTENT_TYPE"].should == ct
            ZMachine.stop
          }
      }
    end

    it "should processed escaped content-type" do
      ZMachine.run {
        ct = "text/html; charset=\"ISO-8859-4\""
        http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/echo_content_type').post({
          :body => {:a => :b}, :head => {'content-type' => ct}})

          http.errback { failed(http) }
          http.callback {
            http.response_header.status.should == 200
            http.content_charset.should == Encoding.find('ISO-8859-4') if defined? Encoding
            http.response_header["CONTENT_TYPE"].should == ct
            ZMachine.stop
          }
      }
    end
  end

  context "optional header callback" do
    it "should optionally pass the response headers" do
      ZMachine.run {
        http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/').get

        http.errback { failed(http) }
        http.headers { |hash|
          hash.should be_an_kind_of Hash
          hash.should include 'CONNECTION'
          hash.should include 'CONTENT_LENGTH'
        }

        http.callback {
          http.response_header.status.should == 200
          http.response.should match(/Hello/)
          ZMachine.stop
        }
      }
    end

    it "should allow to terminate current connection from header callback" do
      ZMachine.run {
        http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/').get

        http.callback { failed(http) }
        http.headers { |hash|
          hash.should be_an_kind_of Hash
          hash.should include 'CONNECTION'
          hash.should include 'CONTENT_LENGTH'

          http.close('header callback terminated connection')
        }

        http.errback { |e|
          http.response_header.status.should == 200
          http.error.should == 'header callback terminated connection'
          http.response.should == ''
          ZMachine.stop
        }
      }
    end
  end

  it "should optionally pass the response body progressively" do
    ZMachine.run {
      body = ''
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/').get

      http.errback { failed(http) }
      http.stream { |chunk| body += chunk }

      http.callback {
        http.response_header.status.should == 200
        http.response.should == ''
        body.should match(/Hello/)
        ZMachine.stop
      }
    }
  end

  it "should optionally pass the deflate-encoded response body progressively" do
    ZMachine.run {
      body = ''
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/deflate').get :head => {
        "accept-encoding" => "deflate, compressed"
      }

      http.errback { failed(http) }
      http.stream { |chunk| body += chunk }

      http.callback {
        http.response_header.status.should == 200
        http.response_header["CONTENT_ENCODING"].should == "deflate"
        http.response.should == ''
        body.should == "compressed"
        ZMachine.stop
      }
    }
  end

  it "should accept & return cookie header to user" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/set_cookie').get

      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 200
        http.response_header.cookie.should == "id=1; expires=Sat, 09 Aug 2031 17:53:39 GMT; path=/;"
        ZMachine.stop
      }
    }
  end

  it "should return array of cookies on multiple Set-Cookie headers" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/set_multiple_cookies').get

      http.errback { failed(http) }
      http.callback {
        http.response_header.status.should == 200
        http.response_header.cookie.size.should == 2
        http.response_header.cookie.first.should == "id=1; expires=Sat, 09 Aug 2031 17:53:39 GMT; path=/;"
        http.response_header.cookie.last.should == "id=2;"

        ZMachine.stop
      }
    }
  end

  it "should pass cookie header to server from string" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/echo_cookie').get :head => {'cookie' => 'id=2;'}

      http.errback { failed(http) }
      http.callback {
        http.response.should == "id=2;"
        ZMachine.stop
      }
    }
  end

  it "should pass cookie header to server from Hash" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/echo_cookie').get :head => {'cookie' => {'id' => 2}}

      http.errback { failed(http) }
      http.callback {
        http.response.should == "id=2;"
        ZMachine.stop
      }
    }
  end

  it "should get the body without Content-Length" do
    # ZMachine.debug = true
    # ZMachine.logger = Object.new
    # class << ZMachine.logger
    #   def debug(str, hash = {})
    #     puts "#{str} #{hash.inspect}"
    #   end
    # end
    ZMachine.run {
      @s = StubServer.new("HTTP/1.1 200 OK\r\n\r\nFoo")

      http = ZMachine::HttpRequest.new('http://127.0.0.1:8081/').get
      http.errback { failed(http) }
      http.callback {
        http.response.should match(/Foo/)
        http.response_header['CONTENT_LENGTH'].should be_nil

        @s.stop
        ZMachine.stop
      }
    }
  end

  context "when talking to a stub HTTP/1.0 server" do
    it "should get the body without Content-Length" do

      ZMachine.run {
        @s = StubServer.new("HTTP/1.0 200 OK\r\nConnection: close\r\n\r\nFoo")

        http = ZMachine::HttpRequest.new('http://127.0.0.1:8081/').get
        http.errback { failed(http) }
        http.callback {
          http.response.should match(/Foo/)
          http.response_header['CONTENT_LENGTH'].should be_nil

          @s.stop
          ZMachine.stop
        }
      }
    end

    it "should work with \\n instead of \\r\\n" do
      ZMachine.run {
        @s = StubServer.new("HTTP/1.0 200 OK\nContent-Type: text/plain\nContent-Length: 3\nConnection: close\n\nFoo")

        http = ZMachine::HttpRequest.new('http://127.0.0.1:8081/').get
        http.errback { failed(http) }
        http.callback {
          http.response_header.status.should == 200
          http.response_header['CONTENT_TYPE'].should == 'text/plain'
          http.response.should match(/Foo/)

          @s.stop
          ZMachine.stop
        }
      }
    end

    it "should handle invalid HTTP response" do
      ZMachine.run {
        @s = StubServer.new("<html></html>")

        http = ZMachine::HttpRequest.new('http://127.0.0.1:8081/').get
        http.callback { failed(http) }
        http.errback {
          http.error.should_not be_nil
          ZMachine.stop
        }
      }
    end
  end

  it "should stream a file off disk" do
    ZMachine.run {
      http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/').post :file => 'spec/fixtures/google.ca'
      http.errback { failed(http) }
      http.callback {
        http.response.should match('google')
        ZMachine.stop
      }
    }
  end

  it "should reconnect if connection was closed between requests" do
    ZMachine.run {
      conn = ZMachine::HttpRequest.new('http://127.0.0.1:8090/')
      req = conn.get

      req.errback { failed(req) }

      req.callback do
        conn.close('client closing connection')

        ZMachine.next_tick do
          req = conn.get :path => "/gzip"
          req.errback { failed(req) }
          req.callback do
            req.response_header.status.should == 200
            req.response.should match('compressed')
            ZMachine.stop
          end
        end
      end
    }
  end

  it "should report error if connection was closed by server on client keepalive requests" do
    ZMachine.run {
      conn = ZMachine::HttpRequest.new('http://127.0.0.1:8090/')
      req = conn.get :keepalive => true
      req.errback { failed(req) }

      req.callback do
        req = conn.get

        req.callback { failed(req) }
        req.errback do
          req.error.should match('connection closed by server')
          ZMachine.stop
        end
      end
    }
  end

  it 'should handle malformed Content-Type header repetitions' do
    ZMachine.run {
      response =<<-HTTP.gsub(/^ +/, '').strip
        HTTP/1.0 200 OK
        Content-Type: text/plain; charset=iso-8859-1
        Content-Type: text/plain; charset=utf-8
        Content-Length: 5
        Connection: close

        Hello
      HTTP

      @s       = StubServer.new(response)
      http     = ZMachine::HttpRequest.new('http://127.0.0.1:8081/').get
      http.errback { failed(http) }
      http.callback {
        http.content_charset.should == Encoding::ISO_8859_1 if defined? Encoding
        ZMachine.stop
      }
    }
  end

  it "should allow indifferent access to headers" do
    ZMachine.run {
      response =<<-HTTP.gsub(/^ +/, '').strip
        HTTP/1.0 200 OK
        Content-Type: text/plain; charset=utf-8
        X-Custom-Header: foo
        Content-Length: 5
        Connection: close

        Hello
      HTTP

      @s       = StubServer.new(response)
      http     = ZMachine::HttpRequest.new('http://127.0.0.1:8081/').get
      http.errback { failed(http) }
      http.callback {
        http.response_header["Content-Type"].should == "text/plain; charset=utf-8"
        http.response_header["CONTENT_TYPE"].should == "text/plain; charset=utf-8"

        http.response_header["Content-Length"].should == "5"
        http.response_header["CONTENT_LENGTH"].should == "5"

        http.response_header["X-Custom-Header"].should == "foo"
        http.response_header["X_CUSTOM_HEADER"].should == "foo"

        ZMachine.stop
      }
    }
  end

  context "User-Agent" do
    it 'should default to "ZMachine HttpClient"' do
      ZMachine.run {
        http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/echo-user-agent').get

        http.errback { failed(http) }
        http.callback {
          http.response.should == '"ZMachine HttpClient"'
          ZMachine.stop
        }
      }
    end

    it 'should keep header if given empty string' do
      ZMachine.run {
        http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/echo-user-agent').get(:head => { 'user-agent'=>'' })

        http.errback { failed(http) }
        http.callback {
          http.response.should == '""'
          ZMachine.stop
        }
      }
    end

    it 'should ommit header if given nil' do
      ZMachine.run {
        http = ZMachine::HttpRequest.new('http://127.0.0.1:8090/echo-user-agent').get(:head => { 'user-agent'=>nil })

        http.errback { failed(http) }
        http.callback {
          http.response.should == 'nil'
          ZMachine.stop
        }
      }
    end
  end
end
