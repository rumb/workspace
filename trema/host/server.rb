require 'socket'
require 'pio'

include Pio

while (true)
  mesg = socket.recvfrom(1024*8)
  frame = mesg[0]
  data = Parser.read( frame )

  if data.ether_type == 2048
    #p data.rest << 32
    moge =  data.rest.unpack("SSa*")
    print moge[2]
  end
end
