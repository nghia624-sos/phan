-- TT:dongphandzs1 - Fram CityNPC (Fixed Version)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

local target = nil
local framEnabled = false
local radius = 10
local speed = 2
local guiOpen = true

-- Tìm NPC chứa từ "citynpc"
local function findTarget()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
			if string.lower(v.Name):find("citynpc") then
				return v
			end
		end
	end
	return nil
end

-- Tự động di chuyển và chạy vòng quanh
local angle = 0
RunService:UnbindFromRenderStep("FramLoop")
RunService:BindToRenderStep("FramLoop", Enum.RenderPriority.Character.Value + 1, function(dt)
	if framEnabled and target and target:FindFirstChild("Humanoid") and target:FindFirstChild("HumanoidRootPart") and target.Humanoid.Health > 0 then
		angle += dt * speed
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local goalPos = target.HumanoidRootPart.Position + offset
		hum:MoveTo(goalPos)

		-- Quay hướng & đánh
		local dir = (target.HumanoidRootPart.Position - hrp.Position).Unit
		hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + dir)
		mouse1click()
	end
end)

-- Theo dõi mục tiêu
task.spawn(function()
	while task.wait(0.3) do
		if framEnabled then
			if not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 then
				target = findTarget()
			end
		end
	end
end)

-- Giao diện đơn giản
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FramCityNPC_GUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 320, 0, 300)
frame.Position = UDim2.new(0.5, -160, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local uilist = Instance.new("UIListLayout", frame)
uilist.Padding = UDim.new(0, 6)
uilist.FillDirection = Enum.FillDirection.Vertical
uilist.HorizontalAlignment = Enum.HorizontalAlignment.Center
uilist.VerticalAlignment = Enum.VerticalAlignment.Top

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "🧠 TT:dongphandzs1 - Fram CityNPC"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextScaled = true

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1, -20, 0, 40)
toggle.Text = "🔁 Bật Fram"
toggle.Font = Enum.Font.GothamBold
toggle.TextScaled = true
toggle.TextColor3 = Color3.new(1,1,1)
toggle.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
toggle.MouseButton1Click:Connect(function()
	framEnabled = not framEnabled
	toggle.Text = framEnabled and "✅ Đang Fram" or "🔁 Bật Fram"
	toggle.BackgroundColor3 = framEnabled and Color3.fromRGB(150, 50, 50) or Color3.fromRGB(50, 150, 50)
end)

local radiusSlider = Instance.new("TextBox", frame)
radiusSlider.Size = UDim2.new(1, -20, 0, 30)
radiusSlider.PlaceholderText = "Bán kính vòng quanh (mặc định 10)"
radiusSlider.Text = ""
radiusSlider.TextScaled = true
radiusSlider.Font = Enum.Font.Gotham
radiusSlider.TextColor3 = Color3.new(1,1,1)
radiusSlider.BackgroundColor3 = Color3.fromRGB(40,40,40)
radiusSlider.FocusLost:Connect(function()
	local val = tonumber(radiusSlider.Text)
	if val then radius = val end
end)

local speedSlider = Instance.new("TextBox", frame)
speedSlider.Size = UDim2.new(1, -20, 0, 30)
speedSlider.PlaceholderText = "Tốc độ quay (mặc định 2)"
speedSlider.Text = ""
speedSlider.TextScaled = true
speedSlider.Font = Enum.Font.Gotham
speedSlider.TextColor3 = Color3.new(1,1,1)
speedSlider.BackgroundColor3 = Color3.fromRGB(40,40,40)
speedSlider.FocusLost:Connect(function()
	local val = tonumber(speedSlider.Text)
	if val then speed = val end
end)

local hpLabel = Instance.new("TextLabel", frame)
hpLabel.Size = UDim2.new(1, -20, 0, 30)
hpLabel.Text = "Máu mục tiêu: -"
hpLabel.TextColor3 = Color3.new(1,1,1)
hpLabel.BackgroundTransparency = 1
hpLabel.Font = Enum.Font.Gotham
hpLabel.TextScaled = true

task.spawn(function()
	while task.wait(0.3) do
		if target and target:FindFirstChild("Humanoid") then
			hpLabel.Text = "Máu mục tiêu: " .. math.floor(target.Humanoid.Health)
		else
			hpLabel.Text = "Máu mục tiêu: -"
		end
	end
end)

local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(1, -20, 0, 30)
closeBtn.Text = "❌ Tắt menu & script"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextScaled = true
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.BackgroundColor3 = Color3.fromRGB(100,0,0)
closeBtn.MouseButton1Click:Connect(function()
	gui:Destroy()
	RunService:UnbindFromRenderStep("FramLoop")
	framEnabled = false
end)