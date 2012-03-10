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
"2012-02-29T09:30:00+01:00 [ INFO] 65784 : Hello World"
#^                         ^       ^       ^
#ISO8601 Timestamp         Level   Pid     message
```

You can alternate the formatting, or completely disable it altogether. See the 
next examples for reference:

```ruby
# No formatting
logger = Yell.new STDOUT, :format => false
logger.info "No formatting"
"No formatting"

# Alternate formatting
logger = Yell.new STDOUT, :format => "'%m' at %d"
logger.info "Alternate formatting"
"'Alternate format' at 2012-02-29T09:30:00+01:00"
```

As you can see, it basically is just string interpolation with a few reserved 
captures. You can see the list at #Yell::Formatter.

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

