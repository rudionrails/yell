# encoding: utf-8

require File.dirname(__FILE__) + '/../lib/yell'

puts <<-EOS

The extended formatting string looks like: %d [%5L] %p %h : %m.

logger = Yell.new STDOUT, :format => "[%f:%n in `%M'] %m"
logger.info "Hello World!"
#=> [003.4-formatting-on-your-own.rb:20 in `<main>'] Hello World!
#    ^                               ^      ^        ^
#    filename                        line   method   message


EOS

puts "=== actuale example ==="
logger = Yell.new STDOUT, :format => "[%f:%n in `%M'] %m"
logger.info "Hello World!"

