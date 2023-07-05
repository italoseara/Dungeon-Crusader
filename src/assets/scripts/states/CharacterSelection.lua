local Class = require 'libs.classic'
local Vector = require 'libs.vector'
local Anim8 = require 'libs.anim8'

local CharacterButton = require 'assets.scripts.ui.CharacterButton'

local CharacterSelection = Class:extend()

local State = {
    MENU = 1,
    TRANSITION = 2
}

function CharacterSelection:new(levelID)
    self.levelID = levelID

    self.background = love.graphics.newImage('assets/images/menu.png')
    self.offset = Vector(0, 0)

    self.selected = nil
    self.state = State.MENU
    self.timer = 0
    self.delay = 1

    local center = Vector(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 + 50)
    local margin = Vector(100, 100)

    local function callback(id)
        if self.state == State.TRANSITION then return end

        self.state = State.TRANSITION
        self.timer = love.timer.getTime()
        self.selected = id
    end

    self.cards = {
        CharacterButton('knight_m', 'Knight (M)', center.x - 3 * margin.x, center.y - margin.y, callback),
        CharacterButton('wizard_m', 'Wizard (M)', center.x - margin.x, center.y - margin.y, callback),
        CharacterButton('lizard_m', 'Lizard (M)', center.x + margin.x, center.y - margin.y, callback),
        CharacterButton('dwarf_m', 'Dwarf (M)', center.x + 3 * margin.x, center.y - margin.y, callback),
        CharacterButton('knight_f', 'Knight (F)', center.x - 3 * margin.x, center.y + margin.y, callback),
        CharacterButton('wizard_f', 'Wizard (F)', center.x - margin.x, center.y + margin.y, callback),
        CharacterButton('lizard_f', 'Lizard (F)', center.x + margin.x, center.y + margin.y, callback),
        CharacterButton('dwarf_f', 'Dwarf (F)', center.x + 3 * margin.x, center.y + margin.y, callback)
    }
end

function CharacterSelection:update(dt)
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
            GameState = require 'assets.scripts.states.Game' (self.selected, self.levelID)
        end
    end
end

function CharacterSelection:draw()
    -- Draw the background from the center
    love.graphics.draw(self.background,
        love.graphics.getWidth() / 2 - self.background:getWidth() / 2 + self.offset.x,
        love.graphics.getHeight() / 2 - self.background:getHeight() / 2 + self.offset.y)

    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1, 1)

    -- Draw the logo above the buttons
    local text = love.graphics.newText(Fonts.Big2, 'Select your character')
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

return CharacterSelection
