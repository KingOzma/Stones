local positions = {}

StartState = Class{__includes = BaseState}

function StartState:init()
    
-- Currently selected menu item.
    self.currentMenuItem = 1

-- Colors we'll use to change the title text.
    self.colors = {
        [1] = {217/255, 87/255, 99/255, 255/255},
        [2] = {95/255, 205/255, 228/255, 255/255},
        [3] = {251/255, 242/255, 54/255, 255/255},
        [4] = {118/255, 66/255, 138/255, 255/255},
        [5] = {153/255, 229/255, 80/255, 255/255},
        [6] = {223/255, 113/255, 38/255, 255/255}
    }

-- Letters of STONES and their spacing relative to the center.
    self.letterTable = {
        {'S', -100},
        {'T', -64},
        {'O', -28},
        {'N', 15},
        {'E', 50},
        {'S', 85}
    }

-- Time for a color change if it's been half a second.
    self.colorTimer = Timer.every(0.075, function()
        
-- Shift every color to the next, looping the last to front.
-- Assign it to 0 so the loop below moves it to 1, default start.
        self.colors[0] = self.colors[6]

        for k = 6, 1, -1 do
            self.colors[k] = self.colors[k - 1]
        end
    end)

-- Generate full table of stones just for display.
    for k = 1, 64 do
        table.insert(positions, gFrames['stones'][math.random(18)][math.random(6)])
    end

-- Used to animate our full-screen transition rect.
    self.transitionAlpha = 0

-- If you've selected an option, you need to pause input while it animates out.
    self.pauseInput = false
end

function StartState:update(dt)
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

-- As long as can still input.
    if not self.pauseInput then
        
-- Change menu selection
        if love.keyboard.wasPressed('up') or love.keyboard.wasPressed('down') then
            self.currentMenuItem = self.currentMenuItem == 1 and 2 or 1
            gSounds['select']:play()
        end

-- Switch to another state via one of the menu options.
        if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
            if self.currentMenuItem == 1 then
                
-- Tween, using Timer, the transition rect's alpha to 255, then 
-- transition to the LaunchGame state after the animation is over.
                Timer.tween(1, {
                    [self] = {transitionAlpha = 255}
                }):finish(function()
                    gStateMachine:change('launch-game', {
                        stage = 1
                    })

-- Remove color timer from Timer.
                    self.colorTimer:remove()
                end)
            else
                love.event.quit()
            end

-- Turn off input during transition.
            self.pauseInput = true
        end
    end

-- Update the Timer, which will be used for the fade transitions
    Timer.update(dt)
end

function StartState:render()
    
-- Render all stones and their drop shadows
    for y = 1, 8 do
        for x = 1, 8 do
            
-- Render shadow first
            love.graphics.setColor(0/255, 0/255, 0/255, 255/255)
            love.graphics.draw(gTextures['main'], positions[(y - 1) * x + x], 
                (x - 1) * 32 + 128 + 3, (y - 1) * 32 + 16 + 3)

-- Render stone
            love.graphics.setColor(255/255, 255/255, 255/255, 255/255)
            love.graphics.draw(gTextures['main'], positions[(y - 1) * x + x], 
                (x - 1) * 32 + 128, (y - 1) * 32 + 16)
        end
    end

-- Keep the backdrop and stones a little darker than normal
    love.graphics.setColor(0/255, 0/255, 0/255, 128/255)
    love.graphics.rectangle('fill', 0, 0, SUPER_WIDTH, SUPER_HEIGHT)

    self:drawStonesText(-60)
    self:drawOptions(12)

-- Draw our transition rect; is normally fully transparent, unless moving to a new state.
    love.graphics.setColor(255/255, 255/255, 255/255, self.transitionAlpha)
    love.graphics.rectangle('fill', 0, 0, SUPER_WIDTH, SUPER_HEIGHT)
end

--Draw the centered STONES text with background rect, placed along the Y axis as needed, relative to the center.
function StartState:drawStonesText(y)
    
-- Draw semi-transparent rect behind STONES
    love.graphics.setColor(255/255, 255/255, 255/255, 128/255)
    love.graphics.rectangle('fill', SUPER_WIDTH / 2 - 76, SUPER_HEIGHT / 2 + y - 11, 150, 58, 6)

-- Draw STONES text shadows.
    love.graphics.setFont(gFonts['big'])
    self:drawTextShadow('STONES', SUPER_HEIGHT / 2 + y)

-- Print STONES letters in their corresponding current colors.
    for k = 1, 6 do
        love.graphics.setColor(self.colors[k])
        love.graphics.printf(self.letterTable[k][1], 0, SUPER_HEIGHT / 2 + y,
            SUPER_WIDTH + self.letterTable[k][2], 'center')
    end
end

-- Draws "Start" and "Quit Game" text over semi-transparent rectangles.
function StartState:drawOptions(y)
    
-- Draw rect behind start and quit game text.
    love.graphics.setColor(255/255, 255/255, 255/255, 128/255)
    love.graphics.rectangle('fill', SUPER_WIDTH / 2 - 76, SUPER_HEIGHT / 2 + y, 150, 58, 6)

-- Draw Start text.
    love.graphics.setFont(gFonts['medium'])
    self:drawTextShadow('Start', SUPER_HEIGHT / 2 + y + 8)
    
    if self.currentMenuItem == 1 then
        love.graphics.setColor(237/255, 135/255, 224/255, 255/255)
    else
        love.graphics.setColor(237/255, 50/255, 212/255, 255/255)
    end
    
    love.graphics.printf('Start', 0, SUPER_HEIGHT / 2 + y + 8, SUPER_WIDTH, 'center')

-- Draw Quit Game text.
    love.graphics.setFont(gFonts['medium'])
    self:drawTextShadow('Quit Game', SUPER_HEIGHT / 2 + y + 33)
    
    if self.currentMenuItem == 2 then
        love.graphics.setColor(237/255, 135/255, 224/255, 255/255)
    else
        love.graphics.setColor(237/255, 50/255, 212/255, 255/255)
    end
    
    love.graphics.printf('Quit Game', 0, SUPER_HEIGHT / 2 + y + 33, SUPER_WIDTH, 'center')
end

-- Helper function for drawing just text backgrounds.
function StartState:drawTextShadow(text, y)
    love.graphics.setColor(34/255, 32/255, 52/255, 255/255)
    love.graphics.printf(text, 2, y + 1, SUPER_WIDTH, 'center')
    love.graphics.printf(text, 1, y + 1, SUPER_WIDTH, 'center')
    love.graphics.printf(text, 0, y + 1, SUPER_WIDTH, 'center')
    love.graphics.printf(text, 1, y + 2, SUPER_WIDTH, 'center')
end