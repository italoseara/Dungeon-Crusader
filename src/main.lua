local Vector = require 'libs.vector'

local StartScreen = require 'assets.scripts.states.start'
local Menu = require 'assets.scripts.states.menu'
local Game = require 'assets.scripts.states.game'

local cursor, last_click
local cursor_scale = 2

local function updateCursor(state, clicked)
    if CursorState == state and last_click == clicked then return end

    CursorState = state
    last_click  = clicked
end

local function drawCursor()
    local current = cursor[CursorState]
    if love.mouse.isDown(1) then current = cursor[CursorState .. '_click'] end

    love.graphics.draw(current.image,
        Mouse.x - (current.ox or 0) * cursor_scale,
        Mouse.y - (current.oy or 0) * cursor_scale,
        0, cursor_scale, cursor_scale)
end

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.mouse.setVisible(false)
    math.randomseed(os.time())

    cursor      = {
        default       = { image = love.graphics.newImage('assets/images/ui/cursor/default.png'), ox = 8, oy = 8 },
        default_click = { image = love.graphics.newImage('assets/images/ui/cursor/default_click.png'), ox = 8, oy = 8 },
        pointer       = { image = love.graphics.newImage('assets/images/ui/cursor/pointer.png') },
        pointer_click = { image = love.graphics.newImage('assets/images/ui/cursor/pointer_click.png') },
        combat        = { image = love.graphics.newImage('assets/images/ui/cursor/combat.png') },
        combat_click  = { image = love.graphics.newImage('assets/images/ui/cursor/combat_click.png') }
    }

    GameState   = StartScreen()
    CursorState = 'default'
end

function love.update(dt)
    GameState:update(dt)
    Mouse = Vector(love.mouse.getX(), love.mouse.getY())

    updateCursor(CursorState, love.mouse.isDown(1))
end

function love.draw()
    GameState:draw()
    drawCursor()
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
