if not game:IsLoaded() then game.Loaded:Wait() end

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

-- GUI Setup
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "MagnetFarmGUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 240, 0, 220)
frame.Position = UDim2.new(0, 10, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner", frame)
UICorner.CornerRadius = UDim.new(0, 8)

local function createButton(text, posY)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(1, -20, 0, 30)
	btn.Position = UDim2.new(0, 10, 0, posY)
	btn.BackgroundColor3 = Color3.fromRGB(60, 130, 200)
	btn.Text = text
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	local corner = Instance.new("UICorner", btn)
	corner.CornerRadius = UDim.new(0, 6)
	return btn
end

local toggleScript = createButton("Bật Script", 10)
local toggleMenu = createButton("Ẩn Menu", 50)

local hpLabel = Instance.new("TextLabel", frame)
hpLabel.Size = UDim2.new(1, -20, 0, 30)
hpLabel.Position = UDim2.new(0, 10, 0, 90)
hpLabel.BackgroundTransparency = 1
hpLabel.TextColor3 = Color3.new(1, 0.4, 0.4)
hpLabel.Font = Enum.Font.Gotham
hpLabel.TextSize = 14
hpLabel.Text = "Máu mục tiêu: N/A"

-- Slider khoảng cách
local distanceLabel = Instance.new("TextLabel", frame)
distanceLabel.Size = UDim2.new(1, -20, 0, 20)
distanceLabel.Position = UDim2.new(0, 10, 0, 130)
distanceLabel.BackgroundTransparency = 1
distanceLabel.TextColor3 = Color3.new(1,1,1)
distanceLabel.Font = Enum.Font.Gotham
distanceLabel.TextSize = 14
distanceLabel.Text = "Khoảng cách: 15"

local slider = Instance.new("TextButton", frame)
slider.Size = UDim2.new(0, 200, 0, 10)
slider.Position = UDim2.new(0, 10, 0, 160)
slider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
slider.AutoButtonColor = false
slider.Text = ""

local sliderKnob = Instance.new("Frame", slider)
sliderKnob.Size = UDim2.new(0, 10, 0, 20)
sliderKnob.Position = UDim2.new(0.3, -5, 0, -5)
sliderKnob.BackgroundColor3 = Color3.fromRGB(150, 150, 255)
Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(0, 5)

-- Biến điều khiển
local running = false
local keepDistance = 15

toggleScript.MouseButton1Click:Connect(function()
	running = not running
	toggleScript.Text = running and "Tắt Script" or "Bật Script"
end)

toggleMenu.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)

-- Kéo slider thay đổi khoảng cách
local dragging = false
sliderKnob.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
	end
end)
sliderKnob.InputEnded:Connect(function(input)
	dragging = false
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
		local x = math.clamp(input.Position.X - slider.AbsolutePosition.X, 0, slider.AbsoluteSize.X)
		sliderKnob.Position = UDim2.new(0, x - 5, 0, -5)
		keepDistance = math.floor((x / slider.AbsoluteSize.X) * 40) + 5 -- 5 đến 45
		distanceLabel.Text = "Khoảng cách: " .. keepDistance
	end
end)

-- Tìm mục tiêu gần nhất
function getClosestTarget()
	local closest, dist = nil, math.huge
	for _, v in pairs(game.Players:GetPlayers()) do
		if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
			local d = (v.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
			if d < dist then
				closest = v.Character
				dist = d
			end
		end
	end
	return closest, dist
end

-- Tấn công nếu có tool
function attackTarget(target)
	local tool = player.Character:FindFirstChildOfClass("Tool")
	if tool then tool:Activate() end
end

-- Tự động di chuyển & đánh
game:GetService("RunService").Heartbeat:Connect(function()
	if not running or not char or not hrp then return end

	local target, dist = getClosestTarget()
	if target and target:FindFirstChild("HumanoidRootPart") then
		local tHRP = target.HumanoidRootPart
		local direction = (tHRP.Position - hrp.Position).Unit

		-- Xoay mặt về mục tiêu
		hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(tHRP.Position.X, hrp.Position.Y, tHRP.Position.Z))

		-- Hiển thị máu mục tiêu
		local hp = target:FindFirstChildOfClass("Humanoid")
		if hp then
			hpLabel.Text = "Máu mục tiêu: " .. math.floor(hp.Health)
		end

		if dist < keepDistance - 1 then
			hum:Move(-direction, false) -- Lùi
		elseif dist > keepDistance + 1 then
			hum:Move(direction, false) -- Tiến
		else
			hum:Move(Vector3.zero)
			attackTarget(target)
		end
	end
end)