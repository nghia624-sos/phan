local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

-- ====== CONFIG & STATE ======
local radius = 30
local speed = 2
local running = false
local autoAttack = false
local currentTarget = nil
local targetOffset = Vector3.new()
local orbitAngle = 0
local noclipEnabled = false

-- Auto-heal threshold (student requested <60)
local AUTO_HEAL_THRESHOLD = 60
-- Keywords to detect bandage/med items (case-insensitive)
local HEAL_KEYWORDS = {"bandage","băng","heal","med","kit"}

-- ====== GUI ======
local gui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
gui.Name = "Menu_TT"
gui.Enabled = true -- bật thẳng luôn

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 270)
frame.Position = UDim2.new(0.5, -150, 0.5, -135)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

-- Toggle Đánh Boss
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1, 0, 0, 40)
toggle.Position = UDim2.new(0, 0, 0, 0)
toggle.Text = "BẬT: Đánh Boss"
toggle.TextColor3 = Color3.new(1,1,1)
toggle.BackgroundColor3 = Color3.fromRGB(40,40,40)

-- Khoảng cách
local disLabel = Instance.new("TextLabel", frame)
disLabel.Text = "Khoảng cách:"
disLabel.Size = UDim2.new(0, 150, 0, 30)
disLabel.Position = UDim2.new(0, 10, 0, 50)
disLabel.TextColor3 = Color3.new(1,1,1)
disLabel.BackgroundTransparency = 1

local disInput = Instance.new("TextBox", frame)
disInput.Size = UDim2.new(0, 100, 0, 30)
disInput.Position = UDim2.new(0, 160, 0, 50)
disInput.Text = tostring(radius)
disInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
disInput.TextColor3 = Color3.new(1,1,1)

-- Tốc độ
local spdLabel = Instance.new("TextLabel", frame)
spdLabel.Text = "Tốc độ quay:"
spdLabel.Size = UDim2.new(0, 150, 0, 30)
spdLabel.Position = UDim2.new(0, 10, 0, 90)
spdLabel.TextColor3 = Color3.new(1,1,1)
spdLabel.BackgroundTransparency = 1

local spdInput = Instance.new("TextBox", frame)
spdInput.Size = UDim2.new(0, 100, 0, 30)
spdInput.Position = UDim2.new(0, 160, 0, 90)
spdInput.Text = tostring(speed)
spdInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
spdInput.TextColor3 = Color3.new(1,1,1)

-- HP label
local hpLabel = Instance.new("TextLabel", frame)
hpLabel.Size = UDim2.new(1, -20, 0, 30)
hpLabel.Position = UDim2.new(0, 10, 0, 130)
hpLabel.Text = "Máu mục tiêu: ..."
hpLabel.TextColor3 = Color3.new(1, 0, 0)
hpLabel.BackgroundTransparency = 1

-- Auto đánh (riêng)
local autoBtn = Instance.new("TextButton", frame)
autoBtn.Size = UDim2.new(1, 0, 0, 30)
autoBtn.Position = UDim2.new(0, 0, 0, 170)
autoBtn.Text = "BẬT: Auto Đánh"
autoBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
autoBtn.TextColor3 = Color3.new(1,1,1)

-- Noclip
local noclipBtn = Instance.new("TextButton", frame)
noclipBtn.Size = UDim2.new(1, 0, 0, 30)
noclipBtn.Position = UDim2.new(0, 0, 0, 200)
noclipBtn.Text = "BẬT: Noclip"
noclipBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
noclipBtn.TextColor3 = Color3.new(1,1,1)

-- Name label (giữ nguyên)
local nameText = Instance.new("TextLabel", frame)
nameText.Size = UDim2.new(1, 0, 0, 30)
nameText.Position = UDim2.new(0, 0, 0, 230)
nameText.Text = "TT:dongphandzs1"
nameText.TextColor3 = Color3.fromRGB(100,255,100)
nameText.BackgroundTransparency = 1
nameText.TextScaled = true

