local art = {}

art.Vector = require("art.Vector")
art.Color = require("art.Color")

art.Renderer = require("art.Renderer")
art.Scene = require("art.Scene")

art.Light = require("art.Light")
art.Camera = require("art.Camera")
art.Object = require("art.Object")

art.Material = require("art.Material")
art.materials = require("art.materials.init")

art.Geometry = require("art.Geometry")
art.geometries = require("art.geometries.init")

return art
