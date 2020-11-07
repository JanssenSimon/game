--character.lua
--contains functions related to player character

map = require("map")

--module table
character = {bodySpriteSheet=0, headSpriteSheet=0, characterQuad=0, posX=0, posY=0, speed=0, direction=0, state=0, previousState=0, frame=0, vx=0, vy=0}


function character.newCharacter(self)
    --sprite for character
    self.bodySpriteSheet = love.graphics.newImage("assets/graphics/isometric_heroine/steel_armor.png")
    self.headSpriteSheet = love.graphics.newImage("assets/graphics/isometric_heroine/head_long.png")
    self.characterQuad = love.graphics.newQuad(512,0,128,128,bodySpriteSheet:getDimensions())
    --vars for character
    self.posX = 1000       --initial position
    self.posY = 1100
    self.speed = 300       --speed
    --vars related to character state
    self.direction = "left"
    self.state = "idle"
    self.previousState = "idle"
    self.frame = 0

    self.vx,self.vy = 0, 0
end

--character movement
function character:move(dir)
    self.state="running"

    --deal with input
    if dir == "up" then
        self.vy = self.vy - 1
    elseif dir == "down" then
        self.vy = self.vy + 1
    elseif dir == "left" then
        self.vx = self.vx - 1
    elseif dir == "right" then
        self.vx = self.vx + 1
    end
end

--character update
function character:update(dt, otherCharacter)

    if (self.vx ~= 0 or self.vy ~= 0) and not otherCharacter then
        --normalize
        magnitude = math.sqrt(self.vx * self.vx + self.vy * self.vy)
        self.vx = self.vx / magnitude
        self.vy = self.vy / magnitude

        --update direction
        angle = math.atan2(self.vy, self.vx)
        if angle < -1.963 then
            self.direction = "upleft"
        elseif angle < -1.178 then
            self.direction = "up"
        elseif angle < -0.393 then
            self.direction = "upright"
        elseif angle < 0.393 then
            self.direction = "right"
        elseif angle < 1.178 then
            self.direction = "downright"
        elseif angle < 1.963 then
            self.direction = "down"
        elseif angle < 2.749 then
            self.direction = "downleft"
        else
            self.direction = "left"
        end

        --adjust speed
        self.vx = self.vx * self.speed * dt 
        self.vy = self.vy * self.speed * dt 

        --register movement
        self.posX = self.posX+vx
        self.posY = self.posY+vy
        
        --TODO send off character values (pos, direction, state)
    end
    
    if otherCharacter then
        --set vx and vy
        if self.direction == "left" then
            self.vx = -self.speed * dt
            self.vy = 0
        elseif self.direction == "upleft" then
            self.vx = -self.speed * math.sqrt(0.5) * dt
            self.vy = -self.speed * math.sqrt(0.5) * dt
        elseif self.direction == "up" then
            self.vx = 0
            self.vy = -self.speed * dt
        elseif self.direction == "upright" then
            self.vx = self.speed * math.sqrt(0.5) * dt
            self.vy = -self.speed * math.sqrt(0.5) * dt
        elseif self.direction == "right" then
            self.vx = self.speed * dt
            self.vy = 0
        elseif self.direction == "downright" then
            self.vx = self.speed * math.sqrt(0.5) * dt
            self.vy = self.speed * math.sqrt(0.5) * dt
        elseif self.direction == "down" then
            self.vx = 0
            self.vy = self.speed * dt
        elseif self.direction == "downleft" then
            self.vx = -self.speed * math.sqrt(0.5) * dt
            self.vy = self.speed * math.sqrt(0.5) * dt
        end
    end

    --if colliding with something
    if map.getTile(map.getTileCoords(self.posX, self.posY)) == "water" then
        --revert movement
        self.posX = self.posX-self.vx
        self.posY = self.posY-self.vy
    end

    --update playerQuad based on direction and frame of animation
    if self.direction == "left" then
        y = 0
    elseif self.direction == "upleft" then
        y = 128
    elseif self.direction == "up" then
        y = 256
    elseif self.direction == "upright" then
        y = 384
    elseif self.direction == "right" then
        y = 512
    elseif self.direction == "downright" then
        y = 640
    elseif self.direction == "down" then
        y = 768
    elseif self.direction == "downleft" then
        y = 896
    end
    
    xComponent = 0
    if self.state == self.previousState then
        --check if state change, if so, set frame to 0 of new state
        self.previousState = self.state
        if self.state == "running" then
            xComponent = 768
            self.frame = 2
        elseif self.state == "idle" then 
            xComponent = 0
            self.frame = 0
        end
    else
        --increment frame (make sure to have it loop back to initial frame)
        if self.state == "running" then
            self.frame = self.frame + self.speed * 0.07 * dt
            self.frame = self.frame % 8
            xComponent = math.floor(self.frame)*128 + 512
            if xComponent == 640 or xComponent == 1152 then
                self.state = "idle"
                self.vx, self.vy = 0, 0
            end
        end
    end

    self.characterQuad = love.graphics.newQuad(xComponent,y,128,128,self.bodySpriteSheet:getDimensions())

    --set bounds for player movement
    if self.posX<400 then
        self.posX=400
    elseif self.posX>49600 then
        self.posX=49600
    end
    if self.posY<300 then
        self.posY=300
    elseif self.posY>49700 then
        self.posY=49700
    end
end


--character draw function
function character:draw(cam)

    l,t,w,h = cam:getVisible()

    --draw character only if they are onscreen
    if self.posX+128 > l and self.posX-128 < l+w and self.posY+128 > t and self.posY-128 < t+h then
        love.graphics.draw(self.bodySpriteSheet,self.characterQuad,self.posX-64,self.posY-96)
        love.graphics.draw(self.headSpriteSheet,self.characterQuad,self.posX-64,self.posY-96)
    end
end


--get position
function character:getPosition()
    return self.posX, self.posY
end

--set data (for other characters)
function character:setData(x, y, s, d)
    self.posX = x
    self.posY = y
    self.state = s
    self.direction = d
end

--returns string of data to send to server
function character:getNetworkingData()
    return self.posX, self.posY, self.state, self.direction
end


--return module
return character
