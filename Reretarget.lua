local function feigning()
	local i, buff = 1, nil
	repeat
		buff = UnitBuff('target', i)
		if buff == [[Interface\Icons\Ability_Rogue_FeignDeath]] 
		or buff == [[Interface\Icons\Ability_Stealth]] 
		or buff == [[Interface\Icons\Ability_Ambush]] then
			return true
		end
		i = i + 1
	until not buff
	return UnitIsPlayer('target') and UnitCanAttack('player', 'target')
end

local unit, dead, lost
local pass = function() end

CreateFrame'Frame':SetScript('OnUpdate', function()
	local target = UnitName('target')

	-- Store hostile player target
	if target and UnitIsPlayer('target') and UnitCanAttack('player', 'target') then
		unit, dead, lost = target, UnitIsDead('target'), false

	-- Clear memory if targeting anything else
	elseif target and target ~= unit then
		unit, dead, lost = nil, false

	elseif unit then
		-- Attempt to reacquire lost player
		local _PlaySound, _UIErrorsFrame_OnEvent = PlaySound, UIErrorsFrame_OnEvent
		PlaySound, UIErrorsFrame_OnEvent = lost and PlaySound or pass, pass
		TargetByName(unit, true)
		PlaySound, UIErrorsFrame_OnEvent = _PlaySound, _UIErrorsFrame_OnEvent

		if UnitExists('target') then
			-- 🔧 NEW: Duel-end fix — forget target if it's no longer hostile
			if UnitName('target') == unit and not UnitCanAttack('player', 'target') then
				unit, lost = nil, false
				return
			end

			if not (lost or (not dead and UnitIsDead('target') and feigning())) then
				ClearTarget()
				if UnitIsPlayer('target') and not UnitIsDead('target') and UnitCanAttack('player', 'target') then
					unit, lost = nil, false
				end
			end
		else
			lost = true
		end
	end
end)