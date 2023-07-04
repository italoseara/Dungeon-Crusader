local Enemy = require 'assets.scripts.enemies.Enemy'

local Ogre = Enemy:extend()

function Ogre:new(x, y, world)
    self.name = 'ogre'
    self.width = 20
    self.height = 24

    self.maxHealth = 250
    self.attackSpeed = 2
    self.attackDamage = 35

    self.viewDistance = 70

    self.speed = 400

    Ogre.super.new(self, x, y, world)
end

return Ogre
