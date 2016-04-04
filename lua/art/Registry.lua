local class = require("art.class")

local Registry = class()

function Registry:init()
  self.namesByPointer = {}
  self.pointersByName = {}
  self.objectsByPointers = {}
end

function Registry:getPointer(obj)
  local ptr = tostring(t):match("%w+: 0x([0-9a-f]+)")
  assert(ptr, "unsupported type")
  return ptr
end

function Registry:contains(obj)
  return self.objectsByPointers[self:getPointer(obj)] ~= nil
end

function Registry:byName(name)
  return self.objectsByPointers[self.pointersByName[name]]
end


function Registry:getName(obj)
  return self.namesByPointer[self:getPointer(obj)]
end

function Registry:setName(obj, name)
  local ptr = self:getPointer(obj)
  local ptr2 = self.pointersByName[name]
  assert((not ptr2) or (ptr == ptr2), "name must be unique")
  self.namesByPointer[ptr] = name
  self.pointersByName[name] = ptr
end

function Registry:register(obj, name)
  if name then
    self:setName(obj, name)
  end
  local ptr = self:getPointer(obj)
  self.objectsByPointers[ptr] = obj
end

function Registry:unregister(obj)
  local ptr = self:getPointer(obj)
  self.objectsByPointers[ptr] = nil
  local name = self.namesByPointer[ptr]
  if name then
    self.namesByPointer[ptr] = nil
    self.pointersByName[name] = nil
  end
end

return Registry
