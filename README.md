Yell - Your Extensible Logging Library

## Installation

System wide:

```console
gem install yell
```

Or in your Gemfile:

```ruby
gem 'yell'
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

## Formatting

In order to format the log message you have a variety of possibilities. Yell provides 
placeholders to enrich your message with additional information. When passing 
the `:format` option, the following placeholders are recognized:

* **%m**: The message to be logged
* **%d**: The ISO8601 Timestamp
* **%L**: The log level, e.g `INFO`, `WARN`
* **%l**: The log level (short), e.g. `I`, `W`
* **%p**: The PID of the current process
* **%h**: The hostname of the machine

You can combine those placeholders as you like and the following examples should give 
you a better understanding.

### Predefined formats

There are some already defined formats available to use:

```ruby
# Default format: "%d [%5L] %p : %m"
logger = Yell.new STDOUT, :format => Yell::DefaultFormat
logger.info "Hello World!"
#=> "2012-02-29T09:30:00+01:00 [ INFO] 65784 : Hello World!"
#    ^                         ^       ^       ^
#    ISO8601 Timestamp         Level   Pid     Message
#
# NOTE: You don't need to pass this one as it will be chosen by default

# Basic format: "%l, %d: %m"
logger = Yell.new STDOUT, :format => Yell::BasicFormat
logger.info "Hello World!"
#=> "I, 2012-02-29T09:30:00+01:00 : Hello World!"
#    ^  ^                          ^
#    ^  ISO8601 Timestamp          Message
#    Level (short)

# Extended format: "%d [%5L] %p %h : %m"
logger = Yell.new STDOUT, :format => Yell::ExtendedFormat
logger.info "Hello World!"
#=> "2012-02-29T09:30:00+01:00 [ INFO] 65784 localhost : Hello World!"
#    ^                          ^      ^     ^           ^
#    ISO8601 Timestamp          Level  Pid   Hostname    Message
```

### No formatting

```ruby
logger = Yell.new STDOUT, :format => false
logger.info "Hello World!"
#=> "Hello World!"

# alternatively, you may use +Yell::NoFormat+
logger = Yell.new STDOUT, :format => Yell::NoFormat
logger.info "Hello World!"
#=> "Hello World!"
```

### Custom formatting

```ruby
logger = Yell.new STDOUT, :format => "%m @ %d"
logger.info "Hello World!"
#=> "Hello World! @ 2012-02-29T09:30:00+01:00"
```

### Alternate time format

```ruby
logger = Yell.new STDOUT, :format => Yell.format( "%d: %m", "%H:%M:%S" )
logger.info "Hello World!"
#=> "09:30:00 : Hello World!"
#    ^          ^
#    ^          Message
#    Custom time format
```



When no arguments are given, Yell will check for `ENV['RACK_ENV']` and 
determine the filename from that.

Alternatively, you may define `ENV['YELL_ENV']` to set the filename. If neither 
`YELL_ENV` or `RACK_ENV` is defined, `'development'` will be the default. Also, if a 
`log` directory exists, Yell will place the file there (only if you have not passed
a filename explicitly.

Naturally, if you pass a `:filename` to Yell:

```ruby
logger = Yell.new 'custom.log'
```

Copyright &copy; 2011-2012 Rudolf Schmidt, released under the MIT license

