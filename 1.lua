--// UI LIBRARY (SIMPLE)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/zekker6/uilib/main/uilib.lua"))()
local Window = Library:CreateWindow("TT:dongphandzs1")

--// VARIABLES
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local BossTarget = nil
local Active = false
local Radius = 20
local Speed = 2

--// TAB
local FarmTab = Window:AddTab("Đánh BOSS")

--// UI ELEMENTS
FarmTab:AddToggle("Đánh BOSS", false, function(state)
    Active = state
    if state then
        FindBoss()
    else
        BossTarget = nil
    end
end)

FarmTab:AddBox("Bán kính quay", function(val)
    local num = tonumber(val)
    if num then Radius = num end
end):SetValue("20")

FarmTab:AddBox("Tốc độ quay", function(val)
    local num = tonumber(val)
    if num then Speed = num end
end):SetValue("2")

local HPLabel = FarmTab:AddLabel("Máu BOSS: Không có")

--// MENU BUTTON
Window:AddButton("Ẩn Menu", function()
    Library:ToggleUI()
end)

--// DRAGGING GUI
Library:MakeDraggable(true)

--// FIND NEAREST BOSS
function FindBoss()
    local nearest, dist = nil, math.huge
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Name:lower():find("boss") then
            local hrp = v:FindFirstChild("HumanoidRootPart")
            if hrp and v.Humanoid.Health > 0 then
                local d = (hrp.Position - HumanoidRootPart.Position).Magnitude
                if d < dist then
                    nearest = v
                    dist = d
                end
            end
        end
    end
    BossTarget = nearest
end

--// MAIN LOOP
RunService.RenderStepped:Connect(function(dt)
    if Active and BossTarget and BossTarget:FindFirstChild("HumanoidRootPart") and BossTarget:FindFirstChild("Humanoid") then
        local humanoid = BossTarget.Humanoid
        local root = BossTarget.HumanoidRootPart

        -- Nếu boss chết thì dừng lại
        if humanoid.Health <= 0 then
            BossTarget = nil
            HPLabel:Set("Máu BOSS: Không có")
            return
        end

        -- Update máu
        HPLabel:Set("Máu BOSS: " .. math.floor(humanoid.Health))

        -- Di chuyển quanh boss
        local t = tick() * Speed
        local x = math.cos(t) * Radius
        local z = math.sin(t) * Radius
        local targetPos = root.Position + Vector3.new(x, 0, z)

        -- Di chuyển
        HumanoidRootPart.CFrame = CFrame.new(targetPos, root.Position)

        -- Gọi hàm đánh nếu có
        pcall(function()
            Character:FindFirstChildOfClass("Tool"):Activate()
        end)
    elseif Active and not BossTarget then
        FindBoss()
    end
end)