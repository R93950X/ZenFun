local players = {...}

local function shuffle(table)
    for i = #table, 2, -1 do
        local j = math.random(i)
        table[i], table[j] = table[j], table[i]
    end
end

local function selectRange(tableIn,first,last)
    local tableOut = {}
    for i = first, last do
        table.insert(tableOut, tableIn[i])
    end
    return tableOut
end

local function offset(table)
    for i = 2, #table do
        table[1], table[i] = table[i], table[1]
    end
end

local maxLength = 0
for i, v in pairs(players) do
    maxLength = #v > maxLength and #v or maxLength
end

for i = 1, #players do
    players[i] = string.rep(" ", maxLength - #players[i])..players[i]
end

local individuals = {}

for i, v in pairs(players) do
    individuals[v] = {}
end

shuffle(players)

local groups = {selectRange(players, 1, 4),
                selectRange(players, 5, 8)}

for round = 1, 4 do
    print("\n Round "..round)
    for player = 1, 4 do
        print("  "..groups[1][player].." VS "..groups[2][player])
        table.insert(individuals[groups[1][player]], groups[2][player])
        table.insert(individuals[groups[2][player]], groups[1][player])
    end
    offset(groups[2])
end

local oldGroups = groups
local groups = {selectRange(oldGroups[1], 1, 2), 
                selectRange(oldGroups[1], 3, 4),
                selectRange(oldGroups[2], 1, 2),
                selectRange(oldGroups[2], 3, 4)}

for round = 5, 6 do
    print("\n Round"..round)
    for pair = 0, 2, 2 do
        for player = 1, 2 do
            print("  "..groups[1+pair][player].." VS "..groups[2+pair][player])
            table.insert(individuals[groups[1+pair][player]], groups[2+pair][player])
            table.insert(individuals[groups[2+pair][player]], groups[1+pair][player])
        end
        offset(groups[2+pair])
    end
end

print("\n Round 7")
for i, v in pairs(groups) do
    print("  "..v[1].." VS "..v[2])
    table.insert(individuals[v[1]], v[2])
    table.insert(individuals[v[2]], v[1])
end

for i, v in pairs(individuals) do
    print(i..":"..(textutils.serialise(v)):gsub("[\n{}\",]",""))
end