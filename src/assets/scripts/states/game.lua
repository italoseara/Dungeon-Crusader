local Class = require 'libs.classic'
local Vector = require 'libs.vector'
local Camera = require 'libs.camera'

local Level = require 'assets.scripts.level'

local Game = Class:extend()

function Game:new()
    -- Camera
    self.camera = Camera(0, 0, 4)
    self.camera.smoother = Camera.smooth.damped(10)

    self.level = Level()
    self.camera:lookAt(self.level.spawn.x, self.level.spawn.y)
end

function Game:update(dt)
    self.level:update(dt)
end

function Game:draw()
    self.camera:attach()
    self.level:draw()

    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("fill", self.camera.x, self.camera.y, 5)
    love.graphics.setColor(1, 1, 1)

    self.camera:detach()

    self.level:drawUI()
    love.graphics.print('Camera Position: ' .. self.camera.x .. ', ' .. self.camera.y, 10, 10)
end

return Game
