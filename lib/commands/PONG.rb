1# To change this template, choose Tools | Templates
# and open the template in the editor.

class PONG < Command
   
    def initialize
        ContentManager.add_response( self ) { |*args|
            self.call(*args)
        }
    end

    def self.call( *args )
        "PONG " + args.join( " " )
    end

    def self.responds_to
        [:PING]
    end
  
end
