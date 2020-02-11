Stone = Class{}

function Stone:init(x, y, color, variety)
    
-- Panel positions
    self.gridX = x
    self.gridY = y

-- Coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

-- Stone appearance/points
    self.color = color
    self.variety = variety


end

function Stone:render(x, y)

-- Draw shadow
    love.graphics.setColor(34/255, 32/255, 52/255, 255/255)
    love.graphics.draw(gTextures['main'], gFrames['stones'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

-- Draw stone itself
    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)
    love.graphics.draw(gTextures['main'], gFrames['stones'][self.color][self.variety],
        self.x + x, self.y + y)

    end