
local botText = "Off";
local botActive = false;

while true do

	if joypad.get()["Up"]== true then
		botActive = not botActive
	end

	if botActive then
		botText = "On"

		--Put bot code here

	else
		botText = "Off"
	end

	gui.drawText(25,0, "Bot: "..botText, "Red", "Black")

	emu.frameadvance();

end
