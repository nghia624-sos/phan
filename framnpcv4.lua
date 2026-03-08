-- ================== SERVICES ==================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

-- ================== CONFIG ==================
local FRAM = false
local AUTO_LOOT = false
local AUTO_HEAL = false
local BOSS_FPS = false 

local TARGET_NAME = "citynpc"
local HEAL_ITEM_NAME = "băng gạc"
local HEAL_THRESHOLD = 0.75

local SAFE_DISTANCE = 10
local ORBIT_SPEED = 5
local ORBIT_HEIGHT = 0

local TOOL_COOLDOWN = 0.25
local LOOT_DISTANCE = 12
local LOOT_DELAY = 1
local DELAY_AFTER_KILL = 1

-- ================== STATE ==================
local lastAttack = 0
local orbitAngle = 0
local currentTarget = nil
local lastLoot = 0
local lastKillTime = 0
local waitingAfterKill = false
local healing = false
local lastHeal = 0

-- ================== HUMANOID FIX ==================
hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
hrp.CanCollide = false

-- ================== LOGIC FIX LAG (BOSS FPS) ==================
local function ApplyBossFPS()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
     Lighting.GlobalShadows = false
     Lighting.FogEnd = 9e9
    
    local function Optimize(v)
        if v:IsA("BasePart") or v:IsA("MeshPart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        elseif v:IsA("PostEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") then
            v.Enabled = false
        end
    end

    for _, v in pairs(game:GetDescendants()) do Optimize(v) end
end

-- ================== GUI (ĐÔNG PHAN HUB) ==================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "DongPhanHub" -- Đã đổi tên GUI
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 280, 0, 380)
main.Position = UDim2.new(0.5, -140, 0.5, -190)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 18)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "ĐÔNG PHAN HUB" -- Đã đổi tiêu đề hiển thị
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(0, 255, 180)

local fpsLabel = Instance.new("TextLabel", main)
fpsLabel.Size = UDim2.new(1, 0, 0, 20)
fpsLabel.Position = UDim2.new(0, 0, 0, 35)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: --"
fpsLabel.Font = Enum.Font.Code
fpsLabel.TextSize = 13
fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

-- ================== BUTTONS ==================
local function makeBtn(text, y)
    local b = Instance.new("TextButton", main)
    b.Size = UDim2.new(1, -40, 0, 36)
    b.Position = UDim2.new(0, 20, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 12)
    return b
end

local framBtn = makeBtn("BẬT FRAM", 65)
local lootBtn = makeBtn("AUTO LOOT: OFF", 107)
local healBtn = makeBtn("AUTO HEAL: OFF", 149)
local bossFpsBtn = makeBtn("BOSS FPS: OFF", 191)

-- ================== DISTANCE UI ==================
local distLabel = Instance.new("TextLabel", main)
distLabel.Size = UDim2.new(1, 0, 0, 25)
distLabel.Position = UDim2.new(0, 0, 0, 235)
distLabel.BackgroundTransparency = 1
distLabel.Font = Enum.Font.Gotham
distLabel.TextSize = 14
distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
distLabel.Text = "Khoảng cách: " .. SAFE_DISTANCE

local minus = Instance.new("TextButton", main)
minus.Size = UDim2.new(0, 40, 0, 32)
minus.Position = UDim2.new(0, 40, 0, 265)
minus.Text = "-"
minus.Font = Enum.Font.GothamBold
minus.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Instance.new("UICorner", minus)

local plus = Instance.new("TextButton", main)
plus.Size = UDim2.new(0, 40, 0, 32)
plus.Position = UDim2.new(1, -80, 0, 265)
plus.Text = "+"
plus.Font = Enum.Font.GothamBold
plus.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Instance.new("UICorner", plus)

-- ================== FUNCTIONS ==================
local function findNPC()
    local closest, minDist
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") 
        and v.Humanoid.Health > 0 and string.find(string.lower(v.Name), TARGET_NAME) then
            local d = (hrp.Position - v.HumanoidRootPart.Position).Magnitude
            if not minDist or d < minDist then
                minDist = d
                closest = v
            end
        end
    end
    return closest
end

local function attackWithTool()
    local tool = char:FindFirstChildOfClass("Tool") or player.Backpack:FindFirstChildOfClass("Tool")
    if not tool then return end
    if tool.Parent ~= char then tool.Parent = char end
    if tick() - lastAttack < TOOL_COOLDOWN then return end
    lastAttack = tick()
    tool:Activate()
