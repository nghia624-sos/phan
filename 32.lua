-- Fram NPC với MoveTo tự nhiên + pathfinding nâng cao + chạy vòng + auto đánh + GUI KRNL mobile

local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FramMenuMobile"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 240, 0, 320)
frame.Position = UDim2.new(0, 10, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true
frame.BorderSizePixel = 0

local uilist = Instance.new("UIListLayout", frame)
uilist.Padding = UDim.new(0, 5)
uilist.FillDirection = Enum.FillDirection.Vertical
uilist.SortOrder = Enum.SortOrder.LayoutOrder

function createToggle(text, default, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 30)
    button.Text = text .. ": " .. (default and "ON" or "OFF")
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.new(1,1,1)
    button.Parent = frame
    local state = default
    button.MouseButton1Click:Connect(function()
        state = not state
        button.Text = text .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
end

function createInput(text, default, callback)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -10, 0, 30)
    box.Text = text .. ": " .. tostring(default)
    box.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    box.TextColor3 = Color3.new(1,1,1)
    box.ClearTextOnFocus = true
    box.Parent = frame
    box.FocusLost:Connect(function()
        local val = tonumber(box.Text:match("%d+"))
        if val then
            callback(val)
        end
    end)
end

local framEnabled, circleEnabled = false, false
local radius, speed, attackSpeed = 8, 2, 0.3

createToggle("Bật Fram", false, function(v) framEnabled = v end)
createToggle("Chạy Vòng", false, function(v) circleEnabled = v end)
createInput("Bán kính", radius, function(v) radius = v end)
createInput("Tốc độ quay", speed, function(v) speed = v end)
createInput("Tốc độ đánh", attackSpeed, function(v) attackSpeed = v end)

local function getNearestTarget()
    local nearest, minDist = nil, math.huge
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and obj ~= char then
            if obj.Name:lower():find("npccity") and obj.Humanoid.Health > 0 then
                local dist = (obj.HumanoidRootPart.Position - hrp.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = obj
                end
            end
        end
    end
    return nearest
end

local function faceTarget(target)
    if not target then return end
    local look = (target.Position - hrp.Position).Unit
    hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + look)
end

local function pathfindTo(targetPos)
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentCanClimb = true
    })
    path:ComputeAsync(hrp.Position, targetPos)
    if path.Status == Enum.PathStatus.Complete then
        for _, waypoint in ipairs(path:GetWaypoints()) do
            humanoid:MoveTo(waypoint.Position)
            humanoid.MoveToFinished:Wait()
        end
    else
        warn("Không tìm được đường đi")
    end
end

local function moveToTarget(npc)
    if not npc or not npc:FindFirstChild("HumanoidRootPart") then return end
    pathfindTo(npc.HumanoidRootPart.Position)
end

local function orbitTarget(npc)
    local angle = 0
    while framEnabled and circleEnabled and npc and npc:FindFirstChild("HumanoidRootPart") and npc.Humanoid.Health > 0 do
        angle += speed * RunService.Heartbeat:Wait()
        local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
        local pos = npc.HumanoidRootPart.Position + offset
        humanoid:MoveTo(pos)
        faceTarget(npc.HumanoidRootPart)
    end
end

local function attack(npc)
    while framEnabled and npc and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 do
        faceTarget(npc.HumanoidRootPart)
        mouse1click()
        wait(attackSpeed)
    end
end

-- Main loop
spawn(function()
    while true do
        wait(0.5)
        if framEnabled then
            local npc = getNearestTarget()
            if npc then
                moveToTarget(npc)
                if circleEnabled then
                    spawn(function() orbitTarget(npc) end)
                end
                attack(npc)
            end
        end
    end
end)