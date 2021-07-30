Piece = {}

function Piece:new(cells)
    local p = {}
	p.cells = cells
    p.dimension = table.maxn(p.cells) + 1
    p.row = 0
    p.column = 0
	setmetatable(p, self)
	self.__index = self
	return p
end

function Piece.fromIndex(index)
    local cells = {};
	cells[0] = {}
	cells[1] = {}
	cells[2] = {}
    if (index == 0) then
		cells[0][0] = true
		cells[0][1] = true
		cells[1][0] = true
		cells[1][1] = true
		cells[2] = nil
	elseif (index == 1) then
		cells[0][0] = true
		cells[0][1] = false
		cells[0][2] = false
		cells[1][0] = true
		cells[1][1] = true
		cells[1][2] = true
		cells[2][0] = false
		cells[2][1] = false
		cells[2][2] = false
	elseif (index == 2) then
		cells[0][0] = false
		cells[0][1] = false
		cells[0][2] = true
		cells[1][0] = true
		cells[1][1] = true
		cells[1][2] = true
		cells[2][0] = false
		cells[2][1] = false
		cells[2][2] = false
	elseif (index == 3) then
		cells[0][0] = true
		cells[0][1] = true
		cells[0][2] = false
		cells[1][0] = false
		cells[1][1] = true
		cells[1][2] = true
		cells[2][0] = false
		cells[2][1] = false
		cells[2][2] = false
	elseif (index == 4) then
		cells[0][0] = false
		cells[0][1] = true
		cells[0][2] = true
		cells[1][0] = true
		cells[1][1] = true
		cells[1][2] = false
		cells[2][0] = false
		cells[2][1] = false
		cells[2][2] = false
	elseif (index == 5) then
		cells[0][0] = false
		cells[0][1] = true
		cells[0][2] = false
		cells[1][0] = true
		cells[1][1] = true
		cells[1][2] = true
		cells[2][0] = false
		cells[2][1] = false
		cells[2][2] = false
	elseif (index == 6) then
		cells[0][0] = false
		cells[0][1] = false
		cells[0][2] = false
		cells[0][3] = false
		cells[1][0] = true
		cells[1][1] = true
		cells[1][2] = true
		cells[1][3] = true
		cells[2][0] = false
		cells[2][1] = false
		cells[2][2] = false
		cells[2][3] = false
		cells[3] = {}
		cells[3][0] = false
		cells[3][1] = false
		cells[3][2] = false
		cells[3][3] = false
	end
	local piece = Piece:new(cells)
    piece.row = 0
    piece.column = math.floor((10 - piece.dimension) / 2)
    return piece
end

function Piece:clone()
    local _cells = {}
    for r = 0, self.dimension - 1 do
        _cells[r] = {}
        for c = 0, self.dimension - 1 do
            _cells[r][c] = self.cells[r][c]
        end
    end

    local piece = Piece:new(_cells)
    piece.row = self.row
    piece.column = self.column
    return piece
end

function Piece:canMoveLeft(grid)
    for r = 0, table.maxn(self.cells) - 1 do
        for c = 0, table.maxn(self.cells[r]) - 1 do
            local _r = self.row + r
            local _c = self.column + c - 1
            if self.cells[r][c] then
                if _c < 0 or grid.cells[_r][_c] then
                    return false
                end
            end
        end
    end
    return true
end

function Piece:canMoveRight(grid)
    for r = 0, table.maxn(self.cells) - 1 do
        for c = 0, table.maxn(self.cells[r]) - 1 do
            local _r = self.row + r
            local _c = self.column + c + 1
            if self.cells[r][c] then
                if _c >= grid.columns or grid.cells[_r][_c] then
                    return false
                end
            end
        end
    end
    return true
end

