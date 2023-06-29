local Vector = require 'libs.vector'

local StartScreen = require 'assets.scripts.states.start'
local Menu = require 'assets.scripts.states.menu'
local Game = require 'assets.scripts.states.game'

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    math.randomseed(os.time())

    GameState = StartScreen()
end

function love.update(dt)
    GameState:update(dt)
    Mouse = Vector(love.mouse.getX(), love.mouse.getY())
end

function love.draw()
    GameState:draw()
end

function math.lerp(a, b, t)
    return a + (b - a) * t
end
