-- ... giữ nguyên toàn bộ phần trên

-- Hàm chạy vòng quanh mục tiêu + aim
local angle = 0
RunService.Heartbeat:Connect(function(dt)
	if not active then return end
	if not HRP then 
		HRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		Humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	end
	if not HRP or not Humanoid then return end

	local target = getCityNPC()
	if not target or not target:FindFirstChild("HumanoidRootPart") then return end

	local radius = tonumber(radiusBox.Text) or 10
	local speed = tonumber(speedBox.Text) or 3

	local tPos = target.HumanoidRootPart.Position
	local distance = (HRP.Position - tPos).Magnitude

	if distance > radius + 2 then
		-- Chạy tới gần mục tiêu
		Humanoid:MoveTo(tPos)
	else
		-- Chạy vòng tròn và auto aim
		angle += dt * speed
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local movePos = tPos + offset
		Humanoid:MoveTo(movePos)

		-- Tự xoay hướng về mục tiêu (auto aim)
		local lookAt = CFrame.new(HRP.Position, tPos)
		HRP.CFrame = CFrame.new(HRP.Position) * CFrame.Angles(0, math.atan2((tPos - HRP.Position).X, (tPos - HRP.Position).Z), 0)
	end
end)
