# To change this template, choose Tools | Templates
# and open the template in the editor.

require "singleton"

class Session

    include Singleton

    def initialize
        @session = Hash.new
    end

    def self.[]=( key, value )
      self.instance[ key ] = value
    end

    def self.[]( key )
        self.instance[ key ]
    end

    def []=( key, value )
        Log.log( :WARN ) { "Overriding session variable with key '#{key}'" } unless @session[ key.to_sym ].nil?
        @session[ key.to_sym ] = value
    end

    def []( key )
        @session[ key.to_sym ]
    end
end
