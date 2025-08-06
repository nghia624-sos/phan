-- MENU TT:dongphandzs1 - BẢN FIX 100% HIỆN MENU CHO ĐIỆN THOẠI

repeat wait() until game:IsLoaded()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

-- Biến chính
local framEnabled = false
local target = nil
local radius = 10
local speed = 2

-- Tìm NPC tên chứa "CityNPC" (không phân biệt hoa thường)
local function findTarget()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
			if v.Name:lower():find("citynpc") then
				return v
			end
		end
	end
	return nil
end

-- MoveTo tự nhiên
local function moveToTarget(pos)
	hum:MoveTo(pos)
end

-- Auto aim và đánh
local function autoAimAndAttack()
	if target and target:FindFirstChild("HumanoidRootPart") then
		local dir = (target.HumanoidRootPart.Position - hrp.Position).Unit
		hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + dir)
		mouse1click()
	end
end

-- Chạy vòng quanh mục tiêu
local function runAround()
	local angle = 0
	RunService:UnbindFromRenderStep("RunAround")
	RunService:BindToRenderStep("RunAround", Enum.RenderPriority.Character.Value + 1, function(dt)
		if not framEnabled or not target or not target:FindFirstChild("HumanoidRootPart") then
			RunService:UnbindFromRenderStep("RunAround")
			return
		end
		autoAimAndAttack()
		angle += dt * speed
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local goalPos = target.HumanoidRootPart.Position + offset
		moveToTarget(goalPos)
	end)
end

-- Luôn theo dõi mục tiêu
task.spawn(function()
	while true do
		task.wait(0.5)
		if framEnabled then
			if not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 then
				target = findTarget()
				if target then
					moveToTarget(target.HumanoidRootPart.Position)
					wait(1)
					runAround()
				end
			end
		end
	end
end)

-- Tải GUI
local success, OrionLib = pcall(function()
	return loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
end)

if not success then
	warn("Không thể tải OrionLib")
	return
end

local Window = OrionLib:MakeWindow({
	Name = "TT:dongphandzs1",
	HidePremium = false,
	SaveConfig = false,
	ConfigFolder = "FramMenuConfig",
	IntroEnabled = false
})

local Tab = Window:MakeTab({
	Name = "Fram",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

Tab:AddToggle({
	Name = "Bật Fram CityNPC",
	Default = false,
	Callback = function(state)
		framEnabled = state
		if not state then
			RunService:UnbindFromRenderStep("RunAround")
			target = nil
		end
	end
})

Tab:AddSlider({
	Name = "Bán kính chạy vòng",
	Min = 5,
	Max = 30,
	Default = 10,
	Increment = 1,
	ValueName = "Studs",
	Callback = function(val)
		radius = val
	end
})

Tab:AddSlider({
	Name = "Tốc độ quay vòng",
	Min = 1,
	Max = 10,
	Default = 2,
	Increment = 0.1,
	ValueName = "Speed",
	Callback = function(val)
		speed = val
	end
})

-- Hiển thị máu mục tiêu
Tab:AddLabel("Máu mục tiêu:")
local hpLabel = Tab:AddLabel("Chưa có mục tiêu")

task.spawn(function()
	while true do
		task.wait(0.3)
		if target and target:FindFirstChild("Humanoid") then
			hpLabel:Set("Máu: " .. math.floor(target.Humanoid.Health))
		else
			hpLabel:Set("Chưa có mục tiêu")
		end
	end
end)

-- Nút tắt script
Tab:AddButton({
	Name = "Tắt Script",
	Callback = function()
		framEnabled = false
		RunService:UnbindFromRenderStep("RunAround")
		OrionLib:Destroy()
	end
})

-- KHỞI TẠO GIAO DIỆN
OrionLib:Init()
OrionLib:MakeNotification({
	Name = "TT:dongphandzs1",
	Content = "Menu đã hiện! Vào tab Fram để bật!",
	Time = 5
})