--[[
    UI Components Module
    Contains all the UI component classes (Tab, Button, Slider, etc.)
]]

local UIComponents = {}
local UILibrary = require(script.Parent.UILibrary)

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Tab Class
local Tab = {}
Tab.__index = Tab

function UIComponents.CreateTab(window, name)
    local self = setmetatable({}, Tab)
    
    self.Name = name
    self.Window = window
    self.Components = {}
    self.Active = false
    
    -- Tab button
    self.Button = Instance.new("TextButton")
    self.Button.Name = name
    self.Button.Size = UDim2.new(1, 0, 0, 35)
    self.Button.BackgroundColor3 = UILibrary.Data.Theme.Secondary
    self.Button.BorderSizePixel = 0
    self.Button.Text = name
    self.Button.TextColor3 = UILibrary.Data.Theme.TextDark
    self.Button.TextScaled = true
    self.Button.Font = Enum.Font.Gotham
    self.Button.Parent = window.TabContainer
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = self.Button
    
    -- Tab content
    self.Content = Instance.new("ScrollingFrame")
    self.Content.Name = name .. "Content"
    self.Content.Size = UDim2.new(1, 0, 1, 0)
    self.Content.Position = UDim2.new(0, 0, 0, 0)
    self.Content.BackgroundTransparency = 1
    self.Content.BorderSizePixel = 0
    self.Content.ScrollBarThickness = 6
    self.Content.ScrollBarImageColor3 = UILibrary.Data.Theme.Accent
    self.Content.Visible = false
    self.Content.Parent = window.MainContent
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    layout.Parent = self.Content
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.Parent = self.Content
    
    -- Button click event
    self.Button.MouseButton1Click:Connect(function()
        self:Activate()
    end)
    
    -- Auto-activate first tab
    if #window.Tabs == 0 then
        self:Activate()
    end
    
    table.insert(window.Tabs, self)
    return self
end

function Tab:Activate()
    -- Deactivate other tabs
    for _, tab in pairs(self.Window.Tabs) do
        tab.Active = false
        tab.Content.Visible = false
        tab.Button.BackgroundColor3 = UILibrary.Data.Theme.Secondary
        tab.Button.TextColor3 = UILibrary.Data.Theme.TextDark
    end
    
    -- Activate this tab
    self.Active = true
    self.Content.Visible = true
    self.Button.BackgroundColor3 = UILibrary.Data.Theme.Accent
    self.Button.TextColor3 = UILibrary.Data.Theme.Text
end

function Tab:UpdateTheme()
    if self.Active then
        self.Button.BackgroundColor3 = UILibrary.Data.Theme.Accent
        self.Button.TextColor3 = UILibrary.Data.Theme.Text
    else
        self.Button.BackgroundColor3 = UILibrary.Data.Theme.Secondary
        self.Button.TextColor3 = UILibrary.Data.Theme.TextDark
    end
    
    self.Content.ScrollBarImageColor3 = UILibrary.Data.Theme.Accent
    
    for _, component in pairs(self.Components) do
        if component.UpdateTheme then
            component:UpdateTheme()
        end
    end
end

function Tab:GetComponentValues()
    local values = {}
    for _, component in pairs(self.Components) do
        if component.Get then
            values[component.Name] = component:Get()
        end
    end
    return values
end

function Tab:LoadComponentValues(values)
    for _, component in pairs(self.Components) do
        if component.Set and values[component.Name] then
            component:Set(values[component.Name])
        end
    end
end

-- Button Class
local Button = {}
Button.__index = Button

function Tab:CreateButton(name, callback)
    local self = setmetatable({}, Button)
    
    self.Name = name
    self.Tab = self
    self.Callback = callback or function() end
    
    self.Frame = Instance.new("Frame")
    self.Frame.Name = name
    self.Frame.Size = UDim2.new(1, 0, 0, 35)
    self.Frame.BackgroundTransparency = 1
    self.Frame.Parent = self.Content
    
    self.Button = Instance.new("TextButton")
    self.Button.Name = "Button"
    self.Button.Size = UDim2.new(1, 0, 1, 0)
    self.Button.BackgroundColor3 = UILibrary.Data.Theme.Accent
    self.Button.BorderSizePixel = 0
    self.Button.Text = name
    self.Button.TextColor3 = UILibrary.Data.Theme.Text
    self.Button.TextScaled = true
    self.Button.Font = Enum.Font.Gotham
    self.Button.Parent = self.Frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = self.Button
    
    -- Hover effect
    self.Button.MouseEnter:Connect(function()
        TweenService:Create(self.Button, TweenInfo.new(0.2), {BackgroundColor3 = UILibrary.Data.Theme.Accent:lerp(Color3.new(1, 1, 1), 0.1)}):Play()
    end)
    
    self.Button.MouseLeave:Connect(function()
        TweenService:Create(self.Button, TweenInfo.new(0.2), {BackgroundColor3 = UILibrary.Data.Theme.Accent}):Play()
    end)
    
    self.Button.MouseButton1Click:Connect(function()
        self.Callback()
    end)
    
    table.insert(self.Components, self)
    return self
