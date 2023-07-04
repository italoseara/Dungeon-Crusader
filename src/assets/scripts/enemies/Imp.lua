local Enemy = require 'assets.scripts.enemies.Enemy'

local Imp = Enemy:extend()

function Imp:new(x, y, world)
    self.name = 'imp'
    self.width = 10
    self.height = 10

    self.maxHealth = 50
    self.attackSpeed = 1
    self.attackDamage = 15

    self.viewDistance = 100

    self.speed = 850

    Imp.super.new(self, x, y, world)
end

return Imp
