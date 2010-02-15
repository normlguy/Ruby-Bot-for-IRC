# To change this template, choose Tools | Templates
# and open the template in the editor.

class EVAL
  
    eval = lambda {
        
        Hooks.add( :PARSED, :EVAL ) do |msg|

            p "eval: #{msg.inspect} + frz: #{msg.frozen?}"
            unless msg.nil? or msg[:message].nil?

                if msg[:message].first.upcase  == \
                      ( Config["Commands"]["trigger"] + "EVAL" ).upcase then

                    str = msg[ :message ][1...msg[:message].length].join( " " )

                    ret = ""

                    p "eval'ing: #{str}"
                    begin
                        ret = eval( str )
                    rescue Exception => ex
                        ret = ex.to_s
                    end
                    p "eval returned '#{ret}'"

                    Commands.queue( "SAY", ret )

                end

            end
            nil
        end

        nil
        
    }

    Hooks.add( :CHANNEL_JOINED, :START_EVAL, &eval )

end
