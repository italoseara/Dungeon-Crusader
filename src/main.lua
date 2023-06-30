local Vector = require 'libs.vector'

local CustomCursor = require 'assets.scripts.CustomCursor'
local StartScreen = require 'assets.scripts.states.Start'
local Menu = require 'assets.scripts.states.Menu'
local Game = require 'assets.scripts.states.Game'

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    math.randomseed(os.time())

    GameState = StartScreen()
    Cursor    = CustomCursor(2)
end

function love.update(dt)
    GameState:update(dt)
    Cursor:update()
    Mouse = Vector(love.mouse.getX(), love.mouse.getY())
end

function love.draw()
    GameState:draw()
    Cursor:draw()
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

-- Debug function to dump a table
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
