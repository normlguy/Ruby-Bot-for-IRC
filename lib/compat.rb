# To change this template, choose Tools | Templates
# and open the template in the editor.

class String
        def end_with?( str )
                sub_s = self.slice( self.length - str.length, self.length )
                sub_s == str
        end
end

class Hash
        def flatten
                arr = []
                self.each { |key, value|
                        arr.push( key )
                        arr.push( value )
                }
                arr
        end
end
