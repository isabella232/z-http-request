# require 'helper'
# require 'fiber'

# describe ZMachine::HttpRequest do
#   context "with fibers" do

#     it "should be transparent to connection errors" do
#       ZMachine.run do
#         Fiber.new do
#           f = Fiber.current
#           fired = false
#           http = ZMachine::HttpRequest.new('http://non-existing.domain/', :connection_timeout => 0.1).get
#           http.callback { failed(http) }
#           http.errback { f.resume :errback }

#           Fiber.yield.should == :errback
#           ZMachine.stop
#         end.resume
#       end
#     end

#   end
# end
