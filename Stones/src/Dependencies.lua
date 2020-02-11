Class = require 'lib/class'

push = require 'lib/push'

-- Used for timers and tweening
Timer = require 'lib/knife.timer'

-- Utility
require 'src/StateMachine'
require 'src/Util'

-- Game pieces
require 'src/Panel'
require 'src/Stone'

-- Game states
require 'src/states/BaseState'
require 'src/states/LaunchGameState'
require 'src/states/GameOverState'
require 'src/states/PlayState'
require 'src/states/StartState'

gSounds = {
    --https://freesound.org/people/LittleRobotSoundFactory/sounds/323881/
    ['music'] = love.audio.newSource('sounds/Loop_CutePuzzle_00.wav', 'static'),
    ['select'] = love.audio.newSource('sounds/select.wav', 'static'),
    ['error'] = love.audio.newSource('sounds/error.wav', 'static'),
    ['match'] = love.audio.newSource('sounds/match.wav', 'static'),
    ['clock'] = love.audio.newSource('sounds/clock.wav', 'static'),
    ['game-over'] = love.audio.newSource('sounds/game-over.wav', 'static'),
    ['next-stage'] = love.audio.newSource('sounds/next-stage.wav', 'static')
}

gTextures = {
    --https://opengameart.org/content/match-3 Buch
    ['main'] = love.graphics.newImage('graphics/stones.png'),
    ['backdrop'] = love.graphics.newImage('graphics/backdrop.png')
}

gFrames = {
    
-- Divided into sets for each stone type in this game.
    ['stones'] = GenerateStoneQuads(gTextures['main'])
}

-- Fonts
gFonts = {
    ['little'] = love.graphics.newFont('fonts/font.ttf', 8),
    ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
    ['big'] = love.graphics.newFont('fonts/font.ttf', 32)
}