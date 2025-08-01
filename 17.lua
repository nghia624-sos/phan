--[[
TT:dongphandzs1 Fram Script
Tính năng:
✅ Chạy bộ tự nhiên tới mục tiêu
✅ Tự động chuyển sang chạy vòng khi tới gần
✅ Tự động tìm mục tiêu CityNPC hoặc NPCity
✅ Auto aim, auto đánh
✅ Noclip bật/tắt
✅ Menu kéo được, gọn, dễ sử dụng
--]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")
local mouse = lp:GetMouse()

-- Cài đặt
local radius = 13
local speed = 3
local framDelay = 0.5
local running = false
local target = nil
local noclip = true

-- Tạo GUI
local screengui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
screengui.ResetOnSpawn = false

local frame = Instance.new("Frame", screengui)
frame.Size = UDim2.new(0, 200, 0, 300)
frame.Position = UDim2.new(0, 50, 0, 200)
frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
frame.Active = true
frame.Draggable = true

local function createButton(text, color, ySize, callback)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, 0, 0, ySize or 30)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextScaled = true
    btn.Font = Enum.Font.SourceSansBold
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function createInput(defaultText)
    local input = Instance.new("TextBox", frame)
    input.Size = UDim2.new(1, 0, 0, 30)
    input.BackgroundColor3 = Color3.new(0.6, 0.6, 0.6)
    input.Text = tostring(defaultText)
    input.TextScaled = true
    input.Font = Enum.Font.SourceSansBold
    input.TextColor3 = Color3.new(0, 0, 0)
    return input
end

local radiusBox = createInput(radius)
radiusBox.FocusLost:Connect(function()
    local value = tonumber(radiusBox.Text)
    if value then radius = value end
end)

local speedBox = createInput(speed)
speedBox.FocusLost:Connect(function()
    local value = tonumber(speedBox.Text)
    if value then speed = value end
end)

createButton("TẮT Fram", Color3.new(1, 0, 0), 40, function()
    running = false
end)

local noclipBtn = createButton("Noclip: ON", Color3.new(0, 0, 1), 30, function()
    noclip = not noclip
    noclipBtn.Text = "Noclip: " .. (noclip and "ON" or "OFF")
end)

local label = Instance.new("TextLabel", frame)
label.Size = UDim2.new(1, 0, 0, 30)
label.Text = "TT:dongphandzs1"
label.TextScaled = true
label.Font = Enum.Font.SourceSansBold
label.TextColor3 = Color3.new(1, 1, 1)
label.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)

-- Tìm NPC gần nhất
local function getNearestTarget()
    local nearest, distance = nil, math.huge
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            local name = v.Name:lower()
            if string.find(name, "citynpc") or string.find(name, "npcity") then
                local dist = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
                if dist < distance then
                    distance = dist
                    nearest = v
                end
            end
        end
    end
    return nearest
end

-- Di chuyển tự nhiên tới NPC
local function moveToTarget(pos)
    local path = game:GetService("PathfindingService"):CreatePath()
    path:ComputeAsync(hrp.Position, pos)
    if path.Status == Enum.PathStatus.Complete then
        for _, waypoint in ipairs(path:GetWaypoints()) do
            if not running then return end
            hum:MoveTo(waypoint.Position)
            hum.MoveToFinished:Wait()
        end
    end
end

-- Chạy vòng quanh và auto đánh
local function runCircle(target)
    while running and target and target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 do
        local angle = tick() * speed
        local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
        local destination = target.HumanoidRootPart.Position + offset
        hum:MoveTo(destination)
        hrp.CFrame = CFrame.new(hrp.Position, target.HumanoidRootPart.Position)
        -- Tấn công tự động
        mouse1click()
        task.wait(framDelay)
    end
end

-- Noclip loop
RunService.Stepped:Connect(function()
    if noclip and chr then
        for _, v in pairs(chr:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false
            end
        end
    end
end)

-- Fram chính
task.spawn(function()
    running = true
    while running do
        target = getNearestTarget()
        if target and target:FindFirstChild("HumanoidRootPart") then
            moveToTarget(target.HumanoidRootPart.Position)
            if (target.HumanoidRootPart.Position - hrp.Position).Magnitude < (radius + 5) then
                runCircle(target)
            end
        end
        task.wait(1)
    end
end)