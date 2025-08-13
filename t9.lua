--// Fram NPC2 - 1 GUI duy nhất (đơn giản, kéo được) + MoveTo mượt //--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

-- Config mặc định
local radius = 28         -- giống ảnh mẫu
local speed = 2           -- tốc độ quay vòng
local running = false
local autoAttack = false
local currentTarget = nil

--==================================================
-- TÌM NPC2 (không phân biệt hoa/thường)
--==================================================
local function findNPC2()
	for _, m in ipairs(workspace:GetDescendants()) do
		if m:IsA("Model") and m ~= chr then
			local h = m:FindFirstChildOfClass("Humanoid")
			local r = m:FindFirstChild("HumanoidRootPart")
			if h and r and h.Health > 0 then
				if string.find(string.lower(m.Name), "npc2") then
					return m
				end
			end
		end
	end
	return nil
end

--==================================================
-- AUTO ATTACK
--==================================================
local function attack()
	local tool = chr:FindFirstChildOfClass("Tool")
	if tool then pcall(function() tool:Activate() end) end
end

--==================================================
-- GUI (giống layout ảnh)
--==================================================
local gui = Instance.new("ScreenGui")
gui.Name = "Menu_TT"
gui.ResetOnSpawn = false
gui.Parent = lp:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.new(0, 340, 0, 260)
frame.Position = UDim2.new(0.5, -170, 0.5, -130)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- dải trên
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
topBar.BorderSizePixel = 0
topBar.Parent = frame

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, 0, 1, 0)
toggle.BackgroundTransparency = 1
toggle.Text = "BẬT: Đánh Boss"
toggle.Font = Enum.Font.GothamSemibold
toggle.TextSize = 18
toggle.TextColor3 = Color3.fromRGB(235,235,235)
toggle.Parent = topBar

-- dòng “Khoảng cách”
local disLabel = Instance.new("TextLabel")
disLabel.Size = UDim2.new(0, 150, 0, 30)
disLabel.Position = UDim2.new(0, 16, 0, 60)
disLabel.BackgroundTransparency = 1
disLabel.Text = "Khoảng cách:"
disLabel.Font = Enum.Font.Gotham
disLabel.TextSize = 16
disLabel.TextColor3 = Color3.fromRGB(230,230,230)
disLabel.Parent = frame

local disInput = Instance.new("TextBox")
disInput.Size = UDim2.new(0, 120, 0, 30)
disInput.Position = UDim2.new(0, 200, 0, 60)
disInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
disInput.BorderSizePixel = 0
disInput.Text = tostring(radius)
disInput.PlaceholderText = "28"
disInput.Font = Enum.Font.Gotham
disInput.TextSize = 16
disInput.TextColor3 = Color3.fromRGB(230,230,230)
disInput.Parent = frame

-- dòng “Tốc độ quay”
local spdLabel = Instance.new("TextLabel")
spdLabel.Size = UDim2.new(0, 150, 0, 30)
spdLabel.Position = UDim2.new(0, 16, 0, 100)
spdLabel.BackgroundTransparency = 1
spdLabel.Text = "Tốc độ quay:"
spdLabel.Font = Enum.Font.Gotham
spdLabel.TextSize = 16
spdLabel.TextColor3 = Color3.fromRGB(230,230,230)
spdLabel.Parent = frame

local spdInput = Instance.new("TextBox")
spdInput.Size = UDim2.new(0, 120, 0, 30)
spdInput.Position = UDim2.new(0, 200, 0, 100)
spdInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
spdInput.BorderSizePixel = 0
spdInput.Text = tostring(speed)
spdInput.PlaceholderText = "2"
spdInput.Font = Enum.Font.Gotham
spdInput.TextSize = 16
spdInput.TextColor3 = Color3.fromRGB(230,230,230)
spdInput.Parent = frame

-- Label máu (đỏ)
local hpLabel = Instance.new("TextLabel")
hpLabel.Size = UDim2.new(1, -32, 0, 30)
hpLabel.Position = UDim2.new(0, 16, 0, 140)
hpLabel.BackgroundTransparency = 1
hpLabel.Text = "Máu mục tiêu: ..."
hpLabel.Font = Enum.Font.GothamSemibold
hpLabel.TextSize = 16
hpLabel.TextColor3 = Color3.fromRGB(255, 70, 70)
hpLabel.Parent = frame

