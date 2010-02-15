# To change this template, choose Tools | Templates
# and open the template in the editor.

class NICK < Command

  def self.call( args )
      "NICK " << Config["IRC"]["nick"]
  end
end
