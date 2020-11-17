--assetManager.lua
--contains functions for accessing assets

--module table
assetManager = {}
assetManager.human = {}
assetManager.human.image = {}
assetManager.human.quads = {}
assetManager.ground = {}
assetManager.ground.image = {}
assetManager.ground.quads = {}

function assetManager.human.image.getHead(sex, variant)
    if sex == "male" then
        if variant == 1 then
            return love.graphics.newImage("assets/graphics/isometric_hero/male_head1.png")
        elseif variant == 2 then 
            return love.graphics.newImage("assets/graphics/isometric_hero/male_head2.png")
        elseif variant == 3 then 
            return love.graphics.newImage("assets/graphics/isometric_hero/male_head3.png")
        end
    elseif sex == "female" then 
        return love.graphics.newImage("assets/graphics/isometric_heroine/head_long.png")
    end
end
function assetManager.human.image.getBody(sex, variant)
    if sex == "male" then
        if variant == "cloth" then
            return love.graphics.newImage("assets/graphics/isometric_hero/clothes.png")
        elseif variant == "leather" then
            return love.graphics.newImage("assets/graphics/isometric_hero/leather_armor.png")
        elseif variant == "steel" then
            return love.graphics.newImage("assets/graphics/isometric_hero/steel_armor.png")
        end
    elseif sex == "female" then
        if variant == "cloth" then
            return love.graphics.newImage("assets/graphics/isometric_heroine/clothes.png")
        elseif variant == "leather" then
            return love.graphics.newImage("assets/graphics/isometric_heroine/leather_armor.png")
        elseif variant == "steel" then
            return love.graphics.newImage("assets/graphics/isometric_heroine/steel_armor.png")
        end
    end
end
function assetManager.human.quads.getRunning(direction)
    y=0
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
    quds = {
        love.graphics.newQuad(768,y,128,128,4096,1024),
        love.graphics.newQuad(896,y,128,128,4096,1024),
        love.graphics.newQuad(1024,y,128,128,4096,1024),
        love.graphics.newQuad(1152,y,128,128,4096,1024),
        love.graphics.newQuad(1280,y,128,128,4096,1024),
        love.graphics.newQuad(768,y,128,128,4096,1024),
        love.graphics.newQuad(512,y,128,128,4096,1024),
        love.graphics.newQuad(640,y,128,128,4096,1024)
    }
    return quds
end
function assetManager.human.quads.getIdle(direction)
    y=0
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
    quds = {
        love.graphics.newQuad(0,y,128,128,4096,1024)
    }
    return quds
end

function assetManager.ground.image.getTiles()
    return love.graphics.newImage("assets/graphics/grass_and_water.png")
end
--TODO add argument for variants depending on other tiles
function assetManager.ground.quads.getGrass(i,j)
    if j then
        return love.graphics.newQuad(0+(j-1)*64, 64, 64, 64, grass_and_water:getDimensions())
    end
    i=math.floor(i%3)
    return love.graphics.newQuad(0+i*64, 0, 64, 64, grass_and_water:getDimensions())
end
--TODO add argument for variants depending on other tiles
function assetManager.ground.quads.getWater(i)
    i=math.floor(i%1)
    return love.graphics.newQuad(128+i*64, 320, 64, 64, grass_and_water:getDimensions())
end

--return module table
return assetManager
