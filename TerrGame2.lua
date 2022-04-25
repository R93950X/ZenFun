-- Settings
local UIWidth = 10
local gameSpeed = 1 -- non-supported speed value, have fun
local players = {
    [colors.red] = true, 
    [colors.blue] = true,
}

-- Advanced settings
local upgradeCostScaling = {
    multiply = 1.05,    -- upgrade cost is multiplied by this and rounded up
    add = 0,         -- added to upgrade cost after rounding (make it an integer you disgrace)
    divide = {1.1, 5}, -- {divide by this, after this many turns}
}
local defaultStats = {
    points = 0,             -- starting points before adding pointsPerTurn
    pointsPerTurn = 3,      -- gain this many points per turn
    pointsPerTurnBonus = 1, -- if you have 100% of the map claimed your pointsPerTurn is multiplied by 1 + this
    growthRate = 50,        -- the initial chance of any given cell on the map attempting to spread to an adjacent space
    deathRate = 10,         -- the initial chance of any given cell just dying (growth occurs first)
    resistance = 10,        -- the initial chance of a given cell rsfusing ot die or be replaced
    upgradeCost = 1,        -- the cost of the first upgrade
    
                 -- Don't touch following values pls, they will absolutely fuck the game
    count = 0,   -- used in the game code to keep track of how many cells a player has
    claims = {}, -- used in the game code to keep track of claimed areas for each player
}
local maxStats = {
    -- {max/min value, true makes it a max}
    pointsPerTurn = {10^10, true}, -- the max value for points per turn
    growthRate = {500, true},      -- the max growth rate (can be greater than 100)
    deathRate = {0, false},        -- the minimum death rate
    resistance = {95, true}        -- the maximum resistance rate
}

-- Game stuff

function deepCopy(tbl)
    local clone = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            clone[k] = deepCopy(v)
        else
            clone[k] = v
        end
    end
    return clone
end

local w, h = term.getSize()
w = w - UIWidth - 1
local worldWindow = window.create(term.current(), 1, 1, w, h)
local UIWindow = window.create(term.current(), w + 2, 1, UIWidth, h)
local globalClaims = {}

for x = -1, w+1 do
    globalClaims[x] = {}
end

function updatePixel(player, x, y)
    if globalClaims[x][y] and globalClaims[x][y] then
        players[globalClaims[x][y]].claims[x][y] = nil
        players[globalClaims[x][y]].count = players[globalClaims[x][y]].count - 1
        globalClaims[x][y] = nil
    end
    if player ~= colors.black then
        if not players[player].claims[x] then players[player].claims[x] = {} end
        players[player].claims[x][y] = true
        globalClaims[x][y] = player
        players[player].count = players[player].count + 1
    else
        globalClaims[x][y] = nil
    end
    worldWindow.setCursorPos(x, y)
    worldWindow.setBackgroundColor(player)
    worldWindow.write(" ")
    worldWindow.setBackgroundColor(colors.black)
end

for i in pairs(players) do
    players[i] = deepCopy(defaultStats)
    updatePixel(i, math.random(1,w), math.random(1,h))
end

function take(player, x, y)
    if players[player].points < gameSpeed or x < 1 or x > w or y < 1 or y > h then
        return false
    end
    if not (
        (globalClaims[x  ][y+1] == player) or
        (globalClaims[x  ][y-1] == player) or
        (globalClaims[x+1][y+1] == player) or
        (globalClaims[x+1][y  ] == player) or
        (globalClaims[x+1][y-1] == player) or
        (globalClaims[x-1][y+1] == player) or
        (globalClaims[x-1][y  ] == player) or
        (globalClaims[x-1][y-1] == player)
    ) then
        return false
    end
    players[player].points = players[player].points - gameSpeed
    if globalClaims[x][y] then
        if math.random()*100 > players[globalClaims[x][y]].resistance then
            updatePixel(player, x, y)
        else
            return false
        end
    else
        updatePixel(player, x, y)
    end
    return true
