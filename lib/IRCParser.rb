# To change this template, choose Tools | Templates
# and open the template in the editor.

class Parser
    def initialize
    
    end

    def parse( response )

        return if response.nil?

        Log.log( :NOTICE ) { "RECEIVED: #{ response.to_s }" }

        text = response.split( " " )
        #puts text.inspect

        check_login( text )
        parts = split_response( response )
        #p "Parts: #{parts.inspect}"
        Hooks.call( :PARSED, parts )
        
        parse_message( parts )

        resp = Commands.response( text.shift, text )

        return if resp.nil?

        Log.log( :NOTICE ) do "QUEUEING COMMAND: #{resp}" end

        Commands.queue( resp.shift, resp )
             
    end

    private

    def parse_message( msg )

        return if msg.nil? or msg[ :message ].nil?
        
    end

    def split_response( text )

        #p "s_resp: otext: #{text}"

        return if text.nil?

        ret = {}
        header = {}

        resp = text.split( /(?:\A|\s):/, 3 )

        resp.each { |part| part.strip! }

        #p "split_resp text: #{resp.inspect}"

        srv_cmd = nil

        if resp.first.empty? then
            resp.shift
        else
            srv_cmd = resp.shift
        end

        unless srv_cmd.nil?
            # => a command came from the server, collect the args and return with nil message
            
            # => is it an address? if it is put it in the address part of the header instead of the args
            header[ :address ] = resp.first if resp.first =~ \
              /^[a-zA-Z0-9\-\.]+\.(com|org|net|mil|edu|COM|ORG|NET|MIL|EDU)$/

            srv_args = resp
            header[ :args ] = [ srv_cmd ] + srv_args
            ret[ :header ] = header
            ret[ :message ] = nil
            return ret
            
        else
            head_text = resp.shift.strip.split( " " )
        

            header[ :address ] = head_text.shift
            header[ :code ] = head_text.first.strip =~ /^[\d]+$/ ? head_text.shift : nil
            header[ :args ] = head_text
        end

        ret[ :header ] = header

        msg = resp.empty? ? nil : resp.shift



        #p "s_r_msg: #{msg} + #{msg.class}"

        ret[ :message ] = nil
        
        return ret if msg.nil?
         
        if msg.length == 1
            ret[ :message ] = msg
        else ret[ :message ] = msg.split( " " )
        end

        #p "s_r_final: #{ret}"

        ret


    end

    def check_login( text )

        #p "status: #{RBICore.get_irc.status}"
        unless RBICore.get_irc.status == :LOGGED_IN


            hits = 0
            text.each { |str|

                str = str.upcase.strip
                %w[END MOTD MESSAGE DAY].each { |i|
                    (hits = hits + 1) if str == i
                }
            }

            #p "hits: " + hits.to_s

            Hooks.call( :LOGGED_IN ) if hits >= 2

        end
    end
end
