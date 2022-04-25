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

local mt = {}
local log = math.log10
local floor = math.floor
local ceil = math.ceil
local exp = function(a) return 10^a end
local abs = math.abs
local function round(a)
    return math.floor(a+0.5)
end

local function new(a)
    local number = {
        sign = a == 0 and 0 or (a < 0 and -1 or 1),
        log = log(abs(a))
    }
    setmetatable(number, mt)
    return number
end

local zero = new(0)
local one = new(1)

function mt.__add(a, b)
    local A = deepCopy(a)
    local B = deepCopy(b)
    local inv = false
    if B.log > A.log then
        A, B = B, A
        inv = true
    end
    if B.sign == 0 then
        -- nothing
    elseif B.sign == A.sign then
        A.log = log(exp(A.log - floor(B.log)) + exp(B.log%1)) + floor(B.log)
    else
        if A.log == B.log then
            return new(0)
        end
        A.log = log(exp(A.log - floor(B.log)) - exp(B.log%1)) + floor(B.log)
        --A.sign = inv and -A.sign or A.sign
    end
    setmetatable(A, mt)
    return A
end

function mt.__unm(a)
    A = deepCopy(a)
    A.sign = -A.sign
    setmetatable(A, mt)
    return A
end

function mt.__sub(a, b)
    return mt.__add(a, mt.__unm(b))
end

function mt.__mul(a, b)
    local number = {
        sign = a.sign * b.sign,
        log = a.log + b.log
    }
    setmetatable(number, mt)
    return number
end

function mt.__div(a, b)
    if b.sign == 0 then
        error("Divide by 0", 2)
    end
    B = deepCopy(b)
    B.log = -B.log
    return mt.__mul(a, B)
end

function mt.__pow(a, b)
    if b.sign == 0 then
        return new(1)
    end
    local A = deepCopy(a)
    A.log = A.log * exp(b.log)
    A.sign = round(exp(b.log)%2) == 1 and A.sign or 1
    if b.sign == -1 then
        A = mt.div(one, A)
    end
    setmetatable(A, mt)
    return A
end

function mt.__eq(a, b)
    return a.sign == b.sign and a.log == b.log
end

function mt.__lt(a, b)
    return (a.sign < b.sign) or (a.sign == b.sign and a.log < b.log) or false
end

function mt.__le(a, b)
    return (a.sign <= b.sign and a.log <= b.log) or false
end

local function unlog(a)
    return exp(a.log)*a.sign
end

function mt.__tostring(a, f)
    f = f or (a.log > 10 and "Sci" or "Dig")
    if f == "Dig" then
        return string.format("%d", a.sign*exp(a.log))
    elseif f == "Sci" then
        return a.sign*exp(a.log%1).."e"..floor(a.log)
    elseif f == "Log" then
        return "e"..a.log
    end
end

return {new = new}