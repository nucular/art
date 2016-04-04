local class = require("art.class")
local Vector = require("art.Vector")

local Color = class(Vector)

Color.BLACK = Color(0, 0, 0)
Color.WHITE = Color(1, 1, 1)

return Color
