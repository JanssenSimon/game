socket = require "socket"

characters = {}

udp = socket.udp()
udp:settimeout(0)
udp:setsockname('*', 6969)

running = true

print "Beginning server loop."
while running do
    dat, msg_or_ip, port_or_nil = udp:receivefrom()

    if dat then
        id = string.sub(dat, 1, string.find(dat, " ")-1)
        --print("Data received from "..id.." : "..dat)
        characters[id] = {}
        characters[id].data = dat
        characters[id].ip = msg_or_ip
        characters[id].port = port_or_nil
    elseif msg_or_ip ~= 'timeout' then
		error("Unknown network error: "..tostring(msg))
	end

    for id1, c1 in pairs(characters) do 
        for id2, c2 in pairs(characters) do
            if id2 ~= id1  then
                --print("Sending "..c2.data.." to "..id1.." at "..c1.ip..":"..c1.port)
                udp:sendto(c2.data, c1.ip, c1.port)
            end
        end
    end
 
	socket.sleep(0.001)

    --running = false
    --print("Server shutdown.")
end
