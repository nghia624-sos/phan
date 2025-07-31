local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FramNPCMenu"
gui.ResetOnSpawn = false

-- Khung chính
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 200)
frame.Position = UDim2.new(0, 50, 0, 200)
frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Tên menu
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Fram NPC"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1

-- Nút bật tắt script
local enabled = false
local runBtn = Instance.new("TextButton", frame)
runBtn.Size = UDim2.new(1, -20, 0, 30)
runBtn.Position = UDim2.new(0, 10, 0, 40)
runBtn.Text = "Bật Script"
runBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    runBtn.Text = enabled and "Tắt Script" or "Bật Script"
end)

-- Bán kính và tốc độ
local radiusBox = Instance.new("TextBox", frame)
radiusBox.PlaceholderText = "Bán kính vòng (vd: 10)"
radiusBox.Size = UDim2.new(1, -20, 0, 25)
radiusBox.Position = UDim2.new(0, 10, 0, 80)
radiusBox.Text = "10"

local speedBox = Instance.new("TextBox", frame)
speedBox.PlaceholderText = "Tốc độ vòng (vd: 2)"
speedBox.Size = UDim2.new(1, -20, 0, 25)
speedBox.Position = UDim2.new(0, 10, 0, 110)
speedBox.Text = "2"

-- Nút bật chạy vòng + đánh
local circling = false
local circleBtn = Instance.new("TextButton", frame)
circleBtn.Size = UDim2.new(1, -20, 0, 30)
circleBtn.Position = UDim2.new(0, 10, 0, 145)
circleBtn.Text = "Chạy vòng + Đánh"
circleBtn.MouseButton1Click:Connect(function()
    circling = not circling
    circleBtn.Text = circling and "Đang chạy vòng" or "Chạy vòng + Đánh"
end)

-- Hàm tìm NPC gần nhất tên chứa "CityNPC"
function getNearestCityNPC()
    local nearest, minDist = nil, math.huge
    for _, npc in pairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
            if string.lower(npc.Name):find("citynpc") then
                local dist = (npc.HumanoidRootPart.Position - hrp.Position).Magnitude
                if dist < minDist then
                    nearest = npc
                    minDist = dist
                end
            end
        end
    end
    return nearest
end

-- Auto fram + chạy bộ + chạy vòng
function autoFram()
    task.spawn(function()
        while true do task.wait(0.1)
            if enabled then
                local target = getNearestCityNPC()
                if target and target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
                    humanoid:MoveTo(target.HumanoidRootPart.Position)
                    humanoid.MoveToFinished:Wait()
                    repeat task.wait(0.1)
                        if circling then
                            local dist = tonumber(radiusBox.Text) or 10
                            local speed = tonumber(speedBox.Text) or 2
                            local angle = tick() * speed
                            local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * dist
                            local goalPos = target.HumanoidRootPart.Position + offset
                            humanoid:MoveTo(goalPos)
                            hrp.CFrame = CFrame.new(hrp.Position, target.HumanoidRootPart.Position)

                            -- Auto đánh
                            local tool = char:FindFirstChildOfClass("Tool")
                            if tool and tool:FindFirstChild("Handle") then
                                for _, part in pairs(target:GetDescendants()) do
                                    if part:IsA("BasePart") and (part.Position - hrp.Position).Magnitude < dist + 3 then
                                        firetouchinterest(tool.Handle, part, 0)
                                        firetouchinterest(tool.Handle, part, 1)
                                    end
                                end
                            end
                        end
                    until not target or target.Humanoid.Health <= 0 or not enabled
                end
            end
        end
    end)
end
