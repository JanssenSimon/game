--character.lua
--contains functions related to player character

class = require("tools.class")
worldObject = require("primitives.worldObject")
moveable = require("primitives.moveable")

map = require("map")
assetManager = require("assetManager")

--module table
character = class.makeFrom({worldObject, moveable})

character.state = "idle"
character.direction = "right"
character.speed = 300
--TODO make framerate depend on speed
character.drawOffsetX = -64
character.drawOffsetY = -96
--if input received in this cycle
character.flagInput = false

function character:setState(stt)
    if self.state ~= stt then
        self.state = stt
        if stt == "idle" then
            self:setAnimation(1)
            self.currentFrameNum = 1
        elseif stt == "running" then
            self:setAnimation(2)
            self.currentFrameNum = 1
        end
    end
end

--TODO put this in its own primitive, controllable
function character:movementInput(x, y)
    if x == 0 and y == 0 then
        return nil
    end
    self.flagInput = true
    self:setState("running")
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
    self.direction = dir
    self:setState(stt)
end

--TODO make it so you don't have to correct this here correct todos in class
function character:update(dt)
    --update quads based on animation timings
    self.t = self.t + dt
    if self.t > 1/self.animationFramerate then
        self.t = self.t - 1/self.animationFramerate
        self.currentFrameNum = ((self.currentFrameNum) % table.getn(self.animations[self.currentAnimation])) + 1
        --print(self.currentFrameNum.."/"..table.getn(self.animations[self.currentAnimation]))
    end

    self.animations = {assetManager.human.quads.getIdle(self.direction), assetManager.human.quads.getRunning(self.direction)}

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

        if not self.flagInput and (self.currentFrameNum == 4 or self.currentFrameNum == 8) then
            self:setState("idle")
        end
    end

    if self.state == "idle" then
        self.velX = 0
        self.velY = 0
    end

    --update velocity
    self.velX = self.velX + self.aclX * dt
    self.velY = self.velY + self.aclY * dt

    --TODO check for collisions and change velocity if there are some
    --TODO es-ce possible de checker s'il y a des collisions sur le segment de 
    --  droite qui contient tous les points entre la position initiale et la 
    --  position apres le deplacement. si oui, deplacer le joueur a la limite.
    --  ensuite evaluer la tangente de la collision pour voir si la vitesse 
    --  change de direction.
    if map.getTile(map.getTileCoords(self.posX+self.velX*dt, self.posY+self.velY*dt)) == "water" then
        self.velX = 0
        self.velY = 0
    end

    --update position
    self.posX = self.posX + self.velX * dt
    self.posY = self.posY + self.velY * dt

    --make sure player doesn't leave map at top or left
    --TODO bottom and right
    if self.posX < 65 then
        self.posX = 65
        self.velX = 0
    end
    if self.posY < 97 then
        self.posY = 97
        self.velY = 0
    end

    if self.flagInput then
        self.flagInput = false
    end
end

--return module
return character
