loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local function getChar()
	return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local Character = getChar()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")

local framEnabled = false
local framRadius = 10
local framSpeed = 3

local spinEnabled = false
local silentEnabled = false
local hitboxEnabled = false

---------------- UI ------------------

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
	Name = "TT:dongphandzs1 by đông phan",
	LoadingTitle = "dongphandzs1",
	LoadingSubtitle = "Fram + PvP",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "dongphandzs1",
		FileName = "fram_settings"
	}
})

------------ TAB 1: Fram NPC ------------

-- Tải Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Lấy thông tin nhân vật
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Gán giá trị mặc định tránh callback error
_G.FramNPC = false
_G.Range = 10
_G.Speed = 5

-- Tìm NPC gần nhất có tên chứa "CityNPC" (không phân biệt hoa thường)
local function getNearestCityNPC()
    local nearest, distance = nil, math.huge
    for _, npc in pairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") and string.lower(npc.Name):find("citynpc") then
            local dist = (npc.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
            if dist < distance then
                distance = dist
                nearest = npc
            end
        end
    end
    return nearest
end

-- Di chuyển tự nhiên tới mục tiêu bằng PathfindingService
local function moveToTarget(target)
    local path = game:GetService("PathfindingService"):CreatePath()
    path:ComputeAsync(HumanoidRootPart.Position, target.Position)
    local points = path:GetWaypoints()

    for _, point in ipairs(points) do
        if (HumanoidRootPart.Position - target.Position).Magnitude <= _G.Range then return end
        Character:WaitForChild("Humanoid"):MoveTo(point.Position)
        Character:WaitForChild("Humanoid").MoveToFinished:Wait()
    end
end

-- Tạo chuyển động xoay quanh mục tiêu
local function startOrbiting(target)
    local RunService = game:GetService("RunService")
    local angle = 0
    local radius = _G.Range or 10
    local speed = _G.Speed or 2
    local orbiting = true

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not target or not target:FindFirstChild("HumanoidRootPart") then
            connection:Disconnect()
            return
        end

        angle = angle + speed * 0.03
        local x = math.cos(angle) * radius
        local z = math.sin(angle) * radius
        local newPosition = target.HumanoidRootPart.Position + Vector3.new(x, 0, z)

        game:GetService("TweenService"):Create(
            HumanoidRootPart,
            TweenInfo.new(0.1, Enum.EasingStyle.Linear),
            {CFrame = CFrame.new(newPosition, target.HumanoidRootPart.Position)}
        ):Play()
    end)

    return connection
end

-- Tự động đánh (kích hoạt tool nếu có)
local function autoAttack()
    local tool = Player.Character:FindFirstChildOfClass("Tool")
    if tool and tool:FindFirstChild("Handle") then
        pcall(function()
            tool:Activate()
        end)
    end
end

-- Vòng lặp Fram NPC
local function framLoop()
    while _G.FramNPC do
        local target = getNearestCityNPC()
        if target then
            moveToTarget(target.HumanoidRootPart)
            if (HumanoidRootPart.Position - target.HumanoidRootPart.Position).Magnitude <= _G.Range + 2 then
                local orbit = startOrbiting(target)

                while target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 and _G.FramNPC do
                    autoAttack()
                    wait(0.3)
                end

                if orbit then orbit:Disconnect() end
            end
        end
        wait(0.2)
    end
end

-- Tạo GUI Rayfield
local Window = Rayfield:CreateWindow({
    Name = "TT:dongphandzs1 by Đông Phan",
    LoadingTitle = "Đang tải menu...",
    LoadingSubtitle = "Fram NPC City by Nghĩa",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = nil,
        FileName = "dongphandzs1"
    },
    Discord = {
        Enabled = false,
    },
    KeySystem = false,
})

-- Tạo Tab "Fram NPC"
local MainTab = Window:CreateTab("Fram NPC", 4483362458)

-- Toggle Fram
MainTab:CreateToggle({
    Name = "Bật Fram NPC",
    CurrentValue = false,
    Callback = function(Value)
    _G.FramNPC = Value
    if Value then
        task.spawn(framLoop)
        AutoPickupItems() -- <== Gọi ở đây để tự nhặt đồ khi fram
    end
end,
})

-- Tùy chỉnh bán kính
MainTab:CreateSlider({
    Name = "Bán kính đánh",
    Range = {5, 30},
    Increment = 1,
    CurrentValue = 10,
    Callback = function(Value)
        _G.Range = Value
    end,
})

-- Tùy chỉnh tốc độ quay vòng
MainTab:CreateSlider({
    Name = "Tốc độ quay",
    Range = {1, 20},
    Increment = 1,
    CurrentValue = 5,
    Callback = function(Value)
        _G.Speed = Value
    end,
})

