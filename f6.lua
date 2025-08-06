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
local auto = false
local target = nil

-- Tìm mục tiêu có chứa từ "boss"
local function getNearestBoss()
	local closest, dist = nil, math.huge
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v.Name:lower():find("boss") then
			local d = (hrp.Position - v.HumanoidRootPart.Position).Magnitude
			if d < dist then
				dist = d
				closest = v
			end
		end
	end
	return closest
end

-- Quay mặt về mục tiêu
local function lookAtTarget()
	if target and target:FindFirstChild("HumanoidRootPart") then
		local direction = (target.HumanoidRootPart.Position - hrp.Position).Unit
		hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(direction.X, 0, direction.Z))
	end
end

-- Di chuyển tới mục tiêu mượt bằng MoveTo
local function moveToTarget(targetPos)
	local done = false
	hum:MoveTo(targetPos)
	hum.MoveToFinished:Connect(function(reached)
		done = true
	end)
	repeat
		wait()
	until done or not running or not auto
end

-- Chạy vòng quanh mục tiêu
local function circleTarget()
	local angle = 0
	RunService:UnbindFromRenderStep("CircleRun")
	RunService:BindToRenderStep("CircleRun", Enum.RenderPriority.Character.Value, function()
		if running and target and target:FindFirstChild("HumanoidRootPart") then
			angle += speed * RunService.RenderStepped:Wait()
			local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
			local desiredPos = target.HumanoidRootPart.Position + offset
			hum:MoveTo(desiredPos)
			lookAtTarget()
		end
	end)
end

-- Tạo menu GUI
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Belkworks/UI-Libraries/main/Nanoblox/Library.lua"))()
local wnd = library:CreateWindow({
	Name = "TT:dongphandzs1",
	Theme = "Dark",
	Size = UDim2.fromOffset(380, 300),
	ToggleKey = Enum.KeyCode.RightControl
})

local tab = wnd:AddTab("Đánh BOSS")
tab:AddSlider("Bán kính chạy vòng", 5, 50, radius, function(val)
	radius = val
end)
tab:AddSlider("Tốc độ xoay", 0.1, 5, speed, function(val)
	speed = val
end)

tab:AddSwitch("Bật Fram", function(state)
	auto = state
	if auto then
		target = getNearestBoss()
		if target and target:FindFirstChild("HumanoidRootPart") then
			local pos = target.HumanoidRootPart.Position + Vector3.new(0, 0, radius)
			moveToTarget(pos)
			wait(0.5)
			running = true
			circleTarget()
		end
	else
		running = false
		RunService:UnbindFromRenderStep("CircleRun")
	end
end)

-- Hiển thị máu mục tiêu
local hpLabel = tab:AddLabel("HP: Không có")
RunService.RenderStepped:Connect(function()
	if target and target:FindFirstChild("Humanoid") then
		local hp = math.floor(target.Humanoid.Health)
		local max = math.floor(target.Humanoid.MaxHealth)
		hpLabel:SetText("HP: " .. hp .. "/" .. max)
	else
		hpLabel:SetText("HP: Không có")
	end
end)