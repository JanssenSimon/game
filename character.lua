--character.lua
--contains functions related to player character

class = require("tools.class")
worldObject = require("primitives.worldObject")
moveable = require("primitives.moveable")

map = require("map")

--module table
character = class.makeFrom({worldObject, moveable})

--TODO make it so you don't have to correct this here correct todos in class
function character:update(dt)
    character:update(dt)
    self.velX = self.velX + self.aclX * dt
    self.velY = self.velY + self.aclY * dt
    self.posX = self.posX + self.velX * dt
    self.posY = self.posY + self.velY * dt
end

--return module
return character
