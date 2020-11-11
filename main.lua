--main.lua
--main function that runs the game

map = require("map")
gamera = require("gamera")
class = require("tools.class")
character = require("character")
assetManager = require("assetManager")
socket = require "socket"

function love.load()

    --load the config file
    configFile = io.open("conf.conf", "a")
    io.input(configFile)
    settings = {}
    for line in io.lines() do
    table.insert(settings, line)
    end
    io.close(configFile)

    --server specification stuff
    --extract server info from settings
    for i,setting in ipairs(settings) do 
        if string.find(setting, 'serverIP:') then
            address = string.sub(setting, select(2, string.find(setting, 'serverIP:')) + 2, -1)
            --TODO if address is localhost, start local server
            --TODO if you can't find file, make it and connect to localhost
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
    print("My uniqueID is "..uniqueID)

    --init the local player's character
    localCharBody = assetManager.human.image.getBody("female", "steel")
    localCharHead = assetManager.human.image.getHead("female")
    localCharAnims = {assetManager.human.quads.getIdle(), assetManager.human.quads.getRunning()}
    localChar = class.makeFrom({character})
    localChar:load(400, 200, {localCharBody, localCharHead}, localCharAnims)
    --send the local player's info to server here
    dg = string.format("%s %f %f %s %s", uniqueID, localChar:getNetworkingData())
    udp:send(dg)


    --TODO put this so that armor and shit varies depending on character
    otherCharsBody = assetManager.human.image.getBody("female", "steel")
    otherCharsHead = assetManager.human.image.getHead("female")
    otherCharsAnims = {assetManager.human.quads.getIdle(), assetManager.human.quads.getRunning()}
    otherCharacters = {}

    --game camera
    cam = gamera.new(0,0,50000,50000)
    cam:setWindow(0,0,800,600)

end

function love.update(dt)

    --TODO manage inputs here
    mx = 0
    my = 0
    if love.keyboard.isDown("right") then
        mx = 1
    end
    if love.keyboard.isDown("left") then
        mx = -1
    end
    if love.keyboard.isDown("up") then
        my = -1
    end
    if love.keyboard.isDown("down") then
        my = 1
    end
    localChar:movementInput(mx, my)

    --TODO computer stuff for updating here
    --update local character
    localChar:update(dt)
    --print(localChar:getNetworkingData())

    --update the camera
    cam:setPosition(localChar:getPosition())

    --send info to server
    t = t + dt
    if t > updaterate then
        --send "uniqueID posX posY state direction"
        dg = string.format("%s %f %f %s %s", uniqueID, localChar:getNetworkingData())
        udp:send(dg)

        t = t - updaterate
    end
    --receive info from server
    repeat
        data, msg = udp:receive()

        if data then
            --print("Message received!: "..data)
            --parse data from server
            firstSeperatorIndex = string.find(data, " ")
            secondSeperatorIndex = string.find(data, " ", firstSeperatorIndex+1)
            thirdSeperatorIndex = string.find(data, " ", secondSeperatorIndex+1)
            fourthSeperatorIndex = string.find(data, " ", thirdSeperatorIndex+1)
            
            id = string.sub(data, 1, firstSeperatorIndex-1)
            x = tonumber(string.sub(data, firstSeperatorIndex+1, secondSeperatorIndex-1))
            y = tonumber(string.sub(data, secondSeperatorIndex+1, thirdSeperatorIndex-1))
            st8 = string.sub(data, thirdSeperatorIndex+1, fourthSeperatorIndex-1)
            dir = string.sub(data, fourthSeperatorIndex+1, -1)

            --TODO init other character if they dont exist
            if not otherCharacters[id] then
                otherCharacters[id] = class.makeFrom({character})
                otherCharacters[id]:load(x, y, {otherCharsBody, otherCharsHead}, otherCharsAnims)
            end
            --change values of other character
            otherCharacters[id]:setFromNetworking(x, y, st8, dir)

        elseif msg ~= 'timeout' then
            --error("Network error: "..tostring(msg))
            --TODO if cannot connect, start local server
        end
    until not data

    --TODO
    --update other characters
    for id, c in pairs(otherCharacters) do
        c:update(dt)
    end
end

function love.draw()
cam:draw(function(l,t,w,h)

    --draw map
    map.draw(cam, 10)

    --draw local character
    localChar:draw(cam)

    --TODO draw other characters
    for id, c in pairs(otherCharacters) do
        c:draw(cam)
    end

end)
end
