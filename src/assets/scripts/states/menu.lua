local Class = require 'libs.classic'
local Vector = require 'libs.vector'
local TextButton = require 'assets.scripts.components.text_button'
local Game = require 'assets.scripts.states.game'

local Menu = Class:extend()

local State = {
    MENU = 1,
    TRANSITION = 2
}

function Menu:new()
    self.background = love.graphics.newImage('assets/images/menu.png')
    self.offset = Vector(0, 0)

    self.fonts = {
        logo   = love.graphics.newFont('assets/fonts/ThaleahFat.ttf', 96),
        button = love.graphics.newFont('assets/fonts/ThaleahFat.ttf', 64)
    }

    local btnOffset = Vector(100, 350)

    self.buttons = {
        TextButton(self.fonts.button, 'Adventure', btnOffset.x, btnOffset.y, nil, 40, 0, 10, function()
            if self.state == State.TRANSITION then return end

            self.state = State.TRANSITION
            self.timer = love.timer.getTime()
        end),
        TextButton(self.fonts.button, 'Credits', btnOffset.x, 50 + btnOffset.y, nil, 40, 0, 10, function()
            love.system.openURL("https://github.com/italoseara")
        end),
        TextButton(self.fonts.button, 'Exit', btnOffset.x, 100 + btnOffset.y, nil, 40, 0, 10, function()
            love.event.quit()
        end)
    }

    self.state = State.MENU
    self.timer = 0
    self.delay = 2
end

function Menu:update(dt)
    -- Move the background around according to the mouse position
    local center = Vector(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    local direction = Mouse - center

    -- Smooth the movement
    self.offset.x = math.lerp(self.offset.x, direction.x / 10, dt * 10)
    self.offset.y = math.lerp(self.offset.y, direction.y / 10, dt * 10)

    -- Update the buttons
    for _, button in ipairs(self.buttons) do
        button:update(dt)
    end

    if self.state == State.TRANSITION then
        local t = love.timer.getTime() - self.timer

        if t > self.delay then
            GameState = Game()
        end
    end
end

function Menu:draw()
    -- Draw the background from the center
    love.graphics.draw(self.background,
        love.graphics.getWidth() / 2 - self.background:getWidth() / 2 + self.offset.x,
        love.graphics.getHeight() / 2 - self.background:getHeight() / 2 + self.offset.y)

    love.graphics.setColor(0, 0, 0, 0.2)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1, 1)

    -- Draw the logo above the buttons
    local text = love.graphics.newText(self.fonts.logo, 'Dungeon Crusader')
    love.graphics.draw(text,
        love.graphics.getWidth() / 2 - text:getWidth() / 2,
        love.graphics.getHeight() / 2 - text:getHeight() / 2 - 200)

    for _, button in ipairs(self.buttons) do
        button:draw()
    end

    -- Draw the transition
    if self.state == State.TRANSITION then
        local t = love.timer.getTime() - self.timer
        local alpha = math.min(t / self.delay, 1)

        love.graphics.setColor(0, 0, 0, alpha)
        love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)
    end
end

return Menu
