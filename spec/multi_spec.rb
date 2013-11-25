require 'helper'
require 'stallion'

describe ZMachine::MultiRequest do

  let(:multi) { ZMachine::MultiRequest.new }
  let(:url)   { 'http://127.0.0.1:8090/' }

  it "should submit multiple requests in parallel and return once all of them are complete" do
    ZMachine.run {
      multi.add :a, ZMachine::HttpRequest.new(url).get
      multi.add :b, ZMachine::HttpRequest.new(url).post
      multi.add :c, ZMachine::HttpRequest.new(url).head
      multi.add :d, ZMachine::HttpRequest.new(url).delete
      multi.add :e, ZMachine::HttpRequest.new(url).put

      multi.callback {
        multi.responses[:callback].size.should == 5
        multi.responses[:callback].each { |name, response|
          [ :a, :b, :c, :d, :e ].should include(name)
          response.response_header.status.should == 200
        }
        multi.responses[:errback].size.should == 0

        ZMachine.stop
      }
    }
  end

  it "should require unique keys for each deferrable" do
    lambda do
      multi.add :df1, ZMachine::DefaultDeferrable.new
      multi.add :df1, ZMachine::DefaultDeferrable.new
    end.should raise_error("Duplicate Multi key")
  end


  describe "#requests" do
    it "should return the added requests" do
      request1 = double('request1', :callback => nil, :errback => nil)
      request2 = double('request2', :callback => nil, :errback => nil)

      multi.add :a, request1
      multi.add :b, request2

      multi.requests.should == {:a => request1, :b => request2}
    end
  end

  describe "#responses" do
    it "should have an empty :callback hash" do
      multi.responses[:callback].should be_a(Hash)
      multi.responses[:callback].size.should == 0
    end

    it "should have an empty :errback hash" do
      multi.responses[:errback].should be_a(Hash)
      multi.responses[:errback].size.should == 0
    end

    it "should provide access to the requests by name" do
      ZMachine.run {
        request1 = ZMachine::HttpRequest.new(url).get
        request2 = ZMachine::HttpRequest.new(url).post
        multi.add :a, request1
        multi.add :b, request2

        multi.callback {
          multi.responses[:callback][:a].should equal(request1)
          multi.responses[:callback][:b].should equal(request2)

          ZMachine.stop
        }
      }
    end
  end

  describe "#finished?" do
    it "should be true when no requests have been added" do
      multi.should be_finished
    end

    it "should be false while the requests are not finished" do
      ZMachine.run {
        multi.add :a, ZMachine::HttpRequest.new(url).get
        multi.should_not be_finished

        ZMachine.stop
      }
    end

    it "should be finished when all requests are finished" do
      ZMachine.run {
        multi.add :a, ZMachine::HttpRequest.new(url).get
        multi.callback {
          multi.should be_finished

          ZMachine.stop
        }
      }
    end
  end

end
