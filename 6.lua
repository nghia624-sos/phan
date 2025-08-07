local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- Flags
local autoFram = false
local autoSpin = false

-- Config
local framRadius = 10
local framSpeed = 3
local spinSpeed = 2

-- UI Library (Bạn cần có sẵn W-UI hoặc UI Library tương thích)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dongphandzs1/ui/main/WOKINUI.lua"))()
local Window = Library:Window("WOKINCLOG 🍑 Fram Boss Tool")
local FramTab = Window:Tab("Fram NPC")
local SpinTab = Window:Tab("Spin")

-- === FUNCTION === --

function getTarget()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
			local name = string.lower(v.Name)
			if string.find(name, "citynpc") or string.find(name, "npcity") then
				if v.Humanoid.Health > 0 then
					return v
				end
			end
		end
	end
	return nil
end

function moveToTarget(target)
	if not target or not target:FindFirstChild("HumanoidRootPart") then return end
	local path = (target.HumanoidRootPart.Position - hrp.Position).Magnitude
	if path > framRadius + 2 then
		char:WaitForChild("Humanoid"):MoveTo(target.HumanoidRootPart.Position)
	end
end

function circleTarget(target)
	while autoFram and target and target:FindFirstChild("HumanoidRootPart") and target.Humanoid.Health > 0 do
		local theta = tick() * framSpeed
		local offset = Vector3.new(math.cos(theta), 0, math.sin(theta)) * framRadius
		local newPos = target.HumanoidRootPart.Position + offset
		local tween = TweenService:Create(hrp, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {CFrame = CFrame.new(newPos, target.HumanoidRootPart.Position)})
		tween:Play()
		tween.Completed:Wait()
	end
end

function autoAttack()
	spawn(function()
		while autoFram and task.wait(0.2) do
			local tool = char:FindFirstChildOfClass("Tool")
			if tool and tool:FindFirstChild("Handle") then
				for _, v in pairs(tool:GetDescendants()) do
					if v:IsA("RemoteEvent") then
						v:FireServer()
					end
				end
			end
		end
	end)
end

-- === MAIN LOOP FRAM NPC === --

spawn(function()
	while true do wait(0.5)
		if autoFram then
			local target = getTarget()
			if target then
				moveToTarget(target)
				repeat wait() until (hrp.Position - target.HumanoidRootPart.Position).Magnitude <= framRadius + 2 or not autoFram
				circleTarget(target)
				autoAttack()

				while autoFram and target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 do
					wait()
				end
			else
				wait(1)
			end
		end
	end
end)

-- === SPIN LOOP === --

RunService.RenderStepped:Connect(function()
	if autoSpin then
		local angle = tick() * spinSpeed
		local cam = workspace.CurrentCamera
		hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, angle, 0)
	end
end)

-- === UI === --

FramTab:Slider("Tốc độ chạy quanh (rad/s)", 1, 15, framSpeed, function(val)
	framSpeed = val
end)

FramTab:Slider("Bán kính đánh", 5, 20, framRadius, function(val)
	framRadius = val
end)

FramTab:Toggle("Bật Fram NPC 💥", false, function(t)
	autoFram = t
end)

SpinTab:Slider("Tốc độ quay spin", 1, 10, spinSpeed, function(val)
	spinSpeed = val
end)

SpinTab:Toggle("Bật chế độ quay người", false, function(t)
	autoSpin = t
end)