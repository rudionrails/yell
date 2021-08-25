module Yell
  # Module intended to be prepended onto ::Logger
  module StdlibLogWrapper
    def level=(level)
      super(level.is_a?(Yell::Level) ? Integer(level) : level)
    end

    def add( severity, message = nil, progname = nil, &block )
      super(Integer(severity), message, progname, &block)
    end
  end
end
