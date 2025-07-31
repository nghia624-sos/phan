-- Script: Fram CityNPC + Auto Vòng Quanh Mục Tiêu + Menu Kéo
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FramMenuMobile"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 200)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local uilist = Instance.new("UIListLayout", frame)
uilist.Padding = UDim.new(0, 4)

function createButton(text, color, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -8, 0, 28)
	btn.Position = UDim2.new(0, 4, 0, 0)
	btn.BackgroundColor3 = color
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 18
	btn.Text = text
	btn.Parent = frame
	btn.MouseButton1Click:Connect(callback)
	return btn
end

local radiusBox = Instance.new("TextBox")
radiusBox.Size = UDim2.new(1, -8, 0, 26)
radiusBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
radiusBox.TextColor3 = Color3.new(1,1,1)
radiusBox.Font = Enum.Font.SourceSans
radiusBox.TextSize = 16
radiusBox.Text = "13" -- bán kính
radiusBox.PlaceholderText = "Bán kính vòng"
radiusBox.ClearTextOnFocus = false
radiusBox.Parent = frame

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(1, -8, 0, 26)
speedBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
speedBox.TextColor3 = Color3.new(1,1,1)
speedBox.Font = Enum.Font.SourceSans
speedBox.TextSize = 16
speedBox.Text = "2" -- tốc độ
speedBox.PlaceholderText = "Tốc độ vòng"
speedBox.ClearTextOnFocus = false
speedBox.Parent = frame

local statusLbl = Instance.new("TextLabel", frame)
statusLbl.Size = UDim2.new(1, -8, 0, 24)
statusLbl.Text = "Tới: ..."
statusLbl.BackgroundTransparency = 1
statusLbl.TextColor3 = Color3.new(1,1,1)
statusLbl.Font = Enum.Font.SourceSans
statusLbl.TextSize = 16

local framRunning = false
local autoCircle = true
local currentTarget = nil

createButton("Bật Fram", Color3.fromRGB(0, 170, 255), function()
	framRunning = true
end)

createButton("Tắt Fram", Color3.fromRGB(255, 60, 60), function()
	framRunning = false
	currentTarget = nil
end)

local autoBtn = createButton("Tự vòng quanh: BẬT", Color3.fromRGB(0, 200, 0), function()
	autoCircle = not autoCircle
	if autoCircle then
		autoBtn.Text = "Tự vòng quanh: BẬT"
		autoBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
	else
		autoBtn.Text = "Tự vòng quanh: TẮT"
		autoBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	end
end)

-- Hàm tìm mục tiêu gần nhất
function getClosestTarget()
	local closest = nil
	local shortest = math.huge
	for _,v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
			if string.lower(v.Name):find("citynpc") then
				local mag = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
				if mag < shortest then
					shortest = mag
					closest = v
				end
			end
		end
	end
	return closest
end

-- Hàm chạy bộ tự nhiên
function walkTo(pos)
	humanoid:MoveTo(pos)
end

-- Hàm chạy vòng quanh
function circleAround(target)
	local radius = tonumber(radiusBox.Text) or 13
	local speed = tonumber(speedBox.Text) or 2
	local angle = 0
	while currentTarget == target and autoCircle and framRunning and target.Parent do
		if not char or not char:FindFirstChild("HumanoidRootPart") then break end
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local targetPos = target.HumanoidRootPart.Position + offset
		humanoid:MoveTo(targetPos)
		hrp.CFrame = CFrame.new(hrp.Position, target.HumanoidRootPart.Position)
		angle = angle + (speed * 0.05)
		task.wait(0.05)
	end
end

-- Vòng lặp chính
task.spawn(function()
	while true do
		if framRunning then
			currentTarget = getClosestTarget()
			if currentTarget then
				statusLbl.Text = "Tới: "..currentTarget.Name
				repeat
					walkTo(currentTarget.HumanoidRootPart.Position + Vector3.new(0,0,2))
					task.wait(0.2)
				until not framRunning or not currentTarget or (hrp.Position - currentTarget.HumanoidRootPart.Position).Magnitude < 8
				if autoCircle and currentTarget then
					circleAround(currentTarget)
				end
			else
				statusLbl.Text = "Tới: Không tìm thấy"
			end
		end
		task.wait(1)
	end
end)