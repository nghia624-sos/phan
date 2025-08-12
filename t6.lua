--// Roblox NPC2 Fram - TweenService vòng tròn mượt
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

-- Cấu hình
local radius = 10       -- bán kính chạy vòng
local speed = 3         -- tốc độ chạy vòng
local attackRange = 15  -- tầm đánh

-- Hàm tìm NPC2
local function getTarget()
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
            if string.find(string.lower(v.Name), "npc2") then
                return v
            end
        end
    end
end

-- Auto đánh
local function attackTarget()
    pcall(function()
        lp.Character:FindFirstChildOfClass("Tool"):Activate()
    end)
end

-- Hiển thị máu mục tiêu
local function createHealthBar(target)
    local screenGui = Instance.new("ScreenGui", lp.PlayerGui)
    screenGui.Name = "TargetHealth"
    local bar = Instance.new("Frame", screenGui)
    bar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    bar.Position = UDim2.new(0.5, -100, 0.05, 0)
    bar.Size = UDim2.new(0, 200, 0, 20)
    bar.BackgroundTransparency = 0.3

    local conn
    conn = RunService.RenderStepped:Connect(function()
        if target and target:FindFirstChild("Humanoid") then
            local hp = target.Humanoid.Health / target.Humanoid.MaxHealth
            bar.Size = UDim2.new(0, 200 * hp, 0, 20)
        else
            conn:Disconnect()
            screenGui:Destroy()
        end
    end)
end

-- Chạy vòng quanh
local function circleTarget(target)
    local angle = 0
    while target and target:FindFirstChild("HumanoidRootPart") and target.Humanoid.Health > 0 do
        local targetPos = target.HumanoidRootPart.Position
        local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
        local goal = {CFrame = CFrame.new(targetPos + offset, targetPos)}
        local tween = TweenService:Create(hrp, TweenInfo.new(1/speed, Enum.EasingStyle.Linear), goal)
        tween:Play()
        angle = angle + math.rad(15)
        attackTarget()
        task.wait(1/speed)
    end
end

-- Chạy script
task.spawn(function()
    while true do
        local target = getTarget()
        if target then
            createHealthBar(target)
            -- Di chuyển tới gần mục tiêu
            while target and target:FindFirstChild("HumanoidRootPart") and (hrp.Position - target.HumanoidRootPart.Position).Magnitude > radius + 2 do
                hum:MoveTo(target.HumanoidRootPart.Position)
                hum.MoveToFinished:Wait()
            end
            -- Chạy vòng
            circleTarget(target)
        end
        task.wait(0.5)
    end
end)