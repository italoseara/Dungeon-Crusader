local Enemy = require 'assets.scripts.enemies.Enemy'

local Plague = Enemy:extend()

function Plague:new(x, y, world)
    self.name = 'plague'
    self.width = 10
    self.height = 14

    self.maxHealth = 120
    self.attackSpeed = 1
    self.attackDamage = 20

    self.viewDistance = 70

    self.speed = 600

    Plague.super.new(self, x, y, world)
end

return Plague
