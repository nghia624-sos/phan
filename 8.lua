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

PvPTab:CreateToggle({
	Name = "🎯 Silent Aim (Tự đánh mục tiêu gần)",
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
						HRP.CFrame = CFrame.new(HRP.Position, nearest.HumanoidRootPart.Position)
						mouse1click()
					end
					wait(0.25)
				end
			end)
		end
	end,
})

PvPTab:CreateToggle({
	Name = "📏 Hitbox + Line đến người chơi",
	Default = false,
	Callback = function(Value)
		hitboxEnabled = Value
		if Value then
			for _, player in pairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
					local part = player.Character.HumanoidRootPart
					
					local adorn = Instance.new("BoxHandleAdornment", part)
					adorn.Size = part.Size + Vector3.new(2,2,2)
					adorn.Color3 = Color3.new(1,0,0)
					adorn.Adornee = part
					adorn.AlwaysOnTop = true
					adorn.ZIndex = 10
					adorn.Name = "Hitbox"

					local beam = Instance.new("Beam", part)
					local a0 = Instance.new("Attachment", HRP)
					local a1 = Instance.new("Attachment", part)
					beam.Attachment0 = a0
					beam.Attachment1 = a1
					beam.Width0 = 0.1
					beam.Width1 = 0.1
					beam.Color = ColorSequence.new(Color3.new(1,0,0))
					beam.FaceCamera = true
					beam.Name = "TargetLine"
				end
			end
		else
			for _, p in pairs(Players:GetPlayers()) do
				if p ~= LocalPlayer and p.Character then
					for _, v in pairs(p.Character:GetDescendants()) do
						if v:IsA("BoxHandleAdornment") and v.Name == "Hitbox" then v:Destroy() end
						if v:IsA("Beam") and v.Name == "TargetLine" then v:Destroy() end
					end
				end
			end
		end
	end,
})