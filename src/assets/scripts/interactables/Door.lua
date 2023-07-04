local Class = require 'libs.classic'
local Vector = require 'libs.vector'

local Crate = Class:extend()

function Crate:new(x, y)
    self.position = Vector(x, y - 12)
    self.images = {
        open = love.graphics.newImage('assets/images/animation/door_open.png'),
        closed = love.graphics.newImage('assets/images/animation/door_closed.png'),
    }

    self.state = 'open'
end

function Crate:update(dt)

end

function Crate:draw()
    love.graphics.draw(self.images[self.state], self.position.x, self.position.y)
end

return Crate