-- ====== Utility: tìm target NPC2 ======
local function getNPC2Target()
	for _,v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v ~= chr and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
			if string.find(string.lower(v.Name), "npc2") then
				return v
			end
		end
	end
	return nil
end

-- ====== MoveTo mượt tới mục tiêu ======
local function moveToTarget(target, timeout)
	timeout = timeout or 10
	if not target or not target:FindFirstChild("HumanoidRootPart") then return false end

	local reached = false
	local conn
	conn = RunService.Heartbeat:Connect(function()
		if not target or not target.Parent then return end
		local dist = (hrp.Position - target.HumanoidRootPart.Position).Magnitude
		if dist <= radius then
			reached = true
		end
	end)

	local t = 0
	while not reached and t < timeout and target and target:FindFirstChild("HumanoidRootPart") do
		hrp:MoveTo(target.HumanoidRootPart.Position)
		wait(0.15)
		t = t + 0.15
	end

	if conn then conn:Disconnect() end
	return reached
end

-- ====== Tấn công ======
local function attack()
	local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
	if tool then
		pcall(function() tool:Activate() end)
	end
end

-- ====== Auto-heal helpers ======
local function nameMatchesHealKeyword(name)
	if not name then return false end
	local lower = string.lower(name)
	for _,kw in ipairs(HEAL_KEYWORDS) do
		if string.find(lower, kw) then
			return true
		end
	end
	return false
end

-- Tìm tool heal trong Backpack hoặc Character
local function findHealTool()
	-- check character first (already equipped)
	for _,v in pairs(chr:GetChildren()) do
		if v:IsA("Tool") and nameMatchesHealKeyword(v.Name) then
			return v, "Character"
		end
	end
	-- then backpack
	local backpack = lp:FindFirstChildOfClass("Backpack")
	if backpack then
		for _,v in pairs(backpack:GetChildren()) do
			if v:IsA("Tool") and nameMatchesHealKeyword(v.Name) then
				return v, "Backpack"
			end
		end
	end
	-- maybe StarterGear
	local sg = lp:FindFirstChild("StarterGear")
	if sg then
		for _,v in pairs(sg:GetChildren()) do
			if v:IsA("Tool") and nameMatchesHealKeyword(v.Name) then
				return v, "StarterGear"
			end
		end
	end
	return nil, nil
end

-- Thực hiện heal bằng cách equip + Activate tool (heuristic)
local function useHealTool(tool, origin)
	if not tool then return false end
	pcall(function()
		-- Try equip if in backpack
		if origin == "Backpack" or origin == "StarterGear" then
			hum:EquipTool(tool)
			wait(0.15)
		end
		-- Try activate
		if tool and tool.Parent == chr then
			pcall(function() tool:Activate() end)
		elseif tool and tool.Parent == lp:FindFirstChildOfClass("Backpack") then
			-- try to move to character then activate
			hum:EquipTool(tool)
			wait(0.15)
			pcall(function() tool:Activate() end)
		end
	end)
	return true
end

-- Auto-heal loop (always enabled when script runs)
coroutine.wrap(function()
	while true do
		pcall(function()
			if hum and hum.Health and hum.Health <= AUTO_HEAL_THRESHOLD then
				-- tìm tool heal
				local tool, origin = findHealTool()
				if tool then
					useHealTool(tool, origin)
					-- chờ chút để heal kịp (tùy game)
					wait(1.2)
				end
			end
		end)
		wait(0.5)
	end
end)()

