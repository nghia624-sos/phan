-- Gui script sử dụng Rayfield UI | Tên menu: TT:dongphandzs1
-- Giữ nguyên tất cả tính năng fram NPC, chạy tự nhiên, không teleport bất hợp pháp
-- Thêm tab PvP: spin + hiển thị line+hitbox + silent attack tất cả mục tiêu

loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Window = Rayfield:CreateWindow({
    Name = "TT:dongphandzs1",
    LoadingTitle = "TT:dongphandzs1",
    LoadingSubtitle = "by bạn",
    ConfigurationSaving = {
        Enabled = false,
    },
    Discord = {
        Enabled = false,
    },
    KeySystem = false,
})

-- // Fram Tab
local FramTab = Window:CreateTab("Fram NPC", 4483362458)
local Settings = {
    Fram = false,
    AutoAttack = false,
    Radius = 10,
    SpinSpeed = 5,
    AutoSpin = false,
}

local function getTarget()
    local npcs = workspace:GetDescendants()
    for _, npc in pairs(npcs) do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc.Name:lower():find("citynpc") then
            return npc
        end
    end
end

local function moveToTarget(target)
    local pathfinding = game:GetService("PathfindingService")
    local path = pathfinding:CreatePath()
    path:ComputeAsync(LocalPlayer.Character.HumanoidRootPart.Position, target.HumanoidRootPart.Position)
    for _, waypoint in ipairs(path:GetWaypoints()) do
        LocalPlayer.Character.Humanoid:MoveTo(waypoint.Position)
        LocalPlayer.Character.Humanoid.MoveToFinished:Wait()
    end
end

local function autoFram()
    task.spawn(function()
        while Settings.Fram do
            local target = getTarget()
            if target then
                moveToTarget(target)
                while Settings.Fram and target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 do
                    if Settings.AutoAttack then
                        for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
                            if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                                tool:Activate()
                            end
                        end
                    end
                    RunService.Heartbeat:Wait()
                end
            end
            task.wait(1)
        end
    end)
end

FramTab:CreateToggle({
    Name = "Bật Fram NPC",
    CurrentValue = false,
    Callback = function(Value)
        Settings.Fram = Value
        if Value then
            autoFram()
        end
    end
})

FramTab:CreateToggle({
    Name = "Auto Attack",
    CurrentValue = false,
    Callback = function(Value)
        Settings.AutoAttack = Value
    end
})

FramTab:CreateInput({
    Name = "Bán kính quay vòng",
    PlaceholderText = "10",
    RemoveTextAfterFocusLost = true,
    Callback = function(Value)
        Settings.Radius = tonumber(Value)
    end
})

FramTab:CreateInput({
    Name = "Tốc độ quay vòng",
    PlaceholderText = "5",
    RemoveTextAfterFocusLost = true,
    Callback = function(Value)
        Settings.SpinSpeed = tonumber(Value)
    end
})

FramTab:CreateToggle({
    Name = "Chạy vòng quanh mục tiêu",
    CurrentValue = false,
    Callback = function(Value)
        Settings.AutoSpin = Value
        task.spawn(function()
            while Settings.AutoSpin do
                local target = getTarget()
                if target and target:FindFirstChild("HumanoidRootPart") then
                    local angle = 0
                    while Settings.AutoSpin and target and target:FindFirstChild("HumanoidRootPart") do
                        angle += 0.05 * Settings.SpinSpeed
                        local offset = Vector3.new(math.cos(angle) * Settings.Radius, 0, math.sin(angle) * Settings.Radius)
                        local goalPos = target.HumanoidRootPart.Position + offset
                        LocalPlayer.Character.Humanoid:MoveTo(goalPos)
                        LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position, target.HumanoidRootPart.Position))
                        task.wait()
                    end
                end
                task.wait(1)
            end
        end)
    end
})

-- // PvP Tab
local PvPTab = Window:CreateTab("PvP", 4483362458)
local PvPSettings = {
    Spin = false,
    HitboxLine = false,
    SilentAttack = false,
}

PvPTab:CreateToggle({
    Name = "Xoay nhân vật",
    CurrentValue = false,
    Callback = function(Value)
        PvPSettings.Spin = Value
        task.spawn(function()
            while PvPSettings.Spin do
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character:SetPrimaryPartCFrame(LocalPlayer.Character.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(15), 0))
                end
                task.wait()
            end
        end)
    end
})

PvPTab:CreateToggle({
    Name = "Hiển thị Line + Hitbox",
    CurrentValue = false,
    Callback = function(Value)
        PvPSettings.HitboxLine = Value
        if Value then
            task.spawn(function()
                while PvPSettings.HitboxLine do
                    for _, model in pairs(workspace:GetDescendants()) do
                        if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") and model ~= LocalPlayer.Character then
                            if not model:FindFirstChild("PvPLine") then
                                local a = Instance.new("BoxHandleAdornment", model)
                                a.Name = "PvPLine"
                                a.Adornee = model.HumanoidRootPart
                                a.Size = Vector3.new(4, 6, 2)
                                a.Color3 = Color3.new(1, 0, 0)
                                a.Transparency = 0.5
                                a.ZIndex = 5
                                a.AlwaysOnTop = true

                                local line = Instance.new("Beam", model)
                                line.Name = "LineBeam"
                                local a0 = Instance.new("Attachment", model.HumanoidRootPart)
                                local a1 = Instance.new("Attachment", LocalPlayer.Character.HumanoidRootPart)
                                line.Attachment0 = a0
                                line.Attachment1 = a1
                                line.Width0 = 0.2
                                line.Width1 = 0.2
                                line.Color = ColorSequence.new(Color3.new(1, 0, 0))
                            end
                        end
                    end
                    task.wait(1)
                end
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BoxHandleAdornment") and v.Name == "PvPLine" then v:Destroy() end
                    if v:IsA("Beam") and v.Name == "LineBeam" then v:Destroy() end
                end
            end)
        end
    end
})

PvPTab:CreateToggle({
    Name = "Silent Attack tất cả mục tiêu",
    CurrentValue = false,
    Callback = function(Value)
        PvPSettings.SilentAttack = Value
        task.spawn(function()
            while PvPSettings.SilentAttack do
                for _, model in pairs(workspace:GetDescendants()) do
                    if model:IsA("Model") and model:FindFirstChild("Humanoid") and model ~= LocalPlayer.Character then
                        for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
                            if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                                tool:Activate()
                            end
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
    end
})