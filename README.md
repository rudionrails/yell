Yell - Your Extensible Logging Library

[![Build Status](https://secure.travis-ci.org/rudionrails/yell.png)](http://travis-ci.org/rudionrails/yell)

## Installation

System wide:

```console
gem install yell
```

Or in your Gemfile:

```ruby
gem "yell"
```

## Usage

On the basics, Yell works just like any other logging library. However, it 
tries to make your log mesages  more readable. By default, it will format the given 
message as follows:

```ruby
logger = Yell.new STDOUT

logger.info "Hello World"
#=> "2012-02-29T09:30:00+01:00 [ INFO] 65784 : Hello World"
#    ^                         ^       ^       ^
#    ISO8601 Timestamp         Level   Pid     Message
```

When no arguments are given, Yell will check for `ENV['RACK_ENV']` and 
determine the filename from that.

Alternatively, you may define `ENV['YELL_ENV']` to set the filename. If neither 
`YELL_ENV` or `RACK_ENV` is defined, *'development'* will be the default. Also, if a 
`log` directory exists, Yell will place the file there (only if you have not passed
a filename explicitly.

Naturally, you can pass a `:filename` to Yell:

```ruby
logger = Yell.new "yell.log"
```

To learn about how to use [log levels](https://github.com/rudionrails/yell/wiki/101-setting-the-log-level), 
[log formatting](https://github.com/rudionrails/yell/wiki/101-formatting-log-messages), or different 
[adapters](https://github.com/rudionrails/yell/wiki/101-using-adapters) see the 
[wiki](https://github.com/rudionrails/yell/wiki) or have a look into the examples folder.


Copyright &copy; 2011-2012 Rudolf Schmidt, released under the MIT license

