local w, h = term.getSize()
local UIWidth = 10
local gameSpeed = 1
w = w-UIWidth

local world = {}
local worldLine = {}
local UI = {}

for i = 1, w do
    table.insert(worldLine, 32768)
end
for i = 1, h do
    table.insert(world, {table.unpack(worldLine)})
    table.insert(UI, {colors.gray})
end

local function draw(image,x,y)
    -- Verify & Format Arguments
    if type(image) ~= "string" and type(image) ~= "table" then
        error("Argument 1 - expected type: string, got "..type(image), 2)
        
    elseif type(x) ~= "number" and x ~= nil then
        error("Argument 2 - expected type: number, got "..type(x), 2)
        
    elseif type(y) ~= "number" and y ~= nil then
        error("Argument 3 - expected type: number, got "..type(y), 2)
        
    end
    
    if x == nil or y == nil then
        x, y = term.getCursorPos()
        
    end
    if type(image) == "string" then
        if not fs.find(image) then
            error("Argument 1 - file not found", 2)
            
        end
        image = paintutils.loadImage(image)
        
    end
    
    -- Function
    local ox, oy = term.getCursorPos()
    local ocolor = term.getBackgroundColor()
    paintutils.drawImage(image, x, y)
    term.setCursorPos(ox, oy)
    term.setBackgroundColor(ocolor)
    
end

world[1][1] = colors.blue
world[h][1] = colors.yellow
world[h][w] = colors.red
world[1][w] = colors.lime
local turn = 0

local playersC = {
    [(colors.blue)] = 0,
    [(colors.red)] = 1,
    [(colors.lime)] = 2,
    [(colors.yellow)] = 3
}

local players = {
    [0] = {
        color = colors.blue,
        movesPerTurn = 3,
        growth = 50,
        resist = 10,
        die = 10,
        upgrade = 1,
        moves = 0,
        alive = true
    },
    [1] = {
        color = colors.red,
        movesPerTurn = 3,
        growth = 50,
        resist = 10,
        die = 10,
        upgrade = 1,
        moves = 0,
        alive = true
    },
    [2] = {
        color = colors.lime,
        movesPerTurn = 3,
        growth = 50,
        resist = 10,
        die = 10,
        upgrade = 1,
        moves = 0,
        alive = true
    },
    [3] = {
        color = colors.yellow,
        movesPerTurn = 3,
        growth = 50,
        resist = 10,
        die = 10,
        upgrade = 1,
        moves = 0,
        alive = true
    }
}

local function tickBoard()
    local updates = {}
    for i in pairs(players) do
        players[i].alive = false
    end
    for y, l in pairs(world) do
        for x, v in pairs(l) do
            if v ~= 32768 then
                players[playersC[v]].alive = true
                if math.random()*100 <= players[playersC[v]].growth then
                    local yOffset = math.random(-1,1)
                    local xOffset = math.random(-1,1)
                    local yPos = y + yOffset
                    local xPos = x + xOffset
                    if yPos < 1 then yPos = 1 end
                    if yPos > #world then yPos = #world end
                    if xPos < 1 then xPos = 1 end
                    if xPos > #l then xPos = #l end
                    if world[yPos][xPos] ~= 32768 then
                        if math.random()*100 > players[playersC[world[yPos][xPos]]].resist then
                            if not updates[yPos] then
                                updates[yPos] = {}
                            end
                            if updates[yPos][xPos] and updates[yPos][xPos] ~= v and updates[yPos][xPos] ~= 32768 then
                                if math.random() > 0.5 then
                                    updates[yPos][xPos] = v
                                end
                            else
                                updates[yPos][xPos] = v
                            end
                        end
                    else
                        if not updates[yPos] then
                            updates[yPos] = {}
                        end
                        if updates[yPos][xPos] and updates[yPos][xPos] ~= v and updates[yPos][xPos] ~= 32768 then
                            if math.random() > 0.5 then
                                updates[yPos][xPos] = v
                            end
                        else
                            updates[yPos][xPos] = v
                        end
                    end
                end
                if math.random()*100 < (players[playersC[v]].die * (100 - players[playersC[v]].resist)/100) then
                    if not updates[y] then
                        updates[y] = {}
                    end
                    updates[y][x] = colors.black
                end
            end
        end
    end
    for y, l in pairs(updates) do
        for x, v in pairs(l) do
            world[y][x] = v
        end
    end
end

local function scaleCost()
    players[turn].upgrade = math.ceil(players[turn].upgrade * 1.05)
end

