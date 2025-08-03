local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hrp = chr:WaitForChild("HumanoidRootPart")
local hum = chr:WaitForChild("Humanoid")

-- Cài đặt
local radius = 10 -- bán kính chạy vòng
local speed = 3 -- tốc độ quay vòng
local moveSpeed = 50 -- tốc độ lướt tới mục tiêu
local target

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "NghiaMinh"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 240, 0, 160)
frame.Position = UDim2.new(0.5, -120, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1, -20, 0, 30)
toggle.Position = UDim2.new(0, 10, 0, 10)
toggle.Text = "BẬT: Chạy vòng + Auto đánh"
toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggle.TextColor3 = Color3.new(1, 1, 1)

local status = false
toggle.MouseButton1Click:Connect(function()
	status = not status
	toggle.Text = status and "TẮT: Chạy vòng + Auto đánh" or "BẬT: Chạy vòng + Auto đánh"
	if not status then
		RunService:UnbindFromRenderStep("AutoFarm")
	end
end)

-- Hàm tìm mục tiêu gần nhất
function getTarget()
	local nearest, minDist = nil, math.huge
	for _, npc in ipairs(workspace:GetDescendants()) do
		if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Humanoid") then
			local dist = (hrp.Position - npc.HumanoidRootPart.Position).Magnitude
			if dist < minDist then
				minDist = dist
				nearest = npc
			end
		end
	end
	return nearest
end

-- Lướt tự nhiên đến vị trí
function smoothMoveTo(position)
	local distance = (hrp.Position - position).Magnitude
	local travelTime = distance / moveSpeed
	local tween = TweenService:Create(hrp, TweenInfo.new(travelTime, Enum.EasingStyle.Linear), {CFrame = CFrame.new(position)})
	tween:Play()
	tween.Completed:Wait()
end

-- Bắt đầu chạy vòng quanh mục tiêu + auto đánh + aim
function startOrbit(target)
	local angle = 0
	RunService:UnbindFromRenderStep("AutoFarm")
	RunService:BindToRenderStep("AutoFarm", Enum.RenderPriority.Character.Value, function(dt)
		if not target or not target:FindFirstChild("HumanoidRootPart") then return end
		angle += speed * dt
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local orbitPos = target.HumanoidRootPart.Position + offset
		hrp.CFrame = CFrame.new(orbitPos, target.HumanoidRootPart.Position)

		-- auto đánh
		local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
		if tool and tool:FindFirstChild("Handle") then
			pcall(function()
				tool:Activate()
			end)
		end
	end)
end

-- Vòng lặp chính
task.spawn(function()
	while true do
		wait(0.5)
		if status then
			target = getTarget()
			if target and target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("Humanoid") then
				local distance = (hrp.Position - target.HumanoidRootPart.Position).Magnitude
				if distance > radius + 5 then
					-- Lướt đến gần mục tiêu
					local destination = target.HumanoidRootPart.Position + Vector3.new(0, 0, 0)
					smoothMoveTo(destination)
				end
				if target.Humanoid.Health > 0 then
					startOrbit(target)
				end
			end
		end
	end
end)