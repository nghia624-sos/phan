--// ================= SERVICES =================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInput = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local character = player.Character or player.CharacterAdded:Wait()

--// ================= GUI =================
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "DongPhanTroll"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 270, 0, 350)
Main.Position = UDim2.new(0.5, -135, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,15)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,40)
Title.BackgroundTransparency = 1
Title.Text = "Đông Phan Troll"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold

--// ================= BUTTON CREATOR =================
local function createButton(text, posY)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.85,0,0,35)
    btn.Position = UDim2.new(0.075,0,posY,0)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    btn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    return btn
end

-- Nút chức năng
local SelectBtn = createButton("Chọn mục tiêu",0.18)
local ChangeBtn = createButton("Đổi mục tiêu",0.30)
local LineBtn = createButton("Bật Line",0.42)
local FollowBtn = createButton("Bám Theo: OFF",0.54)

-- Đã đổi tên: Đổi Slot -> Đánh Nhanh
local FastAttackBtn = createButton("Đánh Nhanh: OFF",0.66)  
-- Đã đổi tên: Đánh Nhanh -> Auto Đánh
local AutoAttackBtn = createButton("Auto Đánh: OFF",0.78)   

--// ================= VARIABLES =================
local target = nil
local lineEnabled = false
local followEnabled = false
local fastAttackEnabled = false  -- Đã đổi tên từ swapEnabled
local autoAttackEnabled = false  -- Đã đổi tên từ fastEnabled

--// ================= LINE SYSTEM =================
local lineMain = Drawing.new("Line")
lineMain.Thickness = 4
lineMain.Color = Color3.fromRGB(255,0,0)
lineMain.Transparency = 1

local lineGlow = Drawing.new("Line")
lineGlow.Thickness = 8
lineGlow.Color = Color3.fromRGB(255,80,80)
lineGlow.Transparency = 0.4

--// ================= TARGET FUNCTIONS =================
local function getPlayersList()
    local list = {}
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            table.insert(list, plr)
        end
    end
    return list
end

local function selectFirst()
    local list = getPlayersList()
    if #list > 0 then
        target = list[1]
        SelectBtn.Text = "Đang chọn: "..target.Name
    end
end

local function changeTarget()
    local list = getPlayersList()
    if #list == 0 then return end
    
    if not target then
        target = list[1]
    else
        local index = table.find(list, target) or 0
        index += 1
        if index > #list then
            index = 1
        end
        target = list[index]
    end
    
    SelectBtn.Text = "Đang chọn: "..target.Name
end

--// ================= BUTTON CLICK HANDLERS =================
SelectBtn.MouseButton1Click:Connect(selectFirst)
ChangeBtn.MouseButton1Click:Connect(changeTarget)

LineBtn.MouseButton1Click:Connect(function()
    lineEnabled = not lineEnabled
    LineBtn.Text = lineEnabled and "Tắt Line" or "Bật Line"
end)

FollowBtn.MouseButton1Click:Connect(function()
    followEnabled = not followEnabled
    if followEnabled then
        FollowBtn.Text = "Bám Theo: ON"
        FollowBtn.BackgroundColor3 = Color3.fromRGB(170,85,0)
    else
        FollowBtn.Text = "Bám Theo: OFF"
        FollowBtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    end
end)

-- Đã đổi tên: SwapBtn -> FastAttackBtn
FastAttackBtn.MouseButton1Click:Connect(function()
    fastAttackEnabled = not fastAttackEnabled
    if fastAttackEnabled then
        FastAttackBtn.Text = "Đánh Nhanh: ON"
        FastAttackBtn.BackgroundColor3 = Color3.fromRGB(0,170,0)  -- Màu xanh lá
    else
        FastAttackBtn.Text = "Đánh Nhanh: OFF"
        FastAttackBtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    end
end)

-- Đã đổi tên: FastBtn -> AutoAttackBtn
AutoAttackBtn.MouseButton1Click:Connect(function()
    autoAttackEnabled = not autoAttackEnabled
    if autoAttackEnabled then
        AutoAttackBtn.Text = "Auto Đánh: ON"
        AutoAttackBtn.BackgroundColor3 = Color3.fromRGB(170,0,0)  -- Màu đỏ
    else
        AutoAttackBtn.Text = "Auto Đánh: OFF"
        AutoAttackBtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    end
end)

--// ================= CHARACTER UPDATE =================
player.CharacterAdded:Connect(function(char)
    character = char
end)

--// ================= HELPER FUNCTIONS =================
local function pressKey(key)
    VirtualInput:SendKeyEvent(true, key, false, game)
    task.wait()
    VirtualInput:SendKeyEvent(false, key, false, game)
end

--// ===== LOOP ĐÁNH NHANH (đổi slot nhanh) =====
-- Đã đổi tên từ swapEnabled -> fastAttackEnabled
task.spawn(function()
    while true do
        task.wait(0.19)
        if fastAttackEnabled then  -- Đánh Nhanh (đổi slot 1-2)
            pressKey(Enum.KeyCode.Two)
            task.wait(0.19)
            pressKey(Enum.KeyCode.One)
        end
    end
end)

--// ===== LOOP AUTO ĐÁNH (tự động đánh) =====
-- Đã đổi tên từ fastEnabled -> autoAttackEnabled
task.spawn(function()
    while true do
        if autoAttackEnabled then  -- Auto Đánh (kích hoạt tool)
            local tool = character:FindFirstChildOfClass("Tool")
            if tool then
                tool:Activate()
            end
        end
        task.wait(0.1)
    end
end)

--// ================= RENDER LOOP (LINE) =================
RunService.RenderStepped:Connect(function()
    if lineEnabled and target and target.Character
    and target.Character:FindFirstChild("HumanoidRootPart")
    and target.Character:FindFirstChild("Humanoid").Health > 0 then

        local myChar = player.Character
        if myChar and myChar:FindFirstChild("HumanoidRootPart") then

            local myPos = camera:WorldToViewportPoint(myChar.HumanoidRootPart.Position)
            local targetPos = camera:WorldToViewportPoint(target.Character.HumanoidRootPart.Position)

            local from = Vector2.new(myPos.X, myPos.Y)
            local to = Vector2.new(targetPos.X, targetPos.Y)

            lineMain.From = from
            lineMain.To = to
            lineGlow.From = from
            lineGlow.To = to

            lineMain.Visible = true
            lineGlow.Visible = true
        end
    else
        lineMain.Visible = false
        lineGlow.Visible = false
    end
end)

--// ================= FOLLOW SYSTEM =================
RunService.Heartbeat:Connect(function()
    if not followEnabled then return end
    if not target or not target.Character then return end
    
    local enemyHRP = target.Character:FindFirstChild("HumanoidRootPart")
    local enemyHum = target.Character:FindFirstChild("Humanoid")
    if not enemyHRP or not enemyHum or enemyHum.Health <= 0 then return end
    
    local myChar = player.Character
    if not myChar then return end
    
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    
    -- Tính vị trí sau lưng 7 studs
    local behindPosition = enemyHRP.Position - (enemyHRP.CFrame.LookVector * 4)
    
    -- Giữ cùng độ cao
    behindPosition = Vector3.new(
        behindPosition.X,
        enemyHRP.Position.Y,
        behindPosition.Z
    )

    -- Teleport thẳng (bám theo mục tiêu)
    myHRP.CFrame = CFrame.new(behindPosition, enemyHRP.Position)
end)