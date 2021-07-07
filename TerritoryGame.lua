local w, h = term.getSize()

local world = {}
local worldLine = {}
local UI = {}

for i = 1, w-6 do
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

world[1][1] = colors.green
world[h][w-6] = colors.red
local turn = 0

local playersC = {
    [(colors.green)] = 0,
    [(colors.red)] = 1
}

local players = {
    [0] = {
        color = colors.green,
        movesPerTurn = 3,
        growth = 50,
        resist = 10,
        die = 10,
        upgrade = 1,
        moves = 0
    },
    [1] = {
        color = colors.red,
        movesPerTurn = 3,
        growth = 50,
        resist = 10,
        die = 10,
        upgrade = 1,
        moves = 0
    }
}

local function tickBoard()
    local updates = {}
    for y, l in pairs(world) do
        for x, v in pairs(l) do
            if v ~= 32768 then
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
                if math.random()*100 <= (players[playersC[v]].die * (100 - players[playersC[v]].resist)/100) then
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

function redrawUI()
    term.setBackgroundColor(players[turn].color)
    term.setCursorPos(w-4,1)
    term.write(string.format("% 5d", players[turn].moves))
    term.setCursorPos(w-4,3)
    term.write(" +"..string.format("% 3d", players[turn].movesPerTurn))
    term.setCursorPos(w-4,4)
    term.write("+"..string.format("% 3d", players[turn].growth).."%")
    term.setCursorPos(w-4,5)
    term.write("|"..string.format("% 3d", players[turn].resist).."%")
    term.setCursorPos(w-4,6)
    term.write("-"..string.format("% 3d", players[turn].die).."%")
    term.setCursorPos(w-4,7)
    term.write("U"..string.format("% 4d", players[turn].upgrade).."")
    term.setCursorPos(w-4,9)
    term.write(" end ")
end

term.clear()
gameSpeed = 1
while true do
    draw(world,1,1)
    draw(UI,w-5,1)

    players[turn].moves = players[turn].moves + gameSpeed*players[turn].movesPerTurn
    repeat
        draw(UI,w-5,1)
        redrawUI()
        local event, button, x, y
        repeat
            event, button, x, y = os.pullEvent("mouse_click")
        until button == 1
        if x >= w - 4 then
            if players[turn].moves >= players[turn].upgrade and y >= 3 and y <= 6  then
                players[turn].moves = players[turn].moves - players[turn].upgrade
                players[turn].upgrade = math.ceil(players[turn].upgrade + 2)
                if y == 3 then
                    players[turn].movesPerTurn = players[turn].movesPerTurn + 1
                elseif y == 4 then
                    players[turn].growth = players[turn].growth + 1
                elseif y == 5 then
                    players[turn].resist = players[turn].resist + 1
                elseif y == 6 then
                    players[turn].die = players[turn].die - 1
                end
            end
        elseif players[turn].moves >= 1 then
            if world[y][x] ~= players[turn].color
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
                if (world[y][x] == 32768) or (math.random()*100 > players[playersC[world[y][x]]].resist) then
                    world[y][x] = players[turn].color
                end
                players[turn].moves = players[turn].moves - 1
            end
            draw(world,1,1)
        end
    until y == 9 and x >= w - 4
    
    redrawUI()
    
    if turn == #players then
        for i = 1, gameSpeed do
            tickBoard()
        end
    end

    turn = (turn + 1)%(1 + #players)

    sleep(1/20)
end