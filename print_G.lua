function printTable(table, prefix)
    for i, v in pairs(table) do
        if type(v) == "table" and i ~= "_G" and i ~= "_ENV" then
            if type(i) == "number" then
                printTable(v, prefix.."["..i.."]")
            else
                printTable(v , prefix.."."..i)
            end
        elseif i ~= "_G" and i ~= "_ENV" then
            if type(i)  == "number" then
                print(prefix.."["..i.."] = "..tostring(v))
            else
                print(prefix.."."..i.." = "..tostring(v))
            end
        end
        sleep(1/20)
    end 
end

printTable(_G, "_G")
    
