--// SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

--// BIẾN
local radius = 15
local speed = 2
local running = false
local currentTarget = nil
local autoAttack = false

--// UI - TT:dongphandzs1 GUI
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = library.CreateLib("TT:dongphandzs1", "Ocean")

local tab = Window:NewTab("Fram")
local section = tab:NewSection("Điều khiển")

section:NewToggle("Bật Fram", "Tìm mục tiêu gần nhất và chạy vòng", function(state)
	running = state
end)

section:NewTextBox("Bán kính vòng (radius)", "Nhập bán kính quay", function(txt)
	local r = tonumber(txt)
	if r then radius = r end
end)

section:NewTextBox("Tốc độ quay (speed)", "Nhập tốc độ vòng", function(txt)
	local s = tonumber(txt)
	if s then speed = s end
end)

section:NewToggle("Auto Đánh", "Tự động đánh khi gần mục tiêu", function(state)
	autoAttack = state
end)

local hpLabel = section:NewLabel("Máu mục tiêu: Không có")

--// HÀM TÌM MỤC TIÊU GẦN NHẤT
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

--// VÒNG LẶP
RunService.Heartbeat:Connect(function()
	if not running then return end

	if not currentTarget or not currentTarget:FindFirstChild("HumanoidRootPart") or currentTarget:FindFirstChild("Humanoid").Health <= 0 then
		currentTarget = getNearestTarget()
	end

	if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
		-- Cập nhật máu
		local hp = math.floor(currentTarget.Humanoid.Health)
		hpLabel:UpdateLabel("Máu mục tiêu: " .. hp)

		-- Tính vị trí vòng tròn
		local angle = tick() * speed
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local targetPos = currentTarget.HumanoidRootPart.Position + offset

		-- Di chuyển
		local direction = (targetPos - hrp.Position)
		if direction.Magnitude > 1 then
			local moveStep = direction.Unit * math.min(direction.Magnitude, 0.4)
			hrp.CFrame = CFrame.new(hrp.Position + moveStep, currentTarget.HumanoidRootPart.Position)
		end

		-- Tự động đánh
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