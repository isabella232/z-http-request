$: << './benchmarks'
require 'server'

url = 'http://127.0.0.1/10k.html'

with_server do
  Tach.meter(100) do

    excon = Excon.new(url)
    tach('Excon (persistent)') do
      excon.request(:method => 'get').body
    end

    tach('Excon') do
      Excon.get(url).body
    end

    tach('z-http-request') do |n|
      ZMachine.run {
        count = 0
        error = 0
        n.times do
          ZMachine.next_tick do
            http = ZMachine::HttpRequest.new(url, :connect_timeout => 1).get

            http.callback {
              count += 1
              if count == n
                p [count, error]
                ZMachine.stop
              end
            }

            http.errback {
              count += 1
              error += 1
              if count == n
                p [count, error]
                ZMachine.stop
              end
            }
          end
        end
      }
    end

    tach('z-http-request (persistent)') do |n|
      ZMachine.run {
        count = 0
        error = 0
        conn = ZMachine::HttpRequest.new(url)

        n.times do
          http = conn.get :keepalive => true
          http.callback {
            count += 1
            if count == n
              p [count, error]
              ZMachine.stop
            end
          }

          http.errback {
            count += 1
            error += 1
            if count == n
              p [count, error]
              ZMachine.stop
            end
          }
        end
      }
    end
  end
end

# +------------------------------+----------+
# | tach                         | total    |
# +------------------------------+----------+
# | z-http-request (persistent) | 0.018133 |
# +------------------------------+----------+
# | Excon (persistent)           | 0.023975 |
# +------------------------------+----------+
# | Excon                        | 0.032877 |
# +------------------------------+----------+
# | z-http-request              | 0.042891 |
# +------------------------------+----------+