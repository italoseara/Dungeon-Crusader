local Class = require 'libs.classic'
local Vector = require 'libs.vector'

local TextButton = Class:extend()

function TextButton:new(font, text, x, y, w, h, ox, oy, callback)
    self.text = love.graphics.newText(font, text)
    self.color = { 1, 1, 1, 1 }

    self.original_pos = Vector(x, y)
    self.position = Vector(x, y)

    self.dimentions = Vector(w or self.text:getWidth(), h or self.text:getHeight())
    self.origin = Vector(ox or 0, oy or 0)

    self.hovering = false
    self.last_click = 0

    self.callback = callback
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

        self:changeColor(1, 0, 0, 1, dt)
        self:changePosition(self.original_pos.x + 10, self.original_pos.y, dt)
    else
        self:changeColor(1, 1, 1, 1, dt)
        self:changePosition(self.original_pos.x, self.original_pos.y, dt)
    end
end

function TextButton:changeColor(r, g, b, a, dt)
    self.color[1] = math.lerp(self.color[1], r, dt * 10)
    self.color[2] = math.lerp(self.color[2], g, dt * 10)
    self.color[3] = math.lerp(self.color[3], b, dt * 10)
    self.color[4] = math.lerp(self.color[4], a, dt * 10)
end

function TextButton:changePosition(x, y, dt)
    self.position.x = math.lerp(self.position.x, x, dt * 10)
    self.position.y = math.lerp(self.position.y, y, dt * 10)
end

function TextButton:draw()
    -- Draw the text
    love.graphics.setColor(self.color)
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
