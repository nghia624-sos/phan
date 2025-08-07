-- Gộp script Fram NPC + Spin + Menu GUI với Kavo UI

loadstring(game:HttpGet("https://raw.githubusercontent.com/kyokobot/roblox-ui-lib/main/kavo.lua"))()

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("TT:dongphandzs1", "DarkTheme")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local HRP = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

local framActive = false
local spinActive = false
local currentTarget = nil

-- TABS
local FramTab = Window:NewTab("Fram NPC")
local SpinTab = Window:NewTab("Spin")

-- Fram Section
local FramSection = FramTab:NewSection("Auto Fram")

-- Input Variables
local radius = 10
local speed = 3

FramSection:NewTextBox("Bán kính", "Bán kính quay", function(val)
    radius = tonumber(val) or 10
end)

FramSection:NewTextBox("Tốc độ", "Tốc độ quay", function(val)
    speed = tonumber(val) or 3
end)

FramSection:NewToggle("Bật Fram", "Tự động fram NPC", function(state)
    framActive = state
    if state then
        task.spawn(startFram)
    end
end)

-- Spin Section
local SpinSection = SpinTab:NewSection("Quay Spin")

SpinSection:NewToggle("Bật Spin", "Nhân vật xoay liên tục", function(state)
    spinActive = state
end)

-- Aim NPC
function faceTarget(target)
    if target and target:FindFirstChild("HumanoidRootPart") then
        local lookVector = (target.HumanoidRootPart.Position - HRP.Position).Unit
        HRP.CFrame = CFrame.new(HRP.Position, HRP.Position + lookVector)
    end
end

-- Vòng quanh
function runAround(target, radius, speed)
    local angle = 0
    while framActive and target and target:FindFirstChild("HumanoidRootPart") and target.Humanoid.Health > 0 do
        local targetPos = target.HumanoidRootPart.Position
        angle += speed * RunService.Heartbeat:Wait()
        local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
        local goal = targetPos + offset
        local tween = TweenService:Create(HRP, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {CFrame = CFrame.new(goal)})
        tween:Play()
        faceTarget(target)
    end
end

-- Auto attack
function autoAttack()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.1)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- Tìm NPC gần nhất
function getNearestCityNPC()
    local nearest = nil
    local shortest = math.huge
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

-- Tự nhặt item quanh NPC
function collectItemsAround(position, radius)
    for _, item in ipairs(workspace:GetDescendants()) do
        if item:IsA("Tool") or item:IsA("Part") then
            if (item.Position - position).Magnitude < radius then
                hum:MoveTo(item.Position)
                task.wait(0.4)
            end
        end
    end
end

-- Vòng lặp spin
task.spawn(function()
    while true do
        if spinActive and HRP then
            HRP.CFrame *= CFrame.Angles(0, math.rad(15), 0)
        end
        task.wait()
    end
end)

-- Main Fram Logic
function startFram()
    while framActive do
        currentTarget = getNearestCityNPC()
        if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
            hum:MoveTo(currentTarget.HumanoidRootPart.Position)
            repeat task.wait() until not framActive or (HRP.Position - currentTarget.HumanoidRootPart.Position).Magnitude < 15

            task.spawn(function()
                while framActive and currentTarget and currentTarget.Humanoid.Health > 0 do
                    autoAttack()
                    task.wait(0.3)
                end
            end)

            runAround(currentTarget, radius, speed)

            if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") and currentTarget.Humanoid.Health <= 0 then
                collectItemsAround(currentTarget.HumanoidRootPart.Position, 20)
            end
        else
            task.wait(1)
        end
    end
end