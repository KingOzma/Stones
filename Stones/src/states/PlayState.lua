PlayState = Class{__includes = BaseState}

function PlayState:init()
    
-- Start the transition alpha at full, so it fades in.
    self.transitionAlpha = 255

-- Position in the grid which we're featuring.
    self.panelFeatureX = 0
    self.panelFeatureY = 0

-- Timer used to switch the feature rect's color.
    self.rectFeatured = false

-- Flag to show if the process input (not swapping or clearing).
    self.canInput = true

-- Stone that's currently featuring (preparing to swap).
    self.featuredStone = nil

    self.score = 0
    self.timer = 60

-- Set our Timer class to turn cursor feature on and off.
    Timer.every(0.5, function()
        self.rectFeatured = not self.rectFeatured
    end)

-- Subtract 1 from timer every second.
    Timer.every(1, function()
        self.timer = self.timer - 1

-- Play warning sound on timer if it gets low.
        if self.timer <= 5 then
            gSounds['clock']:play()
        end
    end)
end

function PlayState:enter(params)
    
-- Grab stage # from the params are passed.
    self.stage = params.stage

-- Spawn a panel and place it toward the right.
    self.panel = params.panel or Panel(SUPER_WIDTH - 272, 16)

-- Grab score from params if it was passed.
    self.score = params.score or 0

-- Score we have to reach to get to the next stage.
    self.scoreGoal = self.stage * 1.25 * 500
end

function PlayState:update(dt)
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

-- Go back to start if time runs out.
    if self.timer <= 0 then
        
-- Clear timers from prior PlayStates.
        Timer.clear()
        
        gSounds['game-over']:play()

        gStateMachine:change('game-over', {
            score = self.score
        })
    end

-- Go to next stage if you surpass score goal.
    if self.score >= self.scoreGoal then
        
-- Clear timers from prior PlayStates always clear before you change state.
        Timer.clear()

        gSounds['next-stage']:play()

-- Change to launch game state with new stage (incremented).
        gStateMachine:change('launch-game', {
            stage = self.stage + 1,
            score = self.score
        })
    end

    if self.canInput then
-- Move cursor around based on bounds of grid, playing sounds.
        if love.keyboard.wasPressed('up') then
            self.panelFeatureY = math.max(0, self.panelFeatureY - 1)
            gSounds['select']:play()
        elseif love.keyboard.wasPressed('down') then
            self.panelFeatureY = math.min(7, self.panelFeatureY + 1)
            gSounds['select']:play()
        elseif love.keyboard.wasPressed('left') then
            self.panelFeatureX = math.max(0, self.panelFeatureX - 1)
            gSounds['select']:play()
        elseif love.keyboard.wasPressed('right') then
            self.panelFeatureX = math.min(7, self.panelFeatureX + 1)
            gSounds['select']:play()
        end

-- If hit enter, to select or deselect a stone.
        if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
            
-- If same stone as currently featured, deselect.
            local x = self.panelFeatureX + 1
            local y = self.panelFeatureY + 1
            
-- If nothing is featured, feature current stone.
            if not self.featuredStone then
                self.featuredStone = self.panel.stones[y][x]

-- If you select the position already featured, remove feature.
            elseif self.featuredStone == self.panel.stones[y][x] then
                self.featuredStone = nil

-- If the difference between X and Y combined of this featureed stone 
-- vs the previous is not equal to 1, also remove feature
            elseif math.abs(self.featuredStone.gridX - x) + math.abs(self.featuredStone.gridY - y) > 1 then
                gSounds['error']:play()
                self.featuredStone = nil
            else
                
-- Swap grid positions of stone.
                local tempX = self.featuredStone.gridX
                local tempY = self.featuredStone.gridY

                local newStone = self.panel.stones[y][x]

                self.featuredStone.gridX = newStone.gridX
                self.featuredStone.gridY = newStone.gridY
                newStone.gridX = tempX
                newStone.gridY = tempY

-- Swap stones in the stones table.
                self.panel.stones[self.featuredStone.gridY][self.featuredStone.gridX] =
                    self.featuredStone

                self.panel.stones[newStone.gridY][newStone.gridX] = newStone

-- Tween coordinates between the two so they swap.
                Timer.tween(0.1, {
                    [self.featuredStone] = {x = newStone.x, y = newStone.y},
                    [newStone] = {x = self.featuredStone.x, y = self.featuredStone.y}
                })
                
-- Once the swap is finished, the tween falling blocks as needed
                :finish(function()
                    self:calculateMatches()
                end)
            end
        end
    end

    Timer.update(dt)
end

--[[
    Calculates whether any matches were found on the panel and tweens the needed
    stones to their new destinations if so. Also removes stones from the panel that
    have matched and replaces them with new randomized stones, deferring most of this
    to the Panel class.
]]
function PlayState:calculateMatches()
    self.featuredStone = nil

-- If we have any matches, remove them and tween the falling blocks that result.
    local matches = self.panel:calculateMatches()
    
    if matches then
        gSounds['match']:stop()
        gSounds['match']:play()

 -- Add score for each match
        for m, match in pairs(matches) do
            self.score = self.score + #match * 50
        end

-- Remove any stones that matched from the panel, making empty spaces.
        self.panel:removeMatches()

-- Gets a table with tween values for stones that should now fall
        local stonesToFall = self.panel:getFallingStones()

-- Tween new stones that spawn from the ceiling over 0.25s to fill in the new upper gaps that exist.
        Timer.tween(0.25, stonesToFall):finish(function()
            
-- Recursively call function in case new matches have been created.
-- As a result of falling blocks once new blocks have finished falling.
            self:calculateMatches()
        end)
    
-- If no matches, you can continue playing.
    else
        self.canInput = true
    end
end

function PlayState:render()
 -- Render panel of stones.
    self.panel:render()

 -- Render featured stone if it exists.
    if self.featuredStone then
        
-- Multiply so drawing white rect makes it brighter.
        love.graphics.setBlendMode('add')

        love.graphics.setColor(255/255, 255/255, 255/255, 96/255)
        love.graphics.rectangle('fill', (self.featuredStone.gridX - 1) * 32 + (SUPER_WIDTH - 272),
            (self.featuredStone.gridY - 1) * 32 + 16, 32, 32, 4)

-- Back to alpha
        love.graphics.setBlendMode('alpha')
    end

-- Render feature rect color based on timer.
    if self.rectFeatured then
        love.graphics.setColor(70/255, 255/255, 145/255, 255/255)
    else
        love.graphics.setColor(55/255, 180/255, 100/255, 255/255)
    end

-- Draw actual cursor rect
    love.graphics.setLineWidth(4)
    love.graphics.rectangle('line', self.panelFeatureX * 32 + (SUPER_WIDTH - 272),
        self.panelFeatureY * 32 + 16, 32, 32, 4)

    -- GUI text
    love.graphics.setColor(56/255, 56/255, 56/255, 234/255)
    love.graphics.rectangle('fill', 16, 16, 186, 116, 4)

    love.graphics.setColor(237/255, 135/255, 224/255, 255/255)
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Stage: ' .. tostring(self.stage), 20, 24, 182, 'center')
    love.graphics.printf('Score: ' .. tostring(self.score), 20, 52, 182, 'center')
    love.graphics.printf('Goal : ' .. tostring(self.scoreGoal), 20, 80, 182, 'center')
    love.graphics.printf('Timer: ' .. tostring(self.timer), 20, 108, 182, 'center')
end