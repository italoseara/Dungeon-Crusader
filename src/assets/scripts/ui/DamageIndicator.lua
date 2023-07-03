local Class = require 'libs.classic'
local Vector = require 'libs.vector'
local Timer = require 'libs.timer'

local DamageIndicator = Class:extend()

function DamageIndicator:new(damage, entity)
    self.font = love.graphics.newFont('assets/fonts/ThaleahFat.ttf', 24)
    self.text = love.graphics.newText(self.font, '-' .. damage)

    self.entity = entity
    self.camera = entity.game.camera
    self.position = Vector(0, 0)
    self.position = self.entity.position

    self.dead = false
    self.timer = love.timer.getTime()

    Timer.after(1, function()
        self.dead = true
    end)
end

function DamageIndicator:draw()
    local screenPosition = Vector(self.camera:cameraCoords(self.position.x, self.position.y - self.entity.height / 2))

    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.draw(self.text,
        screenPosition.x,
        screenPosition.y - 10 * Ease.outCubic(love.timer.getTime() - self.timer))
    love.graphics.setColor(1, 1, 1, 1)
end

return DamageIndicator
