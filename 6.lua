local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

-- Tạo GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FramNPC"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 240, 0, 160)
frame.Position = UDim2.new(0, 100, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Active = true
frame.Draggable = true

local tab1 = Instance.new("TextButton", frame)
tab1.Size = UDim2.new(1, 0, 0, 30)
tab1.Position = UDim2.new(0, 0, 0, 0)
tab1.Text = "Fram Tới CityNPC"

local tab2 = Instance.new("TextButton", frame)
tab2.Size = UDim2.new(1, 0, 0, 30)
tab2.Position = UDim2.new(0, 0, 0, 35)
tab2.Text = "Chạy Vòng Quanh + Đánh"

local radiusBox = Instance.new("TextBox", frame)
radiusBox.Size = UDim2.new(1, -20, 0, 25)
radiusBox.Position = UDim2.new(0, 10, 0, 70)
radiusBox.PlaceholderText = "Bán kính (mặc định: 10)"
radiusBox.Text = ""

local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(1, -20, 0, 25)
speedBox.Position = UDim2.new(0, 10, 0, 100)
speedBox.PlaceholderText = "Tốc độ quay (mặc định: 2)"
speedBox.Text = ""

local stopButton = Instance.new("TextButton", frame)
stopButton.Size = UDim2.new(1, 0, 0, 25)
stopButton.Position = UDim2.new(0, 0, 0, 130)
stopButton.Text = "Tắt Fram"
stopButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)

-- Biến trạng thái
local running = false
local mode = 0 -- 0: none, 1: tới mục tiêu, 2: quay vòng

-- Hàm tìm CityNPC gần nhất
function getNearestCityNPC()
	local nearest, shortest = nil, math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and tostring(v.Name):lower():find("citynpc") then
			local dist = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
			if dist < shortest then
				nearest = v
				shortest = dist
			end
		end
	end
	return nearest
end

-- Di chuyển bộ tự nhiên đến mục tiêu
function moveToTarget(target)
	if target and target:FindFirstChild("HumanoidRootPart") then
		hum:MoveTo(target.HumanoidRootPart.Position)
		hum.MoveToFinished:Wait()
	end
end

-- Tự chạy vòng quanh
task.spawn(function()
	while true do task.wait(0.03)
		if running and mode == 2 then
			local dist = tonumber(radiusBox.Text) or 10
			local speed = tonumber(speedBox.Text) or 2
			local target = getNearestCityNPC()
			if target and target:FindFirstChild("HumanoidRootPart") then
				local angle = tick() * speed
				local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * dist
				local goalPos = target.HumanoidRootPart.Position + offset
				goalPos = Vector3.new(goalPos.X, hrp.Position.Y, goalPos.Z)
				local goalCF = CFrame.new(goalPos, target.HumanoidRootPart.Position)
				TweenService:Create(hrp, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {CFrame = goalCF}):Play()
			end
		end
	end
end)

-- Tự chạy tới mục tiêu → rồi chạy vòng quanh
task.spawn(function()
	while true do task.wait(1)
		if running and mode == 1 then
			local target = getNearestCityNPC()
			if target then
				moveToTarget(target)
				repeat task.wait(0.2)
					if (target.HumanoidRootPart.Position - hrp.Position).Magnitude <= 15 or target:FindFirstChild("Humanoid") == nil or target.Humanoid.Health <= 0 then
						break
					end
				until false
				mode = 2 -- chuyển sang chạy vòng quanh
			end
		end
	end
end)

-- Nút Tab
tab1.MouseButton1Click:Connect(function()
	running = true
	mode = 1
end)

tab2.MouseButton1Click:Connect(function()
	running = true
	mode = 2
end)

stopButton.MouseButton1Click:Connect(function()
	running = false
	mode = 0
end)