module ZMachine

  # ZMachine based Multi request client, based on a streaming HTTPRequest class,
  # which allows you to open multiple parallel connections and return only when all
  # of them finish. (i.e. ideal for parallelizing workloads)
  #
  # == Example
  #
  #  ZMachine.run {
  #
  #    multi = ZMachine::MultiRequest.new
  #
  #    # add multiple requests to the multi-handler
  #    multi.add(:a, ZMachine::HttpRequest.new('http://www.google.com/').get)
  #    multi.add(:b, ZMachine::HttpRequest.new('http://www.yahoo.com/').get)
  #
  #    multi.callback {
  #      p multi.responses[:callback]
  #      p multi.responses[:errback]
  #
  #      ZMachine.stop
  #    }
  #  }
  #

  class MultiRequest
    include ZMachine::Deferrable

    attr_reader :requests, :responses

    def initialize
      @requests  = {}
      @responses = {:callback => {}, :errback => {}}
    end

    def add(name, conn)
      raise 'Duplicate Multi key' if @requests.key? name

      @requests[name] = conn

      conn.callback { @responses[:callback][name] = conn; check_progress }
      conn.errback  { @responses[:errback][name]  = conn; check_progress }
    end

    def finished?
      (@responses[:callback].size + @responses[:errback].size) == @requests.size
    end

    protected

    # invoke callback if all requests have completed
    def check_progress
      succeed(self) if finished?
    end

  end
end
