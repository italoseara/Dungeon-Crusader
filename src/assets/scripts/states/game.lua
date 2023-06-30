local Class = require 'libs.classic'
local Camera = require 'libs.camera'
local WF = require 'libs.windfield'

local Level = require 'assets.scripts.level'
local Player = require 'assets.scripts.player'

local Game = Class:extend()

function Game:new()
    -- Camera
    self.camera = Camera(0, 0, 4)
    self.camera.smoother = Camera.smooth.damped(10)

    -- Level
    self.world = WF.newWorld(0, 0)
    self.world:addCollisionClass('Player')
    self.world:addCollisionClass('Wall')

    self.level = Level(self.world)

    -- Player
    self.player = Player(self.level.spawn.x, self.level.spawn.y, self.world)
    self.camera:lookAt(self.player.position.x, self.player.position.y)
end

function Game:update(dt)
    self.level:update(dt)
    self.player:update(dt)

    self.camera:lookAt(
        math.lerp(self.camera.x, self.player.position.x, (1.0 - math.exp(-10 * dt))),
        math.lerp(self.camera.y, self.player.position.y, (1.0 - math.exp(-10 * dt)))
    )

    self.world:update(dt)
end

function Game:draw()
    self.camera:attach()

    self.level:draw()
    self.player:draw()
    self.world:draw()

    self.camera:detach()

    self.level:drawUI()

    love.graphics.print('Camera Position: ' .. self.camera.x .. ', ' .. self.camera.y, 10, 10)
end

return Game
