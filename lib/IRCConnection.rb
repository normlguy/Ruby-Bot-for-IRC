# To change this template, choose Tools | Templates
# and open the template in the editor.

require "socket"
require "HookManager"

class IRCConnection

    def initialize

        @logged_in = false
        @self_addr = nil
        @status = nil

        Hooks.add( :CHANNEL_JOINED, :IRC_CONN_CHAN_JOINED ) do |name|
            Session[ :in_channel ] = true
            Session[ :channel ] = name[:channel]
            Session[ :self_addr ] = name[:address]
            nil
        end

        Hooks.add( :CHANNEL_PARTED, :IRC_CONN_CHAN_PART ) do
            Session[ :in_channel ] = false
            Session[ :channel ] = nil
            nil
        end

        Hooks.add( :LOGGED_IN, :IRC_CONN_LOG_IN ) do
            @logged_in = true if status == :LOGGING_IN
            nil
        end

        Hooks.add( :LOGGED_OUT, :IRC_CONN_LOG_OUT ) do
            @logged_in = false if status == :LOGGED_IN
            nil
        end

    end
    
    def open
        host = Config["IRC"]["host"]
        port = Config["IRC"]["port"]

        @addrinfo = Socket::getaddrinfo( host, port.to_i, Socket::AF_UNSPEC, Socket::SOCK_STREAM )

        af, aport, name, addr = @addrinfo.first

        @socket = TCPSocket.new( addr, aport )

    end

    def send( text )
        Log.log( :NOTICE ) do "SENDING: #{text}" end
        Log.log( :WARN ) do "SENDING NON STRING: #{text.inspect}" end unless text.is_a?( String )
        
        @socket.write( text + "\n")
    end

    def read_next
        begin
            @socket.readline
        rescue EOFError
            nil
        end
    end

    def status
        #p "IN STATUS"

        status = if @socket.nil? then :NOT_CONNECTED
        elsif not @logged_in and Commands.cmd_sent?( %w[NICK USER] ) then :LOGGING_IN
        elsif @logged_in then :LOGGED_IN
        end

        @status = status
        #p "status: " + status.to_s + " | cmds sent: #{Commands.cmd_sent?( %w[NICK USER] )}"
        status
    end    

end
