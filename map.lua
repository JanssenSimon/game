--map.lua
--contains functions essential to creating a procedural map

assetManager = require("assetManager")

--module table
map = {}


--tiles for ground
grass_and_water = assetManager.ground.image.getTiles()

-- returns elevation at coordinates based on noise function
function map.elevation(x, y)
    return love.math.noise(0.00625*x,0.00625*y)+0.5*love.math.noise(0.0125*x,0.0125*y)+0.25*love.math.noise(0.025*x, 0.025*y)+0.125*love.math.noise(0.05*x, 0.05*y)+0.0625*love.math.noise(0.1*x,0.1*y)
end


-- returns the coordinates for where to draw a tile based on the tile coords
function map.getCoords(x, y)
    return x*32-y*32, x*16+y*16
end
-- get the tile coords based on the pixel coordinates of a drawn tile
function map.getTileCoords(x, y)
    Cx = y + x/2.0
    Cy = y - x/2.0
    return math.floor(Cx/32.0)-1, math.floor(Cy/32.0)
end


--returns what a tile is made of
function map.getTile(x, y)
    if map.elevation(x,y) > 0.7 then
        return "grass"
    else
        return "water"
    end
end


-- draws tiles in a square of radius r around camera's location
function map.draw(cam, r)
    x,y=map.getTileCoords(cam:getPosition())
    for i=-r,r do
        for j=-r,r do
            --Check surrounding tiles
            --+x is down and right, +y is down and left
            surroundingTiles = ""
            for surroundingTile=1,9 do
                deltaX = ((surroundingTile-1)%3)-1
                deltaY = math.floor((surroundingTile-1)/3)-1
                if map.getTile(x+i+deltaX,y+j+deltaY) == "grass" then
                    surroundingTiles = surroundingTiles.."g"
                elseif map.getTile(x+i+deltaX,y+j+deltaY) == "water" then
                    surroundingTiles = surroundingTiles.."w"
                end
            end
            --TODO instead of calling getTile function again, check center char of surroundingTiles
            if map.getTile(x+i,y+j) == "grass" then
                --regular tile
                quad = assetManager.ground.quads.getGrass(love.math.noise(x+i,y+j)*4)
                love.graphics.draw(grass_and_water, quad, map.getCoords(x+i, y+j))
            --TODO instead of calling getTile function again, check center char of surroundingTiles
            elseif map.getTile(x+i,y+j) == "water" then
                if string.find(surroundingTiles, "%ag%agw%a%a%a%a") then
                    quad = assetManager.ground.quads.getWater(1, 1)
                elseif string.find(surroundingTiles, "%ag%awwg%a%a%a") then
                    quad = assetManager.ground.quads.getWater(2, 1)
                elseif string.find(surroundingTiles, "ww%awwg%ag%a") then
                    quad = assetManager.ground.quads.getWater(3, 1)
                elseif string.find(surroundingTiles, "%aw%agww%ag%a") then
                    quad = assetManager.ground.quads.getWater(4, 1)
                elseif string.find(surroundingTiles, "gw%aww%a%a%ag") then
                    quad = assetManager.ground.quads.getWater(1, 5)
                elseif string.find(surroundingTiles, "%awgww%ag%a%a") then
                    quad = assetManager.ground.quads.getWater(2, 5)
                elseif string.find(surroundingTiles, "gw%aww%a%a%a%a") then
                    quad = assetManager.ground.quads.getWater(1, 2)
                elseif string.find(surroundingTiles, "%awgwww%a%a%a") then
                    quad = assetManager.ground.quads.getWater(2, 2)
                elseif string.find(surroundingTiles, "%aw%awww%awg") then
                    quad = assetManager.ground.quads.getWater(3, 2)
                elseif string.find(surroundingTiles, "%aw%awwwgw%a") then
                    quad = assetManager.ground.quads.getWater(4, 2)
                elseif string.find(surroundingTiles, "%ag%awww%a%a%a") then
                    quad = assetManager.ground.quads.getWater(1, 3+math.floor(love.math.noise(x+i,y+j)*2)%2)
                elseif string.find(surroundingTiles, "%aw%awwg%aw%a") then
                    quad = assetManager.ground.quads.getWater(2, 3+math.floor(love.math.noise(x+i,y+j)*2)%2)
                elseif string.find(surroundingTiles, "%aw%awww%ag%a") then
                    quad = assetManager.ground.quads.getWater(3, 3+math.floor(love.math.noise(x+i,y+j)*2)%2)
                elseif string.find(surroundingTiles, "%aw%agww%aw%a") then
                    quad = assetManager.ground.quads.getWater(4, 3+math.floor(love.math.noise(x+i,y+j)*2)%2)
                else
                    --regular tile
                    quad = assetManager.ground.quads.getWater(love.math.noise(x+i,y+j)*2)
                end
                love.graphics.draw(grass_and_water, quad, map.getCoords(x+i, y+j))
            end
        end
    end
end


--return the module
return map
