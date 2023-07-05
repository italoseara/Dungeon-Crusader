local Class = require 'libs.classic'
local Vector = require 'libs.vector'

local CharacterButton = Class:extend()

function CharacterButton:new(id, x, y, callback)
    self.id = id

    -- Spacing
    self.margin = 10
    self.padding = 10

    -- Text
    self.color = { 1, 1, 1, 1 }
    self.text = love.graphics.newText(Fonts.Medium, 'Level ' .. id)

    -- Dimentions
    self.dimentions = Vector(230, 230)

    -- Level
    self.image = love.graphics.newImage('assets/maps/previews/level' .. id .. '.png')

    -- Scale
    self.scale = math.min(self.dimentions.x / self.image:getWidth(), self.dimentions.y / self.image:getHeight())

    -- Position
    self.position = Vector(x - self.dimentions.x / 2, y - self.dimentions.y / 2)

    -- Callback
    self.hovering = false
    self.last_click = 0

    self.callback = callback
end

function CharacterButton:update(dt)
    local mouse = Vector(love.mouse.getX(), love.mouse.getY())

    if mouse.x > self.position.x and
        mouse.y > self.position.y and
        mouse.x < self.position.x + self.dimentions.x and
        mouse.y < self.position.y + self.dimentions.y then
        if love.mouse.isDown(1) and love.timer.getTime() - self.last_click > 0.2 then
            self.last_click = love.timer.getTime()

            if self.callback then
                self.callback(self.id)
            end
        end

        self:changeColor(1, 0, 0, 1, dt)
    else
        self:changeColor(1, 1, 1, 1, dt)
    end
end

function CharacterButton:changeColor(r, g, b, a, dt)
    self.color[1] = math.lerp(self.color[1], r, dt * 10)
    self.color[2] = math.lerp(self.color[2], g, dt * 10)
    self.color[3] = math.lerp(self.color[3], b, dt * 10)
    self.color[4] = math.lerp(self.color[4], a, dt * 10)
end

function CharacterButton:draw()
    -- Draw the map
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.image,
        self.position.x + self.dimentions.x / 2 - self.image:getWidth() * self.scale / 2,
        self.position.y + self.dimentions.y / 2 - self.image:getHeight() * self.scale / 2,
        0, self.scale, self.scale)

    -- Draw the text centered below the animation
    love.graphics.setColor(self.color)
    love.graphics.draw(self.text,
        self.position.x + self.dimentions.x / 2 - self.text:getWidth() / 2,
        self.position.y + self.dimentions.y - self.text:getHeight() + self.margin)

    -- Draw the bounding box
    love.graphics.setLineWidth(5)
    love.graphics.rectangle('line',
        self.position.x - self.padding,
        self.position.y - self.padding,
        self.dimentions.x + self.padding * 2,
        self.dimentions.y + self.padding * 2)
    love.graphics.setColor(1, 1, 1, 1)
end

return CharacterButton
