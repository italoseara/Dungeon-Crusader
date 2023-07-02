local Class = require 'libs.classic'

local Sword = Class:extend()

function Sword:new(game)
    -- Game
    self.game = game

    -- Image
    self.image = love.graphics.newImage('assets/images/weapons/weapon_regular_sword.png')
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()

    -- Stats
    self.damage = 10
    self.range = 10
    self.attackSpeed = 0.5
    self.attackCooldown = 1 / self.attackSpeed
    self.attackTimer = 0
end

function Sword:drop(x, y)
    self.game:dropItem(Sword, x, y)
end

function Sword:getAttackAngle(t, initial, direction)
    return initial + (4 * Easing.swing(t / self.attackSpeed)) * -direction
end

function Sword:onPickup(player)
    player.weapon = self
end

return Sword
