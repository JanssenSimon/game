--main.lua
--main function that runs the game

map = require("map")
gamera = require("gamera")
character = require("character")
math.randomseed(os.time())
uniqueID = tostring(math.random(99999))
otherCharacters = {}
socket = require "socket"

--TODO if local game, run the server locally
--server = require("server")

--open the config file
configFile = io.open("conf.conf", "r")
io.input(configFile)
settings = {}
for line in io.lines() do
  table.insert(settings, line)
end

--extract server info from settings
for i,setting in ipairs(settings) do 
    if string.find(setting, 'serverIP:') then
        address = string.sub(setting, select(2, string.find(setting, 'serverIP:')) + 2, -1)
    end
end
port = 6969
updaterate = 0.1
t = 0

function love.load()

    mainCharacter = character
    mainCharacter.newCharacter(mainCharacter)
    
    --udp socket
    udp = socket.udp()
    udp:settimeout(0)
    udp:setpeername(address, port)
    
    dg = string.format("%s %s %f %f %s %s", uniqueID, 'at', mainCharacter:getNetworkingData())
    udp:send(dg)
    
    --game camera
    cam = gamera.new(0,0,50000,50000)
    cam:setWindow(0,0,800,600)

	-- t is to help us with the update rate of server in love.update.
	t = 0 -- (re)set t to 0
end

function love.update(dt)
    --check inputs
    if love.keyboard.isDown("right") then
        mainCharacter:move("right", dt)
    end
    if love.keyboard.isDown("left") then
        mainCharacter:move("left", dt)
    end
    if love.keyboard.isDown("up") then
        mainCharacter:move("up", dt)
    end
    if love.keyboard.isDown("down") then
        mainCharacter:move("down", dt)
    end

    mainCharacter:update(dt)

    cam:setPosition(mainCharacter:getPosition())
    
    --send info to server
    t = t + dt
    if t > updaterate then
        dg = string.format("%s %f %f %s %s", uniqueID, mainCharacter:getNetworkingData())
        udp:send(dg)

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
            d2 = tonumber(string.sub(data, firstSeperatorIndex+1, secondSeperatorIndex-1))
            d3 = tonumber(string.sub(data, secondSeperatorIndex+1, thirdSeperatorIndex-1))
            d4 = string.sub(data, thirdSeperatorIndex+1, fourthSeperatorIndex-1)
            d5 = string.sub(data, fourthSeperatorIndex+1, -1)

            if not otherCharacters[id] then
                otherCharacters[id] = {}
                otherCharacters[id] = character.newCharacter(otherCharacters[id])
            end
            otherCharacters[id]:setData(d2, d3, d4, d5)

        elseif msg ~= 'timeout' then
            error("Network error: "..tostring(msg))
        end
    until not data

    --update other characters
    for id, c in pairs(otherCharacters) do
        --if c.posX and c.posY and c.state and c.direction then
        c:update(dt, true)
        --end
    end
end

function love.draw()
cam:draw(function(l,t,w,h)

    --draw map
    map.draw(cam, 10)

    --draw character
    character:draw(cam)

    --draw other characters
    --for id, c in pairs(otherCharacters) do
        --c:draw(cam)
    --end

end)
end

function love.mousepressed(x, y, button, istouch, presses)
    print("mouse clicked")
end
