# To change this template, choose Tools | Templates
# and open the template in the editor.

require "HookManager"

class JOIN < Command
    
    Hooks.add( :LOGGED_IN, :JOIN_CHANNEL ) do Commands.queue( "JOIN" ); nil end

    check_join = lambda do |msg|

        p "check_join: #{msg.inspect} + #{Hooks.class}"

        return nil if msg.nil? or msg[:header][:args].nil?

        

        Hooks.call( :CHANNEL_JOINED, { :channel => msg[:header][:args][1], \
                  :address => msg[:header][:address] } )  if msg[:header][:args][0] == "JOIN"

        nil
    end
    
    Hooks.add( :PARSED, :CHECK_JOIN, &check_join )

    Hooks.add( :CHANNEL_JOINED, :REM_CHECK_JOIN ) do
        Hooks.remove( :PARSED, :CHECK_JOIN )
        nil
    end

    Hooks.add( :CHANNEL_PARTED, :RESUME_CHECK_JOIN ) do
        Hooks.add( :PARSED, :CHECK_JOIN, &check_join )
        nil
    end
    

    def self.call( args )
        "JOIN " + args[0].to_s unless args.nil? or not ( args[0].is_a?(String) or args[0].is_a?(Symbol) )
        
        a = Config["IRC"]["channel"]
        "JOIN " + a.to_s
    end

end
