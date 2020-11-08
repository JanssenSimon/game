--moveable.lua
--primitive interface for moveable entities

--module table
moveable = {}

moveable.posX = 0
moveable.posY = 0
moveable.velX = 0
moveable.velY = 0
moveable.aclX = 0
moveable.aclY = 0

function moveable:move(deltaX, deltaY)
    self.posX = self.posX + deltaX
    self.posY = self.posY + deltaY
end

function moveable:setPosition(x, y)
    self.posX = x
    self.posY = y
end

function moveable:getPosition()
    return self.posX, self.posY
end

function moveable:impulse(deltaX, deltaY)
    self.velX = self.velX + deltaX
    self.velY = self.velY + deltaY
end

function moveable:setVelocity(x, y)
    self.velX = x
    self.velY = y
end

function moveable:getVelocity()
    return self.velX, self.velY
end

function moveable:force(deltaX, deltaY)
    self.aclX = self.aclX + deltaX
    self.aclY = self.aclY + deltaY
end

function moveable:setAcceleration(x, y)
    self.aclX = x
    self.aclY = y
end

function moveable:getAcceleration()
    return self.aclX, self.aclY
end

function moveable:update(dt)
    self.velX = self.velX + self.aclX * dt
    self.velY = self.velY + self.aclY * dt
    self.posX = self.posX + self.velX * dt
    self.posY = self.posY + self.velY * dt
end

--return module
return moveable
