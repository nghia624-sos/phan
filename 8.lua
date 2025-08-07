-- Load Kavo UI
loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("TT:dongphandzs1", "DarkTheme")

-- Dịch vụ
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local HRP = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

-- Biến điều khiển
local framActive = false
local spinActive = false
local currentTarget = nil
local radius = 10
local speed = 3

-- Tạo TAB
local FramTab = Window:NewTab("Fram NPC")
local SpinTab = Window:NewTab("Spin")
local FramSection = FramTab:NewSection("Tự động Fram")
local SpinSection = SpinTab:NewSection("Quay vòng")

-- Bán kính + Tốc độ
FramSection:NewTextBox("Bán kính", "Nhập bán kính", function(val)
    radius = tonumber(val) or 10
end)

FramSection:NewTextBox("Tốc độ", "Nhập tốc độ", function(val)
    speed = tonumber(val) or 3
end)

-- Toggle Fram
FramSection:NewToggle("Bật Fram", "Tự fram NPC", function(state)
    framActive = state
    if state then
        task.spawn(startFram)
    end
end)

-- Toggle Spin
SpinSection:NewToggle("Bật Spin", "Nhân vật xoay", function(state)
    spinActive = state
end)

-- Hàm hướng mặt
function faceTarget(target)
    if target and target:FindFirstChild("HumanoidRootPart") then
        local lookVector = (target.HumanoidRootPart.Position - HRP.Position).Unit
        HRP.CFrame = CFrame.new(HRP.Position, HRP.Position + lookVector)
    end
end

-- Spin
task.spawn(function()
    while task.wait() do
        if spinActive and HRP then
            HRP.CFrame *= CFrame.Angles(0, math.rad(10), 0)
        end
    end
end)

-- Tìm NPC gần nhất
function getNearestCityNPC()
    local nearest, shortest = nil, math.huge
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
            if string.lower(v.Name):find("citynpc") and v.Humanoid.Health > 0 then
                local dist = (v.HumanoidRootPart.Position - HRP.Position).Magnitude
                if dist < shortest then
                    shortest = dist
                    nearest = v
                end
            end
        end
    end
    return nearest
end

-- Tự động đánh
function autoAttack()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- Chạy vòng quanh
function runAround(target)
    local angle = 0
    while framActive and target and target:FindFirstChild("HumanoidRootPart") and target.Humanoid.Health > 0 do
        local pos = target.HumanoidRootPart.Position
        angle += speed * RunService.Heartbeat:Wait()
        local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
        local destination = pos + offset

        local tween = TweenService:Create(HRP, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {CFrame = CFrame.new(destination)})
        tween:Play()
        faceTarget(target)
    end
end

-- Tự nhặt đồ
function collectItemsAround(pos, range)
    for _, item in ipairs(workspace:GetDescendants()) do
        if (item:IsA("Tool") or item:IsA("Part")) and item:IsDescendantOf(workspace) and item.Position then
            if (item.Position - pos).Magnitude < range then
                hum:MoveTo(item.Position)
                task.wait(0.3)
            end
        end
    end
end

-- Logic Fram
function startFram()
    while framActive do
        currentTarget = getNearestCityNPC()
        if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
            -- Di chuyển đến mục tiêu
            hum:MoveTo(currentTarget.HumanoidRootPart.Position)
            repeat task.wait() until not framActive or (HRP.Position - currentTarget.HumanoidRootPart.Position).Magnitude < 15

            -- Auto đánh song song
            task.spawn(function()
                while framActive and currentTarget and currentTarget.Humanoid.Health > 0 do
                    autoAttack()
                    task.wait(0.2)
                end
            end)

            -- Chạy vòng
            runAround(currentTarget)

            -- Sau khi NPC chết, nhặt đồ
            if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") and currentTarget.Humanoid.Health <= 0 then
                collectItemsAround(currentTarget.HumanoidRootPart.Position, 20)
            end
        else
            task.wait(1)
        end
    end
end