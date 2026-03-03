-- =================================================
-- DONG PHAN V23 - AUTO CYCLE (10s ON / 3s OFF)
-- =================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

-- ================== CONFIG DEFAULT ==================
local FRAM = false
local AUTO_LOOT = false
local AUTO_HEAL = false

local TARGET_NAME = "citynpc"
local HEAL_ITEM_NAME = "băng gạc"
local HEAL_THRESHOLD = 0.70 

local UP_TIME = 0.7
local BACK_TIME = 1.0
local UP_HEIGHT = 7      
local BACK_DISTANCE = 5  

local ON_DURATION = 10.0  -- Thời gian tự chạy (10 giây)
local OFF_DURATION = 3.0  -- Thời gian tự nghỉ (3 giây)
local TOOL_COOLDOWN = 0.1
local LOOT_DISTANCE = 15

-- ================== STATE ==================
local currentTarget = nil
local phaseTimer = 0
local currentPhase = "Top"
local lastAttack = 0
local lastLoot = 0
local lastHeal = 0
local healing = false
local cycleThread = nil -- Luồng quản lý chu kỳ 10s/3s

-- Chống rung & Vật lý
hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
hrp.CanCollide = false

-- ================== GUI UI ==================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "CityNPC_V23_Cycle"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 320, 0, 420) 
main.Position = UDim2.new(0.5, -160, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(10, 15, 20)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 15)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "V23 - CYCLE 10S ON / 3S OFF"
title.TextColor3 = Color3.fromRGB(255, 100, 255)
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1

local function createInput(name, y, default)
    local label = Instance.new("TextLabel", main)
    label.Size = UDim2.new(0, 200, 0, 30)
    label.Position = UDim2.new(0, 20, 0, y)
    label.Text = name
    label.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox", main)
    box.Size = UDim2.new(0, 60, 0, 25)
    box.Position = UDim2.new(0, 230, 0, y + 2)
    box.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
    box.Text = tostring(default)
    box.TextColor3 = Color3.new(1, 1, 1)
    box.Font = Enum.Font.GothamBold
    Instance.new("UICorner", box)
    return box
end

local upTimeInput = createInput("Thời gian trên đầu (s):", 50, UP_TIME)
local backTimeInput = createInput("Thời gian sau lưng (s):", 85, BACK_TIME)
local upHeightInput = createInput("Độ cao trên đầu (studs):", 120, UP_HEIGHT)
local backDistInput = createInput("Khoảng cách sau lưng (studs):", 155, BACK_DISTANCE)
local onDurInput = createInput("Thời gian bật ON (s):", 190, ON_DURATION)

local function makeBtn(text, y, color)
    local b = Instance.new("TextButton", main)
    b.Size = UDim2.new(1, -40, 0, 35)
    b.Position = UDim2.new(0, 20, 0, y)
    b.BackgroundColor3 = color
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", b)
    return b
end

local farmBtn = makeBtn("FARM: OFF", 235, Color3.fromRGB(45, 45, 45))
local lootBtn = makeBtn("LOOT: OFF", 280, Color3.fromRGB(45, 45, 45))
local healBtn = makeBtn("HEAL: OFF", 325, Color3.fromRGB(45, 45, 45))

-- ================== CẬP NHẬT UI ==================
local function updateFarmUI()
    if FRAM then
        farmBtn.Text = "FARM: ON"
        farmBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        farmBtn.Text = "FARM: OFF"
        farmBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end
end

-- ================== LOGIC CHU KỲ (10S ON / 3S OFF) ==================
local function startCycle()
    if cycleThread then task.cancel(cycleThread) end
    cycleThread = task.spawn(function()
        while true do
            -- Giai đoạn ON (10 giây)
            FRAM = true
            updateFarmUI()
            task.wait(tonumber(onDurInput.Text) or ON_DURATION)
            
            -- Giai đoạn OFF (3 giây)
            FRAM = false
            updateFarmUI()
            currentTarget = nil -- Xóa mục tiêu để đứng yên
            task.wait(OFF_DURATION)
        end
    end)
end

local function stopCycle()
    if cycleThread then 
        task.cancel(cycleThread) 
        cycleThread = nil
    end
    FRAM = false
    updateFarmUI()
end

-- ================== TÌM NPC ==================
local function findNPC()
    local closest, minDist
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") 
        and v.Humanoid.Health > 0 and string.find(string.lower(v.Name), string.lower(TARGET_NAME)) then
            local d = (hrp.Position - v.HumanoidRootPart.Position).Magnitude
            if not minDist or d < minDist then
                minDist = d
                closest = v
            end
        end
    end
    return closest
