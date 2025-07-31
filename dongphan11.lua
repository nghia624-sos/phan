local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "NghiaMinh"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Position = UDim2.new(0, 10, 0.3, 0)
frame.Size = UDim2.new(0, 260, 0, 380)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0

-- Tạo input chung
local function createInput(title, default)
	local label = Instance.new("TextLabel", frame)
	label.Size = UDim2.new(1, -20, 0, 20)
	label.Text = title
	label.TextColor3 = Color3.new(1, 1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.SourceSans
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextSize = 14

	local box = Instance.new("TextBox", frame)
	box.Size = UDim2.new(1, -20, 0, 25)
	box.Text = tostring(default)
	box.TextColor3 = Color3.new(1, 1, 1)
	box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	box.Font = Enum.Font.SourceSans
	box.TextSize = 14
	box.ClearTextOnFocus = false

	return box
end

-- Input thông số
local speedBox = createInput("Tốc độ chạy vòng", 16)
local distBox = createInput("Khoảng cách", 10)
local dmgRangeBox = createInput("Tầm đánh", 15)
local hitboxSizeBox = createInput("Kích thước vùng sát thương", 6)

-- Nút toggle
local function createToggle(title, default, callback)
	local button = Instance.new("TextButton", frame)
	button.Size = UDim2.new(1, -20, 0, 30)
	button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Text = title .. ": " .. (default and "ON" or "OFF")
	button.Font = Enum.Font.SourceSans
	button.TextSize = 16

	local state = default
	button.MouseButton1Click:Connect(function()
		state = not state
		button.Text = title .. ": " .. (state and "ON" or "OFF")
		if callback then callback(state) end
	end)
	return state
end

-- Flags
local framOn, autoHit, autoAim, noclip, bigHitbox = false, false, false, false, false

createToggle("Chạy Vòng", false, function(v) framOn = v end)
createToggle("Auto Đánh", false, function(v) autoHit = v end)
createToggle("Auto Aim", false, function(v) autoAim = v end)
createToggle("Noclip", false, function(v) noclip = v end)
createToggle("Hitbox Vũ khí thật", false, function(v) bigHitbox = v end)

-- Hàm tìm mục tiêu gần nhất
local function getClosest()
	local closest, dist = nil, math.huge
	for _, v in pairs(game:GetService("Players"):GetPlayers()) do
		if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") then
			local d = (v.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
			if d < dist and v.Character.Humanoid.Health > 0 then
				closest = v.Character
				dist = d
			end
		end
	end
	return closest
end

-- Auto Aim + Auto Hit
task.spawn(function()
	while true do
		task.wait(0.1)
		if autoAim or autoHit then
			local target = getClosest()
			if target then
				if autoAim then
					hrp.CFrame = CFrame.new(hrp.Position, target.HumanoidRootPart.Position)
				end
				if autoHit then
					local tool = char:FindFirstChildOfClass("Tool")
					if tool then
						for _, v in pairs(tool:GetChildren()) do
							if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
								pcall(function()
									v:FireServer()
								end)
							end
						end
					end
				end
			end
		end
	end
end)

-- Chạy vòng quanh mục tiêu
task.spawn(function()
	while true do
		task.wait()
		if framOn then
			local target = getClosest()
			if target then
				local speed = tonumber(speedBox.Text) or 16
				local dist = tonumber(distBox.Text) or 10
				local angle = tick() * speed
				local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * dist
				local pos = target.HumanoidRootPart.Position + offset
				hrp.CFrame = CFrame.new(hrp.Position, target.HumanoidRootPart.Position)
				hum:MoveTo(pos)
			end
		end
	end
end)

-- Noclip
game:GetService("RunService").Stepped:Connect(function()
	if noclip then
		for _, v in pairs(char:GetDescendants()) do
			if v:IsA("BasePart") and v.CanCollide then
				v.CanCollide = false
			end
		end
	end
end)

-- Hiển thị máu mục tiêu
local hpLabel = Instance.new("TextLabel", gui)
hpLabel.Position = UDim2.new(1, -180, 0.1, 0)
hpLabel.Size = UDim2.new(0, 170, 0, 30)
hpLabel.BackgroundTransparency = 0.4
hpLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
hpLabel.TextColor3 = Color3.new(1, 1, 1)
hpLabel.Font = Enum.Font.SourceSansBold
hpLabel.TextSize = 18
hpLabel.Text = "HP:"

task.spawn(function()
	while true do
		task.wait(0.2)
		local t = getClosest()
		if t and t:FindFirstChild("Humanoid") then
			hpLabel.Text = "HP: " .. math.floor(t.Humanoid.Health)
		else
			hpLabel.Text = "HP: N/A"
		end
	end
end)

-- Hitbox thật (Handle)
task.spawn(function()
	while true do
		task.wait(0.3)
		if bigHitbox then
			local tool = char:FindFirstChildOfClass("Tool")
			if tool and tool:FindFirstChild("Handle") then
				local handle = tool.Handle
				local size = tonumber(hitboxSizeBox.Text) or 6
				handle.Size = Vector3.new(size, size, size)
				handle.Transparency = 0.5
				handle.Material = Enum.Material.Neon
				handle.BrickColor = BrickColor.new("Really red")
				handle.CanCollide = false
			end
		end
	end
end)