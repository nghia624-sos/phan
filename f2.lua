-- TT:dongphandzs1 - Fram CityNPC FULL FIX GUI

-- Dịch vụ
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- Đợi nhân vật
local function getCharacter()
    if lp.Character then return lp.Character end
    return lp.CharacterAdded:Wait()
end

local chr = getCharacter()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

-- Biến điều khiển
local framEnabled = false
local target = nil
local radius = 10
local speed = 2

-- Tìm mục tiêu có chứa "CityNPC"
local function findTarget()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            if v.Name:lower():find("citynpc") then
                return v
            end
        end
    end
    return nil
end

-- Di chuyển đến mục tiêu bằng MoveTo
local function moveToTarget(pos)
    if hum then hum:MoveTo(pos) end
end

-- Auto Aim + Attack
local function autoAimAndAttack()
    if target and target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("Humanoid") then
        local tPos = target.HumanoidRootPart.Position
        local dir = (tPos - hrp.Position).Unit
        hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + dir)
        mouse1click()
    end
end

-- Chạy vòng quanh mục tiêu
local function runAround()
    local angle = 0
    RunService:UnbindFromRenderStep("RunAround")
    RunService:BindToRenderStep("RunAround", Enum.RenderPriority.Character.Value + 1, function(dt)
        if not framEnabled or not target or not target:FindFirstChild("HumanoidRootPart") then
            RunService:UnbindFromRenderStep("RunAround")
            return
        end

        autoAimAndAttack()

        angle += dt * speed
        local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
        local goalPos = target.HumanoidRootPart.Position + offset
        moveToTarget(goalPos)
    end)
end

-- Theo dõi và tìm mục tiêu mới nếu mục tiêu cũ chết
task.spawn(function()
    while true do
        task.wait(0.5)
        if framEnabled then
            if not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 then
                target = findTarget()
                if target then
                    moveToTarget(target.HumanoidRootPart.Position)
                    task.wait(1)
                    runAround()
                end
            end
        end
    end
end)

-- Tải GUI
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

local Window = OrionLib:MakeWindow({
    Name = "TT:dongphandzs1",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "dongphandzs1Config",
    IntroEnabled = false
})

local Tab = Window:MakeTab({
    Name = "Fram",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Toggle Fram
Tab:AddToggle({
    Name = "Bật Fram CityNPC",
    Default = false,
    Callback = function(v)
        framEnabled = v
        if not v then
            RunService:UnbindFromRenderStep("RunAround")
            target = nil
        end
    end
})

-- Slider bán kính
Tab:AddSlider({
    Name = "Bán kính chạy vòng quanh",
    Min = 5,
    Max = 30,
    Default = 10,
    Increment = 1,
    ValueName = "Studs",
    Callback = function(val)
        radius = val
    end
})

-- Slider tốc độ quay
Tab:AddSlider({
    Name = "Tốc độ quay vòng",
    Min = 1,
    Max = 10,
    Default = 2,
    Increment = 0.1,
    ValueName = "Speed",
    Callback = function(val)
        speed = val
    end
})

-- Hiển thị máu mục tiêu
Tab:AddLabel("Máu mục tiêu:")
local hpLabel = Tab:AddLabel("Chưa có mục tiêu")

task.spawn(function()
    while true do
        task.wait(0.3)
        if target and target:FindFirstChild("Humanoid") then
            hpLabel:Set("Máu: " .. math.floor(target.Humanoid.Health))
        else
            hpLabel:Set("Chưa có mục tiêu")
        end
    end
end)

-- Nút tắt script
Tab:AddButton({
    Name = "Tắt Script",
    Callback = function()
        framEnabled = false
        RunService:UnbindFromRenderStep("RunAround")
        OrionLib:Destroy()
    end
})

-- Cuối cùng, hiển thị GUI
OrionLib:Init()