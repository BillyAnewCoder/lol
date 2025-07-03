--[[
    Advanced UI Components Module
    Contains more complex components like ColorPicker, Dropdown, Input, etc.
]]

local AdvancedComponents = {}
local UILibrary = require(script.Parent.UILibrary)

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Input Class
local Input = {}
Input.__index = Input

function Input:CreateInput(name, placeholder, callback)
    local self = setmetatable({}, Input)
    
    self.Name = name
    self.Tab = self
    self.Value = ""
    self.Callback = callback or function() end
    
    self.Frame = Instance.new("Frame")
    self.Frame.Name = name
    self.Frame.Size = UDim2.new(1, 0, 0, 50)
    self.Frame.BackgroundTransparency = 1
    self.Frame.Parent = self.Content
    
    self.Label = Instance.new("TextLabel")
    self.Label.Name = "Label"
    self.Label.Size = UDim2.new(1, 0, 0, 20)
    self.Label.Position = UDim2.new(0, 0, 0, 0)
    self.Label.BackgroundTransparency = 1
    self.Label.Text = name
    self.Label.TextColor3 = UILibrary.Data.Theme.Text
    self.Label.TextScaled = true
    self.Label.Font = Enum.Font.Gotham
    self.Label.TextXAlignment = Enum.TextXAlignment.Left
    self.Label.Parent = self.Frame
    
    self.InputFrame = Instance.new("Frame")
    self.InputFrame.Name = "InputFrame"
    self.InputFrame.Size = UDim2.new(1, 0, 0, 25)
    self.InputFrame.Position = UDim2.new(0, 0, 0, 25)
    self.InputFrame.BackgroundColor3 = UILibrary.Data.Theme.Secondary
    self.InputFrame.BorderSizePixel = 0
    self.InputFrame.Parent = self.Frame
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = self.InputFrame
    
    self.TextBox = Instance.new("TextBox")
    self.TextBox.Name = "TextBox"
    self.TextBox.Size = UDim2.new(1, -10, 1, 0)
    self.TextBox.Position = UDim2.new(0, 5, 0, 0)
    self.TextBox.BackgroundTransparency = 1
    self.TextBox.Text = ""
    self.TextBox.PlaceholderText = placeholder or "Enter text..."
    self.TextBox.TextColor3 = UILibrary.Data.Theme.Text
    self.TextBox.PlaceholderColor3 = UILibrary.Data.Theme.TextDark
    self.TextBox.TextScaled = true
    self.TextBox.Font = Enum.Font.Gotham
    self.TextBox.TextXAlignment = Enum.TextXAlignment.Left
    self.TextBox.Parent = self.InputFrame
    
    self.TextBox.FocusLost:Connect(function()
        self.Value = self.TextBox.Text
        self.Callback(self.Value)
    end)
    
    table.insert(self.Components, self)
    return self
end

function Input:Set(value)
    self.Value = value
    self.TextBox.Text = value
    self.Callback(self.Value)
end

function Input:Get()
    return self.Value
end

function Input:UpdateTheme()
    self.Label.TextColor3 = UILibrary.Data.Theme.Text
    self.InputFrame.BackgroundColor3 = UILibrary.Data.Theme.Secondary
    self.TextBox.TextColor3 = UILibrary.Data.Theme.Text
    self.TextBox.PlaceholderColor3 = UILibrary.Data.Theme.TextDark
end

