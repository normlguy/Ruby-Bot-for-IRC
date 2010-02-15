# To change this template, choose Tools | Templates
# and open the template in the editor.

require "singleton"
require "RBILog"

class Hooks

    include Singleton

    def initialize
        @hook_list = {}

    end


    def self.call( event, *args )
        self.instance.call( event, args )
    end

    def self.add( event, name, &func )
        self.instance.add( event, name, &func )
    end

    def self.remove( event, name )
        self.instance.remove( event, name )
    end

    def add( event, name, &func )
        Log.log( :NOTICE ) { "Adding hook named \"#{name}\" on event \"#{event}\""}
        @hook_list[ event.to_sym ] = {} if @hook_list[ event.to_sym ].nil?
        @hook_list[ event.to_sym ].store( name.to_sym, func )
    end

    def remove( event, name )
        return if @hook_list[ event.to_sym ].nil?

        Log.log( :NOTICE ) { "Removing hook '#{name}' from event '#{event}'" }
        
        @hook_list[ event.to_sym ].delete( name.to_sym )
    end

    def call( event, args )
        Log.log( :NOTICE ) { "Trying hook \"" + event.to_s + "\"" }
        return if @hook_list[ event.to_sym ].nil?

        ret = nil
        args.freeze

        #p "hooks on event \"#{event}\": #{@hook_list[event.to_sym].inspect}"
        @hook_list[ event.to_sym ].each do |name|

            #begin
            Log.log( :NOTICE ) { "Calling hook named \"" + name[0].to_s + "\"" }

            #p "HERE"
            ret = nil

            begin
                ret = name[1].call( *args )
            rescue StandardError => ex
                Log.log( :ERROR ) { 
                    "Hook '#{name}' on event '#{event}' raised an exception: #{ex}\n" +
                     ex.backtrace


                }
            end

            p "hook '#{name[0]}' returned value '#{ret.inspect}'"
            

            # => if hooks don't return nil, tell the caller and let them decide how to handle that
            return ret unless ret.nil?
            #rescue StandardError => err
            #    Log.log( :WARN ) { "Hook named \"#{name}\" on hook \"#{event}\" raised an exception: #{err}" }
            #end
        end      

        ret
    end

    def self.get_hooks
        @hook_list
    end


end
