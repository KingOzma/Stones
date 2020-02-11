GameOverState = Class{__includes = BaseState}

function GameOverState:init()

end

function GameOverState:enter(params)
    self.score = params.score 
end

function GameOverState:update(dt)
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('start')
    end
end

function GameOverState:render()
    love.graphics.setFont(gFonts['big'])

    love.graphics.setColor(56/255, 56/255, 56/255, 234/255)
    love.graphics.rectangle('fill', SUPER_WIDTH / 2 - 64, 64, 128, 136, 4)

    love.graphics.setColor(237/255, 135/255, 224/255, 255/255)
    love.graphics.printf('GAME OVER', SUPER_WIDTH / 2 - 64, 64, 128, 'center')
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Your Score: ' .. tostring(self.score), SUPER_WIDTH / 2 - 64, 140, 128, 'center')
    love.graphics.printf('Hit Enter', SUPER_WIDTH / 2 - 64, 180, 128, 'center')
end