-- Dropdown Class
local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown:CreateDropdown(name, options, default, callback)
    local self = setmetatable({}, Dropdown)
    
    self.Name = name
    self.Tab = self
    self.Options = options or {}
    self.Value = default or (options and options[1]) or ""
    self.Callback = callback or function() end
    self.Open = false
    
    self.Frame = Instance.new("Frame")
    self.Frame.Name = name
    self.Frame.Size = UDim2.new(1, 0, 0, 50)
    self.Frame.BackgroundTransparency = 1
    self.Frame.Parent = self.Content
    
    self.Label = Instance.new("TextLabel")
    self.Label.Name = "Label"
    self.Label.Size = UDim2.new(1, 0, 0, 20)
    self.Label.Position = UDim2.new(0, 0, 0, 0)
    self.Label.BackgroundTransparency = 1
    self.Label.Text = name
    self.Label.TextColor3 = UILibrary.Data.Theme.Text
    self.Label.TextScaled = true
    self.Label.Font = Enum.Font.Gotham
    self.Label.TextXAlignment = Enum.TextXAlignment.Left
    self.Label.Parent = self.Frame
    
    self.DropdownFrame = Instance.new("TextButton")
    self.DropdownFrame.Name = "DropdownFrame"
    self.DropdownFrame.Size = UDim2.new(1, 0, 0, 25)
    self.DropdownFrame.Position = UDim2.new(0, 0, 0, 25)
    self.DropdownFrame.BackgroundColor3 = UILibrary.Data.Theme.Secondary
    self.DropdownFrame.BorderSizePixel = 0
    self.DropdownFrame.Text = ""
    self.DropdownFrame.Parent = self.Frame
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 4)
    dropdownCorner.Parent = self.DropdownFrame
    
    self.ValueLabel = Instance.new("TextLabel")
    self.ValueLabel.Name = "ValueLabel"
    self.ValueLabel.Size = UDim2.new(1, -30, 1, 0)
    self.ValueLabel.Position = UDim2.new(0, 10, 0, 0)
    self.ValueLabel.BackgroundTransparency = 1
    self.ValueLabel.Text = self.Value
    self.ValueLabel.TextColor3 = UILibrary.Data.Theme.Text
    self.ValueLabel.TextScaled = true
    self.ValueLabel.Font = Enum.Font.Gotham
    self.ValueLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.ValueLabel.Parent = self.DropdownFrame
    
    self.Arrow = Instance.new("TextLabel")
    self.Arrow.Name = "Arrow"
    self.Arrow.Size = UDim2.new(0, 20, 1, 0)
    self.Arrow.Position = UDim2.new(1, -25, 0, 0)
    self.Arrow.BackgroundTransparency = 1
    self.Arrow.Text = "▼"
    self.Arrow.TextColor3 = UILibrary.Data.Theme.TextDark
    self.Arrow.TextScaled = true
    self.Arrow.Font = Enum.Font.Gotham
    self.Arrow.Parent = self.DropdownFrame
    
    self.OptionsFrame = Instance.new("Frame")
    self.OptionsFrame.Name = "OptionsFrame"
    self.OptionsFrame.Size = UDim2.new(1, 0, 0, #self.Options * 25)
    self.OptionsFrame.Position = UDim2.new(0, 0, 0, 50)
    self.OptionsFrame.BackgroundColor3 = UILibrary.Data.Theme.Secondary
    self.OptionsFrame.BorderSizePixel = 0
    self.OptionsFrame.Visible = false
    self.OptionsFrame.ZIndex = 10
    self.OptionsFrame.Parent = self.Frame
    
    local optionsCorner = Instance.new("UICorner")
    optionsCorner.CornerRadius = UDim.new(0, 4)
    optionsCorner.Parent = self.OptionsFrame
    
    local optionsLayout = Instance.new("UIListLayout")
    optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optionsLayout.Parent = self.OptionsFrame
    
    -- Create option buttons
    for i, option in ipairs(self.Options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Name = "Option" .. i
        optionButton.Size = UDim2.new(1, 0, 0, 25)
        optionButton.BackgroundColor3 = UILibrary.Data.Theme.Secondary
        optionButton.BorderSizePixel = 0
        optionButton.Text = option
        optionButton.TextColor3 = UILibrary.Data.Theme.Text
        optionButton.TextScaled = true
        optionButton.Font = Enum.Font.Gotham
        optionButton.Parent = self.OptionsFrame
        
        optionButton.MouseEnter:Connect(function()
            optionButton.BackgroundColor3 = UILibrary.Data.Theme.Accent
        end)
        
        optionButton.MouseLeave:Connect(function()
            optionButton.BackgroundColor3 = UILibrary.Data.Theme.Secondary
        end)
        
        optionButton.MouseButton1Click:Connect(function()
            self:Set(option)
            self:Close()
        end)
    end
    
    self.DropdownFrame.MouseButton1Click:Connect(function()
        if self.Open then
            self:Close()
        else
            self:Open()
        end
    end)
    
    table.insert(self.Components, self)
    return self
end

function Dropdown:Open()
    self.Open = true
    self.OptionsFrame.Visible = true
    self.Arrow.Text = "▲"
    self.Frame.Size = UDim2.new(1, 0, 0, 50 + #self.Options * 25)
end

function Dropdown:Close()
    self.Open = false
    self.OptionsFrame.Visible = false
    self.Arrow.Text = "▼"
    self.Frame.Size = UDim2.new(1, 0, 0, 50)
end

function Dropdown:Set(value)
    self.Value = value
    self.ValueLabel.Text = value
    self.Callback(self.Value)
end

function Dropdown:Get()
    return self.Value
end

function Dropdown:UpdateTheme()
    self.Label.TextColor3 = UILibrary.Data.Theme.Text
    self.DropdownFrame.BackgroundColor3 = UILibrary.Data.Theme.Secondary
    self.ValueLabel.TextColor3 = UILibrary.Data.Theme.Text
    self.Arrow.TextColor3 = UILibrary.Data.Theme.TextDark
    self.OptionsFrame.BackgroundColor3 = UILibrary.Data.Theme.Secondary
    
    for _, child in pairs(self.OptionsFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child.BackgroundColor3 = UILibrary.Data.Theme.Secondary
            child.TextColor3 = UILibrary.Data.Theme.Text
        end
    end
end

-- ColorPicker Class
local ColorPicker = {}
ColorPicker.__index = ColorPicker

function ColorPicker:CreateColorPicker(name, default, callback)
    local self = setmetatable({}, ColorPicker)
    
    self.Name = name
    self.Tab = self
    self.Value = default or Color3.fromRGB(255, 255, 255)
    self.Callback = callback or function() end
    self.Open = false
    
    self.Frame = Instance.new("Frame")
    self.Frame.Name = name
    self.Frame.Size = UDim2.new(1, 0, 0, 35)
    self.Frame.BackgroundTransparency = 1
    self.Frame.Parent = self.Content
    
    self.Label = Instance.new("TextLabel")
    self.Label.Name = "Label"
    self.Label.Size = UDim2.new(1, -40, 1, 0)
    self.Label.Position = UDim2.new(0, 0, 0, 0)
    self.Label.BackgroundTransparency = 1
    self.Label.Text = name
    self.Label.TextColor3 = UILibrary.Data.Theme.Text
    self.Label.TextScaled = true
    self.Label.Font = Enum.Font.Gotham
    self.Label.TextXAlignment = Enum.TextXAlignment.Left
    self.Label.Parent = self.Frame
    
    self.ColorDisplay = Instance.new("TextButton")
    self.ColorDisplay.Name = "ColorDisplay"
    self.ColorDisplay.Size = UDim2.new(0, 30, 0, 30)
    self.ColorDisplay.Position = UDim2.new(1, -35, 0.5, -15)
    self.ColorDisplay.BackgroundColor3 = self.Value
    self.ColorDisplay.BorderSizePixel = 0
    self.ColorDisplay.Text = ""
    self.ColorDisplay.Parent = self.Frame
    
    local displayCorner = Instance.new("UICorner")
    displayCorner.CornerRadius = UDim.new(0, 4)
    displayCorner.Parent = self.ColorDisplay
    
    -- Color picker popup (simplified)
    self.ColorDisplay.MouseButton1Click:Connect(function()
        self:setDisplay()
    end)
    
    table.insert(self.Components, self)
    return self
end

function ColorPicker:setDisplay()
    -- Simple color picker implementation
    -- In a full implementation, this would open a color wheel/palette
    local colors = {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(255, 0, 255),
        Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(0, 0, 0)
    }
    
    local randomColor = colors[math.random(1, #colors)]
    self:Set(randomColor)
end

function ColorPicker:rgbBoxes()
    -- RGB input boxes implementation would go here
    -- This is a placeholder for the full RGB input system
end

function ColorPicker:Set(color)
    self.Value = color
    self.ColorDisplay.BackgroundColor3 = color
    self.Callback(self.Value)
end

function ColorPicker:Get()
    return self.Value
end

function ColorPicker:UpdateTheme()
    self.Label.TextColor3 = UILibrary.Data.Theme.Text
end

-- Keybind Class
local Keybind = {}
Keybind.__index = Keybind

function Keybind:CreateKeybind(name, default, callback)
    local self = setmetatable({}, Keybind)
    
    self.Name = name
    self.Tab = self
    self.Value = default or Enum.KeyCode.Unknown
    self.Callback = callback or function() end
    self.Listening = false
    
    self.Frame = Instance.new("Frame")
    self.Frame.Name = name
    self.Frame.Size = UDim2.new(1, 0, 0, 35)
    self.Frame.BackgroundTransparency = 1
    self.Frame.Parent = self.Content
    
    self.Label = Instance.new("TextLabel")
    self.Label.Name = "Label"
    self.Label.Size = UDim2.new(1, -80, 1, 0)
    self.Label.Position = UDim2.new(0, 0, 0, 0)
    self.Label.BackgroundTransparency = 1
    self.Label.Text = name
    self.Label.TextColor3 = UILibrary.Data.Theme.Text
    self.Label.TextScaled = true
    self.Label.Font = Enum.Font.Gotham
    self.Label.TextXAlignment = Enum.TextXAlignment.Left
    self.Label.Parent = self.Frame
    
    self.KeybindButton = Instance.new("TextButton")
    self.KeybindButton.Name = "KeybindButton"
    self.KeybindButton.Size = UDim2.new(0, 70, 0, 25)
    self.KeybindButton.Position = UDim2.new(1, -75, 0.5, -12.5)
    self.KeybindButton.BackgroundColor3 = UILibrary.Data.Theme.Secondary
    self.KeybindButton.BorderSizePixel = 0
    self.KeybindButton.Text = self.Value.Name
    self.KeybindButton.TextColor3 = UILibrary.Data.Theme.Text
    self.KeybindButton.TextScaled = true
    self.KeybindButton.Font = Enum.Font.Gotham
    self.KeybindButton.Parent = self.Frame
    
    local keybindCorner = Instance.new("UICorner")
    keybindCorner.CornerRadius = UDim.new(0, 4)
    keybindCorner.Parent = self.KeybindButton
    
    self.KeybindButton.MouseButton1Click:Connect(function()
        if not self.Listening then
            self.Listening = true
            self.KeybindButton.Text = "..."
            self.KeybindButton.BackgroundColor3 = UILibrary.Data.Theme.Accent
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if self.Listening and input.UserInputType == Enum.UserInputType.Keyboard then
            self:Set(input.KeyCode)
            self.Listening = false
        end
    end)
    
    -- Register keybind
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == self.Value then
            self.Callback()
        end
    end)
    
    table.insert(self.Components, self)
    return self
end

function Keybind:Set(keyCode)
    self.Value = keyCode
    self.KeybindButton.Text = keyCode.Name
    self.KeybindButton.BackgroundColor3 = UILibrary.Data.Theme.Secondary
    self.Listening = false
end

function Keybind:Get()
    return self.Value
end

function Keybind:UpdateTheme()
    self.Label.TextColor3 = UILibrary.Data.Theme.Text
    if not self.Listening then
        self.KeybindButton.BackgroundColor3 = UILibrary.Data.Theme.Secondary
    end
    self.KeybindButton.TextColor3 = UILibrary.Data.Theme.Text
end

-- Section and Label Classes
local Section = {}
Section.__index = Section

function Section:CreateSection(name)
    local self = setmetatable({}, Section)
    
    self.Name = name
    self.Tab = self
    
    self.Frame = Instance.new("Frame")
    self.Frame.Name = name
    self.Frame.Size = UDim2.new(1, 0, 0, 30)
    self.Frame.BackgroundTransparency = 1
    self.Frame.Parent = self.Content
    
    self.Label = Instance.new("TextLabel")
    self.Label.Name = "Label"
    self.Label.Size = UDim2.new(1, 0, 1, 0)
    self.Label.BackgroundTransparency = 1
    self.Label.Text = name
    self.Label.TextColor3 = UILibrary.Data.Theme.Accent
    self.Label.TextScaled = true
    self.Label.Font = Enum.Font.GothamBold
    self.Label.TextXAlignment = Enum.TextXAlignment.Left
    self.Label.Parent = self.Frame
    
    local line = Instance.new("Frame")
    line.Name = "Line"
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 1, -1)
    line.BackgroundColor3 = UILibrary.Data.Theme.Accent
    line.BorderSizePixel = 0
    line.Parent = self.Frame
    
    table.insert(self.Components, self)
    return self
end

function Section:Set(text)
    self.Label.Text = text
end

function Section:UpdateTheme()
    self.Label.TextColor3 = UILibrary.Data.Theme.Accent
    self.Frame.Line.BackgroundColor3 = UILibrary.Data.Theme.Accent
end

local Label = {}
Label.__index = Label

function Label:CreateLabel(text)
    local self = setmetatable({}, Label)
    
    self.Name = "Label"
    self.Tab = self
    self.Value = text or ""
    
    self.Frame = Instance.new("Frame")
    self.Frame.Name = "Label"
    self.Frame.Size = UDim2.new(1, 0, 0, 25)
    self.Frame.BackgroundTransparency = 1
    self.Frame.Parent = self.Content
    
    self.Label = Instance.new("TextLabel")
    self.Label.Name = "Label"
    self.Label.Size = UDim2.new(1, 0, 1, 0)
    self.Label.BackgroundTransparency = 1
    self.Label.Text = self.Value
    self.Label.TextColor3 = UILibrary.Data.Theme.TextDark
    self.Label.TextScaled = true
    self.Label.Font = Enum.Font.Gotham
    self.Label.TextXAlignment = Enum.TextXAlignment.Left
    self.Label.TextWrapped = true
    self.Label.Parent = self.Frame
    
    table.insert(self.Components, self)
    return self
end

function Label:Set(text)
    self.Value = text
    self.Label.Text = text
end

function Label:Get()
    return self.Value
end

function Label:UpdateTheme()
    self.Label.TextColor3 = UILibrary.Data.Theme.TextDark
end

local Paragraph = {}
Paragraph.__index = Paragraph

function Paragraph:CreateParagraph(text)
    local self = setmetatable({}, Paragraph)
    
    self.Name = "Paragraph"
    self.Tab = self
    self.Value = text or ""
    
    self.Frame = Instance.new("Frame")
    self.Frame.Name = "Paragraph"
    self.Frame.Size = UDim2.new(1, 0, 0, 60)
    self.Frame.BackgroundTransparency = 1
    self.Frame.Parent = self.Content
    
    self.Label = Instance.new("TextLabel")
    self.Label.Name = "Label"
    self.Label.Size = UDim2.new(1, 0, 1, 0)
    self.Label.BackgroundTransparency = 1
    self.Label.Text = self.Value
    self.Label.TextColor3 = UILibrary.Data.Theme.TextDark
    self.Label.TextScaled = true
    self.Label.Font = Enum.Font.Gotham
    self.Label.TextXAlignment = Enum.TextXAlignment.Left
    self.Label.TextYAlignment = Enum.TextYAlignment.Top
    self.Label.TextWrapped = true
    self.Label.Parent = self.Frame
    
    table.insert(self.Components, self)
    return self
end

function Paragraph:Set(text)
    self.Value = text
    self.Label.Text = text
end

function Paragraph:Get()
    return self.Value
end

function Paragraph:UpdateTheme()
    self.Label.TextColor3 = UILibrary.Data.Theme.TextDark
end

return AdvancedComponents