function redrawUI()
    term.setBackgroundColor(players[turn].color)
    term.setCursorPos(w+2,1)
    term.write(string.format("% "..(UIWidth-1).."d", players[turn].moves))
    term.setCursorPos(w+2,3)
    term.write(" +"..string.format("% "..(UIWidth-3).."d", players[turn].movesPerTurn * gameSpeed))
    term.setCursorPos(w+2,4)
    term.write("+"..string.format("% "..(UIWidth-3).."d", players[turn].growth).."%")
    term.setCursorPos(w+2,5)
    term.write("|"..string.format("% "..(UIWidth-3).."d", players[turn].resist).."%")
    term.setCursorPos(w+2,6)
    term.write("-"..string.format("% "..(UIWidth-3).."d", players[turn].die).."%")
    term.setCursorPos(w+2,7)
    term.write("U"..string.format("% "..(UIWidth-2).."d", players[turn].upgrade).."")
    term.setCursorPos(w+2,9)
    term.write(" end ")
end

function takeSpot(x, y)
    if (world[y][x] == 32768) then
        world[y][x] = players[turn].color
        term.setCursorPos(x, y)
        term.setBackgroundColor(players[turn].color)
        term.write(" ")
        players[turn].moves = players[turn].moves - gameSpeed
        return true
    elseif world[y][x] ~= players[turn].color then
        while true do
            players[turn].moves = players[turn].moves - gameSpeed
            if math.random()*100 > players[playersC[world[y][x]]].resist then
                world[y][x] = players[turn].color
                term.setCursorPos(x, y)
                term.setBackgroundColor(players[turn].color)
                term.write(" ")
                return true
            end
            if players[turn].moves < gameSpeed then
                return false
            end
        end
    end
end

term.clear()
while true do
    draw(world,1,1)
    draw(UI,w+1,1)
    draw(world,1,1)

    for index in pairs(playersC) do
        if players[turn].alive then
            players[turn].moves = players[turn].moves + gameSpeed*players[turn].movesPerTurn
            local selected = nil
            repeat
                redrawUI()
                local event, button, x, y
                repeat
                    event, button, x, y = os.pullEvent("mouse_click")
                until (button == 1 or (button == 2 and x < w + 2)) and y <= h
                if x >= w+1 then
                    if players[turn].moves >= players[turn].upgrade and y >= 3 and y <= 6  then
                        if y == 3 and players[turn].movesPerTurn < 100 then
                            players[turn].movesPerTurn = players[turn].movesPerTurn + 1
                            players[turn].moves = players[turn].moves - players[turn].upgrade
                            scaleCost()
                        elseif y == 4 and players[turn].growth < 100 then
                            players[turn].growth = players[turn].growth + 1
                            players[turn].moves = players[turn].moves - players[turn].upgrade
                            scaleCost()
                        elseif y == 5 and players[turn].resist < 95 then
                            players[turn].resist = players[turn].resist + 1
                            players[turn].moves = players[turn].moves - players[turn].upgrade
                            scaleCost()
                        elseif y == 6 and players[turn].die > 0 then
                            players[turn].die = players[turn].die - 1
                            players[turn].moves = players[turn].moves - players[turn].upgrade
                            scaleCost()
                        end
                    end
                elseif players[turn].moves >= gameSpeed then
                    if world[y][x] == players[turn].color then
                        if selected and selected.y == y and selected.x == x then
                            selected = nil
                            term.setCursorPos(x, y)
                            term.setBackgroundColor(players[turn].color)
                            term.write(" ")
                        elseif not selected then
                            selected = {x=x, y=y}
                            term.setCursorPos(x, y)
                            term.setBackgroundColor(colors.white)
                            term.write(" ")
                        end
                    elseif selected then
                        local pos = {x=selected.x, y=selected.y}
                        while players[turn].moves >= gameSpeed do
                            if pos.x < x then pos.x = pos.x + 1 end
                            if pos.x > x then pos.x = pos.x - 1 end
                            if pos.y < y then pos.y = pos.y + 1 end
                            if pos.y > y then pos.y = pos.y - 1 end
                            --print(pos.x, x, pos.y, y)
                            --sleep(1)
                            if world[y][x] ~= players[turn].color then
                                takeSpot(pos.x, pos.y)
                            end
                            if (pos.x == x and pos.y == y and world[y][x] == players[turn].color)
                            then
                                break
                            end
                        end
                    elseif world[y][x] ~= players[turn].color
                        and (
                           (world[y  ] and (world[y  ][x+1] == players[turn].color))
                        or (world[y  ] and (world[y  ][x-1] == players[turn].color))
                        or (world[y+1] and (world[y+1][x-1] == players[turn].color))
                        or (world[y+1] and (world[y+1][x  ] == players[turn].color))
                        or (world[y+1] and (world[y+1][x+1] == players[turn].color))
                        or (world[y-1] and (world[y-1][x-1] == players[turn].color))
                        or (world[y-1] and (world[y-1][x  ] == players[turn].color))
                        or (world[y-1] and (world[y-1][x+1] == players[turn].color))
                        ) then
                        takeSpot(x, y)
                    end
                end
            until y == 9 and x >= w + 2

            redrawUI()
        end

        turn = (turn + 1)%(1 + #players)
    end


    for i = 1, gameSpeed do
        tickBoard()
    end

    sleep(1/20)
end