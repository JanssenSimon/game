--class.lua
--contains tools for composing classes

--module table
class = {}

function class.makeFrom(primitives)
    newClass = {}

    for k1, v1 in pairs(primitives) do
        for k2, v2 in pairs(v1) do
            --TODO if the value is a table, copy it by value and not by index
            if not newClass[k2] then
                newClass[k2] = v2
            else
                --TODO if both things are functions, return a megafunction that contains the whole
            end
        end
    end

    return newClass
end

--return module
return class
