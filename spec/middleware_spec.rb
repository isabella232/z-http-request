require 'helper'

describe ZMachine::HttpRequest do

  class EmptyMiddleware; end

  class GlobalMiddleware
    def response(resp)
      resp.response_header['X-Global'] = 'middleware'
    end
  end

  it "should accept middleware" do
    ZMachine.run {
      lambda {
        conn = ZMachine::HttpRequest.new('http://127.0.0.1:8090')
        conn.use ResponseMiddleware
        conn.use EmptyMiddleware

        ZMachine.stop
      }.should_not raise_error
    }
  end

  context "configuration" do
    class ConfigurableMiddleware
      def initialize(conf, &block)
        @conf = conf
        @block = block
      end

      def response(resp)
        resp.response_header['X-Conf'] = @conf
        resp.response_header['X-Block'] = @block.call
      end
    end

    it "should accept middleware initialization parameters" do
      ZMachine.run {
        conn = ZMachine::HttpRequest.new('http://127.0.0.1:8090')
        conn.use ConfigurableMiddleware, 'conf-value' do
          'block-value'
        end

        req = conn.get
        req.callback {
          req.response_header['X-Conf'].should match('conf-value')
          req.response_header['X-Block'].should match('block-value')
          ZMachine.stop
        }
      }
    end
  end

  context "request" do
    class ResponseMiddleware
      def response(resp)
        resp.response_header['X-Header'] = 'middleware'
        resp.response = 'Hello, Middleware!'
      end
    end

    it "should execute response middleware before user callbacks" do
      ZMachine.run {
        conn = ZMachine::HttpRequest.new('http://127.0.0.1:8090')
        conn.use ResponseMiddleware

        req = conn.get
        req.callback {
          req.response_header['X-Header'].should match('middleware')
          req.response.should match('Hello, Middleware!')
          ZMachine.stop
        }
      }
    end

    it "should execute global response middleware before user callbacks" do
      ZMachine.run {
        ZMachine::HttpRequest.use GlobalMiddleware

        conn = ZMachine::HttpRequest.new('http://127.0.0.1:8090')

        req = conn.get
        req.callback {
          req.response_header['X-Global'].should match('middleware')
          ZMachine.stop
        }
      }
    end
  end

  context "request" do
    class RequestMiddleware
      def request(client, head, body)
        head['X-Middleware'] = 'middleware'   # insert new header
        body += ' modified'                   # modify post body

        [head, body]
      end
    end

    it "should execute request middleware before dispatching request" do
      ZMachine.run {
        conn = ZMachine::HttpRequest.new('http://127.0.0.1:8090/')
        conn.use RequestMiddleware

        req = conn.post :body => "data"
        req.callback {
          req.response_header.status.should == 200
          req.response.should match(/data modified/)
          ZMachine.stop
        }
      }
    end
  end

  context "jsonify" do
    class JSONify
      def request(client, head, body)
        [head, MultiJson.dump(body)]
      end

      def response(resp)
        resp.response = MultiJson.load(resp.response)
      end
    end

    it "should use middleware to JSON encode and JSON decode the body" do
      ZMachine.run {
        conn = ZMachine::HttpRequest.new('http://127.0.0.1:8090/')
        conn.use JSONify

        req = conn.post :body => {:ruby => :hash}
        req.callback {
          req.response_header.status.should == 200
          req.response.should == {"ruby" => "hash"}
          ZMachine.stop
        }
      }
    end
  end

end
