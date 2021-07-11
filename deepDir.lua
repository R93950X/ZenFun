local function printDir(dir, prefix)
    if not prefix then prefix = "" end
    local nextPrefix = prefix.." "
    local contents = fs.list(dir)
    for i, v in ipairs(contents) do
        print(prefix..v)
        sleep(1/20)
        local file = fs.combine(dir,v)
        if fs.isDir(file) then
            printDir(file, nextPrefix)
        end 
    end
end

printDir("")