end

-- ================== VÒNG LẶP CHÍNH ==================
RunService:BindToRenderStep("FinalFarmV23", Enum.RenderPriority.Camera.Value - 1, function(dt)
    -- AUTO LOOT
    if AUTO_LOOT and tick() - lastLoot > 0.05 then
        lastLoot = tick()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") and v.Enabled then
                if (v.Parent.Position - hrp.Position).Magnitude <= LOOT_DISTANCE then
                    fireproximityprompt(v)
                end
            end
        end
    end

    -- AUTO HEAL
    if AUTO_HEAL and not healing and tick() - lastHeal > 1 then
        if (hum.Health / hum.MaxHealth) < HEAL_THRESHOLD then
            local tool = player.Backpack:FindFirstChild(HEAL_ITEM_NAME) or char:FindFirstChild(HEAL_ITEM_NAME)
            if tool then
                healing = true; lastHeal = tick()
                task.spawn(function()
                    local old = char:FindFirstChildOfClass("Tool")
                    hum:EquipTool(tool); task.wait(0.2); tool:Activate(); task.wait(0.5)
                    if old then hum:EquipTool(old) end
                    healing = false
                end)
            end
        end
    end

    -- KIỂM TRA TRẠNG THÁI FARM
    if not FRAM or hum.Health <= 0 then 
        hrp.Velocity = Vector3.new(0,0,0)
        return 
    end

    -- LOGIC NPC CHẾT VẪN GIỮ NGUYÊN (CFRAME TỚI XÁC)
    if currentTarget and (not currentTarget.Parent or currentTarget.Humanoid.Health <= 0) then
        hrp.CFrame = currentTarget.HumanoidRootPart.CFrame
        currentTarget = nil 
        return
    end

    -- TÌM NPC MỚI
    if not currentTarget then
        currentTarget = findNPC()
        phaseTimer = 0
        return
    end

    -- DI CHUYỂN CHIẾN ĐẤU
    local nhrp = currentTarget.HumanoidRootPart
    phaseTimer = phaseTimer + dt

    if currentPhase == "Top" then
        if phaseTimer >= (tonumber(upTimeInput.Text) or UP_TIME) then currentPhase = "Back"; phaseTimer = 0 end
    else
        if phaseTimer >= (tonumber(backTimeInput.Text) or BACK_TIME) then currentPhase = "Top"; phaseTimer = 0 end
    end

    if currentPhase == "Top" then
        hrp.CFrame = nhrp.CFrame * CFrame.new(0, tonumber(upHeightInput.Text) or UP_HEIGHT, 0) * CFrame.Angles(math.rad(-90), 0, 0)
    else
        hrp.CFrame = nhrp.CFrame * CFrame.new(0, 0, tonumber(backDistInput.Text) or BACK_DISTANCE)
    end
    
    hrp.Velocity = Vector3.new(0,0,0)

    -- AUTO ATTACK
    local tool = char:FindFirstChildOfClass("Tool") or player.Backpack:FindFirstChildOfClass("Tool")
    if tool then
        if tool.Parent ~= char then tool.Parent = char end
        if tick() - lastAttack >= TOOL_COOLDOWN then
            lastAttack = tick()
            tool:Activate()
        end
    end
end)

-- SỰ KIỆN NÚT BẤM (KHỞI ĐỘNG CHU KỲ)
farmBtn.MouseButton1Click:Connect(function()
    if not cycleThread then
        startCycle() -- Bắt đầu chu kỳ 10s ON / 3s OFF
    else
        stopCycle() -- Dừng hẳn chu kỳ
    end
end)

lootBtn.MouseButton1Click:Connect(function()
    AUTO_LOOT = not AUTO_LOOT
    lootBtn.Text = AUTO_LOOT and "LOOT: ON" or "LOOT: OFF"
    lootBtn.BackgroundColor3 = AUTO_LOOT and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(45, 45, 45)
end)

healBtn.MouseButton1Click:Connect(function()
    AUTO_HEAL = not AUTO_HEAL
    healBtn.Text = AUTO_HEAL and "HEAL: ON" or "HEAL: OFF"
    healBtn.BackgroundColor3 = AUTO_HEAL and Color3.fromRGB(180, 100, 0) or Color3.fromRGB(45, 45, 45)
end)