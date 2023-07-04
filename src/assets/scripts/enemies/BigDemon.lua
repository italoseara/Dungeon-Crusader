local Enemy = require 'assets.scripts.enemies.Enemy'

local BigDemon = Enemy:extend()

function BigDemon:new(x, y, world)
    self.name = 'big_demon'
    self.width = 20
    self.height = 24

    self.maxHealth = 400
    self.attackSpeed = 1.5
    self.attackDamage = 40

    self.viewDistance = 100

    self.speed = 700

    BigDemon.super.new(self, x, y, world)
end

return BigDemon
