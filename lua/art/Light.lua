local class = require("art.class")
local Object = require("art.Object")
local templet = require("templet")

local Light = class(Object)

Light.HEADER = templet.loadstring[[

]]

function Light:init(props)
end

return Light
