
--[[     History Module     ]]--

local _, BCM = ...
BCM.earlyModules[#BCM.earlyModules+1] = function()
	if bcmDB.BCM_History then bcmDB.lines, bcmDB.savedChat = nil, nil end

	if not bcmDB.lines then bcmDB.lines = {["ChatFrame1"] = 1000} end
	for k, v in next, bcmDB.lines do
		local f = _G[k]
		f:SetMaxLines(v)
		if k == "ChatFrame2" then
			COMBATLOG_MESSAGE_LIMIT = v -- Blizzard keeps changing the combat log max lines in Blizzard_CombatLog_Refilter... this better not taint.
		end
	end

	if true and bcmDB.savedChat then
		for k, v in next, bcmDB.savedChat do
			local cF = _G[k]
			if cF then
				local buffer = cF.historyBuffer
				local num = buffer.headIndex
				local prevElements = buffer.elements
				buffer:ReplaceElements(v) -- We want the chat history to show first, so replace all current chat
				-- Add our little notifications
				buffer:PushBack({message = "|cFF33FF99BasicChatMods|r: ---Begin chat restore---", timestamp = GetTime()})
				buffer:PushFront({message = "|cFF33FF99BasicChatMods|r: ---Chat restored from reload---", timestamp = GetTime()})
				for i = 1, num do -- Restore any early chat we removed (usually addon prints)
					local element = prevElements[i]
					buffer:PushFront(element)
				end
			end
		end
	end
	bcmDB.savedChat = nil

	if true then -- XXX add an option
		local isReloadingUI = 0

		BCM.Events.PLAYER_LOGOUT = function()
			if (GetTime() - isReloadingUI) > 2 then return end

			bcmDB.savedChat = {}
			for cfNum = 1, BCM.chatFrames do
				if i ~= 2 then -- No combat log
					local name = ("ChatFrame%d"):format(cfNum)
					local cf = _G[name]
					if cf then
						local tbl = {1, 2, 3, 4, 5}
						local num = cf.historyBuffer.headIndex
						local tblCount = 5
						for i = num, -10, -1 do
							if i > 0 then
								if cf.historyBuffer.elements[i] then -- Compensate for nil entries
									tbl[tblCount] = cf.historyBuffer.elements[i]
									tblCount = tblCount - 1
									if tblCount == 0 then
										break
									end
								end
							else -- Compensate for less than 5 lines of history
								if tblCount > 0 then
									tremove(tbl, tblCount)
									tblCount = tblCount - 1
								else
									break
								end
							end
						end
						if #tbl > 0 then
							bcmDB.savedChat[name] = tbl
						end
					end
				end
			end
		end
		BCM.Events:RegisterEvent("PLAYER_LOGOUT")

		BCM.Events.LOADING_SCREEN_ENABLED = function()
			isReloadingUI = GetTime()
		end
		BCM.Events:RegisterEvent("LOADING_SCREEN_ENABLED")
	end
end

