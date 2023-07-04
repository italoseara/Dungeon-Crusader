local Class = require 'libs.classic'

local DamageIndicator = require 'assets.scripts.ui.DamageIndicator'

local ManaPotion = Class:extend()

function ManaPotion:new(game)
    self.game = game

    self.image = love.graphics.newImage('assets/images/items/flask_blue.png')
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()

    self.mana = 50
end

function ManaPotion:onPickup(player)
    player.mana = player.mana + self.mana
    if player.mana > player.maxMana then
        player.mana = player.maxMana
    end

    table.insert(player.damageIndicators, DamageIndicator(self.mana, player, { 0, 0, 1, 1 }))
end

function ManaPotion:draw()

end

return ManaPotion
