--map.lua
--contains functions essential to creating a procedural map

gamera = require("gamera")

--module table
map = {}


--tiles for ground
grass_and_water = love.graphics.newImage("assets/graphics/grass_and_water.png")
function getGrassTile(i)
    i=math.floor(i%3)
    return love.graphics.newQuad(0+i*64, 0, 64, 64, grass_and_water:getDimensions())
end
function getWaterTile(i)
    i=math.floor(i%1)
    return love.graphics.newQuad(128+i*64, 320, 64, 64, grass_and_water:getDimensions())
end


-- returns elevation at coordinates based on noise function
function map.elevation(x, y)
    return love.math.noise(0.025*x,0.025*y)+0.5*love.math.noise(0.05*x,0.05*y)+0.25*love.math.noise(0.1*x, 0.1*y)
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
            if map.getTile(x+i,y+j) == "grass" then
                quad = getGrassTile(love.math.noise(x+i,y+j)*4)
                love.graphics.draw(grass_and_water, quad, map.getCoords(x+i, y+j))
            elseif map.getTile(x+i,y+j) == "water" then
                quad = getWaterTile(love.math.noise(x+i,y+j)*2)
                love.graphics.draw(grass_and_water, quad, map.getCoords(x+i, y+j))
            end
        end
    end
end


--return the module
return map
