-- TT:dongphandzs1
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hrp = chr:WaitForChild("HumanoidRootPart")
local hum = chr:WaitForChild("Humanoid")

-- UI lib
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Flxght/uilib2/main/main.lua"))()
local win = lib:Window("TT:dongphandzs1", Color3.fromRGB(0, 200, 100), Enum.KeyCode.RightControl)

local tab = win:Tab("Fram NPC")
local toggleRun, toggleAttack
local radius = 10
local speed = 5
local currentTarget

-- Hàm tìm mục tiêu gần nhất
function getNearestNPC()
    local closest, dist = nil, math.huge
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            local name = string.lower(v.Name)
            if name:find("citynpc") or name:find("npcity") then
                local d = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = v
                end
            end
        end
    end
    return closest
end

-- Aim vào mục tiêu
function faceTarget(target)
    if target and target:FindFirstChild("HumanoidRootPart") then
        local lookVector = (target.HumanoidRootPart.Position - hrp.Position).Unit
        hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + lookVector)
    end
end

-- Chạy vòng quanh mục tiêu
function circleTarget()
    coroutine.wrap(function()
        while toggleRun do
            currentTarget = getNearestNPC()
            if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
                local tpos = currentTarget.HumanoidRootPart.Position
                for i = 0, 360, 10 do
                    if not toggleRun or not currentTarget then break end
                    local rad = math.rad(i)
                    local x = tpos.X + math.cos(rad) * radius
                    local z = tpos.Z + math.sin(rad) * radius
                    local y = tpos.Y
                    local goal = Vector3.new(x, y, z)

                    -- tween move
                    local tween = TweenService:Create(hrp, TweenInfo.new(1 / speed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(goal, tpos)})
                    tween:Play()
                    tween.Completed:Wait()
                end
            else
                task.wait(1)
            end
            task.wait()
        end
    end)()
end

-- Auto attack
function attackTarget()
    coroutine.wrap(function()
        while toggleAttack do
            local target = currentTarget or getNearestNPC()
            if target and target:FindFirstChild("Humanoid") and target:FindFirstChild("HumanoidRootPart") then
                faceTarget(target)
                local tool = lp.Character:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Handle") then
                    tool:Activate()
                end
            end
            task.wait(0.3)
        end
    end)()
end

-- Hiển thị máu mục tiêu
local healthLabel = tab:Label("HP: N/A")
RunService.RenderStepped:Connect(function()
    local target = currentTarget or getNearestNPC()
    if target and target:FindFirstChild("Humanoid") then
        healthLabel:Set("HP: " .. math.floor(target.Humanoid.Health))
    else
        healthLabel:Set("HP: N/A")
    end
end)

-- Menu chính
tab:Toggle("Chạy vòng quanh mục tiêu", false, function(v)
    toggleRun = v
    if v then
        circleTarget()
    end
end)

tab:Toggle("Tự động đánh", false, function(v)
    toggleAttack = v
    if v then
        attackTarget()
    end
end)

tab:Slider("Bán kính vòng", 5, 30, 10, function(val)
    radius = val
end)

tab:Slider("Tốc độ chạy vòng", 1, 10, 5, function(val)
    speed = val
end)