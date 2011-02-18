
--[[     Sticky Channels     ]]--

local _, f = ...
f.functions[#f.functions+1] = function()
	if bcmDB.BCM_Sticky then return end

	if not bcmDB.sticky then 
		bcmDB.sticky = {}
		bcmDB.sticky.EMOTE = 1
		bcmDB.sticky.YELL = 1
		bcmDB.sticky.RAID_WARNING = 1
	end

	for k, v in pairs(bcmDB.sticky) do
		if ChatTypeInfo[k].sticky == v then bcmDB.sticky[k] = nil end --remove entries that are blizz defaults
		ChatTypeInfo[k].sticky = v
	end
end

