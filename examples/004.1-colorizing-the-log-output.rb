# encoding: utf-8

require_relative '../lib/yell'

puts <<-EOS

You may colorize the log output on your io-based loggers loke so:

logger = Yell.new STDOUT, :colors => true

[:debug, :info, :warn, :error, :fatal, :unknown].each do |level|
  logger.send level, level
end

EOS

puts "=== actuale example ==="
logger = Yell.new STDOUT, :colors => true

[:debug, :info, :warn, :error, :fatal, :unknown].each do |level|
  logger.send level, level
end

