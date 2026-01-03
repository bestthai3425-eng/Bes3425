-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer

-- States
local LightOn = false
local ESPOn = false
local Open = true
local ESPTags = {}

-- GUI
local Gui = Instance.new("ScreenGui")
Gui.Name = "MiniHub"
Gui.ResetOnSpawn = false
Gui.Parent = game:GetService("CoreGui")

-- ===== Create Button =====
local function createButton(txt, w)
	local b = Instance.new("TextButton", Gui)
	b.Size = UDim2.new(0, w or 90, 0, 28)
	b.Text = txt
	b.BackgroundColor3 = Color3.fromRGB(25,25,25)
	b.TextColor3 = Color3.new(1,1,1)
	b.TextSize = 13
	b.Font = Enum.Font.SourceSansBold
	b.AutoButtonColor = false

	Instance.new("UICorner", b).CornerRadius = UDim.new(0,7)
	local s = Instance.new("UIStroke", b)
	s.Thickness = 1.4
	return b, s
end

-- (โค้ดต่อทั้งหมดเหมือนที่คุณส่งมา)

