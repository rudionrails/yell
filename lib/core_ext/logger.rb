require 'logger'

class Logger

  # @overload Set the level differently when a {Yell::Level} was given
  def level=( level )
    @level = level.is_a?(Yell::Level) ? level.to_i : level
  end

end