-- ====== Noclip ======
RunService.Stepped:Connect(function()
	if noclipEnabled then
		for _, part in pairs(chr:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

-- ====== Orbit (MoveTo -> Orbit) ======
RunService.Heartbeat:Connect(function(deltaTime)
	if running and currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
		local targetHRP = currentTarget.HumanoidRootPart
		if not currentTarget or not currentTarget.Parent or currentTarget:FindFirstChild("Humanoid") == nil then
			-- invalid target
			running = false
			currentTarget = nil
			targetOffset = Vector3.new()
			toggle.Text = "BẬT: Đánh Boss"
			hpLabel.Text = "Máu mục tiêu: Không tìm thấy"
			return
		end

		if currentTarget.Humanoid.Health <= 0 then
			-- dead
			running = false
			autoAttack = false
			currentTarget = nil
			targetOffset = Vector3.new()
			toggle.Text = "BẬT: Đánh Boss"
			autoBtn.Text = "BẬT: Auto Đánh"
			hpLabel.Text = "Máu mục tiêu: Đã chết"
			return
		end

		-- Nếu chưa ở gần target thì MoveTo
		local dist = (hrp.Position - targetHRP.Position).Magnitude
		if dist > radius then
			-- request mượt di chuyển về hướng target (MoveTo mỗi vòng lặp)
			hrp:MoveTo(targetHRP.Position)
			return
		end

		-- Tạo offset lần đầu
		if targetOffset == Vector3.new() then
			local dir = (hrp.Position - targetHRP.Position)
			local horizDir = Vector3.new(dir.X, 0, dir.Z)
			local len = horizDir.Magnitude
			if len == 0 then len = 1 end
			targetOffset = horizDir.Unit * math.min(len, radius)
			orbitAngle = math.atan2(targetOffset.Z, targetOffset.X)
		end

		-- Tính vị trí mới
		orbitAngle = orbitAngle + speed * deltaTime
		local offset = Vector3.new(math.cos(orbitAngle), 0, math.sin(orbitAngle)) * radius
		local goalPos = targetHRP.Position + offset

		-- Tween mượt đến vị trí orbit
		local ok, tween = pcall(function()
			return TweenService:Create(hrp, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {CFrame = CFrame.new(goalPos, targetHRP.Position)})
		end)
		if ok and tween then
			tween:Play()
		else
			hrp.CFrame = CFrame.new(goalPos, targetHRP.Position)
		end

		-- Quay mặt về phía mục tiêu
		hum.AutoRotate = false
		pcall(function() hrp.CFrame = CFrame.new(hrp.Position, targetHRP.Position) end)

		-- Auto đánh nếu bật
		if autoAttack then
			attack()
		end

		-- Cập nhật HP label
		pcall(function()
			hpLabel.Text = "Máu mục tiêu: " .. math.floor(currentTarget.Humanoid.Health)
		end)
	elseif running then
		-- Reset nếu không tìm thấy mục tiêu
		running = false
		autoAttack = false
		currentTarget = nil
		targetOffset = Vector3.new()
		toggle.Text = "BẬT: Đánh Boss"
		autoBtn.Text = "BẬT: Auto Đánh"
		hpLabel.Text = "Máu mục tiêu: Không tìm thấy"
	end
end)

-- ====== Toggle behavior: khi bật -> tìm NPC2 -> MoveTo -> orbit ======
toggle.MouseButton1Click:Connect(function()
	running = not running
	if running then
		currentTarget = getNPC2Target()
		targetOffset = Vector3.new()
		if currentTarget then
			-- start a small coroutine to MoveTo once (orbit loop also checks distance)
			coroutine.wrap(function()
				moveToTarget(currentTarget, 12)
			end)()
		else
			-- không tìm thấy NPC2
			hpLabel.Text = "Máu mục tiêu: Không tìm thấy NPC2"
		end
	end
	toggle.Text = (running and "TẮT" or "BẬT") .. ": Đánh Boss"
end)

-- Auto đánh riêng toggle
autoBtn.MouseButton1Click:Connect(function()
	autoAttack = not autoAttack
	autoBtn.Text = (autoAttack and "TẮT" or "BẬT") .. ": Auto Đánh"
end)

-- Noclip toggle
noclipBtn.MouseButton1Click:Connect(function()
	noclipEnabled = not noclipEnabled
	noclipBtn.Text = (noclipEnabled and "TẮT" or "BẬT") .. ": Noclip"
end)

-- Cập nhật radius & speed từ GUI
disInput.FocusLost:Connect(function()
	radius = tonumber(disInput.Text) or radius
end)
spdInput.FocusLost:Connect(function()
	speed = tonumber(spdInput.Text) or speed
end)

-- Safety: cập nhật character refs khi respawn
lp.CharacterAdded:Connect(function(c)
	chr = c
	hum = chr:WaitForChild("Humanoid")
	hrp = chr:WaitForChild("HumanoidRootPart")
end)

       --heal---
if getgenv().NM_LOADED then
    warn("Script đã chạy, bỏ qua!")
    return
end
getgenv().NM_LOADED = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

local framBoss = false
local radius = 10
local speed = 8

-- ====== Auto Heal Settings ======
local healThreshold = 60 -- máu ≤ 60 thì heal
local healCooldown = false

local function getWeapon()
    for _, tool in pairs(lp.Backpack:GetChildren()) do
        if tool:IsA("Tool") and not string.find(tool.Name:lower(),"bandage") 
        and not string.find(tool.Name:lower(),"med") 
        and not string.find(tool.Name:lower(),"kit") 
        and not string.find(tool.Name:lower(),"băng") then
            return tool
        end
    end
    return nil
end

local function getBandage()
    for _, tool in pairs(lp.Backpack:GetChildren()) do
        local name = tool.Name:lower()
        if name:find("bandage") or name:find("med") or name:find("kit") or name:find("băng") then
            return tool
        end
    end
    return nil
end

local function autoHeal()
    if healCooldown then return end
    if hum.Health <= healThreshold then
        local bandage = getBandage()
        if bandage then
            healCooldown = true
            -- Lưu vũ khí hiện tại
            local currentTool = chr:FindFirstChildOfClass("Tool") or getWeapon()
            -- Equip băng gạc
            bandage.Parent = chr
            task.wait(0.3)
            hum:EquipTool(bandage)
            task.wait(3) -- thời gian heal
            -- Cầm lại vũ khí
            if currentTool and currentTool.Parent == lp.Backpack then
                currentTool.Parent = chr
                hum:EquipTool(currentTool)
            end
            task.wait(1)
            healCooldown = false
        end
    end
end

-- ====== Tìm Boss ======
local function findBoss()
    for _, npc in pairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Humanoid") then
            if string.find(npc.Name:lower(),"npc2") then
                return npc
            end
        end
    end
    return nil
end

-- ====== MoveTo Boss ======
local function moveToTarget(target)
    local path = PathfindingService:CreatePath()
    path:ComputeAsync(hrp.Position, target.Position)
    path:MoveTo(hrp)
end

-- ====== Chạy vòng quanh ======
local function circleAround(target)
    local angle = tick()
    local pos = target.Position + Vector3.new(math.cos(angle)*radius, 0, math.sin(angle)*radius)
    TweenService:Create(hrp, TweenInfo.new(1/speed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos, target.Position)}):Play()
end

-- ====== Fram Loop ======
RunService.Heartbeat:Connect(function()
    autoHeal()
    if framBoss then
        local boss = findBoss()
        if boss then
            local dist = (boss.HumanoidRootPart.Position - hrp.Position).Magnitude
            if dist > radius+3 then
                hrp.CFrame = hrp.CFrame + (boss.HumanoidRootPart.Position - hrp.Position).Unit * 0.5
            else
                circleAround(boss.HumanoidRootPart)
            end
        end
    end
end)

-- ====== GUI ======
local ScreenGui = Instance.new("ScreenGui", lp.PlayerGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0.3, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true

local Btn = Instance.new("TextButton", Frame)
Btn.Size = UDim2.new(1, 0, 0.5, 0)
Btn.Text = "Bật/Tắt Fram Boss"
Btn.MouseButton1Click:Connect(function()
    framBoss = not framBoss
    Btn.Text = framBoss and "Fram Boss: ON" or "Fram Boss: OFF"
end)

local SlidLabel = Instance.new("TextLabel", Frame)
SlidLabel.Size = UDim2.new(1, 0, 0.5, 0)
SlidLabel.Position = UDim2.new(0, 0, 0.5, 0)
SlidLabel.Text = "Auto Heal ≤ " .. healThreshold