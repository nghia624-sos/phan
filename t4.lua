--// Menu GUI
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()
local Window = OrionLib:MakeWindow({Name = "TT:dongphandzs1", HidePremium = false, SaveConfig = true, ConfigFolder = "TTdongphandzs1"})

local runService = game:GetService("RunService")
local players = game:GetService("Players")
local lp = players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()

local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

-- Biến cấu hình
local running = false
local radius = 10
local speed = 5
local currentTarget
local blood = "Không có mục tiêu"

-- Tìm mục tiêu gần nhất
function GetNearestTarget()
	local closest, closestDist = nil, math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v ~= char and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
			local dist = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
			if dist < closestDist and v.Humanoid.Health > 0 then
				closest = v
				closestDist = dist
			end
		end
	end
	return closest
end

-- Auto Attack
function AutoAttack(target)
	local tool = lp.Character:FindFirstChildOfClass("Tool")
	if tool and target and target:FindFirstChild("Humanoid") then
		tool:Activate()
	end
end

-- Chạy vòng quanh + đánh
runService.RenderStepped:Connect(function(dt)
	if running then
		currentTarget = GetNearestTarget()
		if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
			-- Cập nhật máu mục tiêu
			local targetHealth = currentTarget:FindFirstChild("Humanoid").Health
			local targetMaxHealth = currentTarget:FindFirstChild("Humanoid").MaxHealth
			blood = math.floor(targetHealth) .. " / " .. math.floor(targetMaxHealth)

			-- Tính vị trí chạy vòng
			local tickTime = tick() * speed
			local angle = tickTime % (2 * math.pi)
			local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
			local targetPos = currentTarget.HumanoidRootPart.Position + offset

			-- Di chuyển nhân vật
			hum:MoveTo(targetPos)

			-- Quay mặt về phía mục tiêu
			local lookVector = (currentTarget.HumanoidRootPart.Position - hrp.Position).Unit
			hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + lookVector)

			-- Đánh
			AutoAttack(currentTarget)
		else
			blood = "Không có mục tiêu"
		end
	end
end)

-- Tab: Đánh BOSS
local tab = Window:MakeTab({Name = "Đánh BOSS", Icon = "rbxassetid://4483345998", PremiumOnly = false})

tab:AddToggle({
	Name = "Bật Fram vòng quanh mục tiêu",
	Default = false,
	Callback = function(v)
		running = v
	end
})

tab:AddSlider({
	Name = "Bán kính vòng quanh",
	Min = 5,
	Max = 50,
	Default = 10,
	Increment = 1,
	ValueName = "studs",
	Callback = function(val)
		radius = val
	end
})

tab:AddSlider({
	Name = "Tốc độ vòng quanh",
	Min = 1,
	Max = 20,
	Default = 5,
	Increment = 1,
	ValueName = "speed",
	Callback = function(val)
		speed = val
	end
})

tab:AddLabel("Máu mục tiêu:")
tab:AddParagraph("Cập nhật máu mục tiêu", function()
	return blood
end)

OrionLib:Init()