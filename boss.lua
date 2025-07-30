-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.ResetOnSpawn = false
gui.Name = "FramBossMenu"

local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, 100, 0, 30)
openBtn.Position = UDim2.new(0, 10, 0, 10)
openBtn.Text = "Mở Menu"
openBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 200)
frame.Position = UDim2.new(0, 10, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.Visible = false

-- Toggle menu
openBtn.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)

-- Script Toggle
local runScript = false
local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(0, 180, 0, 30)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.Text = "Bật Script"
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)

toggleBtn.MouseButton1Click:Connect(function()
	runScript = not runScript
	toggleBtn.Text = runScript and "Tắt Script" or "Bật Script"
end)

-- Radius & Speed sliders
local radius = 24
local speed = 3

local radiusBox = Instance.new("TextBox", frame)
radiusBox.Size = UDim2.new(0, 180, 0, 30)
radiusBox.Position = UDim2.new(0, 10, 0, 50)
radiusBox.Text = "Tầm đánh: 24"

local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(0, 180, 0, 30)
speedBox.Position = UDim2.new(0, 10, 0, 90)
speedBox.Text = "Tốc độ: 3"

-- Máu
local healthLabel = Instance.new("TextLabel", frame)
healthLabel.Size = UDim2.new(0, 180, 0, 30)
healthLabel.Position = UDim2.new(0, 10, 0, 130)
healthLabel.Text = "Máu: N/A"
healthLabel.TextColor3 = Color3.new(1, 0, 0)
healthLabel.BackgroundTransparency = 1

-- Logic
local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- Auto Fram Loop
task.spawn(function()
	while true do
		task.wait(0.1)
		if runScript then
			-- Cập nhật giá trị người dùng nhập
			local r = tonumber(radiusBox.Text:match("%d+"))
			local s = tonumber(speedBox.Text:match("%d+"))
			if r then radius = r end
			if s then speed = s end

			-- Tìm mục tiêu gần nhất có Humanoid
			local target = nil
			local closestDist = math.huge
			for _, v in pairs(game.Workspace:GetDescendants()) do
				if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v ~= char then
					local dist = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
					if dist < closestDist then
						closestDist = dist
						target = v
					end
				end
			end

			if target and target:FindFirstChild("HumanoidRootPart") then
				local tPos = target.HumanoidRootPart.Position
				local angle = tick() * speed
				local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
				local movePos = tPos + offset
				char:FindFirstChild("Humanoid"):MoveTo(movePos)

				-- Aim hướng về mục tiêu
				local dir = (tPos - hrp.Position).Unit
				hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + dir)

				-- Auto đánh (giả lập chuột trái hoặc tùy game có thể là RemoteEvent)
				mouse1click()

				-- Hiển thị máu mục tiêu
				local hp = math.floor(target.Humanoid.Health)
				local maxhp = math.floor(target.Humanoid.MaxHealth)
				healthLabel.Text = "Máu: " .. hp .. "/" .. maxhp
			else
				healthLabel.Text = "Máu: Không tìm thấy"
			end
		end
	end
end)