local Weapon = require 'assets.scripts.weapons.Weapon'

local Katana = Weapon:extend()

function Katana:new(game)
    -- Stats
    self.attackRange = 15
    self.attackRadius = 10
    self.attackDamage = 40
    self.attackSpeed = 1
    self.attackKnockback = 150

    -- Image
    self.path = 'assets/images/weapons/weapon_katana.png'

    Katana.super.new(self, game)
end

return Katana
