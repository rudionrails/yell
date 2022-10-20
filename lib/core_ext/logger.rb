# frozen_string_literal: true

require 'logger'

class Logger # :nodoc:
  def level_with_yell=(level)
    self.level_without_yell = level.is_a?(Yell::Level) ? Integer(level) : level
  end
  alias level_without_yell= level=
  alias level= level_with_yell=

  def add_with_yell(severity, message = nil, progname = nil, &)
    add_without_yell(Integer(severity), message, progname, &)
  end
  alias add_without_yell add
  alias add add_with_yell
end
