--// Kavo UI
local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/UiLib/main/Lib.lua"))()
local Window = Kavo.CreateLib("TT:dongphandzs1", "Ocean")

--// Tab & Section
local MainTab = Window:NewTab("Đánh BOSS")
local MainSection = MainTab:NewSection("Auto Fram & Tùy chỉnh")

--// Dịch vụ
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

--// Biến
local radius = 15
local speed = 2
local running = false
local autoAttack = false
local currentTarget = nil

--// Hàm tìm mục tiêu gần nhất
function getNearestTarget()
	local nearest, shortest = nil, math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v ~= chr then
			local mag = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
			if mag < shortest then
				shortest = mag
				nearest = v
			end
		end
	end
	return nearest
end

--// Các nút giao diện
MainSection:NewToggle("Bật Fram", "Chạy tới và quay vòng quanh mục tiêu gần nhất", function(bool)
	running = bool
end)

MainSection:NewToggle("Auto Đánh", "Tự động đánh khi gần mục tiêu", function(bool)
	autoAttack = bool
end)

MainSection:NewSlider("Bán kính quay", "Khoảng cách quay quanh mục tiêu", 50, 5, function(val)
	radius = val
end)

MainSection:NewSlider("Tốc độ quay", "Tốc độ di chuyển vòng quanh", 10, 1, function(val)
	speed = val
end)

local healthLabel = MainSection:NewLabel("Máu mục tiêu: Không có")

--// Vòng lặp Fram + Auto Đánh + Cập nhật máu
RunService.Heartbeat:Connect(function()
	if not running then return end

	if not currentTarget or not currentTarget:FindFirstChild("Humanoid") or currentTarget.Humanoid.Health <= 0 then
		currentTarget = getNearestTarget()
	end

	if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
		local hp = math.floor(currentTarget.Humanoid.Health)
		healthLabel:UpdateLabel("Máu mục tiêu: " .. hp)

		local angle = tick() * speed
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local targetPos = currentTarget.HumanoidRootPart.Position + offset
		local direction = (targetPos - hrp.Position)
		if direction.Magnitude > 1 then
			local moveStep = direction.Unit * math.min(direction.Magnitude, 0.4)
			hrp.CFrame = CFrame.new(hrp.Position + moveStep, currentTarget.HumanoidRootPart.Position)
		end

		if autoAttack then
			local dist = (hrp.Position - currentTarget.HumanoidRootPart.Position).Magnitude
			if dist <= radius + 2 then
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