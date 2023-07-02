local Vector = require 'libs.vector'

local CustomCursor = require 'assets.scripts.CustomCursor'

local CharacterSelection = require 'assets.scripts.states.CharacterSelection'
local StartScreen = require 'assets.scripts.states.Start'
local Menu = require 'assets.scripts.states.Menu'
local Game = require 'assets.scripts.states.Game'


function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    math.randomseed(os.time())

    GameState = StartScreen()

    Cursor    = CustomCursor(2)
    Mouse     = Vector(0, 0)
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

Easing = {}

function Easing.easeInExpo(x)
    if x == 0 then
        return 0
    else
        return math.pow(2, 10 * x - 10)
    end
end

function Easing.easeInOutSine(x)
    return -(math.cos(math.pi * x) - 1) / 2
end

function Easing.easeInOutBack(x)
    local c1 = 1.70158;
    local c2 = c1 * 1.525;

    if x < 0.5 then
        return (math.pow(2 * x, 2) * ((c2 + 1) * 2 * x - c2)) / 2
    else
        return (math.pow(2 * x - 2, 2) * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2
    end
end

function Easing.swing(x)
    if x < 0.5 then
        return Easing.easeInOutSine(x * 2) / 2
    else
        return -1.25 * Easing.easeInOutBack((x - 0.5) * 2) / 2 + 0.5
    end
end
