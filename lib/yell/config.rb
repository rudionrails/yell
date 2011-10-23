module Yell
  class Config
  
    def initialize( yaml_file = nil )
      @yaml_file = yaml_file
      
      reload!
    end
    
    def reload!; @options = nil; end
    
    def []( key ); options[key]; end
    
    def options
      @options ||= begin
        if yaml_file_defined?
          require 'yaml'
          require 'erb'

          (YAML.load( ERB.new( File.read( yaml_file ) ).result ) || {})[ env ] || {}
        else
          {} # default
        end
      end
    end

    def env
      ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'default'
    end

    def root
      return ENV['RAILS_ROOT'] if ENV['RAILS_ROOT']
      return RAILS_ROOT if defined?( RAILS_ROOT )

      '.'
    end
    

    private

    def yaml_file_defined?
      yaml_file && File.exist?( yaml_file )
    end
    
    # Locates the yell.yml file. The file can end in .yml or .yaml,
    # and be located in the current directory (eg. project root) or
    # in a .config/ or config/ subdirectory of the current directory.
    def yaml_file
      @yaml_file || Dir.glob( "#{root}/{,.config/,config/}yell{.yml,.yaml}" ).first
    end
   
  end   
end
