LaunchGameState = Class{__includes = BaseState}

function LaunchGameState:init()
    
-- Start the transition alpha at full, too fade in.
    self.transitionAlpha = 255

-- Spawn a panel and place it toward the right.
    self.panel = Panel(SUPER_WIDTH - 272, 16)

-- Start the stage # label off-screen.
    self.stageLabelY = -64
end

function LaunchGameState:enter(def)
    
-- Grab stage # from the def passed.
    self.stage = def.stage

-- Animate white screen fade-in, then animate a drop-down with the stage text.
-- First, over a period of 1 second, transition our alpha to 0
    Timer.tween(1, {
        [self] = {transitionAlpha = 0}
    })
    
-- Once that's finished, start a transition of our text label to the center of the screen over 0.25 seconds.
    :finish(function()
        Timer.tween(0.25, {
            [self] = {stageLabelY = SUPER_HEIGHT / 2 - 8}
        })
        
-- After that, pause for one second with Timer.after
        :finish(function()
            Timer.after(1, function()
                
-- then, animate the label going down past the bottom edge.
                Timer.tween(0.25, {
                    [self] = {stageLabelY = SUPER_HEIGHT + 30}
                })
                
                :finish(function()
                    gStateMachine:change('play', {
                        stage = self.stage,
                        panel = self.panel
                    })
                end)
            end)
        end)
    end)
end

function LaunchGameState:update(dt)
    Timer.update(dt)
end

function LaunchGameState:render()
    
-- Render panel of stones.
    self.panel:render()

-- Render stage # label and backdrip rect.
    love.graphics.setColor(228/255, 95/255, 228/255, 200/255)
    love.graphics.rectangle('fill', 0, self.stageLabelY - 8, SUPER_WIDTH, 48)
    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)
    love.graphics.setFont(gFonts['big'])
    love.graphics.printf('Stage ' .. tostring(self.stage),
        0, self.stageLabelY, SUPER_WIDTH, 'center')

-- Our transition foreground rectangle.
    love.graphics.setColor(255/255, 255/255, 255/255, self.transitionAlpha)
    love.graphics.rectangle('fill', 0, 0, SUPER_WIDTH, SUPER_HEIGHT)
end