function AutoPickupItems()
    spawn(function()
        while wait(1) do
         if not _G.FramNPC then continue end
            for _, item in pairs(game:GetService("Workspace"):GetChildren()) do
                if item:IsA("Tool") or item.Name:lower():find("item") then
                    if (item.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 20 then
                        firetouchinterest(item, game.Players.LocalPlayer.Character.HumanoidRootPart, 0)
                        wait()
                        firetouchinterest(item, game.Players.LocalPlayer.Character.HumanoidRootPart, 1)
                    end
                end
            end
        end
    end)
end

------------ TAB 2: PvP ------------

local PvPTab = Window:CreateTab("PVP", 4483345998)

-- Spin
PvPTab:CreateToggle({
	Name = "🔄 Spin",
	Default = false,
	Callback = function(Value)
		spinEnabled = Value
		if Value then
			spawn(function()
				while spinEnabled do
					if Character and HRP then
						HRP.CFrame = HRP.CFrame * CFrame.Angles(0, math.rad(1000), 0)
					end
					wait(0.03)
				end
			end)
		end
	end,
})

-- Auto Aim (mới)
PvPTab:CreateToggle({
	Name = "🎯 Auto Aim người chơi gần",
	Default = false,
	Callback = function(Value)
		_G.AutoAimPlayer = Value
		if Value then
			spawn(function()
				while _G.AutoAimPlayer do
					local nearest = nil
					local shortest = math.huge
					for _, p in pairs(Players:GetPlayers()) do
						if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
							local dist = (HRP.Position - p.Character.HumanoidRootPart.Position).Magnitude
							if dist < shortest and p.Character.Humanoid.Health > 0 then
								shortest = dist
								nearest = p.Character
							end
						end
					end

					if nearest then
						HRP.CFrame = CFrame.new(HRP.Position, nearest.HumanoidRootPart.Position)
					end
					wait(0.15)
				end
			end)
		end
	end,
})

-- Silent Aim
PvPTab:CreateToggle({
	Name = "🕶️ Silent Aim (Giả lập bắn)",
	Default = false,
	Callback = function(Value)
		silentEnabled = Value
		if Value then
			spawn(function()
				while silentEnabled do
					local nearest = nil
					local shortest = math.huge
					for _, p in pairs(Players:GetPlayers()) do
						if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
							local dist = (HRP.Position - p.Character.HumanoidRootPart.Position).Magnitude
							if dist < shortest and p.Character.Humanoid.Health > 0 then
								shortest = dist
								nearest = p.Character
							end
						end
					end

					if nearest then
						mouse1click()
					end
					wait(0.25)
				end
			end)
		end
	end,
})

-- Hitbox + Line
PvPTab:CreateToggle({
	Name = "📏 Hitbox + Line đến người chơi",
	Default = false,
	Callback = function(Value)
		hitboxEnabled = Value
		if Value then
			-- Gắn hitbox cho tất cả người chơi liên tục
			spawn(function()
				while hitboxEnabled do
					for _, player in pairs(Players:GetPlayers()) do
						if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
							local part = player.Character.HumanoidRootPart
							if not part:FindFirstChild("Hitbox") then
								local adorn = Instance.new("BoxHandleAdornment")
								adorn.Size = part.Size + Vector3.new(2,2,2)
								adorn.Color3 = Color3.new(1,0,0)
								adorn.Adornee = part
								adorn.AlwaysOnTop = true
								adorn.ZIndex = 10
								adorn.Name = "Hitbox"
								adorn.Parent = part
							end

							if not part:FindFirstChild("TargetLine") then
								local beam = Instance.new("Beam")
								local a0 = HRP:FindFirstChild("HRP_Attach") or Instance.new("Attachment", HRP)
								a0.Name = "HRP_Attach"
								local a1 = Instance.new("Attachment", part)

								beam.Attachment0 = a0
								beam.Attachment1 = a1
								beam.Width0 = 0.1
								beam.Width1 = 0.1
								beam.Color = ColorSequence.new(Color3.new(1,0,0))
								beam.FaceCamera = true
								beam.Name = "TargetLine"
								beam.Parent = part
							end
						end
					end
					wait(1)
				end
			end)
		else
			for _, p in pairs(Players:GetPlayers()) do
				if p ~= LocalPlayer and p.Character then
					for _, v in pairs(p.Character:GetDescendants()) do
						if v:IsA("BoxHandleAdornment") and v.Name == "Hitbox" then v:Destroy() end
						if v:IsA("Beam") and v.Name == "TargetLine" then v:Destroy() end
						if v:IsA("Attachment") and v.Name == "HRP_Attach" then v:Destroy() end
					end
				end
			end
		end
	end,
})

        -------ĐÁNH BOSS------
  
 local NewTab = Window:CreateTab("Fram Boss", 4483362458)
 
 local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

-- Biến
local radius = 20
local speed = 2
local running = false
local autoAttack = false
local currentTarget = nil

-- GUI chính
local gui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
gui.Name = "Menu_TT"
gui.Enabled = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 270)
frame.Position = UDim2.new(0.5, -150, 0.5, -135)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1, 0, 0, 40)
toggle.Position = UDim2.new(0, 0, 0, 0)
toggle.Text = "BẬT: Đánh Boss"
toggle.TextColor3 = Color3.new(1,1,1)
toggle.BackgroundColor3 = Color3.fromRGB(40,40,40)