end

function takeLine(player, x, y, x2, y2)
    local success = true
    while players[player].points >= gameSpeed and
    not (x == x2 and y == y2 and success == true) do
        if success then
            if math.abs(x2 - x) > math.abs(y2 - y) then
                x = x > x2 and x - 1 or x + 1
            elseif math.abs(y2 - y) > math.abs(x2 - x) then
                y = y > y2 and y - 1 or y + 1
            elseif math.abs(x2 - x) == math.abs(y2 - y) then
                x = x > x2 and x - 1 or x + 1
                y = y > y2 and y - 1 or y + 1
            end
        end
        success = globalClaims[x][y] == player or take(player, x, y)

    end
end

local upgrades = {
    [3] = {"pointsPerTurn", 1},
    [4] = {"growthRate", 1},
    [5] = {"resistance", 1},
    [6] = {"deathRate", -1},
}

local playerSelection

function playerTurn(player)
    players[player].points = players[player].points + 
    math.floor((1 + players[player].pointsPerTurnBonus * players[player].count/(w*h)) * players[player].pointsPerTurn * gameSpeed)
    repeat
        drawUI(player)
        local event, button, x, y
        event, button, x, y = os.pullEvent("mouse_click")
        if x <= w then
            if globalClaims[x][y] ~= player then
                if not playerSelection then
                    take(player, x, y)
                else
                    takeLine(player, playerSelection[1], playerSelection[2], x, y)
                end
            else
                if not playerSelection then
                    playerSelection = {x, y}
                    worldWindow.setCursorPos(x, y)
                    worldWindow.setBackgroundColor(colors.white)
                    worldWindow.write(" ")
                    worldWindow.setBackgroundColor(colors.black)
                elseif x == playerSelection[1] and y == playerSelection[2] then
                    playerSelection = nil
                    worldWindow.setCursorPos(x, y)
                    worldWindow.setBackgroundColor(player)
                    worldWindow.write(" ")
                    worldWindow.setBackgroundColor(colors.black)
                end
            end
        -- upgrade handling is an absolute mess lol
        elseif x >= w+2 and y <= 6 and y >= 3 and players[player].points >= players[player].upgradeCost then
            if (maxStats[upgrades[y][1]][2] and players[player][upgrades[y][1]] < maxStats[upgrades[y][1]][1])
            or ((not maxStats[upgrades[y][1]][2]) and players[player][upgrades[y][1]] > maxStats[upgrades[y][1]][1]) then
                players[player][upgrades[y][1]] = players[player][upgrades[y][1]] + upgrades[y][2]
                players[player].points = players[player].points - players[player].upgradeCost
                players[player].upgradeCost = math.ceil(players[player].upgradeCost * upgradeCostScaling.multiply + upgradeCostScaling.add)
            end
        end
    until y == 9 and x >= w+2
    if playerSelection then
        worldWindow.setCursorPos(playerSelection[1], playerSelection[2])
        playerSelection = nil
        worldWindow.setBackgroundColor(player)
        worldWindow.write(" ")
        worldWindow.setBackgroundColor(colors.black)
    end
end

