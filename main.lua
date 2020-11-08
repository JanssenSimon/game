--main.lua
--main function that runs the game

map = require("map")
gamera = require("gamera")
class = require("tools.class")
character = require("character")
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
    --TODO make an asset manager or something
    localCharBody = love.graphics.newImage("assets/graphics/isometric_heroine/steel_armor.png")
    localCharBodyQuads = {love.graphics.newQuad(512,0,128,128,localCharBody:getDimensions())}
    localCharHead = love.graphics.newImage("assets/graphics/isometric_heroine/head_long.png")
    localCharHeadQuads = {love.graphics.newQuad(512,0,128,128,localCharHead:getDimensions())}
    localChar = class.makeFrom({character})
    localChar:load(400, 200, {localCharBody, localCharHead}, {localCharBodyQuads, localCharHeadQuads})
    --TODO send the local player's info to server here


    --second character to test that it works
    localChar2Body = love.graphics.newImage("assets/graphics/isometric_heroine/steel_armor.png")
    localChar2BodyQuads = {love.graphics.newQuad(512,0,128,128,localChar2Body:getDimensions())}
    localChar2Head = love.graphics.newImage("assets/graphics/isometric_heroine/head_long.png")
    localChar2HeadQuads = {love.graphics.newQuad(512,0,128,128,localChar2Head:getDimensions())}
    localChar2 = class.makeFrom({character})
    localChar2:load(300, 180, {localChar2Body, localChar2Head}, {localChar2BodyQuads, localChar2HeadQuads})

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
        --TODO
        --"uniqueID posX posY state direction"
        --dg = string.format("%s %f %f %s %s", uniqueID, mainCharacter:getNetworkingData())
        --udp:send(dg)

        t = t - updaterate
    end
    --receive info from server
    repeat
        data, msg = udp:receive()

        if data then
            --parse data from server
            firstSeperatorIndex = string.find(data, " ")
            secondSeperatorIndex = string.find(data, " ", 2)
            thirdSeperatorIndex = string.find(data, " ", 3)
            fourthSeperatorIndex = string.find(data, " ", 4)
            
            id = string.sub(data, 1, firstSeperatorIndex-1)
            x = tonumber(string.sub(data, firstSeperatorIndex+1, secondSeperatorIndex-1))
            y = tonumber(string.sub(data, secondSeperatorIndex+1, thirdSeperatorIndex-1))
            st8 = string.sub(data, thirdSeperatorIndex+1, fourthSeperatorIndex-1)
            dir = string.sub(data, fourthSeperatorIndex+1, -1)

            --TODO
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

    --TODO
    --update other characters
    --for id, c in pairs(otherCharacters) do
        --if c.posX and c.posY and c.state and c.direction then
            --c:update(dt, true)
        --end
    --end
end

function love.draw()
cam:draw(function(l,t,w,h)

    --draw map
    map.draw(cam, 10)

    --draw local character
    localChar:draw(cam)

    --draw second local character
    localChar2:draw(cam)

    --TODO draw other characters
    --for id, c in pairs(otherCharacters) do
        --c:draw(cam)
    --end

end)
end
