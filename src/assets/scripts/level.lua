local Class = require 'libs.classic'
local Vector = require 'libs.vector'
local STI = require 'libs.sti'

local SpawnRoom = require 'assets.scripts.room'

local Level = Class:extend()

function Level:new()
    love.graphics.setBackgroundColor(0.13, 0.13, 0.13)

    self.map = self:createMap(512, 512, 16, 16)
    self.floorTiles = self:addTileset("floor", 16, 16, "assets/images/scene/floor_tileset.png", 48, 48, 9)
    self.floorLayer = self:addLayer("floor")

    local airID = self:getTileID(self.floorTiles, 0, 0)
    self:populateLayer(self.floorLayer, airID)

    self.ocupied = {}
    self.spawn = SpawnRoom(self, 0, 0)

    self.map = STI(self.map)
end

function Level:createMap(width, height, tilewidth, tileheight)
    return {
        orientation = "orthogonal",
        width = width,
        height = height,
        tilewidth = tilewidth,
        tileheight = tileheight,
        tilesets = {},
        layers = {}
    }
end

function Level:addTileset(name, tilewidth, tileheight, image, imagewidth, imageheight, tilecount)
    local tileset = {
        name = name,
        firstgid = 1,
        tilewidth = tilewidth,
        tileheight = tileheight,
        spacing = 0,
        margin = 0,
        image = image,
        imagewidth = imagewidth,
        imageheight = imageheight,
        tileoffset = { x = 0, y = 0 },
        tilecount = tilecount,
        tiles = {}
    }

    table.insert(self.map.tilesets, tileset)
    return tileset
end

function Level:addLayer(name)
    local layer = {
        type = "tilelayer",
        name = name,
        x = 0,
        y = 0,
        width = 512,
        height = 512,
        visible = true,
        opacity = 1,
        offsetx = 0,
        offsety = 0,
        properties = {},
        encoding = "lua",
        data = {},
        tile = {}
    }

    table.insert(self.map.layers, layer)
    return layer
end

function Level:getTileID(tileset, x, y)
    local width = tileset.imagewidth / tileset.tilewidth
    return x + y * width + 1
end

function Level:populateLayer(layer, tile_id)
    for i = 1, layer.width * layer.height do
        table.insert(layer.data, tile_id)
    end
end

function Level:setTile(layer, x, y, tile_id)
    layer.data[x + y * layer.width + 1] = tile_id -- +1 because Tile ID 0 represents an empty tile
end

function Level:update(dt)
    self.spawn:update(dt)
    self.map:update(dt)
end

function Level:draw()
    self.spawn:draw()
    self.map:drawLayer(self.map.layers["floor"])
    -- self.map:draw()
end

return Level
