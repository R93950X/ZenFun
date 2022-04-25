local numerals = {
    {"I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX"},
    {"X", "XX", "XXX", "XL", "L", "LX", "LXX", "LXXX", "XC"},
    {"C", "CC", "CCC", "CD", "D", "DC", "DCC", "DCCC", "CM"},
}

local function decToRoman(number)
    local val = number:gsub("(%d?)(%d?)(%d?)(%d*)", function(...)
        local digits = {...}
        for i = 1, 3 do
            if digits[i] ~= "" then
                digits[i] = numerals[i][tonumber(digits[i])]
            end
        end
        if digits[4] == "" then
            return digits[3]..digits[2]..digits[1]
        else
            return "|"..decToRoman(digits[4]).."|"..digits[3]..digits[2]..digits[1]
        end
    end)
    return val
end

function pdr(number)
    if type(number) ~= "number" then
        error("expected number, got "..type(number))
    end
    number = string.format("%d", number):reverse()
    return decToRoman(number)
end