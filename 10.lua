--// SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

--// BIẾN
local radius = 15
local speed = 2
local running = false
local currentTarget = nil
local autoAttack = false

--// UI
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = library.CreateLib("TT:dongphandzs1", "Ocean") -- Tên GUI

local tab = Window:NewTab("Fram")
local section = tab:NewSection("Điều khiển")

section:NewToggle("Bật Fram", "Tìm mục tiêu gần nhất và chạy vòng", function(state)
	running = state
end)

section:NewToggle("Auto Đánh", "Tự động đánh mục tiêu", function(state)
	autoAttack = state
end)

section:NewTextBox("Bán kính vòng (radius)", "Nhập bán kính quay", function(txt)
	local r = tonumber(txt)
	if r then radius = r end
end)

section:NewTextBox("Tốc độ quay (speed)", "Nhập tốc độ vòng", function(txt)
	local s = tonumber(txt)
	if s then speed = s end
end)

-- Thêm phần hiển thị máu mục tiêu
local targetHealthLabel = section:NewLabel("Máu mục tiêu: Không có")

--// HÀM TÌM MỤC TIÊU GẦN NHẤT
function getNearestTarget()
	local nearest, shortest = nil, math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v ~= chr then
			local mag = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
			if mag < shortest then
				shortest = mag
				nearest = v
			end
		end
	end
	return nearest
end

--// AUTO ĐÁNH
function attackTarget()
	if currentTarget and currentTarget:FindFirstChild("Humanoid") then
		local tool = lp.Character:FindFirstChildOfClass("Tool")
		if tool and tool:FindFirstChild("Handle") then
			tool:Activate()
		end
	end
end

--// VÒNG LẶP CHÍNH
RunService.Heartbeat:Connect(function()
	if not running then
		targetHealthLabel:UpdateLabel("Máu mục tiêu: Không có")
		return
	end

	if not currentTarget or not currentTarget:FindFirstChild("HumanoidRootPart") then
		currentTarget = getNearestTarget()
	end

	if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
		-- Cập nhật máu mục tiêu
		local hp = math.floor(currentTarget.Humanoid.Health)
		local max = math.floor(currentTarget.Humanoid.MaxHealth)
		targetHealthLabel:UpdateLabel("Máu mục tiêu: " .. hp .. "/" .. max)

		-- Di chuyển vòng tròn
		local angle = tick() * speed
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local targetPos = currentTarget.HumanoidRootPart.Position + offset

		local direction = (targetPos - hrp.Position)
		local moveStep = direction.Unit * math.min(direction.Magnitude, 0.4)
		hrp.CFrame = CFrame.new(hrp.Position + moveStep, currentTarget.HumanoidRootPart.Position)

		-- Auto đánh
		if autoAttack then
			attackTarget()
		end
	end
end)