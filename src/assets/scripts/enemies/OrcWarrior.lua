local Enemy = require 'assets.scripts.enemies.Enemy'

local OrcWarrior = Enemy:extend()

function OrcWarrior:new(x, y, world)
    self.name = 'orc_warrior'
    self.width = 10
    self.height = 14

    self.maxHealth = 120
    self.attackSpeed = 1
    self.attackDamage = 10

    self.viewDistance = 100

    self.speed = 700

    OrcWarrior.super.new(self, x, y, world)
end

return OrcWarrior
