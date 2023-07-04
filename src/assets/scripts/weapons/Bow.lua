local Vector = require 'libs.vector'

local Weapon = require 'assets.scripts.weapons.Weapon'

local Bow = Weapon:extend()

function Bow:new(game)
    -- Stats
    self.attackRadius = 4
    self.attackDamage = 10
    self.attackSpeed = 0.75
    self.attackKnockback = 50
    self.projectileSpeed = 300

    -- Image
    self.path = 'assets/images/weapons/weapon_bow.png'
    self.projectile = love.graphics.newImage('assets/images/weapons/weapon_arrow.png')

    Bow.super.new(self, game)
end

function Bow:getAttackAngle(t, initial, direction, mouseAngle)
    return mouseAngle
end

function Bow:onAttackBegin(angle)
    self.image = love.graphics.newImage('assets/images/weapons/weapon_bow_2.png')
end

function Bow:onAttack(_)
    local player = self.game.player

    local screenPos = Vector(player.camera:cameraCoords(player.position.x, player.position.y + 4))
    local angle = math.atan2(Mouse.y - screenPos.y + player.height / 2, Mouse.x - screenPos.x)

    local x = player.position.x + math.cos(angle) * 5
    local y = player.position.y + math.sin(angle) * 5

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

    self.game:addProjectile(collider, self.projectile, 0.7, angle + math.rad(90))
    self.image = love.graphics.newImage('assets/images/weapons/weapon_bow.png')
end

function Bow:draw(player)
    love.graphics.draw(
        self.image,
        player.position.x,
        player.position.y + 4,
        player:getWeaponAngle(),
        0.8, 0.8,
        self.image:getWidth() / 2 - 2,
        self.image:getHeight() / 2
    )
end

return Bow
