local Vector = require 'libs.vector'

local CustomCursor = require 'assets.scripts.CustomCursor'

local CharacterSelection = require 'assets.scripts.states.CharacterSelection'
local StartScreen = require 'assets.scripts.states.Start'
local Menu = require 'assets.scripts.states.Menu'
local Game = require 'assets.scripts.states.Game'


function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    math.randomseed(os.time())

    debug     = false

    Shaders   = {
        fog    = love.graphics.newShader('assets/shaders/fog.glsl'),
        damage = love.graphics.newShader('assets/shaders/damage.glsl'),
    }

    Fonts     = {
        medium  = love.graphics.newFont('assets/fonts/ThaleahFat.ttf', 16),
        medium2 = love.graphics.newFont('assets/fonts/ThaleahFat.ttf', 24),
        big     = love.graphics.newFont('assets/fonts/ThaleahFat.ttf', 32),
        big2    = love.graphics.newFont('assets/fonts/ThaleahFat.ttf', 64),
        big3    = love.graphics.newFont('assets/fonts/ThaleahFat.ttf', 84),
        big4    = love.graphics.newFont('assets/fonts/ThaleahFat.ttf', 96),
    }

    GameState = CharacterSelection()

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

Ease = {}

function Ease.outCubic(x)
    return 1 - math.pow(1 - x, 3)
end

function Ease.inOutSine(x)
    return -(math.cos(math.pi * x) - 1) / 2
end

function Ease.inOutBack(x)
    local c1 = 1.70158;
    local c2 = c1 * 1.525;

    if x < 0.5 then
        return (math.pow(2 * x, 2) * ((c2 + 1) * 2 * x - c2)) / 2
    else
        return (math.pow(2 * x - 2, 2) * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2
    end
end

function Ease.swing(x)
    if x < 0.5 then
        return Ease.inOutSine(x * 2) / 2
    else
        return -1.25 * Ease.inOutBack((x - 0.5) * 2) / 2 + 0.5
    end
end
