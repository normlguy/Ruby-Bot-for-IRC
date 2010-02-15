# To change this template, choose Tools | Templates
# and open the template in the editor.

class SAY < Command

    def self.call( args )

        return unless Session[ :in_channel ]
        
        addr = Session[ :self_addr ]
        channel = Session[ :channel ]

        return if addr.nil? or channel.nil?

        ret = ""

        ret << ":#{addr} PRIVMSG #{channel} :#{args.join(" ")}"
        ret
    end
end