-- dải giữa cho nút Auto
local midBar = Instance.new("Frame")
midBar.Size = UDim2.new(1, 0, 0, 40)
midBar.Position = UDim2.new(0, 0, 0, 180)
midBar.BackgroundColor3 = Color3.fromRGB(45,45,45)
midBar.BorderSizePixel = 0
midBar.Parent = frame

local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(1, 0, 1, 0)
autoBtn.BackgroundTransparency = 1
autoBtn.Text = "BẬT: Auto Đánh"
autoBtn.Font = Enum.Font.GothamSemibold
autoBtn.TextSize = 18
autoBtn.TextColor3 = Color3.fromRGB(235,235,235)
autoBtn.Parent = midBar

-- dòng chữ xanh cuối
local nameText = Instance.new("TextLabel")
nameText.Size = UDim2.new(1, 0, 0, 30)
nameText.Position = UDim2.new(0, 0, 0, 220)
nameText.BackgroundTransparency = 1
nameText.Text = "TT:dongphandzs1"
nameText.Font = Enum.Font.GothamBlack
nameText.TextSize = 22
nameText.TextColor3 = Color3.fromRGB(100,255,100)
nameText.Parent = frame

--==================================================
-- NHẬP GIÁ TRỊ TỪ GUI
--==================================================
disInput.FocusLost:Connect(function()
	local v = tonumber(disInput.Text)
	if v and v >= 5 then
		radius = v
	else
		disInput.Text = tostring(radius)
	end
end)

spdInput.FocusLost:Connect(function()
	local v = tonumber(spdInput.Text)
	if v and v > 0 then
		speed = v
	else
		spdInput.Text = tostring(speed)
	end
end)

--==================================================
-- NÚT BẬT/TẮT & AUTO
--==================================================
toggle.MouseButton1Click:Connect(function()
	running = not running
	toggle.Text = (running and "TẮT" or "BẬT") .. ": Đánh Boss"
	if running then
		currentTarget = findNPC2()
		if not currentTarget then
			hpLabel.Text = "Máu mục tiêu: Không tìm thấy NPC2"
		end
	end
end)

autoBtn.MouseButton1Click:Connect(function()
	autoAttack = not autoAttack
	autoBtn.Text = (autoAttack and "TẮT" or "BẬT") .. ": Auto Đánh"
end)

--==================================================
-- LOOP CHÍNH: TIẾP CẬN + CHẠY VÒNG (MoveTo)
--==================================================
RunService.Heartbeat:Connect(function()
	if not running then return end

	-- nếu mất mục tiêu → tìm lại
	if (not currentTarget) or (not currentTarget.Parent) or (not currentTarget:FindFirstChild("Humanoid")) or (not currentTarget:FindFirstChild("HumanoidRootPart")) then
		currentTarget = findNPC2()
		return
	end

	local h = currentTarget:FindFirstChildOfClass("Humanoid")
	local r = currentTarget:FindFirstChild("HumanoidRootPart")
	if not h or not r then
		currentTarget = nil
		return
	end

	if h.Health <= 0 then
		hpLabel.Text = "Máu mục tiêu: Đã chết"
		currentTarget = nil
		return
	end

	-- cập nhật HP
	hpLabel.Text = "Máu mục tiêu: " .. math.floor(h.Health)

	-- Tiếp cận khi còn xa, quay vòng khi vào phạm vi
	local dist = (hrp.Position - r.Position).Magnitude
	if dist > radius + 3 then
		-- TIẾP CẬN (mượt, an toàn)
		hum:MoveTo(r.Position)
		hrp.CFrame = CFrame.new(hrp.Position, r.Position)
	else
		-- CHẠY VÒNG
		local angle = tick() * speed
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local goalPos = r.Position + offset
		hum:MoveTo(goalPos)
		hrp.CFrame = CFrame.new(hrp.Position, r.Position)

		if autoAttack then attack() end
	end
end)