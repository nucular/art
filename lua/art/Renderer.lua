local class = require("art.class")
local log = require("art.log")
local templet = require("templet")
local opencl = require("opencl")
local ffi = require("ffi")

local cl_float3 = ffi.typeof("cl_float3")
local cl_uchar3 = ffi.typeof("cl_uchar3")

local Renderer = class()

Renderer.template = templet.loadstring([[
#ifdef cl_khr_fp64
#pragma OPENCL EXTENSION cl_khr_fp64 : enable
#elif defined(cl_amd_fp64)
#pragma OPENCL EXTENSION cl_amd_fp64 : enable
#else
#error "Double precision floating point not supported by OpenCL implementation."
#endif

typedef struct
{
  float3 origin;
  float3 direction;
} Ray;

typedef struct
{
  __local Ray *restrict data;
  size_t size;
} RayStack;

|for i, v in ipairs(self.geometries) do
  ${v.header({self = v})}
|end
|for i, v in ipairs(self.materials) do
  ${v.header({self = v})}
|end

${self.scene.header({self = self.scene})}

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

__kernel void render(__global Node *restrict node, __global uchar3 *restrict image, __local Ray *restrict stackdata)
{
  const size_t localid = get_local_id(0) + get_local_id(1) * 32;
  const uint px = get_global_id(0);
  const uint py = get_global_id(1);

  RayStack stack;
  stack.data = &stackdata[localid * ${self.raylimit}];
  stack.size = 0;

  double3 pixel = double3(${self.scene.background[1]}, ${self.scene.background[2]}, ${self.scene.background[3]});
}
]])

function Renderer:init(device, scene, width, height)
  self.geometries = {}
  self.materials = {}

  self.device = device
  self.context = opencl.create_context({device})
  self.program = nil
  self.kernel = nil
  self.queue = self.context:create_command_queue(self.device, {
    "out_of_order_exec_mode", "profiling"
  })
  self.imagebuffer = nil

  self.scene = scene
  self.width = width
  self.height = height

  self.raylimit = 20
end

function Renderer:generate()
  return Renderer.template({self = self})
end

function Renderer:build()
  self.program = self.context:create_program_with_source(self:generate())
  self.program:build()
  if self.program:get_build_info("status") == "error" then
    log.fatal(self.program:get_build_info("log"))
    self.program = nil
    error("Build failed")
  end
end

function Renderer:bind()
  assert(self.program, "Program not built (call Renderer:build() before binding)")
  self.kernel = self.program:create_kernel("render")
  self.imagebuffer = context:create_buffer(self.width * self.height * ffi.sizeof(cl_uchar3))
  self.kernel:set_arg(0, -- __global Node *restrict root
    self.scene:build()
  )
  self.kernel:set_arg(1, -- __global uchar3 *restrict image
    self.imagebuffer
  )
  self.kernel:set_arg(2, -- __local Ray *restrict stackdata
    (
      self.kernel:get_work_group_info("compile_work_group_size")
      * self.raylimit
      * (ffi.sizeof(cl_float3) * 2) -- sizeof(Ray)
    ), nil
  )
end

function Renderer:upload(scene)
end

function Renderer:render(camera, blocking)
  assert(self.kernel, "Kernel not bound (call Renderer:bind() before rendering)")
  self.queue:enqueue_ndrange_kernel(self.kernel, nil, {self.width, self.height}, {32, 32})
  if blocking then
    self.queue:finish()
  end
end

function Renderer:download()
  assert(self.imagebuffer, "Image buffer not bound (call Renderer:bind() before downloading)")
  return ffi.cast("cl_uchar3 *", self.queue:enqueue_map_buffer(self.imagebuffer, true, "read"))
end

return Renderer
