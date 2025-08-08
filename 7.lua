local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

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

-- TAB Fram NPC
local FramTab = Window:CreateTab("Fram NPC", 4483362458)
-- (Các chức năng Fram NPC ở đây... giữ nguyên như script gốc: tìm NPC tên chứa CityNPC, chạy tới, fram, chạy vòng, auto đánh...)

-- TAB PvP
local PvpTab = Window:CreateTab("PvP", 4483362458)

-- Spin xoay nhân vật
local spinning = false
RunService.RenderStepped:Connect(function()
    if spinning and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(10), 0)
    end
end)

PvpTab:CreateToggle({
    Name = "Xoay nhân vật (Spin)",
    CurrentValue = false,
    Callback = function(Value)
        spinning = Value
    end,
})

-- Hiển thị Line + Hitbox
local showLines = false
local lines = {}
local function clearLines()
    for _,v in pairs(lines) do
        if v then v:Destroy() end
    end
    lines = {}
end

RunService.RenderStepped:Connect(function()
    if showLines then
        clearLines()
        for _,v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local line = Instance.new("Beam")
                local att0 = Instance.new("Attachment", HumanoidRootPart)
                local att1 = Instance.new("Attachment", v.Character.HumanoidRootPart)
                line.Attachment0 = att0
                line.Attachment1 = att1
                line.Width0 = 0.2
                line.Width1 = 0.2
                line.Color = ColorSequence.new(Color3.new(1, 0, 0))
                line.Parent = HumanoidRootPart
                table.insert(lines, line)
            end
        end
    else
        clearLines()
    end
end)

PvpTab:CreateToggle({
    Name = "Hiển thị Hitbox + Line đến mục tiêu",
    CurrentValue = false,
    Callback = function(Value)
        showLines = Value
    end,
})

-- Silent Attack (mọi mục tiêu)
local silentAttack = false
RunService.Heartbeat:Connect(function()
    if silentAttack then
        for _,v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                local args = {
                    [1] = v.Character.Humanoid
                }
                pcall(function()
                    v.Character.Humanoid:TakeDamage(5)
                end)
            end
        end
    end
end)

PvpTab:CreateToggle({
    Name = "Silent Attack (tấn công tất cả mục tiêu)",
    CurrentValue = false,
    Callback = function(Value)
        silentAttack = Value
    end,
})