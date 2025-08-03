-- TT:dongphandzs1 - Fram NPC gần nhất (cập nhật di chuyển mượt)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hrp = chr:WaitForChild("HumanoidRootPart")

local radius = 10
local speed = 5
local isRunning = false
local isAttacking = false
local target = nil

-- UI Setup
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FramMenu"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 230)
frame.Position = UDim2.new(0.3, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

local uicorner = Instance.new("UICorner", frame)
uicorner.CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "TT:dongphandzs1"
title.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

function createButton(text, posY, callback)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.9, 0, 0, 25)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.MouseButton1Click:Connect(callback)
    return btn
end

function createSlider(name, min, max, default, posY, callback)
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0.9, 0, 0, 20)
    lbl.Position = UDim2.new(0.05, 0, 0, posY)
    lbl.Text = name .. ": " .. tostring(default)
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14

    local slider = Instance.new("TextBox", frame)
    slider.Size = UDim2.new(0.9, 0, 0, 20)
    slider.Position = UDim2.new(0.05, 0, 0, posY + 20)
    slider.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    slider.TextColor3 = Color3.new(1,1,1)
    slider.Text = tostring(default)
    slider.Font = Enum.Font.Gotham
    slider.TextSize = 14

    slider.FocusLost:Connect(function()
        local val = tonumber(slider.Text)
        if val then
            val = math.clamp(val, min, max)
            lbl.Text = name .. ": " .. val
            callback(val)
        end
    end)
end

function getNearestNPC()
    local closest, dist = nil, math.huge
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            local d = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
            if d < dist and v ~= chr then
                dist = d
                closest = v
            end
        end
    end
    return closest
end

function faceTarget(target)
    if target and target:FindFirstChild("HumanoidRootPart") then
        local look = (target.HumanoidRootPart.Position - hrp.Position).Unit
        hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + look)
    end
end

function circleMove()
    coroutine.wrap(function()
        while isRunning do
            target = getNearestNPC()
            if target and target:FindFirstChild("HumanoidRootPart") then
                local angle = 0
                while isRunning and target and target:FindFirstChild("HumanoidRootPart") do
                    local tpos = target.HumanoidRootPart.Position
                    angle = (angle + 2) % 360
                    local rad = math.rad(angle)
                    local x = tpos.X + math.cos(rad) * radius
                    local z = tpos.Z + math.sin(rad) * radius
                    local pos = Vector3.new(x, tpos.Y, z)
                    local cf = CFrame.new(pos, tpos)
                    TweenService:Create(hrp, TweenInfo.new(0.03), {CFrame = cf}):Play()
                    task.wait(0.03)
                end
            else
                wait(1)
            end
        end
    end)()
end

function autoAttack()
    coroutine.wrap(function()
        while isAttacking do
            if target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
                faceTarget(target)
                local tool = lp.Character:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                end
            end
            wait(0.4)
        end
    end)()
end

createButton("Bật/Tắt chạy vòng", 35, function()
    isRunning = not isRunning
    if isRunning then circleMove() end
end)

createButton("Bật/Tắt đánh tự động", 65, function()
    isAttacking = not isAttacking
    if isAttacking then autoAttack() end
end)

createSlider("Khoảng cách", 5, 50, radius, 100, function(val)
    radius = val
end)

createSlider("Tốc độ", 1, 15, speed, 150, function(val)
    speed = val
end)

-- Hiển thị máu mục tiêu + auto aim liên tục
local hpLabel = Instance.new("TextLabel", frame)
hpLabel.Size = UDim2.new(0.9, 0, 0, 20)
hpLabel.Position = UDim2.new(0.05, 0, 1, -5)
hpLabel.TextColor3 = Color3.new(1, 1, 1)
hpLabel.BackgroundTransparency = 1
hpLabel.Font = Enum.Font.Gotham
hpLabel.TextSize = 14
hpLabel.Text = "Máu mục tiêu: N/A"

RunService.RenderStepped:Connect(function()
    target = getNearestNPC()
    if target and target:FindFirstChild("Humanoid") then
        hpLabel.Text = "Máu mục tiêu: " .. math.floor(target.Humanoid.Health)
        faceTarget(target)
    else
        hpLabel.Text = "Máu mục tiêu: N/A"
    end
end)
