socket = require "socket"

characters = {}

udp = socket.udp()
udp:settimeout(0)
udp:setsockname('*', 6969)

running = true

print "Beginning server loop."
while running do
    data, msg_or_ip, port_or_nil = udp:receivefrom()

    if data then
        id = string.sub(data, 1, string.find(data, " ")-1)
        characters[id] = data
        print("Data received from "..id.." : "..data)

        for c, dat in pairs(characters) do
            if c ~= id then
                print("Sending "..dat.." to "..id.." at "..msg_or_ip..":"..port_or_nil)
                udp:sendto(dat, msg_or_ip, port_or_nil)
            end
        end
    elseif msg_or_ip ~= 'timeout' then
		error("Unknown network error: "..tostring(msg))
	end
 
	socket.sleep(0.01)

    --running = false
    --print("Server shutdown.")
end
