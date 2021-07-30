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

    for rotation = 0, 3 do
        require "tetrispiece"
        local _piece = workingPiece:clone()
        for i = 0, rotation - 1 do
            _piece:rotate(grid)
        end

        while (_piece:moveLeft(grid)) do end    

        while (grid.valid(_piece)) do
            local _pieceSet = _piece:clone()
            while (_pieceSet:moveDown(grid)) do end

            local _grid = grid:clone()
            _grid:addPiece(_pieceSet)

            local score = nil
            if workingPieceIndex == table.maxn(workingPieces) then
                score = -self.heightWeight * _grid:aggregateHeight() + self.linesWeight * _grid:lines() - self.holesWeight * _grid:holes() - self.bumpinessWeight * _grid:bumpiness()
            else
                score = self:_best(_grid, workingPieces, workingPieceIndex + 1).score
            end

            if (score > bestScore or bestScore == nil) then
                bestScore = score
                best = _piece:clone()
            end

            _piece.column = _piece.column + 1;
        end
    end

    return {piece = best, score = bestScore}
end

function AI:best(grid, workingPieces)
    return self:_best(grid, workingPieces, 0).piece
end