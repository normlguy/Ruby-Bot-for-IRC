# To change this template, choose Tools | Templates
# and open the template in the editor.

require "CommandManager"

class Command

    def initialize
        #CommandManager.add_response( self, lambda { |*a| } )
    end

    def self.inherited( subclass )

        proc = lambda { |*args|
            #thr = Thread.new( args ) { |*args|
                #lock down ruby a bit before we go calling external commands
                #$SAFE = 2 # $SAFE is not supported by jRuby

                #puts "(!) " << args.join( " " )

                return subclass.call( args )#subclass.call( args )

            #}

            #return thr.value

            

        }

        Commands.register( subclass.to_s, &proc )
        #CommandManager.add_response( subclass, &proc )


       
    end

    # => commands respond to nothing by default
    def responds_to
        []
    end

end
