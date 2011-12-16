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
Yell works just like any other logger.

```ruby
logger = Yell.new 'development.log'

logger.info "Hello World"
#=> "Hello World"
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

