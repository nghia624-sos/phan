-- Fram CityNPC - TT:dongphandzs1 (Menu đơn giản không dùng OrionLib)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local mouse = lp:GetMouse()
local gui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
gui.Name = "FramCityNPC_GUI"

-- Variables
local radius = 10
local speed = 2
local enabled = false
local target = nil

-- Create simple menu
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 200)
frame.Position = UDim2.new(0, 10, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "TT:dongphandzs1"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

-- Enable toggle
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1, -10, 0, 30)
toggle.Position = UDim2.new(0, 5, 0, 35)
toggle.Text = "Bật Fram"
toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Font = Enum.Font.SourceSans
toggle.TextSize = 16

-- Health display
local hpLabel = Instance.new("TextLabel", frame)
hpLabel.Size = UDim2.new(1, -10, 0, 25)
hpLabel.Position = UDim2.new(0, 5, 0, 70)
hpLabel.Text = "Máu mục tiêu: N/A"
hpLabel.TextColor3 = Color3.new(1, 1, 1)
hpLabel.Font = Enum.Font.SourceSans
hpLabel.BackgroundTransparency = 1
hpLabel.TextSize = 14

-- Close button
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(1, -10, 0, 25)
closeBtn.Position = UDim2.new(0, 5, 1, -30)
closeBtn.Text = "Tắt Script"
closeBtn.BackgroundColor3 = Color3.fromRGB(70, 0, 0)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.SourceSans
closeBtn.TextSize = 14

-- Find target function
local function findTarget()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
			if v.Name:lower():find("citynpc") and v.Humanoid.Health > 0 then
				return v
			end
		end
	end
end

-- Main logic
local function startFram()
	local chr = lp.Character or lp.CharacterAdded:Wait()
	local hum = chr:WaitForChild("Humanoid")
	local hrp = chr:WaitForChild("HumanoidRootPart")

	RunService:UnbindFromRenderStep("FramLoop")
	RunService:BindToRenderStep("FramLoop", Enum.RenderPriority.Character.Value + 1, function(dt)
		if not enabled then
			RunService:UnbindFromRenderStep("FramLoop")
			return
		end

		if not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 then
			target = findTarget()
		end

		if target then
			hpLabel.Text = "Máu: " .. math.floor(target.Humanoid.Health)
			local pos = target.HumanoidRootPart.Position
			local angle = tick() * speed
			local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
			local goal = pos + offset

			hum:MoveTo(goal)

			-- Auto aim
			local dir = (pos - hrp.Position).Unit
			hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + dir)

			-- Auto click
			mouse1click()
		else
			hpLabel.Text = "Không tìm thấy mục tiêu"
		end
	end)
end

-- Toggle button callback
toggle.MouseButton1Click:Connect(function()
	enabled = not enabled
	toggle.Text = enabled and "Tắt Fram" or "Bật Fram"
	if enabled then
		startFram()
	end
end)

-- Close button callback
closeBtn.MouseButton1Click:Connect(function()
	enabled = false
	RunService:UnbindFromRenderStep("FramLoop")
	gui:Destroy()
end)