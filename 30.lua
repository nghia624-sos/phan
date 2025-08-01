-- Bản cập nhật: Fix teleport, chuyển sang chạy bộ tự nhiên bằng Humanoid:MoveTo
-- Khi tới gần mục tiêu mới bắt đầu chạy vòng tròn

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Cài đặt
local radius = 8
local speed = 5
local attackSpeed = 1
local framEnabled = false
local circleEnabled = false

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FramNpcMenu"
gui.ResetOnSpawn = false
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 260, 0, 240)
frame.Position = UDim2.new(0, 50, 0, 200)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.Active = true
frame.Draggable = true

-- Nút Fram NPC
local framButton = Instance.new("TextButton", frame)
framButton.Size = UDim2.new(0, 240, 0, 40)
framButton.Position = UDim2.new(0, 10, 0, 10)
framButton.Text = "🔁 Bật Fram NPC"
framButton.MouseButton1Click:Connect(function()
    framEnabled = not framEnabled
    framButton.Text = framEnabled and "✅ Đang Fram NPC" or "🔁 Bật Fram NPC"
end)

-- Nút chạy vòng quanh + đánh
local circleButton = Instance.new("TextButton", frame)
circleButton.Size = UDim2.new(0, 240, 0, 40)
circleButton.Position = UDim2.new(0, 10, 0, 60)
circleButton.Text = "🌀 Bật chạy vòng + đánh"
circleButton.MouseButton1Click:Connect(function()
    circleEnabled = not circleEnabled
    circleButton.Text = circleEnabled and "✅ Đang chạy vòng + đánh" or "🌀 Bật chạy vòng + đánh"
end)

-- Ô nhập bán kính
local radiusBox = Instance.new("TextBox", frame)
radiusBox.Size = UDim2.new(0, 115, 0, 35)
radiusBox.Position = UDim2.new(0, 10, 0, 110)
radiusBox.PlaceholderText = "Bán kính vòng"
radiusBox.Text = tostring(radius)
radiusBox.FocusLost:Connect(function()
    local r = tonumber(radiusBox.Text)
    if r then radius = r end
end)

-- Ô nhập tốc độ
local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(0, 115, 0, 35)
speedBox.Position = UDim2.new(0, 135, 0, 110)
speedBox.PlaceholderText = "Tốc độ chạy"
speedBox.Text = tostring(speed)
speedBox.FocusLost:Connect(function()
    local s = tonumber(speedBox.Text)
    if s then speed = s end
end)

-- Tìm NPC gần nhất
local function findNearestNPC()
    local nearest, dist = nil, math.huge
    for _, npc in pairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
            local name = npc.Name:lower()
            if name:find("citynpc") then
                local d = (npc.HumanoidRootPart.Position - hrp.Position).Magnitude
                if d < dist then
                    dist = d
                    nearest = npc
                end
            end
        end
    end
    return nearest
end

-- Auto Aim
local function faceTarget(target)
    if not target then return end
    local lookVector = (target.Position - hrp.Position).Unit
    hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + lookVector)
end

-- Di chuyển tự nhiên bằng MoveTo
local function moveToTarget(npc)
    if not npc or not npc:FindFirstChild("HumanoidRootPart") then return end
    local targetPos = npc.HumanoidRootPart.Position
    humanoid:MoveTo(targetPos)
    local reached = false
    local conn
    conn = humanoid.MoveToFinished:Connect(function(success)
        if success then
            reached = true
        end
        conn:Disconnect()
    end)
    while not reached and (npc and npc.Parent) and (hrp.Position - targetPos).Magnitude > radius do
        RunService.RenderStepped:Wait()
    end
end

-- Chạy vòng quanh mục tiêu
local function orbitTarget(npc)
    local angle = 0
    while framEnabled and circleEnabled and npc and npc:FindFirstChild("HumanoidRootPart") and npc.Humanoid.Health > 0 do
        angle = angle + speed * RunService.Heartbeat:Wait()
        local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
        local pos = npc.HumanoidRootPart.Position + offset
        local tween = TweenService:Create(hrp, TweenInfo.new(0.2), {CFrame = CFrame.new(pos)})
        tween:Play()
        faceTarget(npc.HumanoidRootPart)
        tween.Completed:Wait()
    end
end

-- Đánh
local function attack(npc)
    while framEnabled and circleEnabled and npc and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 do
        faceTarget(npc.HumanoidRootPart)
        mouse1click()
        wait(attackSpeed)
    end
end

-- Main Loop
task.spawn(function()
    while true do
        if framEnabled then
            local npc = findNearestNPC()
            if npc then
                moveToTarget(npc)
                if circleEnabled then
                    task.spawn(function()
                        orbitTarget(npc)
                    end)
                    task.spawn(function()
                        attack(npc)
                    end)
                end
                while npc and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 do
                    RunService.Heartbeat:Wait()
                end
            end
        end
        task.wait(0.2)
    end
end)