local Vector = require 'libs.vector'

local StartScreen = require 'assets.scripts.states.start'
local Menu = require 'assets.scripts.states.menu'
local Game = require 'assets.scripts.states.game'

local cursor, last_click

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    math.randomseed(os.time())

    cursor               = {}
    cursor.default       = love.mouse.newCursor('assets/images/ui/cursor/hover.png', 0, 0)
    cursor.default_click = love.mouse.newCursor('assets/images/ui/cursor/hover_click.png', 0, 0)
    cursor.combat        = love.mouse.newCursor('assets/images/ui/cursor/combat.png', 0, 0)
    cursor.combat_click  = love.mouse.newCursor('assets/images/ui/cursor/combat_click.png', 0, 0)

    GameState            = Game()
    CursorState          = 'default'

    love.mouse.update(CursorState)
end

function love.update(dt)
    GameState:update(dt)
    Mouse = Vector(love.mouse.getX(), love.mouse.getY())

    love.mouse.update(CursorState, love.mouse.isDown(1))
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

function love.mouse.update(state, clicked)
    if CursorState == state and last_click == clicked then return end

    CursorState = state
    last_click  = clicked

    if clicked then
        love.mouse.setCursor(cursor[CursorState .. "_click"])
    else
        love.mouse.setCursor(cursor[CursorState])
    end
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
