local Enemy = require 'assets.scripts.enemies.Enemy'

local Plague = Enemy:extend()

function Plague:new(x, y, world)
    self.name = 'plague'
    self.width = 10
    self.height = 14

    self.maxHealth = 100
    self.attackSpeed = 1
    self.attackDamage = 10

    self.speed = 800

    Plague.super.new(self, x, y, world)
end

return Plague