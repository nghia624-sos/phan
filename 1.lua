-- MENU FARM TIỀN CHẶT GỖ | TÊN: Nghia Minh
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

local running = false
local distanceToChop = 10
local moveSpeed = 100

-- Tìm cây gỗ gần nhất
function findClosestTree()
    local closestTree = nil
    local shortestDist = math.huge

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") or v:IsA("BasePart") then
            if string.lower(v.Name):find("cay") or string.lower(v.Name):find("go") then
                local treePos = v.Position or (v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("HumanoidRootPart").Position)
                if treePos then
                    local dist = (hrp.Position - treePos).Magnitude
                    if dist < shortestDist then
                        closestTree = v
                        shortestDist = dist
                    end
                end
            end
        end
    end
    return closestTree
end

-- Di chuyển đến cây
function moveTo(pos)
    local ti = TweenInfo.new((hrp.Position - pos).Magnitude / moveSpeed, Enum.EasingStyle.Linear)
    local tw = TweenService:Create(hrp, ti, {CFrame = CFrame.new(pos)})
    tw:Play()
    tw.Completed:Wait()
end

-- Auto chặt
function autoChop()
    local tool = lp.Character:FindFirstChildOfClass("Tool") or lp.Backpack:FindFirstChildOfClass("Tool")
    if tool then
        tool.Parent = lp.Character
        for i = 1, 3 do
            tool:Activate()
            wait(0.2)
        end
    end
end

-- Luồng farm chính
task.spawn(function()
    while true do wait(0.5)
        if running then
            local tree = findClosestTree()
            if tree and tree.Position then
                if (hrp.Position - tree.Position).Magnitude > distanceToChop then
                    moveTo(tree.Position + Vector3.new(0, 0, 2))
                else
                    autoChop()
                end
            end
        end
    end
end)

-- GUI Menu
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Position = UDim2.new(0.05, 0, 0.2, 0)
Frame.Size = UDim2.new(0, 220, 0, 220)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.Active = true
Frame.Draggable = true

local title = Instance.new("TextLabel", Frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Nghia Minh | Fram Gỗ"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

local toggle = Instance.new("TextButton", Frame)
toggle.Position = UDim2.new(0, 10, 0, 40)
toggle.Size = UDim2.new(0, 200, 0, 40)
toggle.Text = "Bật Fram Chặt Gỗ"
toggle.BackgroundColor3 = Color3.fromRGB(60, 130, 60)
toggle.TextColor3 = Color3.new(1,1,1)
toggle.MouseButton1Click:Connect(function()
    running = not running
    toggle.Text = running and "Đang Fram..." or "Bật Fram Chặt Gỗ"
    toggle.BackgroundColor3 = running and Color3.fromRGB(200, 60, 60) or Color3.fromRGB(60,130,60)
end)

local distanceBox = Instance.new("TextBox", Frame)
distanceBox.Position = UDim2.new(0, 10, 0, 90)
distanceBox.Size = UDim2.new(0, 200, 0, 30)
distanceBox.PlaceholderText = "Khoảng cách chặt (vd: 10)"
distanceBox.Text = tostring(distanceToChop)
distanceBox.FocusLost:Connect(function()
    local val = tonumber(distanceBox.Text)
    if val then distanceToChop = val end
end)

local speedBox = Instance.new("TextBox", Frame)
speedBox.Position = UDim2.new(0, 10, 0, 130)
speedBox.Size = UDim2.new(0, 200, 0, 30)
speedBox.PlaceholderText = "Tốc độ di chuyển (vd: 100)"
speedBox.Text = tostring(moveSpeed)
speedBox.FocusLost:Connect(function()
    local val = tonumber(speedBox.Text)
    if val then moveSpeed = val end
end)