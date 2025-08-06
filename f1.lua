-- TT:dongphandzs1 - Fram CityNPC
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

-- Biến điều khiển
local running = false
local target = nil
local radius = 10
local speed = 2
local framEnabled = false

-- Tìm NPC chứa "CityNPC"
local function findTarget()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
			local name = v.Name:lower()
			if name:find("citynpc") then
				return v
			end
		end
	end
	return nil
end

-- Di chuyển tự nhiên đến mục tiêu
local function moveToTarget(pos)
	hum:MoveTo(pos)
end

-- Tự động aim + đánh
local function autoAimAndAttack()
	if target and target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("Humanoid") then
		local tPos = target.HumanoidRootPart.Position
		local dir = (tPos - hrp.Position).Unit
		hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + dir)
		mouse1click()
	end
end

-- Di chuyển vòng quanh
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

-- Theo dõi mục tiêu và đổi mục tiêu khi chết
task.spawn(function()
	while true do
		task.wait(0.5)
		if framEnabled then
			if not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 then
				target = findTarget()
				if target then
					moveToTarget(target.HumanoidRootPart.Position)
					task.wait(1)
					runAround()
				end
			end
		end
	end
end)

-- UI
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
local Window = OrionLib:MakeWindow({
	Name = "TT:dongphandzs1",
	HidePremium = false,
	SaveConfig = true,
	ConfigFolder = "dongphandzs1Config",
	IntroText = "TT:dongphandzs1",
	IntroEnabled = false,
	CloseCallback = function()
		print("Menu closed")
	end
})

local MainTab = Window:MakeTab({
	Name = "Fram",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

MainTab:AddToggle({
	Name = "Bật Fram CityNPC",
	Default = false,
	Callback = function(Value)
		framEnabled = Value
		if not Value then
			RunService:UnbindFromRenderStep("RunAround")
			target = nil
		end
	end
})

MainTab:AddSlider({
	Name = "Bán kính chạy vòng quanh",
	Min = 5,
	Max = 30,
	Default = 10,
	Increment = 1,
	ValueName = "Studs",
	Callback = function(val)
		radius = val
	end
})

MainTab:AddSlider({
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

-- Hiển thị máu
MainTab:AddLabel("Máu mục tiêu:")
local hpLabel = MainTab:AddLabel("Chưa có mục tiêu")

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
MainTab:AddButton({
	Name = "Tắt Script",
	Callback = function()
		framEnabled = false
		RunService:UnbindFromRenderStep("RunAround")
		OrionLib:Destroy()
	end
})

-- Mở GUI
OrionLib:Init()