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

-- Logic fram
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local lp = Players.LocalPlayer

local function getCharacter()
    local char = lp.Character or lp.CharacterAdded:Wait()
    return char, char:WaitForChild("Humanoid"), char:WaitForChild("HumanoidRootPart")
end

local function findNearestCityNPC()
    local nearest, shortest = nil, math.huge
    for _, npc in pairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and string.find(npc.Name, "CityNPC") and npc:FindFirstChild("HumanoidRootPart") then
            local dist = (npc.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude
            if dist < shortest then
                shortest = dist
                nearest = npc
            end
        end
    end
    return nearest
end

local framRunning = false

local function naturalWalkToTarget(target)
    local character, humanoid, rootPart = getCharacter()
    if not target or not target:FindFirstChild("HumanoidRootPart") then return end

    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentJumpHeight = 10,
        AgentCanClimb = true,
    })

    path:ComputeAsync(rootPart.Position, target.HumanoidRootPart.Position)
    if path.Status ~= Enum.PathStatus.Complete then return end

    for _, waypoint in pairs(path:GetWaypoints()) do
        if not framRunning then break end
        if waypoint.Action == Enum.PathWaypointAction.Jump then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end

        humanoid:MoveTo(waypoint.Position)
        local reached = false
        local conn
        conn = humanoid.MoveToFinished:Connect(function(success)
            reached = true
        end)

        local timeout = 3
        local t = 0
        while not reached and t < timeout do
            wait(0.1)
            t = t + 0.1
        end
        conn:Disconnect()
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
                end
                wait(0.5)
            end
        end)
    end
end)