--character.lua
--contains functions related to player character

map = require("map")

--module table
character = {}


--sprite for character
bodySpriteSheet = love.graphics.newImage("assets/graphics/isometric_heroine/steel_armor.png")
headSpriteSheet = love.graphics.newImage("assets/graphics/isometric_heroine/head_long.png")
characterQuad = love.graphics.newQuad(512,0,128,128,bodySpriteSheet:getDimensions())
--vars for character
character.posX = 1000       --initial position
character.posY = 1100
character.speed = 300       --speed
--vars related to character state
direction = "left"
state = "idle"
previousState = "idle"
frame = 0


vx,vy = 0, 0

--character movement
function character.move(direction, dt)

    state="running"

    --deal with input
    if direction == "up" then
        vy = vy - 1
    elseif direction == "down" then
        vy = vy + 1
    elseif direction == "left" then
        vx = vx - 1
    elseif direction == "right" then
        vx = vx + 1
    end

end

--character update
function character.update(dt)

    if vx ~= 0 or vy ~= 0 then
        --normalize
        magnitude = math.sqrt(vx * vx + vy * vy)
        vx = vx / magnitude
        vy = vy / magnitude

        --update direction
        angle = math.atan2(vy, vx)
        if angle < -1.963 then
            direction = "upleft"
        elseif angle < -1.178 then
            direction = "up"
        elseif angle < -0.393 then
            direction = "upright"
        elseif angle < 0.393 then
            direction = "right"
        elseif angle < 1.178 then
            direction = "downright"
        elseif angle < 1.963 then
            direction = "down"
        elseif angle < 2.749 then
            direction = "downleft"
        else
            direction = "left"
        end

        --adjust speed
        vx = vx * character.speed * dt 
        vy = vy * character.speed * dt 

        --register movement
        character.posX = character.posX+vx
        character.posY = character.posY+vy
    end

    --if colliding with something
    if map.getTile(map.getTileCoords(character.posX, character.posY)) == "water" then
        --revert movement
        character.posX = character.posX-vx
        character.posY = character.posY-vy
    end

    --update playerQuad based on direction and frame of animation
    if direction == "left" then
        y = 0
    elseif direction == "upleft" then
        y = 128
    elseif direction == "up" then
        y = 256
    elseif direction == "upright" then
        y = 384
    elseif direction == "right" then
        y = 512
    elseif direction == "downright" then
        y = 640
    elseif direction == "down" then
        y = 768
    elseif direction == "downleft" then
        y = 896
    end
    
    xComponent = 0
    if state == previousState then
        --check if state change, if so, set frame to 0 of new state
        previousState = state
        if state == "running" then
            xComponent = 768
            frame = 2
        elseif state == "idle" then 
            xComponent = 0
            frame = 0
        end
    else
        --increment frame (make sure to have it loop back to initial frame)
        if state == "running" then
            frame = frame + character.speed * 0.07 * dt
            frame = frame % 8
            xComponent = math.floor(frame)*128 + 512
            if xComponent == 640 or xComponent == 1152 then
                state = "idle"
                vx, vy = 0, 0
            end
        end
    end

    --characterQuad = love.graphics.newQuad(512,y,128,128,bodySpriteSheet:getDimensions())
    characterQuad = love.graphics.newQuad(xComponent,y,128,128,bodySpriteSheet:getDimensions())

    --set bounds for player movement
    if character.posX<400 then
        character.posX=400
    elseif character.posX>49600 then
        character.posX=49600
    end
    if character.posY<300 then
        character.posY=300
    elseif character.posY>49700 then
        character.posY=49700
    end
end


--character draw function
function character.draw(cam)

    l,t,w,h = cam:getVisible()

    --draw character only if they are onscreen
    if character.posX+128 > l and character.posX-128 < l+w and character.posY+128 > t and character.posY-128 < t+h then
        love.graphics.draw(bodySpriteSheet,characterQuad,character.posX-64,character.posY-96)
        love.graphics.draw(headSpriteSheet,characterQuad,character.posX-64,character.posY-96)
    end
end


--return module
return character
