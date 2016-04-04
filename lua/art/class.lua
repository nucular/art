return function(prototype)
  local prototype = prototype or {}
  prototype.__index = prototype
  return setmetatable(prototype, {
    __call = function(cls, ...)
      local instance = setmetatable({}, prototype)
      return instance, instance.init and instance:init(...)
    end
  })
end
