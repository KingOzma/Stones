love.graphics.setDefaultFilter('nearest', 'nearest')

-- Keeping all requires and assets in the Dependencies.lua file
require 'src/Dependencies'

-- Screen dimensions
BOX_WIDTH = 1280
BOX_HEIGHT = 720

-- Virtual resolution dimensions
SUPER_WIDTH = 512
SUPER_HEIGHT = 288

-- Speed at which the backdrop texture will scroll
BACKDROP_SCROLL_SPEED = 80

function love.load()
    
-- Window bar title
    love.window.setTitle('Stones')

-- Seed the RNG
    math.randomseed(os.time())

-- Initialize emulated resolution
    push:setupScreen(SUPER_WIDTH, SUPER_HEIGHT, BOX_WIDTH, BOX_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true,
        canvas = true
    })

-- Set music to loop and start
    gSounds['music']:setLooping(true)
    gSounds['music']:play()


-- Initialize state machine with all state-returning functions
    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end,
        ['launch-game'] = function() return LaunchGameState() end,
        ['play'] = function() return PlayState() end,
        ['game-over'] = function() return GameOverState() end
    }
    gStateMachine:change('start')

-- Keep track of scrolling our backdrop on the X axis
    backdropX = 0

-- Initialize input table
    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    
-- Add to table of keys pressed this frame
    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

function love.update(dt)
    
-- Scroll backdrop, used across all states
    backdropX = backdropX - BACKDROP_SCROLL_SPEED * dt
    
-- If scrolled the entire image, reset it to 0
    if backdropX <= -1024 + SUPER_WIDTH - 4 + 51 then
        backdropX = 0
    end

    gStateMachine:update(dt)

    love.keyboard.keysPressed = {}
end

function love.draw()
    push:start()

-- Scrolling backdrop drawn behind every state
    love.graphics.draw(gTextures['backdrop'], backdropX, 0)
    
    gStateMachine:render()
    push:finish()
end