--// SERVICES
local Players = game:GetService("Players")
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

--// UI LIBRARY
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = library.CreateLib("TT:dongphandzs1", "Ocean")

local tab = Window:NewTab("Fram")
local section = tab:NewSection("Điều khiển")

--// MÁU MỤC TIÊU (TextLabel động)
local targetHealthLabel = nil

--// GIAO DIỆN
section:NewToggle("Bật Fram", "Tìm mục tiêu gần nhất và chạy vòng", function(state)
	running = state
end)

section:NewTextBox("Bán kính vòng (radius)", "Nhập bán kính quay", function(txt)
	local r = tonumber(txt)
	if r then radius = r end
end)

section:NewTextBox("Tốc độ quay (speed)", "Nhập tốc độ vòng", function(txt)
	local s = tonumber(txt)
	if s then speed = s end
end)

section:NewLabel("Máu mục tiêu: 0/0")
targetHealthLabel = section:NewLabel("")

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

--// VÒNG LẶP CHÍNH
RunService.Heartbeat:Connect(function()
	if not running then return end

	-- Cập nhật mục tiêu nếu cần
	if not currentTarget or not currentTarget:FindFirstChild("HumanoidRootPart") or currentTarget.Humanoid.Health <= 0 then
		currentTarget = getNearestTarget()
	end

	if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
		-- Di chuyển vòng quanh mục tiêu
		local angle = tick() * speed
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local targetPos = currentTarget.HumanoidRootPart.Position + offset

		local direction = (targetPos - hrp.Position)
		local moveStep = direction.Unit * math.min(direction.Magnitude, 0.4)

		-- Cập nhật vị trí + quay mặt
		hrp.CFrame = CFrame.new(hrp.Position + moveStep, currentTarget.HumanoidRootPart.Position)

		-- Auto đánh (nếu có công cụ)
		local tool = lp.Character:FindFirstChildOfClass("Tool")
		if tool and tool:FindFirstChild("Handle") then
			pcall(function()
				tool:Activate()
			end)
		end

		-- Cập nhật máu mục tiêu
		local hp = math.floor(currentTarget.Humanoid.Health)
		local maxHp = math.floor(currentTarget.Humanoid.MaxHealth)
		targetHealthLabel:UpdateLabel("Máu mục tiêu: " .. hp .. "/" .. maxHp)
	else
		-- Reset nếu không có mục tiêu
		targetHealthLabel:UpdateLabel("Máu mục tiêu: 0/0")
	end
end)