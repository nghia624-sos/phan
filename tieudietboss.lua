--== GUI Đơn Giản ==--
local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "BossFarmGui"

-- Nút Bật/Tắt Script
local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 120, 0, 30)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.Text = "Bật Script"
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 16

-- Nhập Bán Kính
local radiusBox = Instance.new("TextBox", gui)
radiusBox.Size = UDim2.new(0, 100, 0, 25)
radiusBox.Position = UDim2.new(0, 10, 0, 50)
radiusBox.Text = "10"
radiusBox.PlaceholderText = "Bán kính"
radiusBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
radiusBox.TextColor3 = Color3.new(1, 1, 1)

-- Nhập Tốc Độ
local speedBox = Instance.new("TextBox", gui)
speedBox.Size = UDim2.new(0, 100, 0, 25)
speedBox.Position = UDim2.new(0, 10, 0, 80)
speedBox.Text = "2"
speedBox.PlaceholderText = "Tốc độ"
speedBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
speedBox.TextColor3 = Color3.new(1, 1, 1)

-- Hiển thị máu Boss
local healthLabel = Instance.new("TextLabel", gui)
healthLabel.Size = UDim2.new(0, 200, 0, 25)
healthLabel.Position = UDim2.new(0, 10, 0, 110)
healthLabel.Text = "HP: 0"
healthLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
healthLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
healthLabel.Font = Enum.Font.SourceSansBold
healthLabel.TextSize = 16
healthLabel.Visible = false

-- Biến điều khiển
local running = false
local radius = 10
local speed = 2

--== Tìm Boss gần nhất ==--
function getNearestBoss()
	local nearest, dist = nil, math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
			if string.find(string.lower(v.Name), "boss") and v.Humanoid.Health > 0 then
				local mag = (player.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
				if mag < dist then
					dist = mag
					nearest = v
				end
			end
		end
	end
	return nearest
end

--== Hàm quay vòng quanh Boss ==--
spawn(function()
	local angle = 0
	while task.wait() do
		if running then
			-- Lấy lại thông số tùy chỉnh
			local r = tonumber(radiusBox.Text)
			local s = tonumber(speedBox.Text)
			if r then radius = r end
			if s then speed = s end

			local char = player.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local target = getNearestBoss()

			if target and hrp then
				local tPos = target.HumanoidRootPart.Position
				angle += speed * 0.03
				local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
				local movePos = tPos + offset

				-- Di chuyển và xoay mặt
				char:MoveTo(movePos)
				local dir = (tPos - hrp.Position).Unit
				hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + dir)

				-- Hiển thị máu
				healthLabel.Visible = true
				healthLabel.Text = "HP: " .. math.floor(target.Humanoid.Health)
			else
				healthLabel.Visible = false
			end
		else
			healthLabel.Visible = false
			wait(0.5)
		end
	end
end)

--== Nút bật/tắt script ==--
toggleBtn.MouseButton1Click:Connect(function()
	running = not running
	toggleBtn.Text = running and "Tắt Script" or "Bật Script"
end)