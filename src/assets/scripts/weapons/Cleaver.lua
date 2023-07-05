local Weapon = require 'assets.scripts.weapons.Weapon'

local Cleaver = Weapon:extend()

function Cleaver:new(game)
    -- Stats
    self.attackRange = 12
    self.attackRadius = 15
    self.attackDamage = 40
    self.attackSpeed = 1
    self.attackKnockback = 170

    -- Image
    self.path = 'assets/images/weapons/weapon_cleaver.png'

    Cleaver.super.new(self, game)
end

return Cleaver
