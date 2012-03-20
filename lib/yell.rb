# encoding: utf-8

# Copyright (c) 2011-2012 Rudolf Schmidt
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'time'

$: << File.dirname(__FILE__)

require 'yell/formatter'
require 'yell/adapters'
require 'yell/level'
require 'yell/logger'

module Yell #:nodoc:
  # The possible log levels
  Severities = [ 'DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL', 'UNKNOWN' ]

  class << self
    # Creates a new logger instance.
    #
    # Refer to #Yell::Loggger for usage.
    #
    # @return [Yell::Logger] The logger instance
    def new( *args, &block )
      Yell::Logger.new( *args, &block )
    end

    def env #:nodoc:
      ENV['YELL_ENV'] || ENV['RACK_ENV'] || 'development'
    end
  end

end

