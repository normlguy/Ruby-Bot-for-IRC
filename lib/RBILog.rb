# To change this template, choose Tools | Templates
# and open the template in the editor.

require "singleton"

class Log

    include Singleton    

    public
    def initialize
        @levels = { :REMARK => "Remark: ", :NOTICE => "Notice: ", :WARN => "Warning: ", :ERROR => "ERROR: " }
        @min_level = :NOTICE
    end

    def log( level, &text )
        str = @levels[ level.to_sym ]

        if str.nil? then str = @levels[ :NOTICE ], level = :NOTICE end

        return if cmp_level( @min_level, level )



        #just puts for now
        puts Time.now.strftime( "%m/%d/%y @ %H:%M:%S" ) + ": #{str} #{ yield }"
    end

    def self.log( level, &text )
        self.instance.log( level ) do yield end
    end

    def min_level( level )
        @level = level.to_sym
    end

    private
    # => returns true if a is a greater level than b
    def cmp_level( a, b )
        case a
        when :REMARK
            false
        when :NOTICE
            return b != :REMARK ? false : true
        when :WARN
            return b != :ERROR ? true : false 
        when :ERROR
            true
        end
    end
end
