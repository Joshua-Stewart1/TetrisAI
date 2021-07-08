
--Move piece
function move (curPos, endPos)

	local dir = (curPos > endPos);
	local distance = 0;

	if(dir) then
		joypad.set({Left=true})
		distance = curPos - endPos
	else
		joypad.set({Right=true})
		distance = endPos - curPos
	end

	for i = distance,1,-1 do

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
	local rotations = 0;

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
local botActive = false;

local x = 0;
local y = 3;

while true do

	if joypad.get()["Up"]== true then
		botActive = not botActive
		emu.frameadvance();
		emu.frameadvance();
		emu.frameadvance();
		emu.frameadvance();
		emu.frameadvance();
	end

	if botActive then
		botText = "On"

		if(x ~= y) then
			move(x,y)
			x = y
		end

	else
		botText = "Off"
		x = 0;
	end

	gui.drawText(25,0, "Bot: "..botText, "Red", "Black")

	emu.frameadvance();

end
