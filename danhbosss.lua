--// ScreenGui Khởi tạo
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "TargetMenu"
gui.ResetOnSpawn = false
gui.Enabled = true

--// Biến
local running = false
local spinning = false
local aiming = false
local speed = 10
local radius = 10

--// Hàm tìm mục tiêu gần nhất
function getNearestTarget()
	local player = game.Players.LocalPlayer
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end

	local closest = nil
	local minDistance = math.huge
	for _, v in pairs(game.Workspace:GetChildren()) do
		if v:IsA("Model") and v ~= character and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
			local dist = (character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
			if dist < minDistance then
				minDistance = dist
				closest = v
			end
		end
	end
	return closest
end

--// Chạy vòng quanh mục tiêu
function spinAroundTarget()
	spawn(function()
		while spinning do
			local char = game.Players.LocalPlayer.Character
			local target = getNearestTarget()
			if char and char:FindFirstChild("HumanoidRootPart") and target and target:FindFirstChild("HumanoidRootPart") then
				local tPos = target.HumanoidRootPart.Position
				local angle = tick() * speed
				local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
				char.Humanoid:MoveTo(tPos + offset)
			end
			wait(0.1)
		end
	end)
end

--// Auto Aim + Auto Đánh
function autoAimAttack()
	spawn(function()
		while aiming do
			local char = game.Players.LocalPlayer.Character
			local target = getNearestTarget()
			if char and target and char:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("HumanoidRootPart") then
				local dir = (target.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Unit
				char.HumanoidRootPart.CFrame = CFrame.new(char.HumanoidRootPart.Position, char.HumanoidRootPart.Position + dir)
				
				-- Auto Click
				mouse1click()
			end
			wait(0.1)
		end
	end)
end

--// Giao diện menu
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, 100, 0, 30)
openBtn.Position = UDim2.new(0, 10, 0, 10)
openBtn.Text = "Mở Menu"
openBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 75)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 200)
frame.Position = UDim2.new(0, 10, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Visible = false

--// Toggle Script
local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(0, 230, 0, 30)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.Text = "Bật Script"
toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)

--// Tab1: Vòng quanh mục tiêu
local spinToggle = Instance.new("TextButton", frame)
spinToggle.Size = UDim2.new(0, 230, 0, 30)
spinToggle.Position = UDim2.new(0, 10, 0, 50)
spinToggle.Text = "Bật Lướt Quanh Mục Tiêu"
spinToggle.BackgroundColor3 = Color3.fromRGB(100, 100, 255)

-- Tốc độ
local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(0, 100, 0, 25)
speedBox.Position = UDim2.new(0, 10, 0, 90)
speedBox.PlaceholderText = "Tốc độ"
speedBox.Text = ""

-- Bán kính
local radiusBox = Instance.new("TextBox", frame)
radiusBox.Size = UDim2.new(0, 100, 0, 25)
radiusBox.Position = UDim2.new(0, 120, 0, 90)
radiusBox.PlaceholderText = "Bán kính"
radiusBox.Text = ""

--// Tab2: Auto Aim
local aimToggle = Instance.new("TextButton", frame)
aimToggle.Size = UDim2.new(0, 230, 0, 30)
aimToggle.Position = UDim2.new(0, 10, 0, 130)
aimToggle.Text = "Bật Auto Aim + Đánh"
aimToggle.BackgroundColor3 = Color3.fromRGB(255, 100, 100)

--// Đóng menu
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0, 230, 0, 30)
closeBtn.Position = UDim2.new(0, 10, 0, 170)
closeBtn.Text = "Đóng Menu"
closeBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 150)

--// Sự kiện
openBtn.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)

closeBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
end)

toggleBtn.MouseButton1Click:Connect(function()
	running = not running
	toggleBtn.Text = running and "Tắt Script" or "Bật Script"
end)

spinToggle.MouseButton1Click:Connect(function()
	spinning = not spinning
	spinToggle.Text = spinning and "Tắt Lướt Quanh" or "Bật Lướt Quanh"
	if spinning then
		speed = tonumber(speedBox.Text) or speed
		radius = tonumber(radiusBox.Text) or radius
		spinAroundTarget()
	end
end)

aimToggle.MouseButton1Click:Connect(function()
	aiming = not aiming
	aimToggle.Text = aiming and "Tắt Aim" or "Bật Aim + Đánh"
	if aiming then autoAimAttack() end
end)