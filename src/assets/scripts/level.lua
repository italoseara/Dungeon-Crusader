local Class = require 'libs.classic'
local Vector = require 'libs.vector'
local STI = require 'libs.sti'

local Level = Class:extend()

function Level:new(world)
    love.graphics.setBackgroundColor(0.133, 0.133, 0.133)

    self.world = world
    self.map = STI('assets/maps/level1.lua')

    self.spawn = Vector(0, 0)
    self.spawn.x, self.spawn.y = self.map:convertTileToPixel(18, 31)
    self.spawn.x = self.spawn.x + 8
    self.spawn.y = self.spawn.y + 8

    self.fogShader = love.graphics.newShader('assets/shaders/fog.glsl')

    self.walls = {}
    if self.map.layers['Collide'] then
        for _, obj in pairs(self.map.layers['Collide'].objects) do
            local x, y, w, h = obj.x, obj.y, obj.width, obj.height
            local wall = self.world:newRectangleCollider(x, y, w, h)
            wall:setCollisionClass('Wall')
            wall:setType('static')
            wall:setFriction(0)
            wall:setRestitution(0)
            wall:setObject(obj)
            table.insert(self.walls, wall)
        end
    end
end

function Level:update(dt)
    self.map:update(dt)
end

function Level:draw()
    self.map:drawLayer(self.map.layers['Floor'])
    self.map:drawLayer(self.map.layers['Walls'])
    self.map:drawLayer(self.map.layers['Decoration'])
end

function Level:drawFog()
    love.graphics.setShader(self.fogShader)
    self.fogShader:send('radius', 700)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setShader()
end

function Level:drawUI()
    self:drawFog()
end

return Level
