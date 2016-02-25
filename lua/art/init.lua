local art = {}

art.Renderer = require("art.Renderer")

art.Light = require("art.Light")
art.Camera = require("art.Camera")
art.Object = require("art.Object")

art.Material = require("art.Material")
art.materials = require("art.materials.init")

art.Shape = require("art.Shape")
art.shapes = require("art.shapes.init")

return art
