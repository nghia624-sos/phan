-- GUI menu
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "tt_dongphandzs1"
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 150)
Frame.Position = UDim2.new(0, 50, 0, 100)
Frame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
Frame.Active = true
Frame.Draggable = true
Frame.BorderSizePixel = 0
Frame.BackgroundTransparency = 0.1

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "tt:dongphandzs1"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextScaled = true

local StartFramBtn = Instance.new("TextButton", Frame)
StartFramBtn.Position = UDim2.new(0, 10, 0, 50)
StartFramBtn.Size = UDim2.new(1, -20, 0, 40)
StartFramBtn.Text = "Bắt đầu Fram"
StartFramBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
StartFramBtn.TextColor3 = Color3.new(1, 1, 1)
StartFramBtn.Font = Enum.Font.SourceSansBold
StartFramBtn.TextScaled = true
StartFramBtn.BorderSizePixel = 0

-- Logic fram mục tiêu có tên chứa "CityNPC"
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local lp = Players.LocalPlayer
local character = lp.Character or lp.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

function findNearestCityNPC()
    local nearest = nil
    local shortest = math.huge
    for _, npc in pairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") and string.find(npc.Name, "CityNPC") then
            local dist = (npc.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
            if dist < shortest then
                shortest = dist
                nearest = npc
            end
        end
    end
    return nearest
end

local framRunning = false

function naturalWalkToTarget(target)
    if not target or not target:FindFirstChild("HumanoidRootPart") then return end
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentJumpHeight = 10,
        AgentCanClimb = true,
    })

    path:ComputeAsync(character.HumanoidRootPart.Position, target.HumanoidRootPart.Position)

    if path.Status == Enum.PathStatus.Complete then
        for _, waypoint in pairs(path:GetWaypoints()) do
            if not framRunning then break end
            humanoid:MoveTo(waypoint.Position)
            humanoid.MoveToFinished:Wait()
        end
    end
end

StartFramBtn.MouseButton1Click:Connect(function()
    framRunning = not framRunning
    StartFramBtn.Text = framRunning and "Đang Fram..." or "Bắt đầu Fram"
    StartFramBtn.BackgroundColor3 = framRunning and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(50, 150, 50)

    if framRunning then
        task.spawn(function()
            while framRunning do
                local npc = findNearestCityNPC()
                if npc then
                    naturalWalkToTarget(npc)
                else
                    wait(1)
                end
                wait(0.5)
            end
        end)
    end
end)