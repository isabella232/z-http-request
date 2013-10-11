require 'helper'

requires_connection do

  describe ZMachine::HttpRequest do

    it "should perform successful pipelined GETs" do
      ZMachine.run do

        # Mongrel doesn't support pipelined requests - bah!
        conn = ZMachine::HttpRequest.new('http://www.igvita.com/')

        pipe1 = conn.get :keepalive => true
        pipe2 = conn.get :path => '/archives/', :keepalive => true

        processed = 0
        stop = proc { ZMachine.stop if processed == 2}

        pipe1.errback { failed(conn) }
        pipe1.callback {
          processed += 1
          pipe1.response_header.status.should == 200
          stop.call
        }

        pipe2.errback { failed(conn) }
        pipe2.callback {
          processed += 1
          pipe2.response_header.status.should == 200
          pipe2.response.should match(/html/i)
          stop.call
        }

      end
    end

    it "should perform successful pipelined HEAD requests" do
      ZMachine.run do
        conn = ZMachine::HttpRequest.new('http://www.igvita.com/')

        pipe1 = conn.head :keepalive => true
        pipe2 = conn.head :path => '/archives/', :keepalive => true

        processed = 0
        stop = proc { ZMachine.stop if processed == 2}

        pipe1.errback { failed(conn) }
        pipe1.callback {
          processed += 1
          pipe1.response_header.status.should == 200
          stop.call
        }

        pipe2.errback { failed(conn) }
        pipe2.callback {
          processed += 1
          pipe2.response_header.status.should == 200
          stop.call
        }

      end

    end
  end

end
