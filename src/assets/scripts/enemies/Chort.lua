local Enemy = require 'assets.scripts.enemies.Enemy'

local Chort = Enemy:extend()

function Chort:new(x, y, world)
    self.name = 'chort'
    self.width = 10
    self.height = 14

    self.maxHealth = 120
    self.attackSpeed = 1
    self.attackDamage = 30

    self.viewDistance = 100

    self.speed = 750

    Chort.super.new(self, x, y, world)
end

return Chort
