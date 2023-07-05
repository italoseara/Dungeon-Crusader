local Class = require 'libs.classic'
local Vector = require 'libs.vector'
local Timer = require 'libs.timer'

local DamageIndicator = Class:extend()

function DamageIndicator:new(damage, entity, color)
    if damage > 0 then damage = '+' .. damage end
    self.text = love.graphics.newText(Fonts.small2, damage)

    self.color = color or { 1, 0, 0, 1 }

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

    love.graphics.setColor(self.color)
    love.graphics.draw(self.text,
        screenPosition.x,
        screenPosition.y - 15 * Ease.outCubic(love.timer.getTime() - self.timer))
    love.graphics.setColor(1, 1, 1, 1)
end

return DamageIndicator
