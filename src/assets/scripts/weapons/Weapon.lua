local Class = require 'libs.classic'
local Timer = require 'libs.timer'

local Weapon = Class:extend()

function Weapon:new(game)
    -- Game
    self.game = game

    -- Image
    self.image = love.graphics.newImage(self.path)
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
end

function Weapon:drop(x, y)
    self.game:dropItem(self.__index, x, y)
end

function Weapon:getAttackAngle(t, initial, direction)
    return initial + (4 * Ease.swing(t / self.attackSpeed)) * -direction
end

function Weapon:onPickup(player)
    if player.weapon then
        -- Swap weapons
        player.weapon:drop(player.position.x, player.position.y)
    end

    player.weapon = self
end

function Weapon:onAttackBegin(angle)

end

function Weapon:onAttack(angle)
    local x = self.game.player.position.x + math.cos(angle) * self.attackRange
    local y = self.game.player.position.y + math.sin(angle) * self.attackRange

    local collider = self.game.world:newCircleCollider(x, y, self.attackRadius)

    collider:setCollisionClass('Weapon')
    collider:setObject(self)

    collider:setPreSolve(function(collider_1, collider_2, contact)
        if collider_2.collision_class == 'Enemy' then
            collider_2.object:takeDamage(self.attackDamage, angle, self.attackKnockback)
        end
        contact:setEnabled(false)
    end)

    Timer.after(0.01, function()
        collider:destroy()
    end)
end

function Weapon:draw(player)
    love.graphics.draw(
        self.image,
        player.position.x,
        player.position.y + 4,
        player:getWeaponAngle() + math.rad(90),
        player.mouseDirection * 0.8, 0.8,
        self.image:getWidth() / 2,
        self.image:getHeight() / 2 + 12
    )
end

return Weapon
