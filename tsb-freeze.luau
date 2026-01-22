local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local Config = {
	Size = 55,
	IconFreeze = "❄️",
	IconUnfreeze = "🐧",
	ColorDefault = Color3.fromRGB(0, 0, 0),
	ColorFrozen = Color3.fromRGB(20, 50, 70),
	StrokeDefault = Color3.fromRGB(200, 200, 200),
	StrokeFrozen = Color3.fromRGB(100, 200, 255),
	TransparencyDefault = 0.4,
	TransparencyFrozen = 0.2
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FrostUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainCircle"
MainFrame.Size = UDim2.fromOffset(Config.Size, Config.Size)
MainFrame.Position = UDim2.new(0.9, -Config.Size * 1.5, 0.65, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Config.ColorDefault
MainFrame.BackgroundTransparency = Config.TransparencyDefault
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Config.StrokeDefault
UIStroke.Thickness = 2
UIStroke.Transparency = 0.3
UIStroke.Parent = MainFrame

local ActionButton = Instance.new("TextButton")
ActionButton.Name = "Trigger"
ActionButton.Size = UDim2.fromScale(1, 1)
ActionButton.BackgroundTransparency = 1
ActionButton.Text = Config.IconFreeze
ActionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ActionButton.TextSize = 26
ActionButton.Font = Enum.Font.GothamBold
ActionButton.Parent = MainFrame

local isFrozen = false
local dragging, dragInput, dragStart, startPos

local function UpdatePosition(input)
	local delta = input.Position - dragStart
	local targetPosition = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
	TweenService:Create(MainFrame, TweenInfo.new(0.08, Enum.EasingStyle.Sine), {Position = targetPosition}):Play()
end

MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

MainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		UpdatePosition(input)
	end
end)

local function ToggleState()
	Character = Player.Character
	if not Character then return end
	local HRP = Character:FindFirstChild("HumanoidRootPart")
	if not HRP then return end

	isFrozen = not isFrozen
	HRP.Anchored = isFrozen

	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	if isFrozen then
		ActionButton.Text = Config.IconUnfreeze
		TweenService:Create(MainFrame, tweenInfo, {
			BackgroundColor3 = Config.ColorFrozen,
			BackgroundTransparency = Config.TransparencyFrozen
		}):Play()
		TweenService:Create(UIStroke, tweenInfo, {
			Color = Config.StrokeFrozen,
			Transparency = 0
		}):Play()
	else
		ActionButton.Text = Config.IconFreeze
		TweenService:Create(MainFrame, tweenInfo, {
			BackgroundColor3 = Config.ColorDefault,
			BackgroundTransparency = Config.TransparencyDefault
		}):Play()
		TweenService:Create(UIStroke, tweenInfo, {
			Color = Config.StrokeDefault,
			Transparency = 0.3
		}):Play()
	end
end

ActionButton.MouseButton1Down:Connect(function()
	TweenService:Create(MainFrame, TweenInfo.new(0.15), {Size = UDim2.fromOffset(Config.Size * 0.9, Config.Size * 0.9)}):Play()
end)

ActionButton.MouseButton1Up:Connect(function()
	TweenService:Create(MainFrame, TweenInfo.new(0.15), {Size = UDim2.fromOffset(Config.Size, Config.Size)}):Play()
end)

ActionButton.Activated:Connect(ToggleState)

Player.CharacterAdded:Connect(function(NewCharacter)
	Character = NewCharacter
	isFrozen = false
	ActionButton.Text = Config.IconFreeze
	TweenService:Create(MainFrame, TweenInfo.new(0.3), {
		BackgroundColor3 = Config.ColorDefault,
		BackgroundTransparency = Config.TransparencyDefault
	}):Play()
	TweenService:Create(UIStroke, TweenInfo.new(0.3), {
		Color = Config.StrokeDefault,
		Transparency = 0.3
	}):Play()
end)