end

-- ================== MAIN LOOP ==================
RunService.Heartbeat:Connect(function(dt)
    local fps = math.floor(1/dt)
    fpsLabel.Text = "FPS: " .. fps
    fpsLabel.TextColor3 = (fps < 30) and Color3.new(1, 0, 0) or Color3.new(0, 1, 0)

    if hum.Health <= 0 then return end

    if AUTO_LOOT and tick() - lastLoot >= LOOT_DELAY then
        lastLoot = tick()
        for _, p in pairs(workspace:GetDescendants()) do
            if p:IsA("ProximityPrompt") and p.Enabled and (p.Parent.Position - hrp.Position).Magnitude <= LOOT_DISTANCE then
                fireproximityprompt(p)
            end
        end
    end

    if AUTO_HEAL and not healing and hum.Health/hum.MaxHealth < 0.8 then
        local tool = player.Backpack:FindFirstChild(HEAL_ITEM_NAME) or char:FindFirstChild(HEAL_ITEM_NAME)
        if tool then
            healing = true
            task.spawn(function()
                hum:EquipTool(tool); task.wait(0.2); tool:Activate(); task.wait(1)
                healing = false
            end)
        end
    end

    if not FRAM then return end

    if waitingAfterKill then
        if tick() - lastKillTime >= DELAY_AFTER_KILL then waitingAfterKill = false else return end
    end

    if currentTarget and (not currentTarget.Parent or currentTarget.Humanoid.Health <= 0) then
        currentTarget = nil; lastKillTime = tick(); waitingAfterKill = true; return
    end

    if not currentTarget then
        currentTarget = findNPC(); orbitAngle = 0; return
    end

    local nhrp = currentTarget.HumanoidRootPart
    orbitAngle += ORBIT_SPEED * dt
    local pos = nhrp.Position + Vector3.new(math.cos(orbitAngle) * SAFE_DISTANCE, ORBIT_HEIGHT, math.sin(orbitAngle) * SAFE_DISTANCE)
    hrp.CFrame = CFrame.new(pos, nhrp.Position)
    hrp.Velocity = Vector3.new(0,0,0)
    
    attackWithTool()
end)

-- ================== UI EVENTS ==================
framBtn.MouseButton1Click:Connect(function()
    FRAM = not FRAM
    framBtn.Text = FRAM and "TẮT FRAM" or "BẬT FRAM"
    framBtn.BackgroundColor3 = FRAM and Color3.fromRGB(0, 160, 120) or Color3.fromRGB(40, 40, 40)
end)

bossFpsBtn.MouseButton1Click:Connect(function()
    BOSS_FPS = not BOSS_FPS
    bossFpsBtn.Text = BOSS_FPS and "BOSS FPS: ON" or "BOSS FPS: OFF"
    bossFpsBtn.BackgroundColor3 = BOSS_FPS and Color3.fromRGB(150, 0, 200) or Color3.fromRGB(40, 40, 40)
    if BOSS_FPS then ApplyBossFPS() end
end)

lootBtn.MouseButton1Click:Connect(function()
    AUTO_LOOT = not AUTO_LOOT
    lootBtn.Text = AUTO_LOOT and "AUTO LOOT: ON" or "AUTO LOOT: OFF"
    lootBtn.BackgroundColor3 = AUTO_LOOT and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(40, 40, 40)
end)

healBtn.MouseButton1Click:Connect(function()
    AUTO_HEAL = not AUTO_HEAL
    healBtn.Text = AUTO_HEAL and "AUTO HEAL: ON" or "AUTO HEAL: OFF"
    healBtn.BackgroundColor3 = AUTO_HEAL and Color3.fromRGB(60, 180, 80) or Color3.fromRGB(40, 40, 40)
end)

minus.MouseButton1Click:Connect(function()
    SAFE_DISTANCE = math.max(3, SAFE_DISTANCE - 1)
    distLabel.Text = "Khoảng cách: " .. SAFE_DISTANCE
end)

plus.MouseButton1Click:Connect(function()
    SAFE_DISTANCE += 1
    distLabel.Text = "Khoảng cách: " .. SAFE_DISTANCE
end)

print("ĐÔNG PHAN HUB Loaded!")
