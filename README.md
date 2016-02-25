# **a** **R**ay**t**racer

**Project status:** *in development*

The **aRt** project aims to create an OpenCL raytracing pipeline implemented as
a LuaJIT library (powered by [OpenCL for Lua](https://colberg.org/lua-opencl))
in order to reach maximum flexibility.

## Ideas

The rendering process will be roughly structured as follows:

- Shapes and materials are loaded, registered and inserted into the program code
- A scene is created and filled with objects
  - An object consists of a position, shape and material
- A k-d tree is built from the scene and uploaded to the device
- The program is compiled, uploaded to the device and executed
- The result image data can now be downloaded and

The scene can be modified (objects added/removed, properties adjusted) without
recompiling the OpenCL program, as long as no shapes or materials are added.
