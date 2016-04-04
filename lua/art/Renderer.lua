local class = require("art.class")
local log = require("art.log")
local Color = require("art.Color")
local Light = require("art.Light")
local Registry = require("art.Registry")
local Scene = require("art.Scene")
local templet = require("templet")
local ffi = require("ffi")

local cl_float3 = ffi.typeof("cl_float3")
local cl_uchar3 = ffi.typeof("cl_uchar3")

local Renderer = class()

Renderer.BODY = templet.loadstring([[
|if self.doubleprecision then
  #ifdef cl_khr_fp64
  #pragma OPENCL EXTENSION cl_khr_fp64 : enable
  #elif defined(cl_amd_fp64)
  #pragma OPENCL EXTENSION cl_amd_fp64 : enable
  #else
  #error "Double precision not supported by OpenCL implementation"
  #endif
  typedef vec3 double3;
|else
  typedef vec3 float3;
|end

#define BACKGROUND (vec3(${self.backgroundColor.x}, ${self.backgroundColor.y}, ${self.backgroundColor.z}))

typedef struct
{
  vec3 origin;
  vec3 direction;
} Ray;

typedef struct
{
  __local Ray *restrict data;
  size_t size;
} RayStack;

|for name, ptr in pairs(self.geometries.pointersByName) do
  |local geometry = self.geometries.objectsByPointers[ptr]
  ${generate(geometry.HEADER, {name = name, self = geometry, renderer = self})}
|end

|for name, ptr in pairs(self.materials.pointersByName) do
  |local material = self.materials.objectsByPointers[ptr]
  ${generate(material.HEADER, {name = name, self = material, renderer = self})}
|end

${Scene.HEADER({renderer = self})}

${Light.HEADER({renderer = self})}

bool pushRay(RayStack * stack, Ray * value)
{
  if (stack->size < ${self.raylimit})
  {
    stack->data[stack->size] = *value;
    stack->size++;
    return true;
  }
  return false;
}

Ray * popRay(RayStack * stack)
{
  if (stack->size > 0)
  {
    stack->size--;
    return &stack->data[stack->size];
  }
  return NULL;
}

__kernel void render(__global Node *restrict node, __global uchar4 *restrict image, __local Ray *restrict stackdata)
{
  const size_t localid = get_local_id(0) + get_local_id(1) * get_local_size(0);
  const uint px = get_global_id(0);
  const uint py = get_global_id(1);

  RayStack stack;
  stack.data = &stackdata[localid * ${self.stacksize}];
  stack.size = 0;

  vec3 pixel = BACKGROUND;

  image[px + py * ${self.width}] = pixel;
}
]])

function Renderer:init(width, height)
  self.geometries = Registry()
  self.materials = Registry()

  self.width = width
  self.height = height

  self.stacksize = 20
  self.doubleprecision = false

  self.backgroundColor = Color.BLACK
end

function Renderer:generate()
  local function generate(template, env, genv)
    genv.generate = function(template, env)
      return generate(template, env)
    end
    return template(setmetatable(genv, {__index = env}))
  end
  return generate(self.BODY, {
    self = self
  }, setmetatable({
    Light = Light
    Scene = Scene
  }, {__index = _G}))
end

function Renderer:build(device, context)
  local code = self:generate()
  local program = context:create_program_with_source(code)
  ok = pcall(program.build, program)
  if not ok then
    log.fatal(program:get_build_info("log"))
    program = nil
  end
  return program
end

function Renderer:bind(device, program)
  assert(program:get_build_info(device, "status") == "success",
    "Build of the passed program didn't succeed on the device")

  local vec3size = self.doubleprecision and
    ffi.sizeof("cl_double3") or
    ffi.sizeof("cl_float3")

  local kernel = program:create_kernel("render")
  local imagebuffer = context:create_buffer(self.width * self.height * ffi.sizeof("cl_uchar3"))
  kernel:set_arg(0, -- __global Node *restrict root
    self.scene:build()
  )
  kernel:set_arg(1, -- __global pixel_t *restrict image
    imagebuffer
  )
  kernel:set_arg(2, -- __local Ray *restrict stackdata
    (
      kernel:get_work_group_info("compile_work_group_size")
      * self.stacksize
      * (vec3size * 2) -- sizeof(Ray)
    ), nil
  )

  for i, v in ipairs(self.geometries) do
    v:bind(device, programm, kernel)
  end

  for i, v in ipairs(self.materials) do
    v:bind(device, program, kernel)
  end

  return kernel, imagebuffer
end

function Renderer:upload(scene)
end

function Renderer:render(queue, kernel, blocking)
  queue:enqueue_ndrange_kernel(kernel, nil, {self.width, self.height}, {32, 32})
  if blocking then
    queue:finish()
  end
end

function Renderer:download(queue, imagebuffer)
  local data = ffi.cast("cl_uchar3 *", self.queue:enqueue_map_buffer(imagebuffer, true, "read"))
  queue:enqueue_unmap_buffer(imagebuffer, true)
  return data
end

return Renderer
