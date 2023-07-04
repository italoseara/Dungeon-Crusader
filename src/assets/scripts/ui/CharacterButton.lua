local Class = require 'libs.classic'
local Vector = require 'libs.vector'
local Anim8 = require 'libs.anim8'

local CharacterButton = Class:extend()

function CharacterButton:new(id, label, x, y, callback)
    self.id = id

    -- Text
    self.color = { 1, 1, 1, 1 }
    self.text = love.graphics.newText(Fonts.big, label)

    -- Animation
    self.scale = 4
    self.frames = 4
    self.image = love.graphics.newImage('assets/images/animation/' .. id .. '/' .. id .. '_idle.png')
    local grid = Anim8.newGrid(
        self.image:getWidth() / self.frames,
        self.image:getHeight(),
        self.image:getWidth(),
        self.image:getHeight())
    self.animation = Anim8.newAnimation(grid('1-' .. self.frames, 1), 0.1)

    -- Position
    self.dimentions = Vector(
        math.max(self.text:getWidth(), self.image:getWidth() / self.frames * self.scale),
        (self.text:getHeight() + self.image:getHeight() * self.scale)
    )

    self.original_pos = Vector(x - self.dimentions.x / 2, y - self.dimentions.y / 2)
    self.position = self.original_pos:clone()

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
        self.animation:update(dt)
    else
        self:changeColor(1, 1, 1, 1, dt)
        self.animation:gotoFrame(1)
    end
end

function CharacterButton:changeColor(r, g, b, a, dt)
    self.color[1] = math.lerp(self.color[1], r, dt * 10)
    self.color[2] = math.lerp(self.color[2], g, dt * 10)
    self.color[3] = math.lerp(self.color[3], b, dt * 10)
    self.color[4] = math.lerp(self.color[4], a, dt * 10)
end

function CharacterButton:draw()
    -- Draw the animation centered
    self.animation:draw(self.image,
        self.position.x + self.dimentions.x / 2 - self.image:getWidth() / self.frames * self.scale / 2,
        self.position.y,
        0, self.scale, self.scale)

    -- Draw the text centered below the animation
    love.graphics.setColor(self.color)
    love.graphics.draw(self.text,
        self.position.x + self.dimentions.x / 2 - self.text:getWidth() / 2,
        self.position.y + self.dimentions.y - self.text:getHeight())
    love.graphics.setColor(1, 1, 1, 1)
end

return CharacterButton
