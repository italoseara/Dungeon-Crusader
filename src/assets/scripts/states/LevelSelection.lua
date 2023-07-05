local Class = require 'libs.classic'
local Vector = require 'libs.vector'

local LevelButton = require 'assets.scripts.ui.LevelButton'

local LevelSelection = Class:extend()

local State = {
    MENU = 1,
    TRANSITION = 2
}

function LevelSelection:new()
    self.background = love.graphics.newImage('assets/images/menu.png')
    self.offset = Vector(0, 0)

    self.selected = nil
    self.state = State.MENU
    self.timer = 0
    self.delay = 0.2

    local center = Vector(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 + 50)

    local function callback(id)
        if self.state == State.TRANSITION then return end

        self.state = State.TRANSITION
        self.timer = love.timer.getTime()
        self.selected = id
    end

    self.cards = {
        LevelButton(1, center.x, center.y, callback),
    }
end

function LevelSelection:update(dt)
    -- Move the background around according to the mouse position
    local center = Vector(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    local direction = Mouse - center

    -- Smooth the movement
    self.offset.x = math.lerp(self.offset.x, direction.x / 10, dt * 10)
    self.offset.y = math.lerp(self.offset.y, direction.y / 10, dt * 10)

    -- Update the buttons
    for _, button in ipairs(self.cards) do
        button:update(dt)
    end

    if self.state == State.TRANSITION then
        local t = love.timer.getTime() - self.timer

        if t > self.delay then
            GameState = require 'assets.scripts.states.CharacterSelection' (self.selected)
        end
    end
end

function LevelSelection:draw()
    -- Draw the background from the center
    love.graphics.draw(self.background,
        love.graphics.getWidth() / 2 - self.background:getWidth() / 2 + self.offset.x,
        love.graphics.getHeight() / 2 - self.background:getHeight() / 2 + self.offset.y)

    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1, 1)

    -- Draw the logo above the buttons
    local text = love.graphics.newText(Fonts.big2, 'Select the level')
    love.graphics.draw(text,
        love.graphics.getWidth() / 2 - text:getWidth() / 2,
        love.graphics.getHeight() / 2 - text:getHeight() / 2 - 200)

    for _, button in ipairs(self.cards) do
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

return LevelSelection
