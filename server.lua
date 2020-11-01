socket = require "socket"

otherCharacters = {}

udp = socket.udp()
udp:settimeout(0)
udp:setsockname('*', 25565)

running = true

print "Beginning server loop."
while running do
    data, msg_or_ip, port_or_nil = udp:receivefrom()

    if data then
        --parse data with data:match()
    elseif msg_or_ip ~= 'timeout' then
		--error("Unknown network error: "..tostring(msg))
	end
 
	socket.sleep(0.01)

    running = false
    print("Server shutdown.")
end
