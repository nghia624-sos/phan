local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Cài đặt mặc định
local radius = 10
local speed = 3
local attackCooldown = 0.3
local autoFram = false
local runAroundEnabled = false
local autoAim = true

-- Tạo GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FramNpcGui"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 240)
frame.Position = UDim2.new(0, 100, 0, 200)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Selectable = true

-- Nút bật/tắt fram
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1, 0, 0, 40)
toggle.Position = UDim2.new(0, 0, 0, 0)
toggle.Text = "Bật Fram CityNpc"
toggle.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
toggle.TextColor3 = Color3.new(1,1,1)
toggle.Font = Enum.Font.SourceSansBold
toggle.TextSize = 18
toggle.MouseButton1Click:Connect(function()
	autoFram = not autoFram
	toggle.Text = autoFram and "Tắt Fram CityNpc" or "Bật Fram CityNpc"
end)

-- Nút bật tắt chạy vòng tròn
local toggleRun = Instance.new("TextButton", frame)
toggleRun.Size = UDim2.new(1, 0, 0, 40)
toggleRun.Position = UDim2.new(0, 0, 0, 45)
toggleRun.Text = "Bật Chạy Vòng"
toggleRun.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
toggleRun.TextColor3 = Color3.new(1,1,1)
toggleRun.Font = Enum.Font.SourceSansBold
toggleRun.TextSize = 18
toggleRun.MouseButton1Click:Connect(function()
	runAroundEnabled = not runAroundEnabled
	toggleRun.Text = runAroundEnabled and "Tắt Chạy Vòng" or "Bật Chạy Vòng"
end)

-- TextBox chỉnh bán kính
local radiusBox = Instance.new("TextBox", frame)
radiusBox.Size = UDim2.new(1, 0, 0, 30)
radiusBox.Position = UDim2.new(0, 0, 0, 90)
radiusBox.PlaceholderText = "Nhập bán kính (VD: 10)"
radiusBox.Text = tostring(radius)
radiusBox.Font = Enum.Font.SourceSans
radiusBox.TextSize = 18
radiusBox.TextColor3 = Color3.new(1,1,1)
radiusBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
radiusBox.FocusLost:Connect(function()
	local val = tonumber(radiusBox.Text)
	if val then
		radius = val
	end
end)

-- TextBox chỉnh tốc độ đánh
local atkBox = Instance.new("TextBox", frame)
atkBox.Size = UDim2.new(1, 0, 0, 30)
atkBox.Position = UDim2.new(0, 0, 0, 125)
atkBox.PlaceholderText = "Thời gian delay đánh (VD: 0.3)"
atkBox.Text = tostring(attackCooldown)
atkBox.Font = Enum.Font.SourceSans
atkBox.TextSize = 18
atkBox.TextColor3 = Color3.new(1,1,1)
atkBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
atkBox.FocusLost:Connect(function()
	local val = tonumber(atkBox.Text)
	if val then
		attackCooldown = val
	end
end)

-- Hàm tìm NPC
function findNearestCityNPC()
	local closest, shortest = nil, math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
			if v.Name:lower():find("citynpc") then
				local dist = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
				if dist < shortest then
					shortest = dist
					closest = v
				end
			end
		end
	end
	return closest
end

-- Auto Aim
function aimAt(target)
	if not target then return end
	local look = CFrame.lookAt(hrp.Position, target.HumanoidRootPart.Position)
	hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, look:ToEulerAnglesYXZ())
end

-- Auto Attack
function attack(target)
	if not target then return end
	local tool = character:FindFirstChildOfClass("Tool")
	if tool and (target.HumanoidRootPart.Position - hrp.Position).Magnitude <= 20 then
		tool:Activate()
	end
end

-- Chạy vòng quanh
function runAround(target)
	if not target then return end
	local t = 0
	while target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 and autoFram and runAroundEnabled do
		t += speed / 100
		local offset = Vector3.new(math.cos(t)*radius, 0, math.sin(t)*radius)
		local goalPos = target.HumanoidRootPart.Position + offset
		humanoid:MoveTo(goalPos)
		if autoAim then aimAt(target) end
		attack(target)
		task.wait(attackCooldown)
	end
end

-- Vòng lặp chính
task.spawn(function()
	while true do
		if autoFram then
			local target = findNearestCityNPC()
			if target then
				humanoid:MoveTo(target.HumanoidRootPart.Position)
				humanoid.MoveToFinished:Wait()
				runAround(target)
			end
		end
		task.wait(0.1)
	end
end)