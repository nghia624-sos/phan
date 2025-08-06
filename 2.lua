--// Dịch vụ
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

--// Biến
local running = false
local radius = 15
local speed = 2
local guiVisible = true
local target
local currentHealth = 0
local maxHealth = 0

--// Tìm boss gần nhất (tên chứa "boss", không phân biệt hoa thường)
local function getClosestBoss()
	local minDist = math.huge
	local closest
	for _, v in pairs(workspace:GetDescendants()) do
		if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
			local name = v.Name:lower()
			if name:find("boss") then
				local dist = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
				if dist < minDist then
					minDist = dist
					closest = v
				end
			end
		end
	end
	return closest
end

--// Teleport đến mục tiêu an toàn
local function safeTeleport(pos)
	chr:PivotTo(CFrame.new(pos + Vector3.new(0, 5, 0)))
end

--// Giao diện
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.ResetOnSpawn = false

local openBtn = Instance.new("TextButton", ScreenGui)
openBtn.Size = UDim2.new(0, 100, 0, 30)
openBtn.Position = UDim2.new(0, 10, 0.5, -15)
openBtn.Text = "TT:dongphandzs1"
openBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
openBtn.TextColor3 = Color3.new(1, 1, 1)
openBtn.Visible = true
openBtn.Active = true
openBtn.Draggable = true

--// Menu chính
local main = Instance.new("Frame", ScreenGui)
main.Size = UDim2.new(0, 350, 0, 230)
main.Position = UDim2.new(0.5, -175, 0.5, -115)
main.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
main.Visible = false
main.Active = true
main.Draggable = true

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "TT:dongphandzs1"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

local toggle = Instance.new("TextButton", main)
toggle.Size = UDim2.new(0, 150, 0, 30)
toggle.Position = UDim2.new(0, 10, 0, 40)
toggle.Text = "Đánh BOSS (Tắt)"
toggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
toggle.TextColor3 = Color3.new(1, 1, 1)

local radiusBox = Instance.new("TextBox", main)
radiusBox.Size = UDim2.new(0, 150, 0, 30)
radiusBox.Position = UDim2.new(0, 10, 0, 80)
radiusBox.PlaceholderText = "Bán kính (vd: 15)"
radiusBox.ClearTextOnFocus = false

local speedBox = Instance.new("TextBox", main)
speedBox.Size = UDim2.new(0, 150, 0, 30)
speedBox.Position = UDim2.new(0, 10, 0, 120)
speedBox.PlaceholderText = "Tốc độ quay (vd: 2)"
speedBox.ClearTextOnFocus = false

local healthLabel = Instance.new("TextLabel", main)
healthLabel.Size = UDim2.new(1, -20, 0, 30)
healthLabel.Position = UDim2.new(0, 10, 0, 170)
healthLabel.TextColor3 = Color3.new(1, 0, 0)
healthLabel.Text = "Máu BOSS: Không có"
healthLabel.BackgroundTransparency = 1

local hideBtn = Instance.new("TextButton", main)
hideBtn.Size = UDim2.new(0, 150, 0, 30)
hideBtn.Position = UDim2.new(0, 180, 0, 40)
hideBtn.Text = "Ẩn Menu"
hideBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
hideBtn.TextColor3 = Color3.new(1, 1, 1)

--// Giao diện
openBtn.MouseButton1Click:Connect(function()
	guiVisible = not guiVisible
	main.Visible = guiVisible
end)

hideBtn.MouseButton1Click:Connect(function()
	main.Visible = false
	guiVisible = false
end)

--// Fram Boss Logic
toggle.MouseButton1Click:Connect(function()
	running = not running
	toggle.Text = running and "Đánh BOSS (Bật)" or "Đánh BOSS (Tắt)"

	if running then
		if tonumber(radiusBox.Text) then radius = tonumber(radiusBox.Text) end
		if tonumber(speedBox.Text) then speed = tonumber(speedBox.Text) end

		target = getClosestBoss()
		if target then
			safeTeleport(target.HumanoidRootPart.Position)
		end
	end
end)

--// Tự động fram boss
task.spawn(function()
	while true do
		task.wait(0.1)
		if running then
			-- Nếu không còn boss hoặc boss đã chết thì tìm boss mới
			if not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 then
				target = getClosestBoss()
				if target then
					safeTeleport(target.HumanoidRootPart.Position)
				end
			end

			-- Nếu có mục tiêu
			if target and target:FindFirstChild("HumanoidRootPart") then
				-- Quay quanh boss
				local tickAngle = tick() * speed
				local offset = Vector3.new(math.cos(tickAngle) * radius, 0, math.sin(tickAngle) * radius)
				local movePos = target.HumanoidRootPart.Position + offset
				hum:MoveTo(movePos)

				-- Quay mặt về boss
				hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(
					target.HumanoidRootPart.Position.X,
					hrp.Position.Y,
					target.HumanoidRootPart.Position.Z
				))

				-- Tự đánh
				local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
				if tool then tool:Activate() end
			end
		end
	end
end)

--// Theo dõi máu mục tiêu
RunService.RenderStepped:Connect(function()
	if running and target and target:FindFirstChild("Humanoid") then
		currentHealth = math.floor(target.Humanoid.Health)
		maxHealth = math.floor(target.Humanoid.MaxHealth)
		healthLabel.Text = "Máu BOSS: " .. currentHealth .. "/" .. maxHealth
	else
		healthLabel.Text = "Máu BOSS: Không có"
	end
end)