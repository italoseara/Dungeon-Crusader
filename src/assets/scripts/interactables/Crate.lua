local Class = require 'libs.classic'
local Vector = require 'libs.vector'

local Crate = Class:extend()

function Crate:new(x, y, level)
    self.level = level

    self.position = Vector(x, y)
    self.image = love.graphics.newImage('assets/images/animation/crate.png')

    local w, h = self.image:getWidth(), self.image:getHeight() - 8
    self.collider = self.level.world:newRectangleCollider(x, y, w, h)
    self.collider:setCollisionClass('Crate')
    self.collider:setType('static')
    self.collider:setFriction(0)
    self.collider:setObject(self)

    self.collider:setPreSolve(function(collider_1, collider_2, contact)
        if collider_2.collision_class == 'Weapon' then
            self.level:removeInteractable(self)
            collider_1:destroy()
        end
        contact:setEnabled(false)
    end)
end

function Crate:update(dt)

end

function Crate:draw()
    love.graphics.draw(self.image, self.position.x, self.position.y)
end

return Crate