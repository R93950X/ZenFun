local function deepCopy(tbl)
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

local new

local mt = {__type = "LogNum"}
local log = function(a)
    if type(a) == "LogNum" then
        return new(a.exponent + math.log10(a.mantissa))
    else
        local A, B = pcall(math.log10, a)
        if A then
            return B
        else
            error(B, 2)
        end
    end
end
local floor = function(a)
    if type(a) == "LogNum" then
        if a.exponent >= 14 then
            return new(a)
        else
            local result = new(a)
            result.mantissa = math.floor(a.mantissa*10^a.exponent)/10^a.exponent
            return result
        end
    else
        local A, B = pcall(math.floor, a)
        if A then
            return B
        else
            error(B, 2)
        end
    end
end
local ceil = function(a)
    if type(a) == "LogNum" then
        if a.exponent >= 14 then
            return new(a)
        else
            local result = new(a)
            result.mantissa = math.ceil(a.mantissa*10^a.exponent)/10^a.exponent
            return result
        end
    else
        local A, B = pcall(math.ceil, a)
        if A then
            return B
        else
            error(B, 2)
        end
    end
end
local exp = function(a) return 10^a end
local abs = function(a)
    if type(a) == "LogNum" then
        local result = new(a)
        result.mantissa = math.abs(result.mantissa)
        return result
    else
        local A, B = pcall(math.abs, a)
        if A then
            return B
        else
            error(B, 2)
        end
    end
end
local function round(a)
    return math.floor(a+0.5)
end

local Ttype = type

_G.type = function(a)
    if Ttype(a) == "table" and getmetatable(a) and getmetatable(a).__type then
        return getmetatable(a).__type
    else
        return Ttype(a)
    end
end

local function new(a)
    local number = {}

    if type(a) == "number" then
        if a == 0 then
            number.exponent = 0
            number.mantissa = 0
        else
            number.exponent = floor(log(abs(a)))
            number.mantissa = a / 10^number.exponent
        end
    elseif type(a) == "LogNum" then
        number = deepCopy(a)
    end

    setmetatable(number, mt)
    return number
end

local zero = new(0)
local one = new(1)

function mt.__add(a, b)
    if type(a) == "number" then
        a = new(a)
    end
    if type(b) == "number" then
        b = new(b)
    end
    local expDiff = b.exponent - a.exponent

    if expDiff <= -15 then
        return new(a)
    elseif expDiff >= 15 then
        return new(b)
    else
        local result = new(0)
        result.mantissa = a.mantissa + b.mantissa * 10^expDiff
        if result.mantissa == 0 then
            result.exponent = 0
        else
            local expCorrection = floor(log(abs(result.mantissa)))
            result.exponent = a.exponent + expCorrection
            result.mantissa = result.mantissa / 10^expCorrection
        end
        return result
    end
end

function mt.__unm(a)
    local result = deepCopy(a)
    result.mantissa = -result.mantissa
    setmetatable(result, mt)
    return result
end

function mt.__sub(a, b)
    return a+-b
end

function mt.__mul(a, b)
    if type(a) == "number" then
        a = new(a)
    end
    if type(b) == "number" then
        b = new(b)
    end
    local result = new(0)
    result.mantissa = a.mantissa * b.mantissa
    result.exponent = a.exponent + b.exponent
    if result.mantissa == 0 then
        result.exponent = 0
    else
        local expCorrection = floor(log(abs(result.mantissa)))
        result.exponent = result.exponent + expCorrection
        result.mantissa = result.mantissa / 10^expCorrection
    end
    return result
end

function mt.__div(a, b)
    if type(a) == "number" then
        a = new(a)
    end
    if type(b) == "number" then
        b = new(b)
    end
    if b == zero then
        error("Divide by 0", 2)
    end
    local result = new(0)
    result.mantissa = a.mantissa / b.mantissa
    result.exponent = a.exponent - b.exponent
    if result.mantissa == 0 then
        result.exponent = 0
    else
        local expCorrection = floor(log(abs(result.mantissa)))
        result.exponent = result.exponent + expCorrection
        result.mantissa = result.mantissa / 10^expCorrection
    end
    return result
end

function mt.__pow(a, b)
    if type(a) == "number" then
        a = new(a)
    end
    if type(b) == "number" then
        b = new(b)
    end
    if a == zero then
        return new(0)
    elseif b == zero then
        return new(1)
    end
    local logAns = (log(abs(a.mantissa)) + a.exponent) * b.mantissa * 10^b.exponent
    local result = new(0)
    result.exponent = floor(logAns)
    result.mantissa = 10^( ( (log(abs(a.mantissa)) * b.mantissa)%1 * 10^b.exponent )%1)
    if a.mantissa < 0 then 
        result.mantissa = result.mantissa * ((-1)^b.mantissa)
    end

    return result
end

function _G.slowPow(a, b)
    if type(a) == "number" then
        a = new(a)
    end
    if type(b) == "number" then
        b = new(b)
    end
    a = new(a)
    for i = 1, abs(b.exponent) do
        a = a ^ 2
        a = a ^ 5
    end
    a = a ^ b.mantissa
    return a
end

function mt.__eq(a, b)
    if type(a) == "number" then
        a = new(a)
    end
    if type(b) == "number" then
        b = new(b)
    end
    return a.mantissa == b.mantissa and a.exponent == b.exponent
end

function mt.__lt(a, b)
    if type(a) == "number" then
        a = new(a)
    end
    if type(b) == "number" then
        b = new(b)
    end
    return a.exponent < b.exponent or (a.exponent == b.exponent and a.mantissa < b.mantissa)
end

function mt.__le(a, b)
    if type(a) == "number" then
        a = new(a)
    end
    if type(b) == "number" then
        b = new(b)
    end
    return a.exponent <= b.exponent and a.mantissa <= b.mantissa
end

function mt.__tostring(a, f)
    f = f or (a.exponent <= 10 and a.exponent >= -4 and "Dig" or "Sci")
    if f == "Dig" then
        return (("%.5f"):format(a.mantissa * 10^a.exponent):gsub("%.0+%f[^%d]", ""):gsub("(%.%d-)0+%f[^%d]", "%1"))
    elseif f == "Sci" then
        local Fexp
        if abs(a.exponent) < 100000 then
            Fexp = ("%.f"):format(abs(a.exponent))
        else
            exp2 = log(abs(a.exponent))
            Fexp = ("%.4f"):format(10^(exp2%1)).."e"..floor(exp2)
        end
        return ((a.exponent < 0 and "1/" or ""))..("%.4f"):format(a.mantissa).."e"..Fexp
    end
end

return {slowPow = slowPow, new = new}