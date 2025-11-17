local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 250)
frame.Position = UDim2.new(0.05,0,0.4,0)
frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
frame.Active = true
frame.Draggable = true

-- Auto Attack toggle
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0,200,0,40)
toggle.Position = UDim2.new(0,10,0,10)
toggle.Text = "Bật Auto Đánh"
toggle.BackgroundColor3 = Color3.fromRGB(80,120,200)
toggle.TextColor3 = Color3.new(1,1,1)

-- HP label
local hpLabel = Instance.new("TextLabel", frame)
hpLabel.Size = UDim2.new(0,200,0,40)
hpLabel.Position = UDim2.new(0,10,0,55)
hpLabel.Text = "HP NPC2: None"
hpLabel.BackgroundColor3 = Color3.fromRGB(60,60,60)
hpLabel.TextColor3 = Color3.new(1,1,1)

-- Damage label
local dmgLabel = Instance.new("TextLabel", frame)
dmgLabel.Size = UDim2.new(0,200,0,40)
dmgLabel.Position = UDim2.new(0,10,0,100)
dmgLabel.Text = "Damage: 0"
dmgLabel.BackgroundColor3 = Color3.fromRGB(80,60,60)
dmgLabel.TextColor3 = Color3.new(1,1,1)

-- Noclip toggle
local noclipBtn = Instance.new("TextButton", frame)
noclipBtn.Size = UDim2.new(0,200,0,40)
noclipBtn.Position = UDim2.new(0,10,0,145)
noclipBtn.Text = "Bật Noclip"
noclipBtn.BackgroundColor3 = Color3.fromRGB(120,80,200)
noclipBtn.TextColor3 = Color3.new(1,1,1)

-- Auto Pickup toggle
local pickupBtn = Instance.new("TextButton", frame)
pickupBtn.Size = UDim2.new(0,200,0,40)
pickupBtn.Position = UDim2.new(0,10,0,190)
pickupBtn.Text = "Bật Auto Nhặt"
pickupBtn.BackgroundColor3 = Color3.fromRGB(80,200,120)
pickupBtn.TextColor3 = Color3.new(1,1,1)

-- Logic
local auto = false
local noclip = false
local autopick = false
local target = nil
local lastNpc2Hp = nil
local currentPrompt = nil

-- Tìm NPC2
local function getNpc2()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:FindFirstChild("Humanoid") and v.Name:lower():find("npc2") then
            return v
        end
    end
    return nil
end

-- Damage bay lên
local function showDamage(target, dmg)
    if not target:FindFirstChild("Head") then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = target.Head
    billboard.Size = UDim2.new(0,100,0,40)
    billboard.StudsOffset = Vector3.new(0,2,0)
    billboard.AlwaysOnTop = true
    billboard.Parent = target

    local text = Instance.new("TextLabel", billboard)
    text.Size = UDim2.new(1,0,1,0)
    text.BackgroundTransparency = 1
    text.Text = "-"..tostring(dmg)
    text.TextColor3 = Color3.fromRGB(255,50,50)
    text.TextScaled = true
    text.Font = Enum.Font.SourceSansBold

    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tween = TweenService:Create(billboard, tweenInfo, {StudsOffset = Vector3.new(0,4,0)})
    tween:Play()
    game.Debris:AddItem(billboard, 1.2)
end

-- Toggle Auto
toggle.MouseButton1Click:Connect(function()
    auto = not auto
    if auto then
        toggle.Text = "Tắt Auto Đánh"
        toggle.BackgroundColor3 = Color3.fromRGB(200,80,80)
    else
        toggle.Text = "Bật Auto Đánh"
        toggle.BackgroundColor3 = Color3.fromRGB(80,120,200)
        hpLabel.Text = "HP NPC2: None"
        dmgLabel.Text = "Damage: 0"
        target = nil
    end
end)

-- Toggle Noclip
noclipBtn.MouseButton1Click:Connect(function()
    noclip = not noclip
    if noclip then
        noclipBtn.Text = "Tắt Noclip"
        noclipBtn.BackgroundColor3 = Color3.fromRGB(200,120,80)
    else
        noclipBtn.Text = "Bật Noclip"
        noclipBtn.BackgroundColor3 = Color3.fromRGB(120,80,200)
    end
end)

-- Toggle Auto Pickup
pickupBtn.MouseButton1Click:Connect(function()
    autopick = not autopick
    if autopick then
        pickupBtn.Text = "Tắt Auto Nhặt"
        pickupBtn.BackgroundColor3 = Color3.fromRGB(200,80,120)
    else
        pickupBtn.Text = "Bật Auto Nhặt"
        pickupBtn.BackgroundColor3 = Color3.fromRGB(80,200,120)
        currentPrompt = nil
    end
end)

-- Main Loop
RunService.Heartbeat:Connect(function()
    if auto and char and hrp then
        local npc2 = getNpc2()
        if npc2 and npc2:FindFirstChild("Humanoid") then
            local humTarget = npc2.Humanoid
            hpLabel.Text = "HP NPC2: " .. math.floor(humTarget.Health) .. "/" .. math.floor(humTarget.MaxHealth)

            -- Quay nhân vật về phía NPC2
            local dir = (npc2.PrimaryPart.Position - hrp.Position).unit
            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(dir.X,0,dir.Z))

            -- Auto attack NPC2    
            local tool = char:FindFirstChildOfClass("Tool")    
            if tool then    
                tool:Activate()    
            end    

            -- Detect damage gây ra    
            if lastNpc2Hp and humTarget.Health < lastNpc2Hp then    
                local dmg = math.floor(lastNpc2Hp - humTarget.Health)    
                dmgLabel.Text = "Damage: "..dmg    
                showDamage(npc2, dmg)    
            end    
            lastNpc2Hp = humTarget.Health    
        else    
            hpLabel.Text = "HP NPC2: None"    
            dmgLabel.Text = "Damage: 0"    
            lastNpc2Hp = nil    
        end
    end

    -- Noclip hoạt động
    if noclip and char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end

    -- Auto Pickup hoạt động
    if autopick and char and hrp then
        -- Nếu đang giữ prompt mà nó biến mất thì bỏ
        if currentPrompt and (not currentPrompt:IsDescendantOf(workspace) or not currentPrompt.Enabled) then
            currentPrompt = nil
        end

        -- Nếu chưa có prompt thì tìm cái gần nhất
        if not currentPrompt then
            local nearest, dist = nil, 20
            for _, prompt in pairs(workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and prompt.Enabled and prompt.Parent:IsA("BasePart") then
                    local d = (prompt.Parent.Position - hrp.Position).Magnitude
                    if d < dist then
                        nearest, dist = prompt, d
                    end
                end
            end
            if nearest then
                currentPrompt = nearest
                -- Giữ dính prompt
                pcall(function()
                    fireproximityprompt(nearest, math.huge)
                end)
            end
        end
    end
end)*