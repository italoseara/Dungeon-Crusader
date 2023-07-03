local Weapon = require 'assets.scripts.weapons.Weapon'

local Sword = Weapon:extend()

function Sword:new(game)
    -- Stats
    self.attackRange = 10
    self.attackRadius = 10
    self.attackDamage = 10
    self.attackSpeed = 0.5
    self.attackKnockback = 150

    -- Image
    self.path = 'assets/images/weapons/weapon_regular_sword.png'

    Sword.super.new(self, game)
end

return Sword
