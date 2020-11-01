--main.lua
--main function that runs the game

map = require("map")
gamera = require("gamera")
character = require("character")
socket = require "socket"

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
port = 25565
updaterate = 0.1

function love.load()
    --  --udp socket
    --  udp = socket.udp()
    --  udp:settimeout(0)
    --  udp:setpeername(address, port)
    --  math.randomseed(os.time())
    --  entity = tostring(math.random(99999))
    --  
    --  udp:send(entity..","..character.posX..","..character.posY)
    --  
	--  -- t is just a variable we use to help us with the update rate in love.update.
	--  t = 0 -- (re)set t to 0

    --game camera
    cam = gamera.new(0,0,50000,50000)
    cam:setWindow(0,0,800,600)
end

function love.update(dt)
    --  t = t+dt

    if love.keyboard.isDown("right") then
        character.move("right", dt)
    end
    if love.keyboard.isDown("left") then
        character.move("left", dt)
    end
    if love.keyboard.isDown("up") then
        character.move("up", dt)
    end
    if love.keyboard.isDown("down") then
        character.move("down", dt)
    end

    character.update(dt)

    cam:setPosition(character.posX, character.posY)
    
end

function love.draw()
cam:draw(function(l,t,w,h)

    --draw map
    map.draw(cam, 10)

    --draw character
    character.draw(cam)

end)
end

function love.mousepressed(x, y, button, istouch, presses)
    print("mouse clicked")
end
