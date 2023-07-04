local Class = require 'libs.classic'
local Vector = require 'libs.vector'

local BigHealingPotion = require 'assets.scripts.potions.BigHealing'
local HealingPotion = require 'assets.scripts.potions.Healing'
local BigManaPotion = require 'assets.scripts.potions.BigMana'
local ManaPotion = require 'assets.scripts.potions.Mana'

local Crate = Class:extend()

function Crate:new(x, y, game, level)
    self.game = game
    self.level = level

    self.position = Vector(x, y)
    self.image = love.graphics.newImage('assets/images/animation/crate.png')

    self.width, self.height = self.image:getWidth(), self.image:getHeight() - 8
    self.collider = self.level.world:newRectangleCollider(x, y, self.width, self.height)
    self.collider:setCollisionClass('Crate')
    self.collider:setType('static')
    self.collider:setFriction(0)
    self.collider:setObject(self)

    self.collider:setPreSolve(function(collider_1, collider_2, contact)
        if collider_2.collision_class == 'Weapon' or collider_2.collision_class == 'Projectile' then
            self.level:removeInteractable(self)
            self:dropPotion()
            collider_1:destroy()
            contact:setEnabled(false)
        end
    end)
end

function Crate:getRandomPotion()
    local random = math.random(1, 100)

    if random <= 50 then
        return HealingPotion
    elseif random <= 75 then
        return BigHealingPotion
    elseif random <= 90 then
        return ManaPotion
    else
        return BigManaPotion
    end
end

function Crate:dropPotion()
    self.game:dropItem(self:getRandomPotion(),
        self.position.x + self.width / 2,
        self.position.y + self.height / 2)
end

function Crate:draw()
    love.graphics.draw(self.image, self.position.x, self.position.y)
end

return Crate
