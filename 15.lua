local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

local gui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
local frame = Instance.new("Frame", gui)
frame.Position = UDim2.new(0.1, 0, 0.2, 0)
frame.Size = UDim2.new(0, 200, 0, 250)
frame.BackgroundTransparency = 0.3
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.Draggable = true

local radiusBox = Instance.new("TextBox", frame)
radiusBox.Size = UDim2.new(1, 0, 0, 30)
radiusBox.Text = "10"
radiusBox.PlaceholderText = "Bán kính"

local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(1, 0, 0, 30)
speedBox.Position = UDim2.new(0, 0, 0, 35)
speedBox.Text = "5"
speedBox.PlaceholderText = "Tốc độ"

local flyHeightBox = Instance.new("TextBox", frame)
flyHeightBox.Size = UDim2.new(1, 0, 0, 30)
flyHeightBox.Position = UDim2.new(0, 0, 0, 70)
flyHeightBox.Text = "1"
flyHeightBox.PlaceholderText = "Cách mặt đất (cm)"

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1, 0, 0, 40)
toggle.Position = UDim2.new(0, 0, 0, 110)
toggle.Text = "BẬT Fram"
toggle.BackgroundColor3 = Color3.fromRGB(0,255,0)

local noclipBtn = Instance.new("TextButton", frame)
noclipBtn.Size = UDim2.new(1, 0, 0, 40)
noclipBtn.Position = UDim2.new(0, 0, 0, 155)
noclipBtn.Text = "Noclip: OFF"
noclipBtn.BackgroundColor3 = Color3.fromRGB(0,0,255)

local running = false
local noclip = false
local currentTarget = nil

local function getTarget()
	local closest, dist = nil, math.huge
	for _,v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
			local name = v.Name:lower()
			if name:find("citynpc") or name:find("npcity") then
				local d = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
				if d < dist then
					dist = d
					closest = v
				end
			end
		end
	end
	return closest
end

local function moveToTarget(target)
	local path = game:GetService("PathfindingService"):CreatePath()
	path:ComputeAsync(hrp.Position, target.HumanoidRootPart.Position)
	if path.Status == Enum.PathStatus.Complete then
		for _,waypoint in pairs(path:GetWaypoints()) do
			hum:MoveTo(waypoint.Position + Vector3.new(0, tonumber(flyHeightBox.Text)/100, 0))
			hum.MoveToFinished:Wait()
		end
	end
end

local function circleTarget(target)
	local r = tonumber(radiusBox.Text)
	local s = tonumber(speedBox.Text)
	spawn(function()
		while running and target and target:FindFirstChild("HumanoidRootPart") and target.Humanoid.Health > 0 do
			local angle = tick() * s
			local offset = Vector3.new(math.cos(angle)*r, 0, math.sin(angle)*r)
			local targetPos = target.HumanoidRootPart.Position + offset + Vector3.new(0, tonumber(flyHeightBox.Text)/100, 0)
			hum:MoveTo(targetPos)
			RunService.RenderStepped:Wait()
		end
	end)
end

toggle.MouseButton1Click:Connect(function()
	running = not running
	toggle.Text = running and "TẮT Fram" or "BẬT Fram"
	toggle.BackgroundColor3 = running and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0)
	if running then
		spawn(function()
			while running do
				if not currentTarget or currentTarget.Humanoid.Health <= 0 then
					currentTarget = getTarget()
				end
				if currentTarget then
					moveToTarget(currentTarget)
					if (hrp.Position - currentTarget.HumanoidRootPart.Position).Magnitude <= tonumber(radiusBox.Text) + 2 then
						circleTarget(currentTarget)
					end
				end
				wait(1)
			end
		end)
	end
end)

noclipBtn.MouseButton1Click:Connect(function()
	noclip = not noclip
	noclipBtn.Text = "Noclip: "..(noclip and "ON" or "OFF")
	for _,v in pairs(chr:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = not noclip
		end
	end
end)

-- Kết thúc script menu TT:dongphandzs1
