local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")

local radius = 10
local speed = 2
local running = false
local target = nil

-- Tạo GUI đơn giản
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 120)
Frame.Position = UDim2.new(0.1, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Text = "TT:dongphandzs1"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

local RadiusBox = Instance.new("TextBox", Frame)
RadiusBox.Size = UDim2.new(1, -10, 0, 25)
RadiusBox.Position = UDim2.new(0, 5, 0, 30)
RadiusBox.PlaceholderText = "Bán kính"
RadiusBox.Text = tostring(radius)

local SpeedBox = Instance.new("TextBox", Frame)
SpeedBox.Size = UDim2.new(1, -10, 0, 25)
SpeedBox.Position = UDim2.new(0, 5, 0, 60)
SpeedBox.PlaceholderText = "Tốc độ"
SpeedBox.Text = tostring(speed)

local Toggle = Instance.new("TextButton", Frame)
Toggle.Size = UDim2.new(1, -10, 0, 25)
Toggle.Position = UDim2.new(0, 5, 0, 90)
Toggle.Text = "Bật Fram"
Toggle.BackgroundColor3 = Color3.fromRGB(70, 200, 70)

-- Tìm mục tiêu gần nhất
local function getNearestTarget()
    local closest, dist = nil, math.huge
    for _, v in pairs(workspace:GetDescendants()) do
        if v:FindFirstChild("Humanoid") and v ~= Character then
            local root = v:FindFirstChild("HumanoidRootPart")
            if root then
                local d = (root.Position - HRP.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = v
                end
            end
        end
    end
    return closest
end

-- Chạy tới mục tiêu tránh vật cản
local function moveToTarget(t)
    local path = PathfindingService:CreatePath({AgentRadius = 2, AgentHeight = 5, AgentCanJump = true})
    path:ComputeAsync(HRP.Position, t.Position)
    if path.Status == Enum.PathStatus.Success then
        for _, waypoint in pairs(path:GetWaypoints()) do
            Humanoid:MoveTo(waypoint.Position)
            Humanoid.MoveToFinished:Wait()
        end
    end
end

-- Chạy vòng quanh mượt
local function circleAroundTarget(t)
    local angle = 0
    while running and t and t:FindFirstChild("HumanoidRootPart") do
        radius = tonumber(RadiusBox.Text) or radius
        speed = tonumber(SpeedBox.Text) or speed
        angle = angle + speed * RunService.Heartbeat:Wait()
        local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
        local goalPos = t.HumanoidRootPart.Position + offset
        Humanoid:MoveTo(goalPos)
        HRP.CFrame = CFrame.lookAt(HRP.Position, t.HumanoidRootPart.Position)
    end
end

-- Khi bấm nút
Toggle.MouseButton1Click:Connect(function()
    running = not running
    Toggle.Text = running and "Tắt Fram" or "Bật Fram"
    if running then
        target = getNearestTarget()
        if target and target:FindFirstChild("HumanoidRootPart") then
            moveToTarget(target.HumanoidRootPart)
            circleAroundTarget(target)
        end
    end
end)