local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

local target = nil
local radius = 10 -- bán kính vòng quanh
local speed = 3 -- tốc độ vòng quanh
local isFarming = true

-- Hàm tìm mục tiêu gần nhất
local function getNearestTarget()
    local closest, distance = nil, math.huge
    for _, npc in pairs(workspace:GetDescendants()) do
        if npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") and npc.Humanoid.Health > 0 then
            local dist = (npc.HumanoidRootPart.Position - hrp.Position).Magnitude
            if dist < distance then
                distance = dist
                closest = npc
            end
        end
    end
    return closest
end

-- Hàm di chuyển đến mục tiêu (MoveTo, tránh xuyên tường)
local function moveToTarget(pos)
    local path = PathfindingService:CreatePath()
    path:ComputeAsync(hrp.Position, pos)
    if path.Status == Enum.PathStatus.Success then
        path:MoveTo(char)
        path.Blocked:Connect(function()
            path:ComputeAsync(hrp.Position, pos)
        end)
        path.MoveToFinished:Wait()
    end
end

-- Hàm auto đánh
local function attack()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- Hàm chạy vòng quanh bằng TweenService
local function circleAroundTarget(tar)
    local angle = 0
    while tar and tar.Parent and tar:FindFirstChild("HumanoidRootPart") and tar.Humanoid.Health > 0 and isFarming do
        angle = angle + speed * RunService.Heartbeat:Wait()
        local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
        local targetPos = tar.HumanoidRootPart.Position + offset

        local tween = TweenService:Create(hrp, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos, tar.HumanoidRootPart.Position)})
        tween:Play()

        attack()
    end
end

-- Vòng chính
task.spawn(function()
    while isFarming do
        target = getNearestTarget()
        if target then
            -- Di chuyển tới mục tiêu trước
            moveToTarget(target.HumanoidRootPart.Position)
            -- Khi tới gần thì chạy vòng quanh
            if (target.HumanoidRootPart.Position - hrp.Position).Magnitude <= radius + 5 then
                circleAroundTarget(target)
            end
        else
            task.wait(0.5)
        end
    end
end)