**Yell - Your Extensible Logging Library**

[![Build Status](https://secure.travis-ci.org/rudionrails/yell.png?branch=master)](http://travis-ci.org/rudionrails/yell)

Yell works and is tested with ruby 1.8.7, 1.9.x, jruby 1.8 and 1.9 mode, rubinius 1.8 and 1.9 as well as ree.


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


### Adapters

Yell comes with various adapters already build-in. Those are the mainly IO-based 
adapters for every day use. There are additional ones available as separate gems. Please 
consult the [wiki](https://github.com/rudionrails/yell/wiki) on that - they are listed 
there.

The standard adapters are:

* **:stdout** or **STDOUT**: Messages will be written to STDOUT
* **:stderr** or **STDERR**: Messages will be written to STDERR
* **:file**: Messages will be written to a file
* **:datefile**: Messages will be written to a timestamped file


Here are some short examples on how to combine them:

#### Example: Notice messages go into `STDOUT` and error messages into `STDERR`

```ruby
logger = Yell.new do
  adapter STDOUT, :level => [:debug, :info, :warn]
  adapter STDERR, :level => [:error, :fatal]
end
```

#### Example: Notice messages to into `application.log` and error messages into `error.log`

```ruby
logger = Yell.new do
  adapter :file, 'application.log', :level => [:debug, :info, :warn]
  adapter :file, 'error.log', :level => [:error, :fatal]
end
```

#### Example: Every log severity is handled by a separate adapter and we ignore `:debug` and `:info` levels

```ruby
logger = Yell.new do
  level :warn # only start logging from :warn upwards

  adapter :stdout, :level => [:warn]
  adapter :datefile, 'error.log', :level => [:error]
  adapter :datefile, 'fatal.log', :level => [:fatal]
end
```

## Further Readings

[How To: Setting The Log Level](https://github.com/rudionrails/yell/wiki/101-setting-the-log-level)  
[How To: Formatting Log Messages](https://github.com/rudionrails/yell/wiki/101-formatting-log-messages)  
[How To: Using Adapters](https://github.com/rudionrails/yell/wiki/101-using-adapters)  
[How To: The Datefile Adapter](https://github.com/rudionrails/yell/wiki/101-the-datefile-adapter)  
[How To: Different Adapters for Different Log Levels](https://github.com/rudionrails/yell/wiki/101-different-adapters-for-different-log-levels)  


You can find further examples and additional adapters in the [wiki](https://github.com/rudionrails/yell/wiki).
or have a look into the examples folder.


Copyright &copy; 2011-2012 Rudolf Schmidt, released under the MIT license

