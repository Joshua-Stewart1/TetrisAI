local movementByte = 0x0202
local rotationByte = 0x0203
local nextPieceByte = 0x0213
g = {}

I = {{{true, true, true, true}}, {{true}, {true}, {true}, {true}}}
O = {{{true, true}, {true, true}}}
T = {{{true, true, true}, {false, true, false}}, {{true, false}, {true, true}, {true, false}}, {{false, true, false}, {true, true, true}}, {{false, true}, {true, true}, {false, true}}}
J = {{{true, true, true}, {false, false, true}}, {{false, true}, {false, true}, {true, true}}, {{true, false, false}, {true, true, true}}, {{true, true}, {true, false}, {true, false}}}
L = {{{true, true, true}, {true, false, false}}, {{true, false}, {true, false}, {true, true}}, {{false, false, true}, {true, true, true}}, {{true, true}, {false, true}, {false, true}}}
S = {{{false, true, true}, {true, true, false}}, {{true, false}, {true, true}, {false, true}}}
Z = {{{true, true, false}, {false, true, true}}, {{false, true}, {true, true}, {true, false}}}

--



function canFit(grid, block, row, col)
	--print("Row " .. row .. " Col: " .. col)
	for i, r in ipairs(block) do
		for j, c in ipairs(block[i]) do
			if block[i][j] and grid[i + row][j + col] then
				return true
			end
		end
	end
	return false
end

function removeFullRows(grid, cols)
	for i, row in ipairs(grid) do
		if sumRow(row) == cols then
			table.remove(grid, i)
			local a = {}
			for j = 1, cols do
				a[j] = false	
			end
			table.insert(grid, 1, a)
		end 	
	end
end

function drop(grid, block, col)
	local row = 0
	while row + table.maxn(block) < table.maxn(grid) and canFit(grid, block, row + 1, col) do
		row = row + 1
	end
	for i, r in ipairs(block) do
		for j, c in ipairs(block[i]) do
			grid[i + row][j + col] = grid[i + row][j + col] or block[i][j]
		end
	end
	removeFullRows(grid, table.maxn(grid[1]))
end

function sumRow(row)
	local x = 0
	for i, c in ipairs(row) do
		x = x + (row[i] and 1 or 0)
	end
	return x
end

function sumCol(grid, col) 
	local x = 0
	for i, row in ipairs(grid) do
		x = x + (row[col] and 1 or 0)
	end
	return x
end

function holes(grid) 
	local x = 0
	for i, col in ipairs(grid[1]) do
		for j, row in ipairs(grid) do
			if row[i] then
				x = x + table.maxn(grid) - j - sumCol(grid, i)
				break
			end
		end
	end
	return x
end

function best(grid, block) 
	local x = {0, 0, grid}
	local y = 10000
	for i, rot in ipairs(block) do
		for c = 1, table.maxn(grid) - table.maxn(rot), 1 do
			local a = grid
			drop(a, rot, c)
			local z = 0
			while (z < table.maxn(a)) and (sumRow(a[table.maxn(a) - z]) > 0) do z = z + 1 end
			z = z + holes(a) * 10
			if z < y then
				y = z
				x = {c, i, a}
			end
		end
	end
	return x
end

function getCurrentPiece()
	local currentPiece = mainmemory.readbyte(rotationByte)
	return math.floor(currentPiece / 4)
end

function getNextPiece()
	local nextPieceText = mainmemory.readbyte(nextPieceByte)
	return math.floor(nextPieceText / 4)
end

function blockNumToBlockArray(blockNum)
	if(blockNum == 0) then
		return L
	elseif(blockNum == 1) then
		return J
	elseif(blockNum == 2) then
		return I
	elseif(blockNum == 3) then
		return O
	elseif(blockNum == 4) then
		return Z
	elseif(blockNum == 5) then
		return S
	elseif(blockNum == 6) then
		return T
	else
		return {{-1}}	
	end
end

--Move piece
function move (curPos, endPos)

	local dir = (curPos > endPos)
	local distance = 0

	if(dir) then
		joypad.set({Left=true})
		distance = curPos - endPos
	else
		joypad.set({Right=true})
		distance = endPos - curPos
	end

	for i = distance,0,-1 do

		if(dir) then
			joypad.set({Left=true})
		else
			joypad.set({Right=true})
		end

		emu.frameadvance();

		joypad.set({Right=false, Left=false})

		emu.frameadvance();
	end

	return nil
end

--Rotate piece
function rotate (curPos, endPos)

	local dir = (curPos > endPos);
	local rotations = 0

	if(dir) then
		joypad.set({A=true})
		rotations = curPos - endPos
	else
		joypad.set({B=true})
		rotations = endPos - curPos
	end

	for i = rotations,1,-1 do

		if(dir) then
			joypad.set({A=true})
		else
			joypad.set({B=true})
		end

		emu.frameadvance();

		joypad.set({A=false, B=false})

		emu.frameadvance();
	end

	return nil
end

local botText = "Off";
local botActive = true;
for i=1,18 do
	g[i] = {}    
	for j=1,10 do
	  g[i][j] = false
	end
end

local currPos = 3
local targetPos
local currRot = 1
local targetRot
local currPiece = nil
local output

require "tuner"
require "tetrispiece"
require "tetrisai_"
require "tetrisgrid"

local grid = Grid:new(18, 10)
local weights = {}
weights.heightWeight = 0.510066
weights.linesWeight = 0.760666
weights.holesWeight = 0.35663
weights.bumpinessWeight = 0.184483
local ai = AI:new(weights)
local workingPieces = {nil, Piece:fromIndex(getCurrentPiece())}

--tune()

function startTurn()
	for i = 1, table.maxn(workingPieces) do
		--print("in here")
		workingPieces[i] = workingPieces[i+1]
	end
	--print(getCurrentPiece())
	workingPieces[2] = Piece:fromIndex(getNextPiece())
	workingPiece = workingPieces[0]
	--print(table.maxn(workingPieces[table.maxn(workingPieces)].cells))
	--print(getNextPiece())
	--workingPieces[1]:clone()
	--workingPieces[2]:clone()
	workingPiece = ai:best(grid, workingPieces)
	--while workingPiece:moveDown(grid) do end
	grid:addPiece(workingPiece)
	print("Col: " .. workingPiece.column)
	print("Rots: " .. workingPiece.rotations)
	move(currPos, workingPiece.column)
	rotate(currRot, workingPiece.rotations)
end

while true do

	if joypad.get()["Up"] == true then
		botActive = not botActive
		emu.frameadvance();
		emu.frameadvance();
		emu.frameadvance(); 	
		emu.frameadvance();
		emu.frameadvance();
	end

	if botActive then
		botText = "On"

		if currPiece ~= getCurrentPiece() then
			currPos = 3
			currRot = 1
			currPiece = getCurrentPiece()
			startTurn()
		end

	else
		botText = "Off"
		x = 0
	end

	gui.drawText(25,0, "Bot: "..botText, "Red", "Black")

	emu.frameadvance();

end
