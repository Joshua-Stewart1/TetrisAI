AI = {}
 
function AI:new(weights)
	local a = {}
    a.heightWeight = weights.heightWeight
    a.linesWeight = weights.linesWeight
    a.holesWeight = weights.holesWeight
    a.bumpinessWeight = weights.bumpinessWeight
	setmetatable(a, self)
	self.__index = self
	return a
end

function AI:_best(grid, workingPieces, workingPieceIndex)
    local best = nil
    local bestScore = nil
    local workingPiece = workingPieces[workingPieceIndex]
    local newPiece = {}
    for rotation = 0, 3 do
        require "tetrispiece"
        local _piece = workingPiece:clone()
        --print("Row: " .. _piece.row)
        for i = 0, rotation do
            _piece:rotate(grid)
        end
        while _piece:moveLeft(grid) and _piece.column < 0 do 
            --print("Col: " .. _piece.column)
            emu.frameadvance()
        end    
        --print(_piece.row)
        --print(table.maxn(_piece.cells))
        --while grid:valid(_piece) do
            local _pieceSet = _piece:clone()
            while _pieceSet:moveDown(grid) and _pieceSet.row < 18 do 
                --print("Row: " .. _pieceSet.row .. " Grid Row: " .. grid.rows)
                emu.frameadvance()
            end

            local _grid = grid:clone()
            _grid:addPiece(_pieceSet)

            local score = nil
            if workingPieceIndex == table.maxn(workingPieces) then
                score = -self.heightWeight * _grid:aggregateHeight() + self.linesWeight * _grid:lines() - self.holesWeight * _grid:holes() - self.bumpinessWeight * _grid:bumpiness()
                print(score)
            else
                --print("Inside call to recursive function")
                score = self:_best(_grid, workingPieces, workingPieceIndex + 1).score
            end

            if bestScore == nil or score > bestScore then
                print("Inside bestScore")
                bestScore = score
                best = _piece:clone()
            end

            _piece.column = _piece.column + 1;
            emu.frameadvance()
        --end
    end
    newPiece.piece = best
    newPiece.score = bestScore
    return newPiece
end

function AI:best(grid, workingPieces)
    return self:_best(grid, workingPieces, 1).piece
end