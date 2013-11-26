# Z-HTTP-Request

This is a fork of Ilya Gregoriks em-http-request, ported to
[ZMachine](https://github.com/liquidm/zmachine). Furthermore stuff like
socksify has been removed as it is not needed for our simple http client use
case.

[![Gem Version](https://badge.fury.io/rb/z-http-request.png)](http://badge.fury.io/rb/z-http-request)
[![Build Status](https://travis-ci.org/liquidm/z-http-request.png)](https://travis-ci.org/liquidm/z-http-request)
[![Code Climate](https://codeclimate.com/github/liquidm/z-http-request.png)](https://codeclimate.com/github/liquidm/z-http-request)
[![Dependency Status](https://gemnasium.com/liquidm/z-http-request.png)](https://gemnasium.com/liquidm/z-http-request)

## Installation

Add this line to your application's Gemfile:

    gem 'z-http-request'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install z-http-request

## Usage

Z-HTTP-Request is mostly API compatible with em-http-request and EventMachine.
Replace `EM` / `EventMachine` with `ZMachine` in your code and it should work
out of the box.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
