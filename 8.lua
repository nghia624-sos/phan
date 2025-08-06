--// Fix Kavo UI và Fram NPC cho KRNL Mobile

-- Tải UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/UiLib/main/Lib.lua"))()
local Window = Library.CreateLib("TT:dongphandzs1", "Ocean") -- Bạn thích Ocean đúng không?

-- Tạo Tab và Section
local Tab = Window:NewTab("Đánh BOSS")
local Section = Tab:NewSection("Auto Fram Boss")

-- Dịch vụ cần thiết
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

-- Biến điều khiển
local running = false
local autoAttack = false
local radius = 15
local speed = 2
local target = nil

-- Hàm tìm mục tiêu gần nhất
local function getNearest()
	local closest, dist = nil, math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v ~= chr then
			local d = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
			if d < dist then
				dist = d
				closest = v
			end
		end
	end
	return closest
end

-- Tạo các thành phần giao diện
Section:NewToggle("Bật Fram", "Chạy tới và vòng quanh mục tiêu gần nhất", function(state)
	running = state
end)

Section:NewToggle("Auto Đánh", "Tự động đánh khi gần", function(state)
	autoAttack = state
end)

Section:NewSlider("Bán kính vòng", "Khoảng cách quay quanh", 50, 5, function(val)
	radius = val
end)

Section:NewSlider("Tốc độ quay", "Tốc độ vòng quanh mục tiêu", 10, 1, function(val)
	speed = val
end)

local hpLabel = Section:NewLabel("Máu mục tiêu: Chưa có")

-- Vòng lặp xử lý chính
RunService.Heartbeat:Connect(function()
	if not running then return end

	if not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 then
		target = getNearest()
	end

	if target and target:FindFirstChild("HumanoidRootPart") then
		local hp = math.floor(target.Humanoid.Health)
		hpLabel:UpdateLabel("Máu mục tiêu: " .. hp)

		local tickNow = tick()
		local offset = Vector3.new(math.cos(tickNow * speed), 0, math.sin(tickNow * speed)) * radius
		local targetPos = target.HumanoidRootPart.Position + offset
		local moveDir = (targetPos - hrp.Position)

		if moveDir.Magnitude > 1 then
			hrp.CFrame = CFrame.new(hrp.Position + moveDir.Unit * 0.3, target.HumanoidRootPart.Position)
		end

		if autoAttack then
			if (hrp.Position - target.HumanoidRootPart.Position).Magnitude < radius + 2 then
				for _, tool in pairs(lp.Backpack:GetChildren()) do
					if tool:IsA("Tool") then
						tool.Parent = chr
						tool:Activate()
					end
				end
				for _, tool in pairs(chr:GetChildren()) do
					if tool:IsA("Tool") then
						tool:Activate()
					end
				end
			end
		end
	end
end)