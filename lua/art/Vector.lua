local class = require("art.class")
local log = require("art.log")
local ffi = require("ffi")
local cl = require("opencl") -- make sure the cl_x types exist

local cl_float = ffi.typeof("cl_float")
local cl_float3 = ffi.typeof("cl_float3")
local cl_double = ffi.typeof("cl_double")
local cl_double3 = ffi.typeof("cl_double3")

local Vector = class()

function Vector:init(x, y, z)
  self.x = x or 0
  self.y = y or 0
  self.z = z or 0
end

--- Numeric tolerance when casting Lua numbers to cl_doubles
local TOLERANCE = 0.000001
local function cast(n, ctype)
  local m = ffi.cast(ctype, n)
  if math.abs(n - tonumber(m)) > TOLERANCE then
    log.warn("double %s loses accuracy when casted to %s", n, ctype)
  end
  return m
end

function Vector:toFloat3()
  return ffi.new(cl_float3,
    cast(self.x, cl_float),
    cast(self.y, cl_float),
    cast(self.z, cl_float),
    cast(0, cl_float) -- actually a float4
  )
end

function Vector:toDouble3()
  return ffi.new(cl_double3,
    cast(self.x, cl_double),
    cast(self.y, cl_double),
    cast(self.z, cl_double),
    cast(0, cl_double) -- actually a double4
  )
end

return Vector
