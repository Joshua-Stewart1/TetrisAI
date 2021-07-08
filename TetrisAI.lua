local movementByte = 0x0202
local rotationByte = 0x0203
local nextPieceByte = 0x0213

function findNextPiece(nextPiece)
	if(math.floor(nextPiece / 4) == 0) then
		return "L-Block"
	elseif(math.floor(nextPiece / 4) == 1) then
		return "Back-L"
	elseif(math.floor(nextPiece / 4) == 2) then
		return "I-Block"
	elseif(math.floor(nextPiece / 4) == 3) then
		return "Square"
	elseif(math.floor(nextPiece / 4) == 4) then
		return "Z-Block"
	elseif(math.floor(nextPiece / 4) == 5) then
		return "Back-Z"
	elseif(math.floor(nextPiece / 4) == 6) then
		return "T-Block"
	else
		return "Unknown"	
	end
end

function move(row)
	mainmemory.writebyte(movementByte, row)
end

function getCurrentPiece()
	local currentPiece = mainmemory.readbyte(rotationByte)
	return math.floor(currentPiece / 4)
end

function getNextPiece()
	local nextPieceText = mainmemory.readbyte(nextPieceByte)
	return math.floor(nextPieceText / 4)
end


while true do
	local nextPieceText = findNextPiece(mainmemory.readbyte(nextPieceByte))
	gui.drawText(0,30, nextPieceText)
	--move(20);		
	emu.frameadvance();
end


