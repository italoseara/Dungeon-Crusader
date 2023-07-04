local Weapon = require 'assets.scripts.weapons.Weapon'

local GreenMagicStaff = Weapon:extend()

function GreenMagicStaff:new(game)
    -- Stats
    self.attackRadius = 4
    self.attackDamage = 25
    self.attackSpeed = 0.5
    self.attackKnockback = 50
    self.projectileSpeed = 300
    self.manaCost = 5

    -- Image
    self.path = 'assets/images/weapons/weapon_green_magic_staff.png'
    self.projectile = love.graphics.newImage('assets/images/weapons/weapon_spell.png')

    GreenMagicStaff.super.new(self, game)
end

function GreenMagicStaff:onAttack(angle)
    -- Spend mana
    if not self.game.player:spendMana(self.manaCost) then return end

    local x = self.game.player.position.x + math.cos(angle) * 5
    local y = self.game.player.position.y + math.sin(angle) * 5

    local collider = self.game.world:newCircleCollider(x, y, self.attackRadius)

    collider:setCollisionClass('Projectile')
    collider:setObject(self)
    collider:setLinearVelocity(math.cos(angle) * self.projectileSpeed, math.sin(angle) * self.projectileSpeed)

    collider:setPreSolve(function(collider_1, collider_2, contact)
        if collider_2.collision_class == 'Enemy' then
            collider_2.object:takeDamage(self.attackDamage, angle, self.attackKnockback)
            self.game:removeProjectile(collider)
            collider:destroy()
        elseif collider_2.collision_class == 'Wall' then
            self.game:removeProjectile(collider)
            collider:destroy()
        end
        contact:setEnabled(false)
    end)

    self.game:addProjectile(collider, self.projectile, 0.4)
end

return GreenMagicStaff
