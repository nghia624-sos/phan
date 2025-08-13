local g = getgenv and getgenv() or _G
if g.TT_NPC2_LOADED then
    warn("[TT] Script đã chạy rồi. Bỏ qua để tránh nhân đôi loop/GUI.")
    return
end
g.TT_NPC2_LOADED = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")
local UIS = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

--== Config ==--
local radius = 28     -- bán kính mặc định
local turnSpeed = 2   -- tốc độ quay vòng
local running = false
local autoAttack = false

--== State ==--
local currentTarget = nil
local loopConn: RBXScriptConnection? = nil
local moveConn: RBXScriptConnection? = nil
local lastAttack = 0
local attackCD = 0.2

--== Tìm NPC2 (không phân biệt hoa/thường) ==--
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

--== Auto Attack gọn, an toàn ==--
local function attack()
	if not autoAttack then return end
	if tick() - lastAttack < attackCD then return end
	lastAttack = tick()

	-- Ưu tiên tool đang cầm; nếu không có thì equip tool đầu trong Backpack 1 lần
	local tool = chr:FindFirstChildOfClass("Tool")
	if not tool then
		for _, t in ipairs(lp.Backpack:GetChildren()) do
			if t:IsA("Tool") then
				pcall(function() hum:EquipTool(t) end)
				tool = t
				break
			end
		end
	end
	if tool then pcall(function() tool:Activate() end) end
end

--== Path-Navigation (không block, không tạo vòng lặp phụ) ==--
local currentPath = nil
local waypoints = nil
local wpIndex = 0
local recomputeAt = 0
local recomputeCD = 0.6  -- tránh spam ComputeAsync

local function clearPath()
	currentPath = nil
	waypoints = nil
	wpIndex = 0
	if moveConn then
		moveConn:Disconnect()
		moveConn = nil
	end
end

local function onMoveFinished(reached)
	-- Tới 1 waypoint, đẩy tiếp waypoint kế
	if not running then return end
	if not currentTarget or not currentTarget.Parent then return end
	if not waypoints or wpIndex >= #waypoints then return end
	wpIndex += 1
	local nextWP = waypoints[wpIndex]
	if nextWP then
		hum:MoveTo(nextWP.Position)
	end
end

local function computePath(destPos)
	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true
	})
	path:ComputeAsync(hrp.Position, destPos)
	if path.Status == Enum.PathStatus.Success then
		currentPath = path
		waypoints = path:GetWaypoints()
		wpIndex = 1
		if #waypoints > 0 then
			if moveConn then moveConn:Disconnect() end
			moveConn = hum.MoveToFinished:Connect(onMoveFinished)
			hum:MoveTo(waypoints[wpIndex].Position)
			return true
		end
	end
	return false
end

--== GUI (đơn giản, kéo được, 1 menu) ==--
-- Dọn GUI cũ nếu có
pcall(function()
	local old = lp:WaitForChild("PlayerGui"):FindFirstChild("Menu_TT")
	if old then old:Destroy() end
end)

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
spdInput.Text = tostring(turnSpeed)
spdInput.PlaceholderText = "2"
spdInput.Font = Enum.Font.Gotham
spdInput.TextSize = 16
spdInput.TextColor3 = Color3.fromRGB(230,230,230)
spdInput.Parent = frame

local hpLabel = Instance.new("TextLabel")
hpLabel.Size = UDim2.new(1, -32, 0, 30)
hpLabel.Position = UDim2.new(0, 16, 0, 140)
hpLabel.BackgroundTransparency = 1
hpLabel.Text = "Máu mục tiêu: ..."
hpLabel.Font = Enum.Font.GothamSemibold
hpLabel.TextSize = 16
hpLabel.TextColor3 = Color3.fromRGB(255, 70, 70)
hpLabel.Parent = frame

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

local nameText = Instance.new("TextLabel")
nameText.Size = UDim2.new(1, 0, 0, 30)
nameText.Position = UDim2.new(0, 0, 0, 220)
nameText.BackgroundTransparency = 1
nameText.Text = "TT:dongphandzs1"
nameText.Font = Enum.Font.GothamBlack
nameText.TextSize = 22
nameText.TextColor3 = Color3.fromRGB(100,255,100)
nameText.Parent = frame

--== Nhập GUI ==--
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
		turnSpeed = v
	else
		spdInput.Text = tostring(turnSpeed)
	end
end)

--== Toggle Fram/Auto ==--
local function stopAll()
	running = false
	toggle.Text = "BẬT: Đánh Boss"
	if loopConn then loopConn:Disconnect() loopConn = nil end
	clearPath()
end

toggle.MouseButton1Click:Connect(function()
	running = not running
	toggle.Text = (running and "TẮT" or "BẬT") .. ": Đánh Boss"

	if not running then
		stopAll()
		return
	end

	-- khởi tạo mục tiêu & loop 1 lần duy nhất
	currentTarget = findNPC2()
	if not currentTarget then
		hpLabel.Text = "Máu mục tiêu: Không tìm thấy NPC2"
	end

	if loopConn then loopConn:Disconnect() loopConn = nil end
	loopConn = RunService.Heartbeat:Connect(function()
		if not running then return end

		-- validate target
		if (not currentTarget) or (not currentTarget.Parent) then
			currentTarget = findNPC2()
			clearPath()
			return
		end
		local h = currentTarget:FindFirstChildOfClass("Humanoid")
		local r = currentTarget:FindFirstChild("HumanoidRootPart")
		if not h or not r then
			currentTarget = nil
			clearPath()
			return
		end
		if h.Health <= 0 then
			hpLabel.Text = "Máu mục tiêu: Đã chết"
			currentTarget = nil
			clearPath()
			return
		end

		hpLabel.Text = "Máu mục tiêu: " .. math.floor(h.Health)

		local dist = (hrp.Position - r.Position).Magnitude
		if dist > radius + 3 then
			-- Tiếp cận bằng Pathfinding (recompute có cooldown)
			if tick() >= recomputeAt or (not currentPath) or (not waypoints) or (wpIndex >= #waypoints) then
				recomputeAt = tick() + recomputeCD
				if not computePath(r.Position) then
					-- fallback nhẹ: nếu path lỗi, MoveTo trực tiếp một nhịp ngắn
					hum:MoveTo(r.Position)
				end
			end
		else
			-- Trong phạm vi: chạy vòng + tấn công
			clearPath()
			local angle = tick() * turnSpeed
			local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
			local goal = r.Position + offset
			hum:MoveTo(goal)

			-- xoay mặt về mục tiêu (giữ Y để không lắc đầu)
			local look = Vector3.new(r.Position.X, hrp.Position.Y, r.Position.Z)
			hrp.CFrame = CFrame.new(hrp.Position, look)

			attack()
		end
	end)
end)

autoBtn.MouseButton1Click:Connect(function()
	autoAttack = not autoAttack
	autoBtn.Text = (autoAttack and "TẮT" or "BẬT") .. ": Auto Đánh"
end)

--== Kéo GUI mượt (không cần plugin) ==--
do
	local dragging, dragInput, dragStart, startPos
	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end

--== Khi nhân vật respawn: giữ GUI, reset state an toàn ==--
lp.CharacterAdded:Connect(function(nc)
	chr = nc
	hum = chr:WaitForChild("Humanoid")
	hrp = chr:WaitForChild("HumanoidRootPart")
	clearPath()
end)