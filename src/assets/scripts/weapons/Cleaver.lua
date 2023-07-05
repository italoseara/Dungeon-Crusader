local Weapon = require 'assets.scripts.weapons.Weapon'

local Cleaver = Weapon:extend()

function Cleaver:new(game)
    -- Stats
    self.attackRange = 10
    self.attackRadius = 12
    self.attackDamage = 35
    self.attackSpeed = 1
    self.attackKnockback = 150

    -- Image
    self.path = 'assets/images/weapons/weapon_cleaver.png'

    Cleaver.super.new(self, game)
end

return Cleaver
