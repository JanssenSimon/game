--main.lua
--main function that runs the game

map = require("map")
gamera = require("gamera")
socket = require "socket"

function love.load()

    --load the config file
    configFile = io.open("conf.conf", "r")
    io.input(configFile)
    settings = {}
    for line in io.lines() do
    table.insert(settings, line)
    end

    --server specification stuff
    --extract server info from settings
    for i,setting in ipairs(settings) do 
        if string.find(setting, 'serverIP:') then
            address = string.sub(setting, select(2, string.find(setting, 'serverIP:')) + 2, -1)
        end
    end
    port = 6969
    updaterate = 0.1
	-- t is to help us with the update rate of server in love.update.
	t = 0 -- (re)set t to 0

    --udp socket
    udp = socket.udp()
    udp:settimeout(0)
    udp:setpeername(address, port)

    --generates (probably) unique ID for this client
    math.randomseed(os.time())
    uniqueID = tostring(math.random(99999))

    --init the local player's character
    --TODO send the local player's info to server here

    --game camera
    cam = gamera.new(0,0,50000,50000)
    cam:setWindow(0,0,800,600)

end

function love.update(dt)

    --TODO manage inputs here
    --TODO computer stuff for updating here

    --send info to server
    t = t + dt
    if t > updaterate then
        --"uniqueID posX posY state direction"
        --dg = string.format("%s %f %f %s %s", uniqueID, mainCharacter:getNetworkingData())
        --udp:send(dg)

        t = t - updaterate
    end
    --receive info from server
    repeat
        data, msg = udp:receive()

        if data then
            firstSeperatorIndex = string.find(data, " ")
            secondSeperatorIndex = string.find(data, " ", 2)
            thirdSeperatorIndex = string.find(data, " ", 3)
            fourthSeperatorIndex = string.find(data, " ", 4)
            
            id = string.sub(data, 1, firstSeperatorIndex-1)
            x = tonumber(string.sub(data, firstSeperatorIndex+1, secondSeperatorIndex-1))
            y = tonumber(string.sub(data, secondSeperatorIndex+1, thirdSeperatorIndex-1))
            st8 = string.sub(data, thirdSeperatorIndex+1, fourthSeperatorIndex-1)
            dir = string.sub(data, fourthSeperatorIndex+1, -1)

            --if not otherCharacters[id] then
                --otherCharacters[id] = {}
                --setmetatable(otherCharacters[id], {__index=character})
            --end
            --otherCharacters[id]:setData(d2, d3, d4, d5)

        elseif msg ~= 'timeout' then
            --error("Network error: "..tostring(msg))
            --TODO if cannot connect, start local server
        end
    until not data

    --update other characters
--    for id, c in pairs(otherCharacters) do
        --if c.posX and c.posY and c.state and c.direction then
--        c:update(dt, true)
        --end
--    end
end

function love.draw()
cam:draw(function(l,t,w,h)

    --draw map
    map.draw(cam, 10)

    --draw character
    --character:draw(cam)

    --draw other characters
    --for id, c in pairs(otherCharacters) do
        --c:draw(cam)
    --end

end)
end
