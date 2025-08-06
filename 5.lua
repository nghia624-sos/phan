--// Dịch vụ
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

--// Biến
local fram = false
local autoHit = false
local runCircle = false
local radius = 10
local speed = 2

--// Tìm NPC gần nhất
function getNearestNPC()
	local nearest, dist = nil, math.huge
	for _, npc in pairs(workspace:GetDescendants()) do
		if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") then
			local name = npc.Name:lower()
			if name:find("citynpc") or name:find("npcity") then
				local d = (npc.HumanoidRootPart.Position - hrp.Position).Magnitude
				if d < dist then
					dist = d
					nearest = npc
				end
			end
		end
	end
	return nearest
end

--// Di chuyển bằng Pathfinding (né vật thể)
function moveToTarget(targetPos)
	local path = PathfindingService:CreatePath()
	path:ComputeAsync(hrp.Position, targetPos)
	if path.Status == Enum.PathStatus.Complete then
		for _, waypoint in pairs(path:GetWaypoints()) do
			hum:MoveTo(waypoint.Position)
			hum.MoveToFinished:Wait()
		end
	else
		hum:MoveTo(targetPos) -- fallback nếu path lỗi
	end
end

--// Chạy vòng quanh
function runAround(target)
	local angle = 0
	RunService:UnbindFromRenderStep("RunAround")
	RunService:BindToRenderStep("RunAround", Enum.RenderPriority.Character.Value, function()
		if not runCircle or not target or not target:FindFirstChild("HumanoidRootPart") then
			RunService:UnbindFromRenderStep("RunAround")
			return
		end
		angle += speed / 100
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local destination = target.HumanoidRootPart.Position + offset
		hum:MoveTo(destination)
		hrp.CFrame = CFrame.new(hrp.Position, target.HumanoidRootPart.Position)
	end)
end

--// Tự đánh
function autoAttack(target)
	while autoHit and target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 do
		local tool = lp.Character:FindFirstChildOfClass("Tool")
		if tool then
			tool:Activate()
		end
		task.wait(0.3)
	end
end

--// Fram chính
task.spawn(function()
	while true do
		task.wait(0.2)
		if fram then
			local npc = getNearestNPC()
			if npc and npc:FindFirstChild("HumanoidRootPart") then
				local dist = (hrp.Position - npc.HumanoidRootPart.Position).Magnitude
				if dist > radius + 2 then
					moveToTarget(npc.HumanoidRootPart.Position)
				end
				if (hrp.Position - npc.HumanoidRootPart.Position).Magnitude <= radius + 2 then
					if runCircle then runAround(npc) end
					if autoHit then autoAttack(npc) end
				end
			end
		end
	end
end)

--// GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FramGui"
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 230)
frame.Position = UDim2.new(0.5, -125, 0.5, -115)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

local uilist = Instance.new("UIListLayout", frame)
uilist.Padding = UDim.new(0, 5)
uilist.SortOrder = Enum.SortOrder.LayoutOrder

function newToggle(name, callback)
	local button = Instance.new("TextButton", frame)
	button.Size = UDim2.new(1, -10, 0, 30)
	button.Text = name .. ": OFF"
	button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	button.TextColor3 = Color3.new(1, 1, 1)
	local state = false
	button.MouseButton1Click:Connect(function()
		state = not state
		button.Text = name .. ": " .. (state and "ON" or "OFF")
		callback(state)
	end)
end

function newSlider(name, min, max, default, callback)
	local text = Instance.new("TextLabel", frame)
	text.Size = UDim2.new(1, -10, 0, 20)
	text.Text = name .. ": " .. default
	text.TextColor3 = Color3.new(1, 1, 1)
	text.BackgroundTransparency = 1

	local slider = Instance.new("TextBox", frame)
	slider.Size = UDim2.new(1, -10, 0, 30)
	slider.Text = tostring(default)
	slider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	slider.TextColor3 = Color3.new(1, 1, 1)
	slider.ClearTextOnFocus = false

	slider.FocusLost:Connect(function()
		local value = tonumber(slider.Text)
		if value then
			value = math.clamp(value, min, max)
			callback(value)
			text.Text = name .. ": " .. value
		end
	end)
end

--// GUI Các nút
newToggle("Fram", function(v) fram = v end)
newToggle("Tự Đánh", function(v) autoHit = v end)
newToggle("Chạy Vòng", function(v) runCircle = v end)
newSlider("Bán Kính", 5, 50, radius, function(v) radius = v end)
newSlider("Tốc Độ", 1, 10, speed, function(v) speed = v end)