local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

-- GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 350)
Frame.Position = UDim2.new(0, 50, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true

local UIListLayout = Instance.new("UIListLayout", Frame)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Tabs
local tabs = {
    {Name = "Fram", Content = function(container)
        local ToggleFram = Instance.new("TextButton", container)
        ToggleFram.Text = "Bật Fram"
        ToggleFram.Size = UDim2.new(1, 0, 0, 30)
        ToggleFram.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

        local ToggleVong = Instance.new("TextButton", container)
        ToggleVong.Text = "Chạy Vòng + Auto Đánh"
        ToggleVong.Size = UDim2.new(1, 0, 0, 30)
        ToggleVong.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

        ToggleFram.MouseButton1Click:Connect(function()
            _G.Fram = not _G.Fram
        end)

        ToggleVong.MouseButton1Click:Connect(function()
            _G.Auto = not _G.Auto
        end)
    end},
    {Name = "Tùy Chỉnh", Content = function(container)
        local radiusLabel = Instance.new("TextLabel", container)
        radiusLabel.Text = "Bán kính:"
        radiusLabel.Size = UDim2.new(1, 0, 0, 20)
        radiusLabel.BackgroundTransparency = 1

        local radiusBox = Instance.new("TextBox", container)
        radiusBox.Text = "20"
        radiusBox.Size = UDim2.new(1, 0, 0, 25)

        local speedLabel = Instance.new("TextLabel", container)
        speedLabel.Text = "Tốc độ:"
        speedLabel.Size = UDim2.new(1, 0, 0, 20)
        speedLabel.BackgroundTransparency = 1

        local speedBox = Instance.new("TextBox", container)
        speedBox.Text = "3"
        speedBox.Size = UDim2.new(1, 0, 0, 25)

        radiusBox.FocusLost:Connect(function()
            radius = tonumber(radiusBox.Text) or 20
        end)

        speedBox.FocusLost:Connect(function()
            speed = tonumber(speedBox.Text) or 3
        end)
    end},
    {Name = "Giảm Đồ Họa", Content = function(container)
        local Button = Instance.new("TextButton", container)
        Button.Text = "Bật Giảm Đồ Họa"
        Button.Size = UDim2.new(1, 0, 0, 30)
        Button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)

        Button.MouseButton1Click:Connect(function()
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("Decal") or v:IsA("Texture") or v:IsA("ParticleEmitter") then
                    v:Destroy()
                elseif v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                end
            end
            game.Lighting.GlobalShadows = false
            game.Lighting.FogEnd = 1000000
            game.Lighting.Brightness = 1
        end)
    end}
}

-- Tab Buttons
local tabButtons = Instance.new("Frame", Frame)
tabButtons.Size = UDim2.new(1, 0, 0, 30)
tabButtons.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
tabButtons.LayoutOrder = -1

local tabContainer = Instance.new("Frame", Frame)
tabContainer.Size = UDim2.new(1, 0, 1, -30)
tabContainer.BackgroundTransparency = 1

local UIList = Instance.new("UIListLayout", tabButtons)
UIList.FillDirection = Enum.FillDirection.Horizontal
UIList.SortOrder = Enum.SortOrder.LayoutOrder

for _, tab in ipairs(tabs) do
    local Button = Instance.new("TextButton", tabButtons)
    Button.Text = tab.Name
    Button.Size = UDim2.new(1 / #tabs, 0, 1, 0)
    Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

    Button.MouseButton1Click:Connect(function()
        tabContainer:ClearAllChildren()
        tab.Content(tabContainer)
    end)
end

-- Tìm NPC gần nhất
local function FindTarget()
    local nearest, distance = nil, math.huge
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Name:lower():find("citynpc") then
            local dist = (v.HumanoidRootPart.Position - hrp.Position).magnitude
            if dist < distance then
                distance = dist
                nearest = v
            end
        end
    end
    return nearest
end

-- Di chuyển đến mục tiêu
local function MoveToTarget(target)
    local path = (target.HumanoidRootPart.Position - hrp.Position).Unit
    local goal = hrp.Position + path * 5
    hum:MoveTo(goal)
end

-- Chạy vòng + đánh
RunService.Heartbeat:Connect(function(dt)
    if not chr or not chr:FindFirstChild("HumanoidRootPart") then return end

    local target = FindTarget()
    if target and target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("Humanoid").Health > 0 then
        local dist = (target.HumanoidRootPart.Position - hrp.Position).Magnitude

        if _G.Fram and dist > radius then
            MoveToTarget(target)
        end

        if _G.Auto and dist <= radius then
            local angle = tick() * speed
            local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
            local pos = target.HumanoidRootPart.Position + offset
            local tween = TweenService:Create(hrp, TweenInfo.new(dt, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos, target.HumanoidRootPart.Position)})
            tween:Play()

            -- Đánh
            for _, tool in ipairs(lp.Backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    tool.Parent = chr
                end
            end
            for _, tool in ipairs(chr:GetChildren()) do
                if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                    tool:Activate()
                end
            end
        end
    end
end)