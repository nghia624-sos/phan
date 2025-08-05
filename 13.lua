--// DỊCH VỤ
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local mouse = lp:GetMouse()

--// BIẾN TOÀN CỤC
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")
local target = nil
local framEnabled = false
local moveCircleEnabled = false
local radius = 20
local speed = 2

--// GUI
local ScreenGui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
ScreenGui.Name = "NghiaMinhGUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 250)
Frame.Position = UDim2.new(0, 100, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.Active = true
Frame.Draggable = true

local uilist = Instance.new("UIListLayout", Frame)
uilist.SortOrder = Enum.SortOrder.LayoutOrder
uilist.Padding = UDim.new(0, 5)

local title = Instance.new("TextLabel", Frame)
title.Text = "Nghia Minh Menu"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
title.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Helper tạo nút
local function createButton(text, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Text = text
	btn.Parent = Frame
	btn.MouseButton1Click:Connect(callback)
	return btn
end

-- Tìm mục tiêu gần nhất
local function findNearestTarget()
	local closest, dist = nil, math.huge
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
			local name = v.Name:lower()
			if name:find("citynpc") or name:find("npcity") then
				local d = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
				if d < dist then
					closest = v
					dist = d
				end
			end
		end
	end
	return closest
end

-- Chạy đến mục tiêu
local function moveToTarget()
	if not target or not target:FindFirstChild("HumanoidRootPart") then return end
	hum:MoveTo(target.HumanoidRootPart.Position)
end

-- Chạy vòng quanh mục tiêu
local angle = 0
RunService.Heartbeat:Connect(function(dt)
	if moveCircleEnabled and target and target:FindFirstChild("HumanoidRootPart") then
		local rootPos = target.HumanoidRootPart.Position
		angle += speed * dt
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local goalPos = rootPos + offset

		hum:MoveTo(goalPos)

		-- Quay mặt về mục tiêu
		local lookVector = (rootPos - hrp.Position).Unit
		hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + lookVector)
	end
end)

-- Nút bật Fram (chạy đến mục tiêu)
createButton("Bật Fram", function()
	framEnabled = not framEnabled
	if framEnabled then
		task.spawn(function()
			while framEnabled do
				target = findNearestTarget()
				if target then
					local distance = (target.HumanoidRootPart.Position - hrp.Position).Magnitude
					if distance > radius + 5 then
						hum:MoveTo(target.HumanoidRootPart.Position)
						repeat
							task.wait(0.1)
						until not framEnabled or (target.HumanoidRootPart.Position - hrp.Position).Magnitude <= radius + 5
					end
				end
				wait(1)
			end
		end)
	end
end)

-- Nút chạy vòng quanh mục tiêu
createButton("Chạy vòng tròn + Auto Đánh", function()
	moveCircleEnabled = not moveCircleEnabled
end)

-- Nhập bán kính
local radiusBox = Instance.new("TextBox", Frame)
radiusBox.PlaceholderText = "Bán kính vòng (default 20)"
radiusBox.Text = ""
radiusBox.Size = UDim2.new(1, 0, 0, 30)
radiusBox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
radiusBox.TextColor3 = Color3.fromRGB(255, 255, 255)
radiusBox.FocusLost:Connect(function()
	local val = tonumber(radiusBox.Text)
	if val then radius = val end
end)

-- Nhập tốc độ quay
local speedBox = Instance.new("TextBox", Frame)
speedBox.PlaceholderText = "Tốc độ quay (default 2)"
speedBox.Text = ""
speedBox.Size = UDim2.new(1, 0, 0, 30)
speedBox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.FocusLost:Connect(function()
	local val = tonumber(speedBox.Text)
	if val then speed = val end
end)