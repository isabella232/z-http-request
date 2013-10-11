# z-http-Request

TODO : update documentation

This is a fork of Ilya Gregoriks em-http-request, which will work with ZMachine/JRuby only and removes Eventmachine.
Furthmore alot of the nice stuff like socksify and more is removed as it is not needed for our simple http client use case.

Async (ZMachine) HTTP client, with support for:

- Asynchronous HTTP API for single & parallel request execution
- Keep-Alive and HTTP pipelining support
- Auto-follow 3xx redirects with max depth
- Automatic gzip & deflate decoding
- Streaming response processing
- Streaming file uploads
- HTTP proxy and SOCKS5 support
- Basic Auth & OAuth
- Connection-level & Global middleware support
- HTTP parser via [http_parser.rb](https://github.com/tmm1/http_parser.rb)
- Works wherever ZMachine runs: Rubinius, JRuby, MRI

## Getting started

    gem install z-http-request

- Introductory [screencast](http://everburning.com/news/ZMachine-screencast-z-http-request/)
- [Issuing GET/POST/etc requests](https://github.com/igrigorik/z-http-request/wiki/Issuing-Requests)
- [Issuing parallel requests with Multi interface](https://github.com/igrigorik/z-http-request/wiki/Parallel-Requests)
- [Handling Redirects & Timeouts](https://github.com/igrigorik/z-http-request/wiki/Redirects-and-Timeouts)
- [Keep-Alive and HTTP Pipelining](https://github.com/igrigorik/z-http-request/wiki/Keep-Alive-and-HTTP-Pipelining)
- [Stream processing responses & uploads](https://github.com/igrigorik/z-http-request/wiki/Streaming)
- [Issuing requests through HTTP & SOCKS5 proxies](https://github.com/igrigorik/z-http-request/wiki/Proxy)
- [Basic Auth & OAuth](https://github.com/igrigorik/z-http-request/wiki/Basic-Auth-and-OAuth)
- [GZIP & Deflate decoding](https://github.com/igrigorik/z-http-request/wiki/Compression)
- [z-http Middleware](https://github.com/igrigorik/z-http-request/wiki/Middleware)

## Extensions

Several higher-order Ruby projects have incorporated z-http and other Ruby HTTP clients:

- [EM-Synchrony](https://github.com/igrigorik/em-synchrony) - Collection of convenience classes and primitives to help untangle evented code (Ruby 1.9 + Fibers).
- [Rack-Client](https://github.com/halorgium/rack-client) - Use Rack API for server, test, and client side. Supports Rack middleware!
    - [Example in action](https://gist.github.com/802391)
- [Faraday](https://github.com/lostisland/faraday) - Modular HTTP client library using middleware heavily inspired by Rack.
    - [Example in action](https://gist.github.com/802395)

## Testing

- [WebMock](https://github.com/bblimke/webmock) - Library for stubbing and setting expectations on HTTP requests in Ruby.
    - Example of [using WebMock, VCR & z-http](https://gist.github.com/802553)

## Other libraries & applications using z-http

- [VMWare CloudFoundry](https://github.com/cloudfoundry) - The open platform-as-a-service project
- [PubSubHubbub](https://github.com/igrigorik/PubSubHubbub) - Asynchronous PubSubHubbub ruby client
- [em-net-http](https://github.com/jfairbairn/em-net-http) - Monkeypatching Net::HTTP to play ball with ZMachine
- [chirpstream](https://github.com/joshbuddy/chirpstream) - EM client for Twitters Chirpstream API
- [rsolr-async](https://github.com/mwmitchell/rsolr-async) - An asynchronus connection adapter for RSolr
- [Firering](https://github.com/EmmanuelOga/firering) - ZMachine powered Campfire API
- [RDaneel](https://github.com/hasmanydevelopers/RDaneel) - Ruby crawler which respects robots.txt
- [em-eventsource](https://github.com/AF83/em-eventsource) - EventSource client for ZMachine
- [sinatra-synchrony](https://github.com/kyledrake/sinatra-synchrony) - Sinatra plugin for synchronous use of EM
- and many others.. drop me a link if you want yours included!

### License

(MIT License) - Copyright (c) 2011 Ilya Grigorik
