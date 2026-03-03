-- ================== SERVICES ==================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

-- ================== CONFIG ==================
local SPEED_A = 6 
local SPEED_B = 6 
local REACH_DIST = 1
local AUTO_ATTACK_DELAY = 0.1
local NPC_NAME = "npc2"

-- AUTO PICK & HEAL
local AUTO_PICK = false
local PICK_DISTANCE = 18
local AUTO_HEAL = true
local HEAL_ITEM_NAME = "băng gạc"
local HEAL_THRESHOLD = 0.75
local HEAL_COOLDOWN = 2.2
local healing = false
local lastHeal = 0

-- CAM
local CAM_HEIGHT = 40

-- ================== WAYPOINTS ==================
local WaypointsA = {
	Vector3.new(-2793.10, 238.64, -1770.73),
	Vector3.new(-2816.25, 238.64, -1767.14),
	Vector3.new(-2814.50, 238.64, -1736.67),
	Vector3.new(-2790.56, 238.64, -1735.15),
	Vector3.new(-2768.30, 238.64, -1736.27),
	Vector3.new(-2765.91, 238.64, -1762.51),
}

local WaypointsB = {
	Vector3.new(-2790, 238, -1772),
	Vector3.new(-2816, 238, -1751),
	Vector3.new(-2794, 238, -1735),
	Vector3.new(-2765, 238, -1754)
}

-- ================== STATE ==================
local FARM_A_ENABLED = false
local FARM_B_ENABLED = false
local AUTO_CYCLE = false
local CAM_ON = false
local currentIndex = 1
local lastAttack = 0
local nextMode = "A" -- Biến để biết mode tiếp theo cần bật là gì

-- ================== UTILS ==================
local function getNPC()
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") then
			if string.find(v.Name:lower(), NPC_NAME:lower()) then
				local h = v:FindFirstChild("Humanoid")
				if h and h.Health > 0 then return v end
			end
		end
	end
	return nil
end

local function faceTarget(npc)
	if not npc then return end
	local pos = npc.HumanoidRootPart.Position
	hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(pos.X, hrp.Position.Y, pos.Z))
end

local function moveStep(targetPos, dt, speed)
	local dir = targetPos - hrp.Position
	if dir.Magnitude <= REACH_DIST then return true end
	hrp.CFrame += dir.Unit * math.min(speed * dt * 60, dir.Magnitude)
	return false
end

-- ================== GUI ==================
local gui = Instance.new("ScreenGui", game.CoreGui)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 280) 
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "ĐÔNG PHAN V2"
title.TextColor3 = Color3.fromRGB(0, 255, 170)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold

local function makeBtn(text, y, widthScale)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(widthScale or 0.86, 0, 0, 32)
	b.Position = UDim2.new(0.07, 0, y, 0)
	b.Text = text
	b.BackgroundColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	Instance.new("UICorner", b)
	return b
end

local function makeInput(text, y)
	local t = Instance.new("TextBox", frame)
	t.Size = UDim2.new(0.35, 0, 0, 32)
	t.Position = UDim2.new(0.58, 0, y, 0)
	t.Text = text
	t.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	t.TextColor3 = Color3.new(1, 1, 1)
	t.Font = Enum.Font.GothamBold
	Instance.new("UICorner", t)
	return t
end

local btnA = makeBtn("A: OFF", 0.15, 0.45)
local inputA = makeInput(tostring(SPEED_A), 0.15)
local btnB = makeBtn("B: OFF", 0.30, 0.45)
local inputB = makeInput(tostring(SPEED_B), 0.30)
local cycleBtn = makeBtn("AUTO CYCLE: OFF", 0.45)
local pickBtn = makeBtn("AUTO PICK: OFF", 0.60)
local camBtn = makeBtn("CAM: OFF", 0.75)

-- ================== LOGIC HÀNH ĐỘNG ==================
local function stopAllFarm()
	FARM_A_ENABLED = false
	FARM_B_ENABLED = false
	btnA.Text = "A: OFF"
	btnB.Text = "B: OFF"
end

cycleBtn.MouseButton1Click:Connect(function()
	AUTO_CYCLE = not AUTO_CYCLE
	cycleBtn.Text = AUTO_CYCLE and "AUTO CYCLE: ON" or "AUTO CYCLE: OFF"
	cycleBtn.BackgroundColor3 = AUTO_CYCLE and Color3.fromRGB(0, 255, 150) or Color3.new(1,1,1)
	if AUTO_CYCLE then
		stopAllFarm()
		nextMode = "A" -- Luôn bắt đầu từ A khi nhấn nút
	else
		stopAllFarm()
	end
end)

btnA.MouseButton1Click:Connect(function()
	AUTO_CYCLE = false
	cycleBtn.Text = "AUTO CYCLE: OFF"
	cycleBtn.BackgroundColor3 = Color3.new(1,1,1)
	FARM_A_ENABLED = not FARM_A_ENABLED
	FARM_B_ENABLED = false
	btnA.Text = FARM_A_ENABLED and "A: ON" or "A: OFF"
	btnB.Text = "B: OFF"
	currentIndex = 1
end)

