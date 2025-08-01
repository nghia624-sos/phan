-- GUI Menu Fram NPC
-- Tên menu: TT:dongphandzs1

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")
local mouse = lp:GetMouse()

local target = nil
local running = false
local noclip = false
local radius = 10
local speed = 5
local delayTime = 5000
local gui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 250)
frame.Position = UDim2.new(0, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.Active = true
frame.Draggable = true

local radiusBox = Instance.new("TextBox", frame)
radiusBox.Size = UDim2.new(1, 0, 0, 40)
radiusBox.Position = UDim2.new(0, 0, 0, 0)
radiusBox.Text = tostring(radius)
radiusBox.PlaceholderText = "Bán kính"

local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(1, 0, 0, 40)
speedBox.Position = UDim2.new(0, 0, 0, 40)
speedBox.Text = tostring(speed)
speedBox.PlaceholderText = "Tốc độ"

local delayBox = Instance.new("TextBox", frame)
delayBox.Size = UDim2.new(1, 0, 0, 40)
delayBox.Position = UDim2.new(0, 0, 0, 80)
delayBox.Text = tostring(delayTime)
delayBox.PlaceholderText = "Delay"

local toggleButton = Instance.new("TextButton", frame)
toggleButton.Size = UDim2.new(1, 0, 0, 40)
toggleButton.Position = UDim2.new(0, 0, 0, 120)
toggleButton.Text = "BẬT Fram"
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)

local noclipButton = Instance.new("TextButton", frame)
noclipButton.Size = UDim2.new(1, 0, 0, 40)
noclipButton.Position = UDim2.new(0, 0, 0, 160)
noclipButton.Text = "Noclip: OFF"
noclipButton.BackgroundColor3 = Color3.fromRGB(0, 0, 255)

local nameLabel = Instance.new("TextLabel", frame)
nameLabel.Size = UDim2.new(1, 0, 0, 40)
nameLabel.Position = UDim2.new(0, 0, 0, 210)
nameLabel.Text = "TT:dongphandzs1"
nameLabel.BackgroundTransparency = 1
nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
nameLabel.TextScaled = true

function getTarget()
    local closest = nil
    local shortest = math.huge
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v ~= chr then
            local name = v.Name:lower()
            if name:find("citynpc") or name:find("npcity") then
                local dist = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = v
                end
            end
        end
    end
    return closest
end

function moveToTarget(targetPos)
    hum:MoveTo(targetPos)
end

function startFram()
    running = true
    toggleButton.Text = "TẮT Fram"
    toggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)

    while running do
        target = getTarget()
        if target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
            repeat
                local dist = (hrp.Position - target.HumanoidRootPart.Position).Magnitude
                if dist > radius then
                    moveToTarget(target.HumanoidRootPart.Position)
                else
                    local angle = tick() * speed
                    local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
                    local pos = target.HumanoidRootPart.Position + offset
                    moveToTarget(pos)
                    hrp.CFrame = CFrame.new(hrp.Position, target.HumanoidRootPart.Position)
                end
                task.wait()
            until not running or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0
            task.wait(delayTime / 1000)
        else
            task.wait(0.5)
        end
    end
end

toggleButton.MouseButton1Click:Connect(function()
    radius = tonumber(radiusBox.Text) or radius
    speed = tonumber(speedBox.Text) or speed
    delayTime = tonumber(delayBox.Text) or delayTime

    if not running then
        startFram()
    else
        running = false
        toggleButton.Text = "BẬT Fram"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    end
end)

noclipButton.MouseButton1Click:Connect(function()
    noclip = not noclip
    noclipButton.Text = "Noclip: " .. (noclip and "ON" or "OFF")
end)

RunService.Stepped:Connect(function()
    if noclip then
        for _, part in pairs(chr:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)