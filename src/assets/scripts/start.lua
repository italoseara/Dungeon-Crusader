local Class = require 'libs.classic'
local Menu = require 'assets.scripts.menu'

local StartScreen = Class:extend()

local State = {
    START = 'start',
    FADE_OUT = 'fade_out'
}

function StartScreen:new()
    self.state = State.START
    self.timer = love.timer.getTime()
    self.logo  = love.graphics.newImage('assets/images/logo.png')

    self.duration = {
        start    = 3,
        fade_out = 1
    }

    love.graphics.setBackgroundColor(0, 0, 0)
end

function StartScreen:update(dt)
    if self.state == State.START then
        if love.timer.getTime() - self.timer > self.duration.start then
            self.state = State.FADE_OUT
            self.timer = love.timer.getTime()
        end
    elseif self.state == State.FADE_OUT then
        if love.timer.getTime() - self.timer > self.duration.fade_out then
            GameState = Menu()
        end
    end
end

function StartScreen:draw()
    -- Draw the logo in the center of the screen
    love.graphics.draw(self.logo,
        love.graphics.getWidth() / 2 - self.logo:getWidth() / 2,
        love.graphics.getHeight() / 2 - self.logo:getHeight() / 2)

    if self.state == State.FADE_OUT then
        -- Fade out the logo
        love.graphics.setColor(0, 0, 0, (love.timer.getTime() - self.timer) / self.duration.fade_out)
        love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return StartScreen