function Piece:canMoveDown(grid)
    for r = 0, table.maxn(self.cells) - 1 do
        for c = 0, table.maxn(self.cells[r]) - 1 do
            local _r = self.row + r + 1
            local _c = self.column + c
            if self.cells[r][c] then
                if r >= grid.rows or grid.cells[_r][_c] then
                    return false
                end
            end
        end
    end
    return true
end

function Piece:moveLeft(grid)
    if not self.canMoveLeft(grid) then
        return false
    end
    self.column = self.column - 1
    return true
end

function Piece:moveRight(grid)
    if not self.canMoveRight(grid) then
        return false
    end
    self.column = self.column + 1
    return true
end

function Piece:moveDown(grid)
    if not self.canMoveDown(grid) then
        return false
    end
    self.row = self.row + 1
    return true
end

function Piece:rotateCells()
	local _cells = {}
	for r = 0, self.dimension - 1 do
		_cells[r] = {}
	end

    if (self.dimension == 2) then
		_cells[0][0] = self.cells[1][0]
		_cells[0][1] = self.cells[0][0]
		_cells[1][0] = self.cells[1][1]
		_cells[1][1] = self.cells[0][1]
	elseif (self.dimension == 3) then
		_cells[0][0] = self.cells[2][0]
		_cells[0][1] = self.cells[1][0]
		_cells[0][2] = self.cells[0][0]
		_cells[1][0] = self.cells[2][1]
		_cells[1][1] = self.cells[1][1]
		_cells[1][2] = self.cells[0][1]
		_cells[2][0] = self.cells[2][2]
		_cells[2][1] = self.cells[1][2]
		_cells[2][2] = self.cells[0][2]
	elseif (self.dimension == 4) then
		_cells[0][0] = self.cells[3][0]
		_cells[0][1] = self.cells[2][0]
		_cells[0][2] = self.cells[1][0]
		_cells[0][3] = self.cells[0][0]
		_cells[1][3] = self.cells[0][1]
		_cells[2][3] = self.cells[0][2]
		_cells[3][3] = self.cells[0][3]
		_cells[3][2] = self.cells[1][3]
		_cells[3][1] = self.cells[2][3]
		_cells[3][0] = self.cells[3][3]
		_cells[2][0] = self.cells[3][2]
		_cells[1][0] = self.cells[3][1]
		_cells[1][1] = self.cells[2][1]
		_cells[1][2] = self.cells[1][1]
		_cells[2][2] = self.cells[1][2]
		_cells[2][1] = self.cells[2][2]
	end

	self.cells = _cells
end

function Piece:computeRotateOffset(grid)
    local _piece = self.clone()
    _piece.rotateCells()
    if (grid.valid(_piece)) then
        return { _piece.row - self.row, _piece.column - self.column }
    end

    local initialRow = _piece.row;
    local initialCol = _piece.column;

    for i = 0, _piece.dimension - 2 do
        _piece.column = initialCol + i
        if (grid.valid(_piece)) then
            return {  _piece.row - self.row, _piece.column - self.column }
        end

        for j = 0, _piece.dimension - 2 do
            _piece.row = initialRow - j
            if (grid.valid(_piece)) then
                return {  _piece.row - self.row, _piece.column - self.column }
            end
        end
        _piece.row = initialRow
    end
    _piece.column = initialCol

    for i = 0, _piece.dimension - 2 do
        _piece.column = initialCol - i
        if (grid.valid(_piece)) then
            return { _piece.row - self.row, _piece.column - self.column }
        end

        for j = 0, _piece.dimension - 2 do
            _piece.row = initialRow - j
            if (grid.valid(_piece)) then
                return { _piece.row - self.row, _piece.column - self.column }
            end
        end
        _piece.row = initialRow
    end
    _piece.column = initialCol

    return nil
end

function Piece:rotate(grid)
    local offset = self.computeRotateOffset(grid)
    if (offset ~= nil) then
        self.rotateCells()
        self.row = self.row + offset.rowOffset
        self.column = self.column + offset.columnOffset
    end
end