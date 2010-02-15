# To change this template, choose Tools | Templates
# and open the template in the editor.

class USER < Command
  def self.call( args )
      [ 
          "USER",
          Config["IRC"]["nick"],
          Config["IRC"]["server"],
          Config["IRC"]["nick"],
          ":" + Config["IRC"]["fullNick"]
      ].join( " " )   
  end
end