local disLabel = Instance.new("TextLabel", frame)
disLabel.Text = "Khoảng cách:"
disLabel.Size = UDim2.new(0, 150, 0, 30)
disLabel.Position = UDim2.new(0, 10, 0, 50)
disLabel.TextColor3 = Color3.new(1,1,1)
disLabel.BackgroundTransparency = 1

local disInput = Instance.new("TextBox", frame)
disInput.Size = UDim2.new(0, 100, 0, 30)
disInput.Position = UDim2.new(0, 160, 0, 50)
disInput.Text = tostring(radius)
disInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
disInput.TextColor3 = Color3.new(1,1,1)

local spdLabel = Instance.new("TextLabel", frame)
spdLabel.Text = "Tốc độ quay:"
spdLabel.Size = UDim2.new(0, 150, 0, 30)
spdLabel.Position = UDim2.new(0, 10, 0, 90)
spdLabel.TextColor3 = Color3.new(1,1,1)
spdLabel.BackgroundTransparency = 1

local spdInput = Instance.new("TextBox", frame)
spdInput.Size = UDim2.new(0, 100, 0, 30)
spdInput.Position = UDim2.new(0, 160, 0, 90)
spdInput.Text = tostring(speed)
spdInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
spdInput.TextColor3 = Color3.new(1,1,1)

local hpLabel = Instance.new("TextLabel", frame)
hpLabel.Size = UDim2.new(1, -20, 0, 30)
hpLabel.Position = UDim2.new(0, 10, 0, 130)
hpLabel.Text = "Máu mục tiêu: ..."
hpLabel.TextColor3 = Color3.new(1, 0, 0)
hpLabel.BackgroundTransparency = 1

local autoBtn = Instance.new("TextButton", frame)
autoBtn.Size = UDim2.new(1, 0, 0, 30)
autoBtn.Position = UDim2.new(0, 0, 0, 170)
autoBtn.Text = "BẬT: Auto Đánh"
autoBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
autoBtn.TextColor3 = Color3.new(1,1,1)

local nameText = Instance.new("TextLabel", frame)
nameText.Size = UDim2.new(1, 0, 0, 30)
nameText.Position = UDim2.new(0, 0, 0, 230)
nameText.Text = "TT:dongphandzs1"
nameText.TextColor3 = Color3.fromRGB(100,255,100)
nameText.BackgroundTransparency = 1
nameText.TextScaled = true

-- Hàm tìm mục tiêu
local function getTarget()
	for _,v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v ~= chr and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
			return v
		end
	end
end

-- Tấn công
local function attack()
	local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
	if tool then pcall(function() tool:Activate() end) end
end

-- Vòng quay quanh mục tiêu
RunService.Heartbeat:Connect(function()
	if running and currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
		if currentTarget.Humanoid.Health <= 0 then
			running = false
			autoAttack = false
			currentTarget = nil
			toggle.Text = "BẬT: Đánh Boss"
			autoBtn.Text = "BẬT: Auto Đánh (Riêng)"
			hpLabel.Text = "Máu mục tiêu: Đã chết"
			return
		end

		local angle = tick() * speed
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local goalPos = currentTarget.HumanoidRootPart.Position + offset
		local tween = TweenService:Create(hrp, TweenInfo.new(0.1), {CFrame = CFrame.new(goalPos, currentTarget.HumanoidRootPart.Position)})
		tween:Play()
		hum.AutoRotate = false
		hrp.CFrame = CFrame.new(hrp.Position, currentTarget.HumanoidRootPart.Position)

		if autoAttack then attack() end
		hpLabel.Text = "Máu mục tiêu: " .. math.floor(currentTarget.Humanoid.Health)
	elseif running then
		running = false
		autoAttack = false
		currentTarget = nil
		toggle.Text = "BẬT: Đánh Boss"
		autoBtn.Text = "BẬT: Auto Đánh (Riêng)"
		hpLabel.Text = "Máu mục tiêu: Không tìm thấy"
	end
end)

-- Bật tắt chạy vòng
toggle.MouseButton1Click:Connect(function()
	running = not running
	if running then
		currentTarget = getTarget()
	end
	toggle.Text = (running and "TẮT" or "BẬT") .. ": Đánh Boss"
end)

disInput.FocusLost:Connect(function()
	radius = tonumber(disInput.Text) or radius
end)

spdInput.FocusLost:Connect(function()
	speed = tonumber(spdInput.Text) or speed
end)

autoBtn.MouseButton1Click:Connect(function()
	autoAttack = not autoAttack
	autoBtn.Text = (autoAttack and "TẮT" or "BẬT") .. ": Auto Đánh (Riêng)"
end)