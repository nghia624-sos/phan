--⚠️ Script Roblox đầy đủ tính năng Fram CityNPC menu "TT:dongphandzs1"
--✅ Giữ toàn bộ chức năng cũ + sửa lỗi giao diện

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hrp = chr:WaitForChild("HumanoidRootPart")
local hum = chr:WaitForChild("Humanoid")

--⚙️ Config
local radius = 15
local speed = 3
local attackDelay = 1
local noclip = false

--📦 GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "FramMenu"
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 300)
Frame.Position = UDim2.new(0, 100, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Title.Text = "TT:dongphandzs1"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true

local function createButton(text, y, callback)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, y)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextScaled = true
    btn.MouseButton1Click:Connect(callback)
    return btn
end

--🔘 Trạng thái Fram
local isFraming = false
local currentTarget = nil

--🔍 Tìm NPC chứa "CityNPC" hoặc "NPCity"
function getTarget()
    local minDist, target = math.huge, nil
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            local name = v.Name:lower()
            if name:find("citynpc") or name:find("npcity") then
                local dist = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    target = v
                end
            end
        end
    end
    return target
end

--🏃‍♂️ Di chuyển bộ tới mục tiêu
function walkTo(pos)
    hum:MoveTo(pos)
end

--🔁 Chạy vòng quanh mục tiêu
function runCircle(target)
    coroutine.wrap(function()
        while isFraming and target and target:FindFirstChild("HumanoidRootPart") and target.Humanoid.Health > 0 do
            local tPos = target.HumanoidRootPart.Position
            local angle = tick() * speed
            local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
            local goalPos = tPos + offset
            hum:MoveTo(goalPos)
            RunService.Heartbeat:Wait()
        end
    end)()
end

--⚔️ Auto đánh
function attack()
    if not currentTarget then return end
    local tool = lp.Character:FindFirstChildOfClass("Tool")
    if tool and tool:FindFirstChild("Handle") then
        tool:Activate()
    end
end

--🔁 Fram liên tục
function startFram()
    isFraming = true
    coroutine.wrap(function()
        while isFraming do
            currentTarget = getTarget()
            if currentTarget then
                walkTo(currentTarget.HumanoidRootPart.Position)
                repeat
                    RunService.Heartbeat:Wait()
                until not isFraming or (currentTarget.HumanoidRootPart.Position - hrp.Position).Magnitude < radius + 2

                runCircle(currentTarget)
                while currentTarget and currentTarget:FindFirstChild("Humanoid") and currentTarget.Humanoid.Health > 0 and isFraming do
                    attack()
                    wait(attackDelay)
                end
            else
                wait(1)
            end
        end
    end)()
end

function stopFram()
    isFraming = false
    currentTarget = nil
end

--👻 Noclip
RunService.Stepped:Connect(function()
    if noclip then
        for _, v in pairs(lp.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

--📲 Nút menu
createButton("Bật Fram", 40, function()
    if not isFraming then startFram() end
end)

createButton("Tắt Fram", 80, function()
    stopFram()
end)

createButton("Noclip ON/OFF", 120, function()
    noclip = not noclip
end)

createButton("+ Bán kính", 160, function()
    radius = radius + 2
end)

createButton("- Bán kính", 200, function()
    radius = math.max(5, radius - 2)
end)

createButton("+ Tốc độ", 240, function()
    speed = speed + 1
end)

createButton("- Tốc độ", 280, function()
    speed = math.max(1, speed - 1)
end)