socket = require "socket"
udp = socket.udp()

udp:settimeout(0)
udp:setsockname('*', 6969)

running = true

while running do
    running = false
end

print("server shutdown")