end

function Button:Set(text)
    self.Button.Text = text
end

function Button:UpdateTheme()
    self.Button.BackgroundColor3 = UILibrary.Data.Theme.Accent
    self.Button.TextColor3 = UILibrary.Data.Theme.Text
end

-- Toggle Class
local Toggle = {}
Toggle.__index = Toggle

function Tab:CreateToggle(name, default, callback)
    local self = setmetatable({}, Toggle)
    
    self.Name = name
    self.Tab = self
    self.Value = default or false
    self.Callback = callback or function() end
    
    self.Frame = Instance.new("Frame")
    self.Frame.Name = name
    self.Frame.Size = UDim2.new(1, 0, 0, 35)
    self.Frame.BackgroundTransparency = 1
    self.Frame.Parent = self.Content
    
    self.Label = Instance.new("TextLabel")
    self.Label.Name = "Label"
    self.Label.Size = UDim2.new(1, -50, 1, 0)
    self.Label.Position = UDim2.new(0, 0, 0, 0)
    self.Label.BackgroundTransparency = 1
    self.Label.Text = name
    self.Label.TextColor3 = UILibrary.Data.Theme.Text
    self.Label.TextScaled = true
    self.Label.Font = Enum.Font.Gotham
    self.Label.TextXAlignment = Enum.TextXAlignment.Left
    self.Label.Parent = self.Frame
    
    self.ToggleFrame = Instance.new("Frame")
    self.ToggleFrame.Name = "ToggleFrame"
    self.ToggleFrame.Size = UDim2.new(0, 40, 0, 20)
    self.ToggleFrame.Position = UDim2.new(1, -45, 0.5, -10)
    self.ToggleFrame.BackgroundColor3 = self.Value and UILibrary.Data.Theme.Success or UILibrary.Data.Theme.Secondary
    self.ToggleFrame.BorderSizePixel = 0
    self.ToggleFrame.Parent = self.Frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 10)
    toggleCorner.Parent = self.ToggleFrame
    
    self.ToggleButton = Instance.new("Frame")
    self.ToggleButton.Name = "ToggleButton"
    self.ToggleButton.Size = UDim2.new(0, 16, 0, 16)
    self.ToggleButton.Position = self.Value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    self.ToggleButton.BackgroundColor3 = UILibrary.Data.Theme.Text
    self.ToggleButton.BorderSizePixel = 0
    self.ToggleButton.Parent = self.ToggleFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = self.ToggleButton
    
    local clickDetector = Instance.new("TextButton")
    clickDetector.Size = UDim2.new(1, 0, 1, 0)
    clickDetector.BackgroundTransparency = 1
    clickDetector.Text = ""
    clickDetector.Parent = self.Frame
    
    clickDetector.MouseButton1Click:Connect(function()
        self:Set(not self.Value)
    end)
    
    table.insert(self.Components, self)
    return self
end

