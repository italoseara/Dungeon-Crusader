local StartScreen = require 'assets.scripts.start'
local Menu = require 'assets.scripts.menu'

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    GameState = StartScreen()
end

function love.update(dt)
    GameState:update(dt)
end

function love.draw()
    GameState:draw()
end

function Lerp(a, b, t)
    return a + (b - a) * t
end