loadstring(game:HttpGet("local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

local radius = 20
local speed = 2
local running = false
local framEnabled = false
local target

-- Hàm tìm NPC gần nhất chứa "CityNPC" hoặc "NPCity"
local function getClosestTarget()
    local nearest, dist = nil, math.huge
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
            local name = v.Name:lower()
            if name:find("citynpc") or name:find("npcity") then
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

-- Hàm dịch chuyển đến gần mục tiêu trước khi chạy vòng
local function teleportNearTarget(t)
    if t and t:FindFirstChild("HumanoidRootPart") then
        local direction = (hrp.Position - t.HumanoidRootPart.Position).Unit
        local teleportPos = t.HumanoidRootPart.Position + direction * radius
        hrp.CFrame = CFrame.new(teleportPos + Vector3.new(0, 5, 0))
    end
end

-- MoveTo chạy mượt đến gần mục tiêu
local function smoothMoveTo(targetPos)
    if hum and targetPos then
        hum:MoveTo(targetPos)
        hum.MoveToFinished:Wait()
    end
end

-- Hàm chạy vòng quanh mục tiêu
local function runAroundTarget(t)
    if not t or not t:FindFirstChild("HumanoidRootPart") then return end
    local angle = 0
    local function update()
        if not running then return end
        angle += speed * RunService.Heartbeat:Wait()
        local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
        local pos = t.HumanoidRootPart.Position + offset
        local cf = CFrame.new(pos, t.HumanoidRootPart.Position)
        hrp.CFrame = cf
    end
    while running and t and t:FindFirstChild("HumanoidRootPart") do
        update()
    end
end

-- Hàm bật fram
local function startFram()
    if running then return end
    running = true
    task.spawn(function()
        target = getClosestTarget()
        if target then
            teleportNearTarget(target)
            smoothMoveTo(target.HumanoidRootPart.Position + Vector3.new(0, 0, -radius))
            runAroundTarget(target)
        end
        running = false
    end)
end

-- Hàm tắt fram
local function stopFram()
    running = false
end

-- Tạo GUI
local ScreenGui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
ScreenGui.Name = "NghiaMinhMenu"
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 220)
Frame.Position = UDim2.new(0, 50, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true

local function createButton(name, pos, text, callback)
    local button = Instance.new("TextButton", Frame)
    button.Name = name
    button.Size = UDim2.new(0, 200, 0, 30)
    button.Position = pos
    button.Text = text
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.MouseButton1Click:Connect(callback)
    return button
end

local radiusBox = Instance.new("TextBox", Frame)
radiusBox.Size = UDim2.new(0, 200, 0, 30)
radiusBox.Position = UDim2.new(0, 25, 0, 140)
radiusBox.PlaceholderText = "Nhập bán kính (mặc định 20)"
radiusBox.Text = ""
radiusBox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
radiusBox.TextColor3 = Color3.new(1, 1, 1)

local speedBox = Instance.new("TextBox", Frame)
speedBox.Size = UDim2.new(0, 200, 0, 30)
speedBox.Position = UDim2.new(0, 25, 0, 175)
speedBox.PlaceholderText = "Nhập tốc độ quay (mặc định 2)"
speedBox.Text = ""
speedBox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
speedBox.TextColor3 = Color3.new(1, 1, 1)

createButton("FramBtn", UDim2.new(0, 25, 0, 20), "Bật Fram", function()
    framEnabled = not framEnabled
    if framEnabled then
        radius = tonumber(radiusBox.Text) or 20
        speed = tonumber(speedBox.Text) or 2
        startFram()
    else
        stopFram()
    end
end)

createButton("AutoAim", UDim2.new(0, 25, 0, 60), "Auto Aim", function()
    RunService.RenderStepped:Connect(function()
        if target and target:FindFirstChild("HumanoidRootPart") then
            hrp.CFrame = CFrame.new(hrp.Position, target.HumanoidRootPart.Position)
        end
    end)
end)

createButton("AutoHit", UDim2.new(0, 25, 0, 100), "Auto Đánh", function()
    task.spawn(function()
        while framEnabled do
            local tool = lp.Character:FindFirstChildOfClass("Tool")
            if tool then
                tool:Activate()
            end
            wait(0.3)
        end
    end)
end)"))()