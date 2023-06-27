local Class = require 'libs.classic'
local Vector = require 'libs.vector'
local TextButton = require 'assets.scripts.components.textbutton'

local Menu = Class:extend()

function Menu:new()
    self.background = love.graphics.newImage('assets/images/menu.png')
    self.backgroundOffset = Vector(0, 0)

    local font = love.graphics.newFont('assets/fonts/ThaleahFat.ttf', 64)
    local offset = Vector(100, 350)

    self.buttons = {
        TextButton(font, 'Start', 0 + offset.x, 0 + offset.y, nil, 40, 0, 10, function()
            print("Start")
        end),
        TextButton(font, 'Options', 0 + offset.x, 50 + offset.y, nil, 40, 0, 10, function()

        end),
        TextButton(font, 'Exit', 0 + offset.x, 100 + offset.y, nil, 40, 0, 10, function()
            love.event.quit()
        end)
    }
end

function Menu:update(dt)
    -- Move the background around according to the mouse position
    local mouse = Vector(love.mouse.getX(), love.mouse.getY())
    local center = Vector(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    local direction = mouse - center

    -- Smooth the movement
    self.backgroundOffset.x = Lerp(self.backgroundOffset.x, direction.x / 10, dt * 10)
    self.backgroundOffset.y = Lerp(self.backgroundOffset.y, direction.y / 10, dt * 10)

    -- Update the buttons
    for _, button in ipairs(self.buttons) do
        button:update(dt)
    end
end

function Menu:draw()
    -- Draw the background from the center
    love.graphics.draw(self.background,
        love.graphics.getWidth() / 2 - self.background:getWidth() / 2 + self.backgroundOffset.x,
        love.graphics.getHeight() / 2 - self.background:getHeight() / 2 + self.backgroundOffset.y)

    love.graphics.setColor(0, 0, 0, 0.2)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1, 1)

    for _, button in ipairs(self.buttons) do
        button:draw()
    end
end

return Menu
