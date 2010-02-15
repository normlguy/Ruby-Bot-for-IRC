# To change this template, choose Tools | Templates
# and open the template in the editor.

require "singleton"

class Config

    include Singleton
    
    CONFIG_FILE = "../config/default_conf.ini"
    
    def initialize
        @config = parse_config
    end

    def []( key )
        @config[ key ] unless @config[ key ].nil?
    end

    def self.[]( key )
        self.instance[ key ]
    end

    #thanks to gdsx in #ruby-lang
    def parse_config()

        input = ""

        IO.foreach( CONFIG_FILE ) { |line| input << line }

        tamed = {}

        # split data on city names, throwing out surrounding brackets
        input = input.split(/\[([^\]]+)\]/)[1..-1]

        # sort the data into key/value pairs
        input.inject([]) {|tary, field|
            tary << field
            if(tary.length == 2)
                # we have a key and value; put 'em to use
                tamed[tary[0]] = tary[1].sub(/^\s+/,'').sub(/\s+$/,'')
                # pass along a fresh temp-array
                tary.clear
            end
            tary
        }

        tamed.dup.each { |tkey, tval|
            tvlist = tval.split(/[\r\n]+/)

            #p tvlist
            tamed[tkey] = tvlist.inject({}) { |hash, val|
                k, v = val.split(/=/)
                hash[k]=v
                hash
            }
        }

        tamed
    end

    def save_config

    end
end
