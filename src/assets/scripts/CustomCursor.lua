local Class = require 'libs.classic'

local CustomCursor = Class:extend()

function CustomCursor:new(scale)
    love.mouse.setVisible(false)

    self.state = 'default'
    self.scale = scale or 1
    self.images = {
        default       = { image = love.graphics.newImage('assets/images/ui/cursor/default.png'), ox = 8, oy = 8 },
        default_click = { image = love.graphics.newImage('assets/images/ui/cursor/default_click.png'), ox = 8, oy = 8 },
        pointer       = { image = love.graphics.newImage('assets/images/ui/cursor/pointer.png') },
        pointer_click = { image = love.graphics.newImage('assets/images/ui/cursor/pointer_click.png') },
        combat        = { image = love.graphics.newImage('assets/images/ui/cursor/combat.png') },
        combat_click  = { image = love.graphics.newImage('assets/images/ui/cursor/combat_click.png') }
    }
    self.last_click = false
end

function CustomCursor:update(state)
    local clicked = love.mouse.isDown(1)

    if self.last_click == clicked then return end
    if state then self.state = state end
    self.last_click = clicked
end

function CustomCursor:draw()
    local current = self.images[self.state]
    if love.mouse.isDown(1) then current = self.images[self.state .. '_click'] end

    love.graphics.draw(current.image,
        Mouse.x - (current.ox or 0) * self.scale,
        Mouse.y - (current.oy or 0) * self.scale,
        0, self.scale, self.scale)
end

return CustomCursor
