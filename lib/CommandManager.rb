# To change this template, choose Tools | Templates
# and open the template in the editor.

%w[ConfigManager RBILog RBICommand singleton].each { |lib| require lib }

class Commands

        include Singleton

        def initialize
                @cmd_list = Hash.new
                @cmd_queue = Array.new
                @sent_cmds = Array.new
                @responses = Hash.new

        end
    

        def self.[]( cmd )
                if( @cmd_list[ cmd.to_sym ].nil? )
                        Log.log( :WARN ) { "Tried to call non-existant command " + cmd  }
                else
                        @cmd_list[ cmd.to_sym ]
                end
        end

        def self.register( cmd, &proc )
                self.instance.register( cmd, &proc )
        end

        def self.add_response( cmd_class, &proc )
                self.instance.add_response( cmd_class, &proc )
        end

        def self.response( cmd, *args )
                self.instance.response( cmd, *args )
        end

        def self.queue( cmd, *args )
                self.instance.queue( cmd, args )
        end

        def self.queue_raw(cmd)
                self.instance.queue_raw(cmd)
        end

        def self.cmd_sent?(cmd)
                self.instance.cmd_sent?( cmd )
        end

        def load
                cmd_folder = Config['Commands']['folder']

                Dir.foreach( cmd_folder ) do |cmd|

                        if cmd.end_with?( ".rb" )
                                Log.instance.log( :NOTICE ) { "loading command: " + cmd[0..-4] }
                                require cmd_folder + "/" + cmd[0..-4]

                                klass = Kernel::const_get( cmd[0..-4] )
                
                                next unless klass.superclass.name == "Command"
                           

                                klass.class_eval do
                                        def self.setup_response
                        
                                                Commands.add_response( self, &method( :call ).to_proc )
                                        end
                                end

                                klass.setup_response
                        end
                end
        end

        def register( cmd, &proc )
                Log.log( :WARN ) { "Overwriting command " + cmd } unless @cmd_list[ cmd.to_sym ].nil?

                @cmd_list[ cmd.to_sym ] = proc

        end

        def cmd_name( proc )
                proc = proc.flatten[0] if proc.is_a?( Hash )

                #p "cmd_name with proc #{proc}"
                @cmd_list.each do |key, value|
            
                        #p "trying cmd_name with key: #{key} and value #{value}"
                        return key if proc == value end
        
        end



        def raw_call( cmd, *args )

                if ( @cmd_list.has_key?( cmd.to_sym ) )
                        begin
                                @cmd_list[ cmd.to_sym ].call( args )
                        end
                end
        end

        # => can take a string of the command or single proc with args for either
        def queue( cmd, args = nil )
                Log.log( :ERROR ) do "CommandManager.queue() can only take a string of the command name or a single proc,
                                along with an array of args"  end \
                  unless cmd.is_a?(String) or cmd.is_a?(Proc)

                q_item = nil
        
                if cmd.is_a?(String) then
                        if @cmd_list[ cmd.to_sym ].nil?
                                Log.log( :ERROR ) do "Passed unknown command \"" + cmd + "\" to CommandManager.queue()" end
                        else
                                q_item = { @cmd_list[ cmd.to_sym ] => args }
                        end
                elsif cmd.is_a?(Proc)
                        q_item = { cmd => args }
                end

                @cmd_queue.push( q_item )
                nil
        end

        def queue_raw( cmd )
                @cmd_queue.push( cmd )
                nil
        end

        def next_cmd
                if @cmd_queue.first.is_a?( Proc )
                        result = @cmd_queue.shift#.call
                        return result.call if result.is_a?( Proc )
                elsif @cmd_queue.first.is_a?( Hash )
            
                        arr = @cmd_queue.shift.flatten

                        Log.log( :ERROR ) { "Miscall with argumented command!" } unless \
                          arr.is_a?(Array) and arr[0].is_a?( Proc ) and arr.length == 2

                        #p "cmd_q: #{arr.inspect}"
                        result = arr[0].call( arr[1] )
                        #p "cmd_q_res: #{result}"
                        #puts result.call
                        #return result.call if result.is_a?( Proc )
                        return result
                elsif @cmd_queue.first.is_a?( String )
                        @cmd_queue.shift
                end
        end

        def add_response( cmd_class, &proc )
                Log.log( :WARN ) { "CommandManager.add_response takes only RBICommand class objects" } \
                  unless cmd_class.is_a?(Class)

                return unless cmd_class.respond_to?( :responds_to )

                cmd_class.responds_to.each do |cmd|
                        Log.log( :WARN ) { "Overriding response to command " + cmd } \
                          unless @responses[ cmd.to_sym ].nil?

                        @responses[ cmd.to_sym ] = proc

                end

        end

        def response( cmd, *args )
                #puts @responses.inspect
                #p @responses[ cmd.to_sym ]

                Log.log( :REMARK ) { "No response for command \"" + cmd + "\""  } \
                  if @responses[ cmd.to_sym ].nil?

                a = @responses[ cmd.to_sym ].call( args ) if @responses[ cmd.to_sym ].is_a?( Proc )

                return a.split( " " ) unless a.nil?

        end
    

        def peek_next_cmd
                return nil unless has_next_cmd

                #p "c_q= #{@cmd_queue.inspect}"

                a = cmd_name @cmd_queue.first
                #p "a= #{a.to_s}"
                a
        end

        def has_next_cmd
                not @cmd_queue.empty?
        end

        def cmd_sent( cmd )
                ( Log.log( :ERROR ) { "Non-string parameter in cmd_sent - param: #{cmd} - #{cmd.class}"}; return nil ) \
                  unless cmd.is_a?( String ) or cmd.is_a?( Symbol )

                @sent_cmds.push( cmd.to_sym )
        end

        def cmd_sent?( cmd )
                #Log.log( :NOTICE ) { "Checking for sent command #{cmd}, commands sent: #{@sent_cmds}" }
                if cmd.is_a?( Array )
                        cmd.each { |comd|
                                a = @sent_cmds.include?( comd.to_sym )

                                return a unless a
                        }
                        true
                else
                        @sent_cmds.include?( cmd.to_sym )
                end
        end

        def get_all_cmds_sent

                @sent_cmds
        end

end
