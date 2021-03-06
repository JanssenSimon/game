--class.lua
--contains tools for composing classes

--module table
class = {}

function class.makeFrom(primitives)
    newClass = {}

    for k1, v1 in pairs(primitives) do
        for k2, v2 in pairs(v1) do
            if not newClass[k2] then
                -- if the value is a table, copy it by value and not by index
                -- TODO this but recursively
                if type(v2) == "table" then
                    newClass[k2] = {}
                    for k3,v3 in pairs(v2) do
                        newClass[k2][k3] = v3
                    end
                else
                    newClass[k2] = v2
                end
            else
                --TODO if both things are functions, return a megafunction that contains everything
            end
        end
    end

    return newClass
end

--return module
return class
