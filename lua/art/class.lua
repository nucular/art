return function(prototype, ...)
  local prototype = prototype or {}
  local prototypes = {prototype, ...}
  return setmetatable(prototype, {
    __index = {
      unpack(prototypes),
      inherits = function(proto)
        for i, p in ipairs(prototypes) do
          if p == proto then return true end
        end
        return false
      end
    },
    __call = function(cls, ...)
      local instance = setmetatable({}, {
        unpack(prototypes),
        __index = (#prototypes == 1)
          and prototype
          or function(table, key)
            for i, p in ipairs(prototypes) do
              if p[key] then
                return p[key]
              end
            end
          end
      })
      return instance, instance.init and instance:init(...)
    end
  })
end
