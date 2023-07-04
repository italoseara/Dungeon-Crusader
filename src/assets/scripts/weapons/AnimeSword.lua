local Weapon = require 'assets.scripts.weapons.Weapon'

local AnimeSword = Weapon:extend()

function AnimeSword:new(game)
    -- Stats
    self.attackRange = 12
    self.attackRadius = 15
    self.attackDamage = 50
    self.attackSpeed = 1.5
    self.attackKnockback = 200

    -- Image
    self.path = 'assets/images/weapons/weapon_anime_sword.png'

    AnimeSword.super.new(self, game)
end

return AnimeSword
