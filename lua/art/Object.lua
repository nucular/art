local class = require("art.class")

local Object = class()

function Object:init(geometry, material)
  self.geometry = geometry
  self.material = material
end

return Object
