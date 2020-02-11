Panel = Class{}

function Panel:init(x, y)
    self.x = x
    self.y = y
    self.matches = {}

    self:initializeStones()
end

function Panel:initializeStones()
    self.stones = {}

    for stoneY = 1, 8 do
        
-- Empty table that will serve as a new row
        table.insert(self.stones, {})

        for stoneX = 1, 8 do
            
-- Create a new stone at X,Y with a random color and variety
            table.insert(self.stones[stoneY], Stone(stoneX, stoneY, math.random(18), math.random(6)))
        end
    end

    while self:calculateMatches() do
        
-- Recursively initialize if matches were returned so there's always a matchless board on start
        self:initializeStones()
    end
end

-- Goes left to right, top to bottom in the board, calculating matches by counting consecutive
-- stones of the same color. Doesn't need to check the last stone in every row or column if the 
-- last two haven't been a match.

function Panel:calculateMatches()
    local matches = {}

-- How many of the same color blocks in a row found.
    local matchNum = 1

-- Horizontal stones first.
    for y = 1, 8 do

        local colorToMatch = self.stones[y][1].color

        matchNum = 1
        
-- Every horizontal stone.
        for x = 2, 8 do
            
-- If this is the same color as the one you're trying to match.
            if self.stones[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                
-- Set this as the new color to watch for.
                colorToMatch = self.stones[y][x].color

-- If we have a match of 3 or more up to now, add it to our matches table.
                if matchNum >= 3 then
                    local match = {}

-- Go backwards from here by matchNum.
                    for x2 = x - 1, x - matchNum, -1 do
  
-- Add each stone to the match that's in that match.
                        table.insert(match, self.stones[y][x2])
                end

-- Add this match to our total matches table.
                    table.insert(matches, match)
                end

                matchNum = 1

-- Don't need to check last two if they won't be in a match.
                if x >= 7 then
                    break
                end
            end
        end

-- Account for the last row ending with a match.
        if matchNum >= 3 then
            local match = {}
            
-- Go backwards from end of last row by matchNum.
            for x = 8, 8 - matchNum + 1, -1 do
                    table.insert(match, self.stones[y][x])
                end

            table.insert(matches, match)
        end
    end

-- Vertical matches
    for x = 1, 8 do

        local colorToMatch = self.stones[1][x].color

        matchNum = 1

-- Every vertical tile
        for y = 2, 8 do
            if self.stones[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                colorToMatch = self.stones[y][x].color

                if matchNum >= 3 then
                    local match = {}

                    for y2 = y - 1, y - matchNum, -1 do
                            table.insert(match, self.stones[y2][x])
                        end

                    table.insert(matches, match)
                end

                matchNum = 1

-- Don't need to check last two if they won't be in a match.
                if y >= 7 then
                    break
                end
            end
        end

-- Account for the last column ending with a match.
        if matchNum >= 3 then
            local match = {}
            
-- Go backwards from end of last row by matchNum.
            for y = 8, 8 - matchNum + 1, -1 do
                    table.insert(match, self.stones[y][x])
                end
            table.insert(matches, match)
        end
    end

    -- store matches for later reference
    self.matches = matches

-- Return matches table if > 0, else just return false
    return #self.matches > 0 and self.matches or false
end

-- Remove the matches from the Panel by just setting the stone slots within them to nil, then setting self.matches to nil.

function Panel:removeMatches()
    for m, match in pairs(self.matches) do
        for m, stone in pairs(match) do
            self.stones[stone.gridY][stone.gridX] = nil
        end
    end

    self.matches = nil
end

-- Shifts down all of the stones that now have spaces below them, then returns a table that
-- contains tweening information for these new stones.
function Panel:getFallingStones()

-- Tween table, with stones as keys and their x and y as the to values
    local tweens = {}

-- For each column, go up stone by stone till you hit a space
    for x = 1, 8 do
        local space = false
        local spaceY = 0

        local y = 8
        while y >= 1 do
            
-- If the last stone was a space.
            local stone = self.stones[y][x]
            
            if space then
                
-- If the current stone is not a space, bring this down to the lowest space.
                if stone then
                    
-- Put the stone in the correct spot in the panel and fix its grid positions.
                    self.stones[spaceY][x] = stone
                    stone.gridY = spaceY

-- Set its prior position to nil
                    self.stones[y][x] = nil

-- Tween the Y position to 32 x its grid position.
                    tweens[stone] = {
                        y = (stone.gridY - 1) * 32
                    }

-- Set Y to spaceY to start back from here again.
                    space = false
                    y = spaceY

-- Set this back to 0 to not have an active space.
                    spaceY = 0
                end
            elseif stone == nil then
                space = true
                
-- If there's no assigned space, set this to it.
                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

-- Create replacement stones at the top of the screen.
    for x = 1, 8 do
        for y = 8, 1, -1 do
            local stone = self.stones[y][x]

-- If the stone is nil, then need to add a new one.
            if not stone then

-- New stone with random color and variety
                local stone = Stone(x, y, math.random(8), math.random(6))
                stone.y = -32
                self.stones[y][x] = stone

-- Create a new tween to return for this stone to fall down
                tweens[stone] = {
                    y = (stone.gridY - 1) * 32
                }
            end
        end
    end

    return tweens
end

function Panel:render()
    for y = 1, #self.stones do
        for x = 1, #self.stones[1] do
            self.stones[y][x]:render(self.x, self.y)
        end
    end
end