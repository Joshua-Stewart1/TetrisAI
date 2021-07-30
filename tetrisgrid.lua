Grid = {}

function Grid:new(rows, columns)
	local g = {}
    g.rows = rows
    g.columns = columns
    g.cells = {}
    for r = 0, g.rows - 1 do
        g.cells[r] = {}
        for c = 0, g.columns - 1 do
            g.cells[r][c] = false
        end
    end
	setmetatable(g, self)
	self.__index = self
	return g
end

function Grid:clone()
    local _grid = Grid:new(self.rows, self.columns);
    for r = 0, self.rows - 1 do
        for c = 0, self.columns - 1 do
            _grid.cells[r][c] = self.cells[r][c]
        end
    end
    return _grid
end

function Grid:clearLines()
    local distance = 0
    local row = {}
    for r = self.rows - 1, 0, -1 do
        if (self:isLine(r)) then
            distance = distance + 1
            for c = 0, self.columns - 1 do
                self.cells[r][c] = false
            end
        elseif (distance > 0) then
            for c = 0, self.columns do
                self.cells[r + distance][c] = self.cells[r][c]
                self.cells[r][c] = false
            end
        end
    end
    return distance
end

function Grid:isLine(row)
    for c = 0, self.columns - 1 do
        if not self.cells[row][c] then
            return false
        end
    end
    return true
end

function Grid:isEmptyRow(row)
    for c = 0, self.columns - 1 do
        if self.cells[row][c] then
            return false
        end
    end
    return true
end

function Grid:exceeded()
    return not self:isEmptyRow(0) or not self:isEmptyRow(1)
end

function Grid:height()
    local r = 0;
    while r < self.rows and self:isEmptyRow(r) do
		r = r + 1
	end
    return self.rows - r
end

function Grid:lines()
    local count = 0
    for r = 0, self.rows - 1 do
        if self:isLine(r) then
            count = count + 1
        end
    end
    return count
end

function Grid:holes()
    local count = 0
    for c = 0, self.columns - 1 do
        local block = false;
        for r = 0, self.rows - 1 do
            if self.cells[r][c] then
                block = true
            elseif not self.cells[r][c] and block then
                count = count + 1
            end
        end
    end
    return count
end

function Grid:blockades()
    local count = 0
    for c = 0, self.columns - 1 do
        local hole = false
        for r = self.rows - 1, 0, -1 do
            if not self.cells[r][c] then
                hole = true
            elseif self.cells[r][c] and hole then
                count = count + 1
            end
        end
    end
    return count
end

function Grid:aggregateHeight()
    local total = 0
    for c = 0, self.columns - 1 do
        total = total + self:columnHeight(c)
    end
    return total
end

function Grid:bumpiness()
    local total = 0
    for c = 0, self.columns - 2 do
        total = total + math.abs(self:columnHeight(c) - self:columnHeight(c + 1))
    end
    return total
end

function Grid:columnHeight(column)
    local r = 0;
    while r < self.rows and not self.cells[r][column] do
		r = r + 1
	end
    return self.rows - r
end

function Grid:addPiece(piece)
    for r = 0, table.maxn(piece.cells) do
        for c = 0, table.maxn(piece.cells[r]) do
            local _r = piece.row + r
            local _c = piece.column + c
            if piece.cells[r][c] and _r >= 0 then
                self.cells[_r][_c] = piece.cells[r][c]
            end
        end
    end
end

function Grid:valid(piece)
    for r = 0, table.maxn(piece.cells) do
        for c = 0, table.maxn(piece.cells[r]) do
            local _r = piece.row + r
            local _c = piece.column + c
            if piece.cells[r][c] then
                if _r < 0 or _r >= self.rows or _c < 0 or _c >= self.columns or self.cells[_r][_c] then
                    return false
                end
            end
        end
    end
    return true
end