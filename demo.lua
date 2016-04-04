package.path = package.path .. ";./lua/?.lua;./lua/?/init.lua"
local art = require("art")
local cl = require("opencl")

local renderer = art.Renderer(1280, 720)

renderer.geometries:register(art.geometries.Sphere)
renderer.materials:register(art.materials.BlinnPhong)

local object = art.Object(
  art.geometries.Sphere{
    position = art.Vector(0, 0, -5)
    radius = 2
  },
  art.materials.BlinnPhong{
    color = art.Color(1, 1, 1)
  }
)

local light = art.Light{
  position = art.Vector(0, -2, 0),
  color = art.Color(1, 1, 1)
}

local scene = art.Scene()
scene:addObject(object)
scene:addLight(light)
local tree = scene:compile()

local camera = art.Camera{
  position = art.Vector(0, 0, 0)
}
camera:lookAt(object)

local platform = cl.get_platforms()[1]
local device = platform:get_devices()[1]
local context = cl.create_context({device})
local queue = context:create_command_queue(device)

local program = renderer:build(device, context)

local kernel, imagebuffer = renderer:bind(device, program)
renderer:upload(scene)
renderer:render(queue, kernel, camera)

local result = renderer:download(queue, imagebuffer)
