local matrix = {
    { 5,  2,  1,  4,  6},
    { 9,  4,  2,  5,  2},
    {11,  5,  7,  3,  9},
    { 5,  6,  6,  7,  2},
    { 7,  5,  9,  3,  3}
}

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

_G.matrices = {}

function matrixDeterminant(matrix)
    -- check if matrix is square and complete & made of numbers
    for _, row in pairs(matrix) do
        if #row ~= #matrix then
            error("non-square matrix", 2)
        end
        for _, val in pairs(row) do
            if type(val) ~= "number" then
                error("type "..type(val).." found in matrix", 2)
            end
        end
    end
    if #matrix == 2 then
        return matrix[1][1]*matrix[2][2]-matrix[1][2]*matrix[2][1]
    else
        local determinant = 0
        for subMatrix in pairs(matrix) do
            local newMatrix = deepCopy(matrix)
            table.remove(newMatrix, 1)
            for _, row in pairs(newMatrix) do
                table.remove(row, subMatrix)
            end
            determinant = determinant + matrix[1][subMatrix]*(subMatrix%2 == 1 and 1 or -1) * matrixDeterminant(newMatrix)
        end
        return determinant
    end
end

print(matrixDeterminant(matrix))