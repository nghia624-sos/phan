-- TT:dongphandzs1 Menu chạy vòng + Auto đánh + Aim + Tùy chỉnh
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

local run = false
local radius = 10
local speed = 5
local target = nil

-- Tìm mục tiêu gần nhất
local function getNearestTarget()
	local nearest, dist = nil, math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v ~= chr then
			local d = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
			if d < dist then
				dist = d
				nearest = v
			end
		end
	end
	return nearest
end

-- Auto đánh
task.spawn(function()
	while true do
		task.wait(0.1)
		if run and target and target:FindFirstChild("Humanoid") and target:FindFirstChild("HumanoidRootPart") then
			-- Tăng tốc đánh
			pcall(function()
				for _, v in pairs(lp.Backpack:GetChildren()) do
					if v:IsA("Tool") then
						v.Parent = chr
						v:Activate()
					end
				end
				for _, v in pairs(chr:GetChildren()) do
					if v:IsA("Tool") then
						v:Activate()
					end
				end
			end)
		end
	end
end)

-- Chạy vòng quanh + Aim
task.spawn(function()
	while task.wait() do
		if run then
			if not target or not target:FindFirstChild("HumanoidRootPart") then
				target = getNearestTarget()
			end
			if target then
				local tPos = target.HumanoidRootPart.Position
				local angle = tick() * speed
				local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
				local goalPos = tPos + offset
				local tween = TweenService:Create(hrp, TweenInfo.new(0.1), {CFrame = CFrame.new(goalPos, tPos)})
				tween:Play()
			end
		end
	end
end)

-- Giao diện
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "dongphandzs1"

local frame = Instance.new("Frame", gui)
frame.Position = UDim2.new(0.4, 0, 0.3, 0)
frame.Size = UDim2.new(0, 260, 0, 180)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1, 0, 0, 30)
toggle.Text = "BẬT: Chạy vòng + Auto đánh"
toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.MouseButton1Click:Connect(function()
	run = not run
	toggle.Text = run and "TẮT: Chạy vòng + Auto đánh" or "BẬT: Chạy vòng + Auto đánh"
end)

-- Nhập khoảng cách
local rLabel = Instance.new("TextLabel", frame)
rLabel.Position = UDim2.new(0, 0, 0, 40)
rLabel.Size = UDim2.new(0, 120, 0, 25)
rLabel.Text = "Khoảng cách:"
rLabel.TextColor3 = Color3.new(1,1,1)
rLabel.BackgroundTransparency = 1

local rBox = Instance.new("TextBox", frame)
rBox.Position = UDim2.new(0, 130, 0, 40)
rBox.Size = UDim2.new(0, 100, 0, 25)
rBox.Text = tostring(radius)
rBox.FocusLost:Connect(function()
	local val = tonumber(rBox.Text)
	if val then radius = val end
end)

-- Nhập tốc độ
local sLabel = Instance.new("TextLabel", frame)
sLabel.Position = UDim2.new(0, 0, 0, 75)
sLabel.Size = UDim2.new(0, 120, 0, 25)
sLabel.Text = "Tốc độ quay:"
sLabel.TextColor3 = Color3.new(1,1,1)
sLabel.BackgroundTransparency = 1

local sBox = Instance.new("TextBox", frame)
sBox.Position = UDim2.new(0, 130, 0, 75)
sBox.Size = UDim2.new(0, 100, 0, 25)
sBox.Text = tostring(speed)
sBox.FocusLost:Connect(function()
	local val = tonumber(sBox.Text)
	if val then speed = val end
end)