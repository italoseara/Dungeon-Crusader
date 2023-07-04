local Class = require 'libs.classic'
local Vector = require 'libs.vector'

local BigHealingPotion = require 'assets.scripts.potions.BigHealing'
local HealingPotion = require 'assets.scripts.potions.Healing'

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
        if collider_2.collision_class == 'Weapon' then
            self.level:removeInteractable(self)
            self:dropPotion()
            collider_1:destroy()
            contact:setEnabled(false)
        end
    end)
end

function Crate:dropPotion()
    local random = math.random(1, 100)

    local potion = nil

    if random <= 75 then
        potion = HealingPotion
    else
        potion = BigHealingPotion
    end

    self.game:dropItem(potion,
        self.position.x + self.width / 2,
        self.position.y + self.height / 2)
end

function Crate:draw()
    love.graphics.draw(self.image, self.position.x, self.position.y)
end

return Crate
