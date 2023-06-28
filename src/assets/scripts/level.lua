local Class = require 'libs.classic'
local Vector = require 'libs.vector'
local STI = require 'libs.sti'

local Level = Class:extend()

function Level:new()
    love.graphics.setBackgroundColor(0.133, 0.133, 0.133)

    self.map = STI('assets/maps/level1.lua')

    self.spawn = Vector(0, 0)
    self.spawn.x, self.spawn.y = self.map:convertTileToPixel(18, 31)
    self.spawn.x = self.spawn.x + 8
    self.spawn.y = self.spawn.y + 8
end

function Level:update(dt)
    self.map:update(dt)
end

function Level:draw()
    self.map:drawLayer(self.map.layers['Floor'])
    self.map:drawLayer(self.map.layers['Walls'])
    self.map:drawLayer(self.map.layers['Decoration'])
end

function Level:drawUI()
    
end

return Level
