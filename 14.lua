local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

-- SETTINGS
local radius = 10
local speed = 5
local flyHeight = 1
local running = false
local noclip = false
local gui
local dragging, dragInput, dragStart, startPos

-- FUNCTION: tìm NPC phù hợp
local function findTarget()
    local closest = nil
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            local name = v.Name:lower()
            if name:find("citynpc") or name:find("npcity") then
                if v.Humanoid.Health > 0 then
                    closest = v
                    break
                end
            end
        end
    end
    return closest
end

-- FUNCTION: tween bộ tự nhiên
local function moveToTarget(target)
    local path = (target.HumanoidRootPart.Position - hrp.Position).Unit
    local tween = TweenService:Create(hrp, TweenInfo.new((hrp.Position - target.HumanoidRootPart.Position).Magnitude / speed), {Position = target.HumanoidRootPart.Position - path * radius + Vector3.new(0, flyHeight, 0)})
    tween:Play()
    tween.Completed:Wait()
end

-- FUNCTION: chạy vòng quanh
local function orbitTarget(target)
    local angle = 0
    while running and target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 do
        angle += speed * RunService.Heartbeat:Wait()
        local offset = Vector3.new(math.cos(angle) * radius, flyHeight, math.sin(angle) * radius)
        hrp.CFrame = CFrame.new(target.HumanoidRootPart.Position + offset, target.HumanoidRootPart.Position)
    end
end

-- FUNCTION: toggle Noclip
RunService.Stepped:Connect(function()
    if noclip then
        for _, v in ipairs(chr:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

-- FUNCTION: Fram Loop
local function startFram()
    while running do
        local target = findTarget()
        if target then
            moveToTarget(target)
            if (hrp.Position - target.HumanoidRootPart.Position).Magnitude <= radius + 2 then
                orbitTarget(target)
            end
            repeat wait() until not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0
        else
            wait(1)
        end
    end
end

-- GUI
gui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
gui.Name = "FramGui"
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 180, 0, 250)
frame.Position = UDim2.new(0, 50, 0, 150)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

local function makeButton(txt, y, callback)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = txt
    btn.TextColor3 = Color3.new(1,1,1)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local radiusBox = Instance.new("TextBox", frame)
radiusBox.Size = UDim2.new(1, 0, 0, 30)
radiusBox.Position = UDim2.new(0, 0, 0, 0)
radiusBox.Text = tostring(radius)
radiusBox.PlaceholderText = "Bán kính"

local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(1, 0, 0, 30)
speedBox.Position = UDim2.new(0, 0, 0, 35)
speedBox.Text = tostring(speed)
speedBox.PlaceholderText = "Tốc độ"

local flyBox = Instance.new("TextBox", frame)
flyBox.Size = UDim2.new(1, 0, 0, 30)
flyBox.Position = UDim2.new(0, 0, 0, 70)
flyBox.Text = tostring(flyHeight)
flyBox.PlaceholderText = "Độ cao bay"

makeButton("BẬT Fram", 105, function()
    radius = tonumber(radiusBox.Text) or radius
    speed = tonumber(speedBox.Text) or speed
    flyHeight = tonumber(flyBox.Text) or flyHeight
    running = true
    startFram()
end)

makeButton("TẮT Fram", 140, function()
    running = false
end)

makeButton("Noclip: TOGGLE", 175, function()
    noclip = not noclip
end)