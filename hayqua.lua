--// GUI ĐƠN GIẢN
local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "SimpleBossFarm"

local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 120, 0, 30)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.Text = "Bật Menu"
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 250)

local menu = Instance.new("Frame", gui)
menu.Size = UDim2.new(0, 200, 0, 200)
menu.Position = UDim2.new(0, 10, 0, 50)
menu.Visible = false
menu.BackgroundColor3 = Color3.fromRGB(30,30,30)

-- Nút bật/tắt script
local runToggle = Instance.new("TextButton", menu)
runToggle.Size = UDim2.new(0, 180, 0, 30)
runToggle.Position = UDim2.new(0, 10, 0, 10)
runToggle.Text = "Bật Script"
runToggle.BackgroundColor3 = Color3.fromRGB(100,200,100)

-- Tốc độ bay quanh
local speedLabel = Instance.new("TextLabel", menu)
speedLabel.Size = UDim2.new(0, 180, 0, 20)
speedLabel.Position = UDim2.new(0, 10, 0, 50)
speedLabel.Text = "Tốc độ (default: 0.05)"

local radiusLabel = Instance.new("TextLabel", menu)
radiusLabel.Size = UDim2.new(0, 180, 0, 20)
radiusLabel.Position = UDim2.new(0, 10, 0, 80)
radiusLabel.Text = "Bán kính (default: 10)"

local running = false
local radius = 10
local speed = 0.05

-- Mở/Tắt menu
toggleBtn.MouseButton1Click:Connect(function()
	menu.Visible = not menu.Visible
end)

-- Bật/Tắt script
runToggle.MouseButton1Click:Connect(function()
	running = not running
	runToggle.Text = running and "Tắt Script" or "Bật Script"
end)

-- Hàm tìm NPC gần nhất
function getClosestTarget()
	local closest, dist = nil, math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v ~= player.Character then
			local mag = (player.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
			if mag < dist then
				closest = v
				dist = mag
			end
		end
	end
	return closest
end

-- Vòng tròn quanh mục tiêu + auto aim + đánh
task.spawn(function()
	while task.wait() do
		if running and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local target = getClosestTarget()
			if target and target:FindFirstChild("HumanoidRootPart") then
				local tPos = target.HumanoidRootPart.Position
				local angle = tick() * speed
				local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
				local newPos = tPos + offset

				-- Dịch chuyển
				player.Character.HumanoidRootPart.CFrame = CFrame.new(newPos, tPos)

				-- Đánh (click chuột)
				mouse1click()
			end
		end
	end
end)