function drawUI(player)
    UIWindow.setBackgroundColor(player)

    UIWindow.setCursorPos(1, 1)
    UIWindow.write(string.format("% "..UIWidth.."d", players[player].points))
    UIWindow.setCursorPos(1, 3)
    UIWindow.write("+"..string.format("% "..(UIWidth-1).."d", players[player].pointsPerTurn * gameSpeed))
    UIWindow.setCursorPos(1, 4)
    UIWindow.write("="..string.format("% "..(UIWidth-2).."d", players[player].growthRate).."%")
    UIWindow.setCursorPos(1, 5)
    UIWindow.write("|"..string.format("% "..(UIWidth-2).."d", players[player].resistance).."%")
    UIWindow.setCursorPos(1, 6)
    UIWindow.write("-"..string.format("% "..(UIWidth-2).."d", players[player].deathRate).."%")
    UIWindow.setCursorPos(1, 7)
    UIWindow.write("U"..string.format("% "..(UIWidth-1).."d", players[player].upgradeCost))
    UIWindow.setCursorPos(1, 9)
    UIWindow.write(string.rep(" ", math.ceil((UIWidth-3)/2)).."end"..string.rep(" ", math.floor((UIWidth-3)/2)))
    UIWindow.setCursorPos(1, 11)
    UIWindow.write("#"..string.format("% "..(UIWidth-1).."d", players[player].count))
    UIWindow.setCursorPos(1, 12)
    UIWindow.write(string.format("% "..(UIWidth-1).."f", 100*players[player].count/(w*h)).."%")
    
    UIWindow.setBackgroundColor(colors.gray)
end

function drawWorld()
    worldWindow.clear()
    for player, data in pairs(players) do
        local worldData = data.claims
        for x, column in pairs(worldData) do
            for y, val in pairs(column) do
                worldWindow.setCursorPos(x, y)
                worldWindow.setBackgroundColor(player)
                worldWindow.write(" ")
            end
        end
    end
end


local maxTier = 1

-- tier to be used for >= 100 growth
function tick(tier)
    local updates = {}
    for player, data in pairs(players) do
        local playerTier = math.ceil(players[player].growthRate/100)
        if playerTier >= tier then
            local worldData = data.claims
            for x, column in pairs(worldData) do
                for y, val in pairs(column) do
                    local xOff, yOff = math.random(-1,1), math.random(-1,1)
                    local xPos, yPos = x + xOff, y + yOff
                    if xPos < 1 then xPos = 1 end
                    if xPos > w then xPos = w end
                    if yPos < 1 then yPos = 1 end
                    if yPos > h then yPos = h end
                    if (not (globalClaims[xPos][yPos] == player)) and
                    math.random()*100 <= players[player].growthRate/playerTier and
                    (globalClaims[xPos][yPos] == nil or 
                    math.random()*100 >= players[globalClaims[xPos][yPos]].resistance) then
                        if not updates[xPos] then updates[xPos] = {} end
                        if not updates[xPos][yPos] then updates[xPos][yPos] = {} end
                        table.insert(updates[xPos][yPos], player)
                    end                    
                end
            end
        end
    end
    if tier == maxTier then
        for player, data in pairs(players) do
            local worldData = data.claims
            for x, column in pairs(worldData) do
                for y, val in pairs(column) do
                    if math.random()*100 < players[player].deathRate*(1-players[player].resistance/100) then
                        updatePixel(colors.black, x, y)
                    end
                end
            end
        end
    end
    for x, column in pairs(updates) do
        for y, val in pairs(column) do
            updatePixel(val[math.random(1, #val)], x, y)
        end
    end
end

term.setBackgroundColor(colors.gray)
term.clear()
drawWorld()

local lastTurn

local turnCount = 0

-- Game loop
while true do

    for i, v in pairs(players) do
        if players[i].count > 0 then
            if lastTurn == i then
                term.setBackgroundColor(colors.black)
                term.setTextColor(colors.white)
                term.clear()
                term.setCursorPos(1,1)
                for _, name in pairs(colors) do
                    if lastTurn == v then
                        print(i.." wins")
                    end
                end
                return
            end
            lastTurn = i
            playerTurn(i)
        end
        if players[i].growthRate > maxTier * 100 then
            maxTier = maxTier + 1
        end
    end

    for i = 1, gameSpeed do
        for tier = 1, maxTier do
            tick(tier)
        end
    end

    turnCount = turnCount + 1
    if turnCount % upgradeCostScaling.divide[2] == 0 then
        for i, v in pairs(players) do
            players[i].upgradeCost = math.ceil(players[i].upgradeCost/upgradeCostScaling.divide[1])
        end
    end

    sleep(1/20)
end