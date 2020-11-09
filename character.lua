--character.lua
--contains functions related to player character

class = require("tools.class")
worldObject = require("primitives.worldObject")
moveable = require("primitives.moveable")

map = require("map")

--module table
character = class.makeFrom({worldObject, moveable})

character.state = "idle"
character.direction = "right"
character.speed = 300
--TODO make change of state from running to idle depend on animation
character.ft = 0
character.drawOffsetX = -64
character.drawOffsetY = -96

--TODO put this in its own primitive, controllable
function character:movementInput(x, y)
    self.state = "running"
    if y > 0 then
        if x > 0 then
            self.direction = "downright"
            self.ft = 0.05
        elseif x == 0 then
            self.direction = "down"
            self.ft = 0.05
        elseif x < 0 then
            self.direction = "downleft"
            self.ft = 0.05
        end
    elseif y == 0 then
        if x > 0 then
            self.direction = "right"
            self.ft = 0.05
        elseif x == 0 then
            --wat
        elseif x < 0 then
            self.direction = "left"
            self.ft = 0.05
        end
    elseif y < 0 then
        if x > 0 then
            self.direction = "upright"
            self.ft = 0.05
        elseif x == 0 then
            self.direction = "up"
            self.ft = 0.05
        elseif x < 0 then
            self.direction = "upleft"
            self.ft = 0.05
        end
    end
end

function character:getNetworkingData()
    return self.posX, self.posY, self.state, self.direction
end

function character:setFromNetworking(x, y, stt, dir)
    self.posX = x
    self.posY = y
    self.state = stt
    self.direction = dir
end

--TODO make it so you don't have to correct this here correct todos in class
function character:update(dt)
    --update quads based on animation timings
    self.t = self.t + dt
    if self.t > 1/self.animationFramerate then
        self.t = self.t - 1/self.animationFramerate
        self.currentFrameNum = (self.currentFrameNum + 1) % table.getn(self.quads[self.currentAnimation]) 
        self.currentFrameNum = 1
    end

    if self.state == "running" then
        if self.direction == "right" then
            self.velX = self.speed
            self.velY = 0
        elseif self.direction == "upright" then
            self.velX = self.speed * math.sqrt(0.5)
            self.velY = -self.speed * math.sqrt(0.5)
        elseif self.direction == "up" then
            self.velX = 0
            self.velY = -self.speed
        elseif self.direction == "upleft" then
            self.velX = -self.speed * math.sqrt(0.5)
            self.velY = -self.speed * math.sqrt(0.5)
        elseif self.direction == "left" then
            self.velX = -self.speed
            self.velY = 0
        elseif self.direction == "downleft" then
            self.velX = -self.speed * math.sqrt(0.5)
            self.velY = self.speed * math.sqrt(0.5)
        elseif self.direction == "down" then
            self.velX = 0
            self.velY = self.speed
        elseif self.direction == "downright" then
            self.velX = self.speed * math.sqrt(0.5)
            self.velY = self.speed * math.sqrt(0.5)
        end

        self.ft = self.ft - dt
        if self.ft < 0 then
            self.ft = 0
            self.state = "idle"
        end
    end

    if self.state == "idle" then
        self.velX = 0
        self.velY = 0
    end

    --update velocity and position
    self.velX = self.velX + self.aclX * dt
    self.velY = self.velY + self.aclY * dt
    self.posX = self.posX + self.velX * dt
    self.posY = self.posY + self.velY * dt

    --make sure 
    if self.posX < 65 then
        self.posX = 65
        self.velX = 0
    end
    if self.posY < 97 then
        self.posY = 97
        self.velY = 0
    end
end

--return module
return character
