local Weapon = require 'assets.scripts.weapons.Weapon'

local GoldenSword = Weapon:extend()

function GoldenSword:new(game)
    -- Stats
    self.attackRange = 10
    self.attackRadius = 10
    self.attackDamage = 40
    self.attackSpeed = 0.5
    self.attackKnockback = 150

    -- Image
    self.path = 'assets/images/weapons/weapon_golden_sword.png'

    GoldenSword.super.new(self, game)
end

return GoldenSword
