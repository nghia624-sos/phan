local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local runService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- GUI
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "TTdongphandzs1"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 200, 0, 160)
frame.Position = UDim2.new(0, 50, 0.5, -80)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

local radiusBox = Instance.new("TextBox", frame)
radiusBox.Size = UDim2.new(1, -10, 0, 40)
radiusBox.Position = UDim2.new(0, 5, 0, 5)
radiusBox.PlaceholderText = "Bán kính (vd: 20)"
radiusBox.Text = "20"
radiusBox.TextScaled = true

local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(1, -10, 0, 40)
speedBox.Position = UDim2.new(0, 5, 0, 50)
speedBox.PlaceholderText = "Tốc độ (vd: 5)"
speedBox.Text = "5"
speedBox.TextScaled = true

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(1, -10, 0, 40)
toggleBtn.Position = UDim2.new(0, 5, 0, 95)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.Text = "BẬT Fram"
toggleBtn.TextScaled = true

-- Logic
local running = false
local currentTarget = nil

function findTarget()
	for _, npc in pairs(workspace:GetDescendants()) do
		if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") then
			local name = string.lower(npc.Name)
			if name:find("citynpc") then
				return npc
			end
		end
	end
	return nil
end

function autoMoveToTarget(target)
	if not target or not target:FindFirstChild("HumanoidRootPart") then return end

	humanoid:MoveTo(target.HumanoidRootPart.Position)

	-- chờ đến khi đến gần (dưới 6 studs)
	local reached = false
	humanoid.MoveToFinished:Wait()
	if (hrp.Position - target.HumanoidRootPart.Position).Magnitude < 6 then
		reached = true
	end
	return reached
end

function runAroundTarget(target, radius, speed)
	local angle = 0
	local conn
	conn = runService.Heartbeat:Connect(function(dt)
		if not running or not target or not target:FindFirstChild("HumanoidRootPart") then
			conn:Disconnect()
			return
		end

		angle += dt * speed
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local newPos = target.HumanoidRootPart.Position + offset
		humanoid:MoveTo(newPos)

		-- Xoay mặt về mục tiêu
		hrp.CFrame = CFrame.new(hrp.Position, target.HumanoidRootPart.Position)

		-- Auto attack (nếu có công cụ cận chiến)
		local tool = player.Character:FindFirstChildOfClass("Tool")
		if tool and tool:FindFirstChild("Activate") then
			pcall(function() tool:Activate() end)
		end
	end)
end

toggleBtn.MouseButton1Click:Connect(function()
	running = not running
	toggleBtn.Text = running and "TẮT Fram" or "BẬT Fram"
	if running then
		spawn(function()
			while running do
				currentTarget = findTarget()
				if currentTarget then
					local reached = autoMoveToTarget(currentTarget)
					if reached then
						local radius = tonumber(radiusBox.Text) or 20
						local speed = tonumber(speedBox.Text) or 5
						runAroundTarget(currentTarget, radius, speed)
						repeat task.wait(1) until not currentTarget or not running
					end
				end
				wait(0.5)
			end
		end)
	end
end)