btnB.MouseButton1Click:Connect(function()
	AUTO_CYCLE = false
	cycleBtn.Text = "AUTO CYCLE: OFF"
	cycleBtn.BackgroundColor3 = Color3.new(1,1,1)
	FARM_B_ENABLED = not FARM_B_ENABLED
	FARM_A_ENABLED = false
	btnB.Text = FARM_B_ENABLED and "B: ON" or "B: OFF"
	btnA.Text = "A: OFF"
	currentIndex = 1
end)

inputA.FocusLost:Connect(function() SPEED_A = tonumber(inputA.Text) or 6 end)
inputB.FocusLost:Connect(function() SPEED_B = tonumber(inputB.Text) or 6 end)
pickBtn.MouseButton1Click:Connect(function()
	AUTO_PICK = not AUTO_PICK
	pickBtn.Text = AUTO_PICK and "AUTO PICK: ON" or "AUTO PICK: OFF"
end)
camBtn.MouseButton1Click:Connect(function()
	CAM_ON = not CAM_ON
	camBtn.Text = CAM_ON and "CAM: ON" or "CAM: OFF"
end)

-- HP Bar
local hpBg = Instance.new("Frame", gui)
hpBg.Size = UDim2.new(0, 280, 0, 20)
hpBg.Position = UDim2.new(0.5, -140, 0.05, 0)
hpBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
hpBg.Visible = false
local hpFill = Instance.new("Frame", hpBg)
hpFill.Size = UDim2.new(1, 0, 1, 0)
hpFill.BackgroundColor3 = Color3.fromRGB(255, 0, 50)

-- ================== AUTO HEAL ==================
RunService.Heartbeat:Connect(function()
	if not AUTO_HEAL or healing then return end
	if tick() - lastHeal < HEAL_COOLDOWN then return end
	if humanoid.Health / humanoid.MaxHealth >= HEAL_THRESHOLD then return end
	local backpack = player.Backpack:GetChildren()
	local charItems = char:GetChildren()
	local healTool = nil
	for _, i in ipairs(backpack) do if i:IsA("Tool") and string.find(i.Name:lower(), HEAL_ITEM_NAME) then healTool = i break end end
	if not healTool then for _, i in ipairs(charItems) do if i:IsA("Tool") and string.find(i.Name:lower(), HEAL_ITEM_NAME) then healTool = i break end end end
	if healTool then
		healing = true
		lastHeal = tick()
		task.spawn(function()
			local old = char:FindFirstChildOfClass("Tool")
			humanoid:EquipTool(healTool)
			task.wait(0.3)
			healTool:Activate()
			task.wait(1.5)
			if old and old.Parent then humanoid:EquipTool(old) end
			healing = false
		end)
	end
end)

-- ================== MAIN LOOP ==================
RunService.Heartbeat:Connect(function(dt)
	-- Auto Pick
	if AUTO_PICK then
		for _, p in ipairs(workspace:GetDescendants()) do
			if p:IsA("ProximityPrompt") and p.Enabled and (p.Parent.Position - hrp.Position).Magnitude <= PICK_DISTANCE then
				pcall(function() fireproximityprompt(p) end)
			end
		end
	end

	-- Cam
	if CAM_ON then
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = CFrame.new(hrp.Position + Vector3.new(0, CAM_HEIGHT, 0), hrp.Position)
	else
		camera.CameraType = Enum.CameraType.Custom
	end

	local npc = getNPC()

	-- LOGIC AUTO CYCLE (A <-> B dựa trên NPC)
	if AUTO_CYCLE then
		if npc then -- NPC xuất hiện và còn sống
			if nextMode == "A" and not FARM_A_ENABLED then
				FARM_A_ENABLED = true
				FARM_B_ENABLED = false
				btnA.Text = "A: ON"
				btnB.Text = "B: OFF"
				currentIndex = 1
			elseif nextMode == "B" and not FARM_B_ENABLED then
				FARM_B_ENABLED = true
				FARM_A_ENABLED = false
				btnB.Text = "B: ON"
				btnA.Text = "A: OFF"
				currentIndex = 1
			end
		else -- NPC chết hoặc chưa xuất hiện
			if FARM_A_ENABLED then
				FARM_A_ENABLED = false
				btnA.Text = "A: OFF"
				nextMode = "B" -- Chuẩn bị để khi NPC hồi sinh sẽ bật B
			elseif FARM_B_ENABLED then
				FARM_B_ENABLED = false
				btnB.Text = "B: OFF"
				nextMode = "A" -- Chuẩn bị để khi NPC hồi sinh sẽ bật A
			end
		end
	end

	-- DI CHUYỂN VÀ TẤN CÔNG
	if FARM_A_ENABLED or FARM_B_ENABLED then
		local path = FARM_A_ENABLED and WaypointsA or WaypointsB
		local speed = FARM_A_ENABLED and SPEED_A or SPEED_B
		
		if moveStep(path[currentIndex], dt, speed) then
			currentIndex = currentIndex % #path + 1
		end

		if npc then
			hpBg.Visible = true
			faceTarget(npc)
			hpFill.Size = UDim2.new(math.clamp(npc.Humanoid.Health/npc.Humanoid.MaxHealth, 0, 1), 0, 1, 0)
			local tool = char:FindFirstChildOfClass("Tool")
			if tool and not healing and tick() - lastAttack >= AUTO_ATTACK_DELAY then
				lastAttack = tick()
				tool:Activate()
			end
		else
			hpBg.Visible = false
		end
	else
		hpBg.Visible = false
	end
end)
