module Yell
  module Adapters

    Dir[ ::File.dirname(__FILE__) + '/adapters/*.rb' ].each do |file|
      autoload ::File.basename(file, '.rb').capitalize, file
    end

    # returns an instance of the given processor type
    def self.new( type, options = {}, &block )
      puts "type: #{type.to_s.capitalize}"

      klass = case type
        when String, Symbol then self.const_get( type.to_s.capitalize )
        else type
      end
      
      klass.new( options, &block )
#rescue NameError => e
#      raise Yell::NoSuchAdapter, "no such adapter #{type.inspect}"
    end
    
  end
end
