local Vector = require 'libs.vector'

local StartScreen = require 'assets.scripts.states.start'
local Menu = require 'assets.scripts.states.menu'
local Game = require 'assets.scripts.states.game'

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    math.randomseed(os.time())

    GameState = Game()
end

function love.update(dt)
    GameState:update(dt)
    Mouse = Vector(love.mouse.getX(), love.mouse.getY())
end

function love.draw()
    GameState:draw()
end

function love.keypressed(k)
    if GameState.keypressed then GameState:keypressed(k) end
end

function love.mousepressed(x, y, b)
    if GameState.mousepressed then GameState:mousepressed(x, y, b) end
end

function math.lerp(a, b, t)
    return a + (b - a) * t
end

function dump(o)
    if type(o) == 'table' then
        local s = '\n'
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. tostring(v) .. ',\n'
        end
        return s
    else
        return tostring(o)
    end
end
