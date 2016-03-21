package = "aRt"
version = "scm-1"
source = {
  url = "git://github.com/nucular/art",
  branch = "master"
}
description = {
  summary = "OpenCL raytracing pipeline as a LuaJIT library",
  detailed = [[
    The aRt project aims to create an OpenCL raytracing pipeline implemented
    as a LuaJIT library (powered by OpenCL for Lua) in order to reach maximum
    flexibility.
  ]],
  homepage = "https://github.com/nucular/art",
  license = "MIT/X11"
}
dependencies = {
  "lua ~> 5.1",
  "opencl ~> 1.2.0",
  "templet ~> 1.0.2"
}
build = {
  type = "builtin",
  modules = {
    -- ./lua/* is copied automatically
  }
}
