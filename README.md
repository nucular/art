# **a** **R**ay**t**racer

**Project status:** *in development*

The **aRt** project aims to create an OpenCL raytracing pipeline implemented as
a LuaJIT library (powered by [OpenCL for Lua](https://colberg.org/lua-opencl))
in order to reach maximum flexibility.

## Ideas

The rendering process will be roughly structured as follows:

- Geometries and materials are loaded, registered and inserted into the program
  code by the preprocessor.
- A scene is created and filled with objects.
  - An object consists of a geometry, a material and their properties such as
    position.
- A k-d tree is built from the scene and uploaded to the device.
  - Each leaf node will only contain the IDs of the geometry, material and their
    property structs. While geometries and materials will have to be hard-coded
    and looked up using a switch-construct, properties are stored as structs
    inside an array.
- The program is compiled, uploaded to the device and jobs for rendering small
  chunks of the image (and then assembling them in global storage) are enqueued.
- Once all jobs have been finished, the result can be downloaded from global
  storage, processed and saved.

The scene can be modified (objects added/removed, properties adjusted) without
recompiling the OpenCL program, as long as no geometries or materials are added.
