local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

local gui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
gui.Name = "TT_dongphandzs1"

local frame = Instance.new("Frame", gui)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.Position = UDim2.new(0, 100, 0, 100)
frame.Size = UDim2.new(0, 270, 0, 270)
frame.Active = true
frame.Draggable = true
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.2

local function createLabel(text, pos)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Position = pos
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.Text = text
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    return label
end

local radiusInput = Instance.new("TextBox", frame)
radiusInput.PlaceholderText = "Bán kính (VD: 10)"
radiusInput.Position = UDim2.new(0, 10, 0, 25)
radiusInput.Size = UDim2.new(0, 120, 0, 25)
radiusInput.Text = ""

local speedInput = Instance.new("TextBox", frame)
speedInput.PlaceholderText = "Tốc độ (VD: 5)"
speedInput.Position = UDim2.new(0, 140, 0, 25)
speedInput.Size = UDim2.new(0, 120, 0, 25)
speedInput.Text = ""

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0, 250, 0, 30)
toggle.Position = UDim2.new(0, 10, 0, 60)
toggle.Text = "Bật Fram"
toggle.BackgroundColor3 = Color3.fromRGB(100, 200, 100)

local hpLabel = Instance.new("TextLabel", frame)
hpLabel.Size = UDim2.new(1, -10, 0, 20)
hpLabel.Position = UDim2.new(0.05, 0, 1, -30)
hpLabel.BackgroundTransparency = 1
hpLabel.TextColor3 = Color3.new(1,1,1)
hpLabel.Text = "Máu mục tiêu: N/A"
hpLabel.Font = Enum.Font.SourceSansBold
hpLabel.TextSize = 16

local menuToggle = Instance.new("TextButton", gui)
menuToggle.Size = UDim2.new(0, 120, 0, 30)
menuToggle.Position = UDim2.new(0, 10, 0, 10)
menuToggle.Text = "Hiện/Ẩn Menu"
menuToggle.BackgroundColor3 = Color3.fromRGB(255, 150, 0)

local xInput = Instance.new("TextBox", frame)
xInput.PlaceholderText = "Hitbox X"
xInput.Position = UDim2.new(0, 10, 0, 100)
xInput.Size = UDim2.new(0, 70, 0, 25)

local yInput = Instance.new("TextBox", frame)
yInput.PlaceholderText = "Y"
yInput.Position = UDim2.new(0, 90, 0, 100)
yInput.Size = UDim2.new(0, 70, 0, 25)

local zInput = Instance.new("TextBox", frame)
zInput.PlaceholderText = "Z"
zInput.Position = UDim2.new(0, 170, 0, 100)
zInput.Size = UDim2.new(0, 70, 0, 25)

local hitboxPart = nil

function getNearestNPC()
    local nearest, dist = nil, math.huge
    for _, npc in pairs(workspace:GetDescendants()) do
        if npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") and not npc:IsDescendantOf(lp.Character) then
            local d = (npc.HumanoidRootPart.Position - hrp.Position).Magnitude
            if d < dist then
                dist = d
                nearest = npc
            end
        end
    end
    return nearest
end

function faceTarget(target)
    if target and target:FindFirstChild("HumanoidRootPart") then
        local dir = (target.HumanoidRootPart.Position - hrp.Position).Unit
        hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(dir.X, 0, dir.Z))
    end
end

function updateHitbox()
    local tool = lp.Character:FindFirstChildOfClass("Tool")
    if tool and tool:FindFirstChild("Handle") then
        local handle = tool.Handle
        local x = tonumber(xInput.Text) or 4
        local y = tonumber(yInput.Text) or 4
        local z = tonumber(zInput.Text) or 4
        handle.Size = Vector3.new(x, y, z)
        handle.Transparency = 1
        handle.Massless = true
        handle.CanCollide = false
        if not hitboxPart then
            hitboxPart = Instance.new("Part", handle)
            hitboxPart.Anchored = false
            hitboxPart.CanCollide = false
            hitboxPart.Massless = true
            hitboxPart.Color = Color3.new(1, 0, 0)
            hitboxPart.Material = Enum.Material.Neon
            hitboxPart.Transparency = 0.3
            hitboxPart.Name = "HitboxDisplay"
        end
        hitboxPart.Size = Vector3.new(x, y, z)
        local weld = Instance.new("WeldConstraint", hitboxPart)
        weld.Part0 = hitboxPart
        weld.Part1 = handle
    end
end

menuToggle.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

toggle.MouseButton1Click:Connect(function()
    local running = true
    while running and hum and hum.Health > 0 do
        local radius = tonumber(radiusInput.Text) or 10
        local speed = tonumber(speedInput.Text) or 5
        updateHitbox()
        local target = getNearestNPC()
        if target and target:FindFirstChild("HumanoidRootPart") then
            local tPos = target.HumanoidRootPart.Position
            local angle = tick() * speed
            local x = math.cos(angle) * radius
            local z = math.sin(angle) * radius
            local destination = tPos + Vector3.new(x, 0, z)
            hum:MoveTo(destination)
        end
        task.wait(0.1)
    end
end)

RunService.RenderStepped:Connect(function()
    local target = getNearestNPC()
    if target and target:FindFirstChild("Humanoid") then
        hpLabel.Text = "Máu mục tiêu: " .. math.floor(target.Humanoid.Health)
        faceTarget(target)
    else
        hpLabel.Text = "Máu mục tiêu: N/A"
    end
end)