function Toggle:Set(value)
    self.Value = value
    
    local targetColor = self.Value and UILibrary.Data.Theme.Success or UILibrary.Data.Theme.Secondary
    local targetPosition = self.Value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    
    TweenService:Create(self.ToggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
    TweenService:Create(self.ToggleButton, TweenInfo.new(0.2), {Position = targetPosition}):Play()
    
    self.Callback(self.Value)
end

function Toggle:Get()
    return self.Value
end

function Toggle:UpdateTheme()
    self.Label.TextColor3 = UILibrary.Data.Theme.Text
    self.ToggleFrame.BackgroundColor3 = self.Value and UILibrary.Data.Theme.Success or UILibrary.Data.Theme.Secondary
    self.ToggleButton.BackgroundColor3 = UILibrary.Data.Theme.Text
end

-- Slider Class
local Slider = {}
Slider.__index = Slider

function Tab:CreateSlider(name, min, max, default, callback)
    local self = setmetatable({}, Slider)
    
    self.Name = name
    self.Tab = self
    self.Min = min or 0
    self.Max = max or 100
    self.Value = default or min or 0
    self.Callback = callback or function() end
    
    self.Frame = Instance.new("Frame")
    self.Frame.Name = name
    self.Frame.Size = UDim2.new(1, 0, 0, 50)
    self.Frame.BackgroundTransparency = 1
    self.Frame.Parent = self.Content
    
    self.Label = Instance.new("TextLabel")
    self.Label.Name = "Label"
    self.Label.Size = UDim2.new(1, -60, 0, 20)
    self.Label.Position = UDim2.new(0, 0, 0, 0)
    self.Label.BackgroundTransparency = 1
    self.Label.Text = name
    self.Label.TextColor3 = UILibrary.Data.Theme.Text
    self.Label.TextScaled = true
    self.Label.Font = Enum.Font.Gotham
    self.Label.TextXAlignment = Enum.TextXAlignment.Left
    self.Label.Parent = self.Frame
    
    self.ValueLabel = Instance.new("TextLabel")
    self.ValueLabel.Name = "ValueLabel"
    self.ValueLabel.Size = UDim2.new(0, 50, 0, 20)
    self.ValueLabel.Position = UDim2.new(1, -50, 0, 0)
    self.ValueLabel.BackgroundTransparency = 1
    self.ValueLabel.Text = tostring(self.Value)
    self.ValueLabel.TextColor3 = UILibrary.Data.Theme.TextDark
    self.ValueLabel.TextScaled = true
    self.ValueLabel.Font = Enum.Font.Gotham
    self.ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    self.ValueLabel.Parent = self.Frame
    
    self.SliderFrame = Instance.new("Frame")
    self.SliderFrame.Name = "SliderFrame"
    self.SliderFrame.Size = UDim2.new(1, 0, 0, 6)
    self.SliderFrame.Position = UDim2.new(0, 0, 0, 30)
    self.SliderFrame.BackgroundColor3 = UILibrary.Data.Theme.Secondary
    self.SliderFrame.BorderSizePixel = 0
    self.SliderFrame.Parent = self.Frame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 3)
    sliderCorner.Parent = self.SliderFrame
    
    self.SliderFill = Instance.new("Frame")
    self.SliderFill.Name = "SliderFill"
    self.SliderFill.Size = UDim2.new((self.Value - self.Min) / (self.Max - self.Min), 0, 1, 0)
    self.SliderFill.Position = UDim2.new(0, 0, 0, 0)
    self.SliderFill.BackgroundColor3 = UILibrary.Data.Theme.Accent
    self.SliderFill.BorderSizePixel = 0
    self.SliderFill.Parent = self.SliderFrame
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = self.SliderFill
    
    self.SliderButton = Instance.new("Frame")
    self.SliderButton.Name = "SliderButton"
    self.SliderButton.Size = UDim2.new(0, 12, 0, 12)
    self.SliderButton.Position = UDim2.new((self.Value - self.Min) / (self.Max - self.Min), -6, 0.5, -6)
    self.SliderButton.BackgroundColor3 = UILibrary.Data.Theme.Text
    self.SliderButton.BorderSizePixel = 0
    self.SliderButton.Parent = self.SliderFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = self.SliderButton
    
    -- Slider functionality
    local dragging = false
    
    local function updateSlider(input)
        local relativeX = math.clamp((input.Position.X - self.SliderFrame.AbsolutePosition.X) / self.SliderFrame.AbsoluteSize.X, 0, 1)
        local newValue = math.floor(self.Min + (self.Max - self.Min) * relativeX)
        self:Set(newValue)
    end
    
    self.SliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    table.insert(self.Components, self)
    return self
end

function Slider:Set(value)
    self.Value = math.clamp(value, self.Min, self.Max)
    self.ValueLabel.Text = tostring(self.Value)
    
    local percentage = (self.Value - self.Min) / (self.Max - self.Min)
    
    TweenService:Create(self.SliderFill, TweenInfo.new(0.1), {Size = UDim2.new(percentage, 0, 1, 0)}):Play()
    TweenService:Create(self.SliderButton, TweenInfo.new(0.1), {Position = UDim2.new(percentage, -6, 0.5, -6)}):Play()
    
    self.Callback(self.Value)
end

function Slider:Get()
    return self.Value
end

function Slider:UpdateTheme()
    self.Label.TextColor3 = UILibrary.Data.Theme.Text
    self.ValueLabel.TextColor3 = UILibrary.Data.Theme.TextDark
    self.SliderFrame.BackgroundColor3 = UILibrary.Data.Theme.Secondary
    self.SliderFill.BackgroundColor3 = UILibrary.Data.Theme.Accent
    self.SliderButton.BackgroundColor3 = UILibrary.Data.Theme.Text
end

return UIComponents