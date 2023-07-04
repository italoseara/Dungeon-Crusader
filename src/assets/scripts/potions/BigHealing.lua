local Class = require 'libs.classic'

local DamageIndicator = require 'assets.scripts.ui.DamageIndicator'

local BigHealingPotion = Class:extend()

function BigHealingPotion:new(game)
    self.game = game

    self.image = love.graphics.newImage('assets/images/items/flask_big_red.png')
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()

    self.heal = 75
end

function BigHealingPotion:onPickup(player)
    player.health = player.health + self.heal
    if player.health > player.maxHealth then
        player.health = player.maxHealth
    end

    table.insert(player.damageIndicators, DamageIndicator(self.heal, player, { 0, 1, 0, 1 }))
end

function BigHealingPotion:draw()

end

return BigHealingPotion
