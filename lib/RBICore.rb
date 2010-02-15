# To change this template, choose Tools | Templates
# and open the template in the editor.

%w[ compat IRCConnection ConfigManager SessionManager
    CommandManager IRCParser RBILog HookManager
     singleton ].each { |lib| require lib  }



class RBICore

    include Singleton
    
    def initialize
        @l = Log.instance
        @config = Config.instance
        @cmds = Commands.instance
        $irc = IRCConnection.new
        @parser = Parser.new

        @cmds.load

        Hooks.call( :STARTUP )

        begin_connect
        log_in
        message_loop
    end

    def self.get_irc
        $irc
    end

    private

    def begin_connect
        @l.log( :NOTICE ) { "Opening connection..." }

        $irc.open
    end

    def get_irc
        $irc
    end
    
    def log_in
        @cmds.queue( "NICK" )
        @cmds.queue( "USER" )
    end

    def message_loop

        while( 1 )

            # => send the commands we have in the queue
            while @cmds.has_next_cmd
              
                cmd = @cmds.peek_next_cmd
                #@l.log( :NOTICE ) do "SENDING: #{ cmd }" end
                #puts @cmds.next_cmd if @cmds.has_next_cmd

                Log.log( :REMARK ) { "Peeked command: " + cmd.to_s }

            
                next_comd = @cmds.next_cmd
                new_cmd = Hooks.call( :SEND_CMD, next_comd )

                Log.log( :NOTICE ) { "Generated response overriden by hook. Old cmd: " +
                      next_comd + " | New cmd: " + new_cmd } unless new_cmd.nil?

                $irc.send( next_comd )

                @cmds.cmd_sent( cmd )

            end
                
            Hooks.call( :READ_RESPONSE )

            line = $irc.read_next

            new_resp = Hooks.call( :RESPONSE, line )

            Log.log( :NOTICE ) { "Server response overridden by hook. Old resp: " + line +
                  " | New resp: " + new_resp } unless new_resp.nil?

            @parser.parse( line )

            Hooks.call( :THINK )


            sleep( 0.1 )
        end

    end

end
