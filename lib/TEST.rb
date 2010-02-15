# To change this template, choose Tools | Templates
# and open the template in the editor.

class A
    @hash = Hash.new

    def self.[]=( key, value )
        @hash[ key ] = value
    end

    def self.print
        p @hash.inspect
    end

end

A[:what] = "who"

A.print



