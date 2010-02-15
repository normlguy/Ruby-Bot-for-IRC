# To change this template, choose Tools | Templates
# and open the template in the editor.

class ECHO

    echo = lambda {

        Hooks.add( :PARSED, :COMMAND_ECHO ) do |msg|

            #p "echo inspect: #{msg.inspect}"

            unless msg.nil? or msg[:message].nil?
                if msg[:message].first.upcase  == \
                      ( Config["Commands"]["trigger"] + "ECHO" ).upcase then
                    Commands.queue( "SAY", msg[:message][1..msg[:message].length-1] )

                end
            end
            nil
        end

        nil
    
    }

    Hooks.add( :CHANNEL_JOINED, :START_ECHO, &echo )
end
