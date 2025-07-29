-- Menu UI
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
local Window = OrionLib:MakeWindow({
    Name = "Dong Phan Hub | Vòng quanh NPC",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "VongNPC"
})

-- Biến điều khiển
local autoRun = false
local runSpeed = 10

-- Tab điều khiển
local MainTab = Window:MakeTab({
    Name = "Chính",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MainTab:AddToggle({
    Name = "Bật/Tắt chạy vòng",
    Default = false,
    Callback = function(Value)
        autoRun = Value
    end
})

MainTab:AddSlider({
    Name = "Tốc độ chạy vòng",
    Min = 5,
    Max = 50,
    Default = 10,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "speed",
    Callback = function(Value)
        runSpeed = Value
    end
})

-- Hàm tìm NPC gần nhất có tên đúng
function getNearestNPC()
    local nearest = nil
    local shortest = math.huge
    for _, npc in pairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and (npc.Name == "NPC" or npc.Name == "npc c") and npc:FindFirstChild("HumanoidRootPart") then
            local dist = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - npc.HumanoidRootPart.Position).Magnitude
            if dist < shortest then
                shortest = dist
                nearest = npc
            end
        end
    end
    return nearest
end

-- Hàm chạy vòng quanh
spawn(function()
    while true do
        wait()
        if autoRun then
            local npc = getNearestNPC()
            if npc and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local char = game.Players.LocalPlayer.Character.HumanoidRootPart
                local npcPos = npc.HumanoidRootPart.Position
                local t = tick()
                local radius = 10
                local x = math.cos(t * runSpeed / 10) * radius
                local z = math.sin(t * runSpeed / 10) * radius
                char.CFrame = CFrame.new(npcPos + Vector3.new(x, 0, z))
            end
        end
    end
end)