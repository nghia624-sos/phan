-- GUI + Script Auto Fram Vòng Quanh Mục Tiêu (KRNL Mobile)

-- Khởi tạo GUI
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FramMenu"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 280)
frame.Position = UDim2.new(0, 20, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0

local uilist = Instance.new("UIListLayout", frame)
uilist.Padding = UDim.new(0, 5)

function createToggle(text)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.Position = UDim2.new(0, 5, 0, 0)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Text = text.." [OFF]"
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 16
	btn.BorderSizePixel = 0
	frame:AddChild(btn)
	return btn
end

function createSlider(text, min, max, default)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -10, 0, 20)
	label.Text = text..": "..default
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1,1,1)
	label.Font = Enum.Font.SourceSans
	label.TextSize = 14
	frame:AddChild(label)

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, -10, 0, 30)
	box.Text = tostring(default)
	box.TextColor3 = Color3.new(1,1,1)
	box.BackgroundColor3 = Color3.fromRGB(40,40,40)
	box.ClearTextOnFocus = false
	box.Font = Enum.Font.SourceSans
	box.TextSize = 16
	box.BorderSizePixel = 0
	frame:AddChild(box)

	return box, label
end

-- Tùy chỉnh
local distanceBox, distanceLabel = createSlider("Khoảng cách", 5, 100, 10)
local speedBox, speedLabel = createSlider("Tốc độ", 1, 50, 10)

-- Các nút bật tắt
local toggleGui = createToggle("Ẩn/Hiện Menu")
local toggleFram = createToggle("Chạy Vòng")
local toggleAim = createToggle("Auto Aim")
local toggleClick = createToggle("Auto Đánh")
local toggleNoclip = createToggle("Noclip")

-- Trạng thái
local running = false
local aiming = false
local clicking = false
local noclip = false
local guiVisible = true

-- Tìm mục tiêu gần nhất
function getNearestEnemy()
	local nearest, minDist = nil, math.huge
	for _, v in pairs(game.Workspace:GetDescendants()) do
		if v:IsA("Model") and v ~= char and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
			local dist = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
			if dist < minDist then
				nearest = v
				minDist = dist
			end
		end
	end
	return nearest
end

-- Auto Click
task.spawn(function()
	while true do
		task.wait(0.1)
		if clicking then
			mouse1click()
		end
	end
end)

-- Noclip
game:GetService("RunService").Stepped:Connect(function()
	if noclip and char then
		for _, v in pairs(char:GetDescendants()) do
			if v:IsA("BasePart") and v.CanCollide == true then
				v.CanCollide = false
			end
		end
	end
end)

-- Auto Fram
task.spawn(function()
	while true do
		task.wait()
		if running and char and hrp then
			local dist = tonumber(distanceBox.Text) or 10
			local speed = tonumber(speedBox.Text) or 10
			local target = getNearestEnemy()
			if target and target:FindFirstChild("HumanoidRootPart") then
				local root = target.HumanoidRootPart
				local tpos = root.Position
				local angle = tick() * speed
				local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * dist
				local dest = tpos + offset
				hrp.CFrame = CFrame.new(dest, tpos)
			end
		end
	end
end)

-- Auto Aim
task.spawn(function()
	while true do
		task.wait()
		if aiming then
			local target = getNearestEnemy()
			if target and target:FindFirstChild("HumanoidRootPart") then
				local tpos = target.HumanoidRootPart.Position
				local look = CFrame.new(hrp.Position, tpos)
				hrp.CFrame = CFrame.new(hrp.Position, tpos)
			end
		end
	end
end)

-- Nút bật tắt chức năng
toggleFram.MouseButton1Click:Connect(function()
	running = not running
	toggleFram.Text = "Chạy Vòng ["..(running and "ON" or "OFF").."]"
end)

toggleAim.MouseButton1Click:Connect(function()
	aiming = not aiming
	toggleAim.Text = "Auto Aim ["..(aiming and "ON" or "OFF").."]"
end)

toggleClick.MouseButton1Click:Connect(function()
	clicking = not clicking
	toggleClick.Text = "Auto Đánh ["..(clicking and "ON" or "OFF").."]"
end)

toggleNoclip.MouseButton1Click:Connect(function()
	noclip = not noclip
	toggleNoclip.Text = "Noclip ["..(noclip and "ON" or "OFF").."]"
end)

toggleGui.MouseButton1Click:Connect(function()
	guiVisible = not guiVisible
	frame.Visible = guiVisible
end)