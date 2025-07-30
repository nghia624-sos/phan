-- GUI
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "AutoFarmGui"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 260, 0, 250)
frame.Position = UDim2.new(0.35, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Visible = true
frame.Active = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "AUTO FARM MENU"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20

local toggleScript = Instance.new("TextButton", frame)
toggleScript.Size = UDim2.new(1, -20, 0, 30)
toggleScript.Position = UDim2.new(0, 10, 0, 40)
toggleScript.Text = "BẬT SCRIPT"
toggleScript.BackgroundColor3 = Color3.fromRGB(50,50,50)
toggleScript.TextColor3 = Color3.new(1,1,1)

local toggleMenu = Instance.new("TextButton", frame)
toggleMenu.Size = UDim2.new(1, -20, 0, 30)
toggleMenu.Position = UDim2.new(0, 10, 0, 80)
toggleMenu.Text = "ẨN MENU"
toggleMenu.BackgroundColor3 = Color3.fromRGB(50,50,50)
toggleMenu.TextColor3 = Color3.new(1,1,1)

local speedLabel = Instance.new("TextLabel", frame)
speedLabel.Text = "Tốc độ bay:"
speedLabel.Size = UDim2.new(1, -20, 0, 20)
speedLabel.Position = UDim2.new(0, 10, 0, 120)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.new(1,1,1)

local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(1, -20, 0, 30)
speedBox.Position = UDim2.new(0, 10, 0, 140)
speedBox.Text = "3"
speedBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
speedBox.TextColor3 = Color3.new(1,1,1)

local rangeLabel = Instance.new("TextLabel", frame)
rangeLabel.Text = "Tầm đánh:"
rangeLabel.Size = UDim2.new(1, -20, 0, 20)
rangeLabel.Position = UDim2.new(0, 10, 0, 180)
rangeLabel.BackgroundTransparency = 1
rangeLabel.TextColor3 = Color3.new(1,1,1)

local rangeBox = Instance.new("TextBox", frame)
rangeBox.Size = UDim2.new(1, -20, 0, 30)
rangeBox.Position = UDim2.new(0, 10, 0, 200)
rangeBox.Text = "24"
rangeBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
rangeBox.TextColor3 = Color3.new(1,1,1)

-- 👇 Thêm chức năng kéo menu 👇
local UserInputService = game:GetService("UserInputService")
local dragging = false
local dragInput, dragStart, startPos

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- Logic
local running = false
local currentTarget = nil
local RunService = game:GetService("RunService")

function getNearbyTargets()
    local found = {}
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v ~= char then
            if v.Humanoid.Health > 0 then
                table.insert(found, v)
            end
        end
    end
    table.sort(found, function(a, b)
        local distA = (char.HumanoidRootPart.Position - a.HumanoidRootPart.Position).Magnitude
        local distB = (char.HumanoidRootPart.Position - b.HumanoidRootPart.Position).Magnitude
        return distA < distB
    end)
    return found
end

function moveTo(pos)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:MoveTo(pos)
    end
end

function aimAt(target)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp and target:FindFirstChild("HumanoidRootPart") then
        local dir = (target.HumanoidRootPart.Position - hrp.Position).Unit
        hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + dir)
    end
end

function showHealth(target)
    local h = target:FindFirstChild("Humanoid")
    if h then
        game.StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = "👊 Máu mục tiêu: "..math.floor(h.Health).."/"..math.floor(h.MaxHealth);
            Color = Color3.fromRGB(255, 120, 120)
        })
    end
end

RunService.Heartbeat:Connect(function()
    if not running then return end
    if not currentTarget or currentTarget.Humanoid.Health <= 0 then
        local targets = getNearbyTargets()
        currentTarget = targets[1]
    end

    if currentTarget then
        local targetHRP = currentTarget:FindFirstChild("HumanoidRootPart")
        local myHRP = char:FindFirstChild("HumanoidRootPart")
        if targetHRP and myHRP then
            local dist = (targetHRP.Position - myHRP.Position).Magnitude
            local range = tonumber(rangeBox.Text) or 24
            local speed = tonumber(speedBox.Text) or 3

            if dist > range then
                moveTo(targetHRP.Position)
            else
                local angle = tick() * speed
                local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * range
                moveTo(targetHRP.Position + offset)

                aimAt(currentTarget)
                showHealth(currentTarget)

                local tool = char:FindFirstChildWhichIsA("Tool")
                if tool then tool:Activate() end
            end
        end
    end
end)

toggleScript.MouseButton1Click:Connect(function()
    running = not running
    toggleScript.Text = running and "TẮT SCRIPT" or "BẬT SCRIPT"
    if not running then currentTarget = nil end
end)

toggleMenu.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)