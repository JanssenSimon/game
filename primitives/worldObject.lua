--worldObject.lua
--primitive for any entity in the game world drawn over the game map

--module table
worldObject = {}

worldObject.posX = 0
worldObject.posY = 0
worldObject.sprites = {}
worldObject.quads = {}
worldObject.animationFramerate = 8
worldObject.currentFrameNum = 1
worldObject.currentAnimation = 1
worldObject.drawOffsetX = 0
worldObject.drawOffsetY = 0
worldObject.t = 0

function worldObject:getPosition()
    return self.posX, self.posY
end

function worldObject:setAnimation(num)
    if num < 1 then
        error("Argument of setAnimation() out of bounds or incompatible quads")
    end
    self.currentAnimation = num % table.getn(self.quads)
end

function worldObject:getAnimation()
    return self.currentAnimation
end

function worldObject:setDrawOffset(x, y)
    self.drawOffsetX = x
    self.drawOffsetY = y
end

function worldObject:getDrawOffset()
    return drawOffsetX, drawOffsetY
end

function worldObject:load(x, y, sprts, quds)
    self.posX = x
    self.posY = y
    for k, sprite in pairs(sprts) do
        self.sprites[k] = sprite
        self.quads[k] = {}
        for l, quad in pairs(quds[k]) do
            self.quads[k][l] = quad
        end
    end
end

function worldObject:update(dt)
    --update quads based on animation timings
    self.t = self.t + dt
    if self.t > 1/self.animationFramerate then
        self.t = self.t - 1/self.animationFramerate
        --self.currentFrameNum = (self.currentFrameNum + 1) % table.getn(self.quads[self.currentAnimation]) 
        print("New frame! Max: "..table.getn(self.quads[self.currentAnimation]))
        self.currentFrameNum = 1
    end
end

function worldObject:draw(cam)

    l,t,w,h = cam:getVisible()

    --draw using sprites, quads, and position
    for k, sprite in pairs(self.sprites) do
        if self.posX+self.drawOffsetX > l and self.posX+self.drawOffsetX < l+w and self.posY+self.drawOffsetY > t and self.posY+self.drawOffsetY < t+h then
            love.graphics.draw(sprite, self.quads[k][self.currentFrameNum], self.posX+self.drawOffsetX, self.posY+self.drawOffsetY)
        end
    end
end

--return module
return worldObject
