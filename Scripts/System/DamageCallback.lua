Client.damageCallback = function(b, damage, skillDataID)
	-- 피격 유닛의 초기 검사
	if not b or damage < 1 then
		return 0
	end

	local findUnit = b
	local power = rand(-5, 6)
	-- 진동 효과
	findUnit.DOPunch(Point(power, power), 0.2, 5, 0)

	-- 색상 효과
	local redColor = Color(255, 0, 0)
	local whiteColor = Color(255, 255, 255)
	findUnit.DOColor(redColor, 0.1).OnComplete(
		function()
			findUnit.DOColor(whiteColor, 0.1)
		end
	)

	return damage
end
