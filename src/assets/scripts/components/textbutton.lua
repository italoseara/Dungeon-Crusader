local Class = require 'libs.classic'
local Vector = require 'libs.vector'

local TextButton = Class:extend()

function TextButton:new(font, text, x, y, w, h, ox, oy, callback)
    self.text = love.graphics.newText(font, text)
    self.position = Vector(x, y)
    self.dimentions = Vector(w or self.text:getWidth(), h or self.text:getHeight())
    self.origin = Vector(ox or 0, oy or 0)
    self.hovering = false
    self.callback = callback
    self.last_click = 0
end

function TextButton:update(dt)
    local mouse = Vector(love.mouse.getX(), love.mouse.getY())

    if mouse.x > self.position.x + self.origin.x and
        mouse.x < self.position.x + self.origin.x + self.dimentions.x and
        mouse.y > self.position.y + self.origin.y and
        mouse.y < self.position.y + self.origin.y + self.dimentions.y then
        if love.mouse.isDown(1) and love.timer.getTime() - self.last_click > 0.2 then
            self.last_click = love.timer.getTime()

            if self.callback then
                self.callback()
            end
        end

        self.hovering = true
    else
        self.hovering = false
    end
end

function TextButton:draw()
    -- Draw the text
    love.graphics.setColor(1, 1, 1, 1)

    if self.hovering then
        love.graphics.setColor(1, 0, 0, 1)
    end

    love.graphics.draw(self.text, self.position.x, self.position.y)
    love.graphics.setColor(1, 1, 1, 1)

    -- Draw a rectangle around the text
    -- love.graphics.rectangle('line',
    --     self.position.x + self.origin.x,
    --     self.position.y + self.origin.y,
    --     self.dimentions.x,
    --     self.dimentions.y)
end

return TextButton
