local Class = require 'libs.classic'
local Vector = require 'libs.vector'
local Camera = require 'libs.camera'

local Level = require 'assets.scripts.level'

local Game = Class:extend()

function Game:new()
    -- Camera
    self.camera = Camera(0, 0, 3)
    self.camera.smoother = Camera.smooth.damped(10)
    self.camera:move((256 * 16) + 8, (256 * 16) + 8)

    self.level = Level()
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

    -- self.player:drawUI()
end

return Game
