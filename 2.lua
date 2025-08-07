-- TT:dongphandzs1 - Fram CityNPC by NghiaMinh (KRNL Mobile)

-- Variables
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local autoFram = false
local radius = 10
local speed = 3
local target = nil
local guiVisible = true

-- Function: Find closest NPC containing 'CityNPC'
function getTarget()
    local nearest, dist = nil, math.huge
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            if string.lower(v.Name):find("citynpc") and v.Humanoid.Health > 0 then
                local d = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
                if d < dist then
                    nearest = v
                    dist = d
                end
            end
        end
    end
    return nearest
end

-- Function: Move to target using MoveTo
function moveToTarget(npc)
    if not npc or not npc:FindFirstChild("HumanoidRootPart") then return end
    hum:MoveTo(npc.HumanoidRootPart.Position)
    hum.MoveToFinished:Wait()
end

-- Function: Circle around target
function circleTarget(npc)
    coroutine.wrap(function()
        while autoFram and npc and npc:FindFirstChild("HumanoidRootPart") and npc.Humanoid.Health > 0 do
            local angle = tick() * speed
            local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
            local goalPos = npc.HumanoidRootPart.Position + offset
            local tween = TweenService:Create(hrp, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
                CFrame = CFrame.new(goalPos, npc.HumanoidRootPart.Position)
            })
            tween:Play()
            wait(0.2)
        end
    end)()
end

-- Function: Auto attack
function autoAttack(npc)
    coroutine.wrap(function()
        while autoFram and npc and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 do
            local tool = player.Character:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
            wait(0.3)
        end
    end)()
end

-- Main loop: Lặp liên tục
spawn(function()
    while true do wait(0.5)
        if autoFram then
            target = getTarget()
            if target then
                moveToTarget(target)
                wait(0.2)
                circleTarget(target)
                autoAttack(target)
                -- Wait target die
                repeat wait() until not autoFram or not target or target.Humanoid.Health <= 0
                repeat wait() until not workspace:FindFirstChild(target.Name)
            else
                wait(1)
            end
        end
    end
end)

-- GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "TT_dongphandzs1"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Position = UDim2.new(0.02, 0, 0.2, 0)
Frame.Size = UDim2.new(0, 220, 0, 180)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local title = Instance.new("TextLabel", Frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "TT:dongphandzs1"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundColor3 = Color3.fromRGB(50,50,50)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

-- Toggle Button
local toggle = Instance.new("TextButton", Frame)
toggle.Position = UDim2.new(0,10,0,40)
toggle.Size = UDim2.new(0,200,0,30)
toggle.Text = "Bật Fram"
toggle.BackgroundColor3 = Color3.fromRGB(0,150,0)
toggle.TextColor3 = Color3.new(1,1,1)
toggle.Font = Enum.Font.SourceSans
toggle.TextSize = 16

toggle.MouseButton1Click:Connect(function()
    autoFram = not autoFram
    toggle.Text = autoFram and "Tắt Fram" or "Bật Fram"
    toggle.BackgroundColor3 = autoFram and Color3.fromRGB(150,0,0) or Color3.fromRGB(0,150,0)
end)

-- Bán kính
local radiusLabel = Instance.new("TextLabel", Frame)
radiusLabel.Position = UDim2.new(0,10,0,80)
radiusLabel.Size = UDim2.new(0,100,0,25)
radiusLabel.Text = "Bán kính:"
radiusLabel.TextColor3 = Color3.new(1,1,1)
radiusLabel.BackgroundTransparency = 1
radiusLabel.Font = Enum.Font.SourceSans
radiusLabel.TextSize = 16

local radiusBox = Instance.new("TextBox", Frame)
radiusBox.Position = UDim2.new(0,110,0,80)
radiusBox.Size = UDim2.new(0,90,0,25)
radiusBox.Text = tostring(radius)
radiusBox.Font = Enum.Font.SourceSans
radiusBox.TextSize = 16
radiusBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
radiusBox.TextColor3 = Color3.new(1,1,1)

radiusBox.FocusLost:Connect(function()
    local val = tonumber(radiusBox.Text)
    if val then radius = val end
end)

-- Tốc độ
local speedLabel = Instance.new("TextLabel", Frame)
speedLabel.Position = UDim2.new(0,10,0,115)
speedLabel.Size = UDim2.new(0,100,0,25)
speedLabel.Text = "Tốc độ:"
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.BackgroundTransparency = 1
speedLabel.Font = Enum.Font.SourceSans
speedLabel.TextSize = 16

local speedBox = Instance.new("TextBox", Frame)
speedBox.Position = UDim2.new(0,110,0,115)
speedBox.Size = UDim2.new(0,90,0,25)
speedBox.Text = tostring(speed)
speedBox.Font = Enum.Font.SourceSans
speedBox.TextSize = 16
speedBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
speedBox.TextColor3 = Color3.new(1,1,1)

speedBox.FocusLost:Connect(function()
    local val = tonumber(speedBox.Text)
    if val then speed = val end
end)