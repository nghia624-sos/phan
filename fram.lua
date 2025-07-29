-- GUI đơn giản
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()

local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 230)
frame.Position = UDim2.new(0, 10, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(1, 0, 0, 30)
toggleBtn.Text = "Bật Script"
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)

local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(1, -10, 0, 30)
speedBox.Position = UDim2.new(0, 5, 0, 40)
speedBox.PlaceholderText = "Tốc độ (mặc định 10)"
speedBox.Text = ""

local radiusBox = Instance.new("TextBox", frame)
radiusBox.Size = UDim2.new(1, -10, 0, 30)
radiusBox.Position = UDim2.new(0, 5, 0, 80)
radiusBox.PlaceholderText = "Bán kính (mặc định 10)"
radiusBox.Text = ""

local hpLabel = Instance.new("TextLabel", frame)
hpLabel.Size = UDim2.new(1, -10, 0, 30)
hpLabel.Position = UDim2.new(0, 5, 0, 130)
hpLabel.Text = "Máu: ?"
hpLabel.TextColor3 = Color3.new(1,1,1)
hpLabel.BackgroundTransparency = 1

local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(1, 0, 0, 30)
closeBtn.Position = UDim2.new(0, 0, 1, -30)
closeBtn.Text = "Đóng Menu"
closeBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
closeBtn.TextColor3 = Color3.new(1, 1, 1)

-- Logic xử lý
local running = false
local speed = 10
local radius = 10
local target = nil

function findNpc()
    local nearest = nil
    local shortest = math.huge
    local myPos = char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.Position

    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name:lower():find("npccity") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
            local dist = (v.HumanoidRootPart.Position - myPos).Magnitude
            if dist < shortest then
                shortest = dist
                nearest = v
            end
        end
    end
    return nearest
end

function moveAndAttack()
    spawn(function()
        while running do
            if not char:FindFirstChild("HumanoidRootPart") then wait(0.1) continue end

            if not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 then
                target = findNpc()
                if not target then
                    hpLabel.Text = "Máu: Không có mục tiêu"
                    wait(1)
                    continue
                end
            end

            local angle = tick() * speed
            local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
            local moveTo = target.HumanoidRootPart.Position + offset
            local myHRP = char:FindFirstChild("HumanoidRootPart")
            if myHRP then
                myHRP.CFrame = CFrame.new(myHRP.Position, target.HumanoidRootPart.Position)
                myHRP.Velocity = (moveTo - myHRP.Position).Unit * speed
            end

            -- Auto đánh nếu có tool
            local tool = char:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Handle") then
                tool:Activate()
            end

            -- Cập nhật máu
            if target and target:FindFirstChild("Humanoid") then
                hpLabel.Text = "Máu: " .. math.floor(target.Humanoid.Health)
            end

            wait(0.1)
        end
    end)
end

toggleBtn.MouseButton1Click:Connect(function()
    running = not running
    toggleBtn.Text = running and "Tắt Script" or "Bật Script"

    local newSpeed = tonumber(speedBox.Text)
    local newRadius = tonumber(radiusBox.Text)
    if newSpeed then speed = newSpeed end
    if newRadius then radius = newRadius end

    if running then
        moveAndAttack()
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)