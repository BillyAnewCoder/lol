--[[
    Roblox UI Library - Single File Version for Executors
    A comprehensive UI library for creating modern interfaces in Roblox
    
    Features:
    - Theme system with customizable colors
    - Draggable windows
    - Multiple UI components (buttons, sliders, toggles, etc.)
    - Configuration save/load system
    - Keybind system
    - Notification system
]]

local UILibrary = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Library Data
UILibrary.Data = {
    Windows = {},
    Notifications = {},
    Keybinds = {},
    Configuration = {},
    Theme = {
        Primary = Color3.fromRGB(30, 30, 30),
        Secondary = Color3.fromRGB(40, 40, 40),
        Accent = Color3.fromRGB(0, 162, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(200, 200, 200),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Error = Color3.fromRGB(231, 76, 60),
        Background = Color3.fromRGB(20, 20, 20)
    }
}

-- Utility Functions
function UILibrary.PackColor(color)
    return {R = color.R, G = color.G, B = color.B}
end

function UILibrary.UnpackColor(packedColor)
    return Color3.fromRGB(packedColor.R * 255, packedColor.G * 255, packedColor.B * 255)
end

function UILibrary.IsNotNaN(value)
    return value == value
end

function UILibrary.GenUid()
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local uid = ""
    for i = 1, 16 do
        local randomIndex = math.random(1, #chars)
        uid = uid .. string.sub(chars, randomIndex, randomIndex)
    end
    return uid
end

function UILibrary.ChangeTheme(newTheme)
    for key, value in pairs(newTheme) do
        if UILibrary.Data.Theme[key] then
            UILibrary.Data.Theme[key] = value
        end
    end
    
    -- Update all existing UI elements
    for _, window in pairs(UILibrary.Data.Windows) do
        window:UpdateTheme()
    end
end

-- Configuration System
function UILibrary.SaveConfiguration(configName)
    if not configName then configName = "default" end
    
    local config = {
        Theme = {},
        WindowStates = {},
        ComponentValues = {}
    }
    
    -- Save theme
    for key, value in pairs(UILibrary.Data.Theme) do
        config.Theme[key] = UILibrary.PackColor(value)
    end
    
    -- Save window states and component values
    for _, window in pairs(UILibrary.Data.Windows) do
        config.WindowStates[window.Name] = {
            Position = {X = window.Frame.Position.X.Offset, Y = window.Frame.Position.Y.Offset},
            Visible = window.Frame.Visible,
            Minimized = window.Minimized
        }
        
        config.ComponentValues[window.Name] = window:GetComponentValues()
    end
    
    UILibrary.Data.Configuration[configName] = config
    return config
end

function UILibrary.LoadConfiguration(configName)
    if not configName then configName = "default" end
    local config = UILibrary.Data.Configuration[configName]
    
    if not config then return false end
    
    -- Load theme
    if config.Theme then
        local newTheme = {}
        for key, value in pairs(config.Theme) do
            newTheme[key] = UILibrary.UnpackColor(value)
        end
        UILibrary.ChangeTheme(newTheme)
    end
    
    -- Load window states and component values
    for _, window in pairs(UILibrary.Data.Windows) do
        local windowState = config.WindowStates[window.Name]
        if windowState then
            window.Frame.Position = UDim2.new(0, windowState.Position.X, 0, windowState.Position.Y)
            window.Frame.Visible = windowState.Visible
            if windowState.Minimized then
                window:Minimise()
            end
        end
        
        local componentValues = config.ComponentValues[window.Name]
        if componentValues then
            window:LoadComponentValues(componentValues)
        end
    end
    
    return true
end

-- Drawing Functions
function UILibrary.DrawTriangle(parent, pointA, pointB, pointC, color)
    local triangle = Instance.new("Frame")
    triangle.Name = "Triangle"
    triangle.BackgroundColor3 = color or UILibrary.Data.Theme.Accent
    triangle.BorderSizePixel = 0
    triangle.Parent = parent
    
    -- Simple triangle approximation using rotation
    local centerX = (pointA.X + pointB.X + pointC.X) / 3
    local centerY = (pointA.Y + pointB.Y + pointC.Y) / 3
    
    triangle.Position = UDim2.new(0, centerX - 5, 0, centerY - 5)
    triangle.Size = UDim2.new(0, 10, 0, 10)
    triangle.Rotation = 45
    
    return triangle
end

function UILibrary.DrawQuad(parent, size, position, color)
    local quad = Instance.new("Frame")
    quad.Name = "Quad"
    quad.Size = size
    quad.Position = position
    quad.BackgroundColor3 = color or UILibrary.Data.Theme.Secondary
    quad.BorderSizePixel = 0
    quad.Parent = parent
    
    return quad
end

-- Dragging Functionality
function UILibrary.AddDraggingFunctionality(frame, dragHandle)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    dragHandle = dragHandle or frame
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Binding System
UILibrary.binds = {
    frames = {},
    parts = {},
    parents = {}
}

function UILibrary.BindFrame(frame, part)
    local bindId = UILibrary.GenUid()
    UILibrary.binds.frames[bindId] = frame
    UILibrary.binds.parts[bindId] = part
    UILibrary.binds.parents[bindId] = part.Parent
    
    return bindId
end

function UILibrary.UnbindFrame(bindId)
    UILibrary.binds.frames[bindId] = nil
    UILibrary.binds.parts[bindId] = nil
    UILibrary.binds.parents[bindId] = nil
end

function UILibrary.HasBinding(bindId)
    return UILibrary.binds.frames[bindId] ~= nil
end

function UILibrary.GetBoundParts()
    local parts = {}
    for bindId, part in pairs(UILibrary.binds.parts) do
        table.insert(parts, part)
    end
    return parts
end

function UILibrary.UpdateOrientation()
    for bindId, frame in pairs(UILibrary.binds.frames) do
        local part = UILibrary.binds.parts[bindId]
        if part and part.Parent then
            -- Update frame position based on part position
            local camera = workspace.CurrentCamera
            local screenPoint, onScreen = camera:WorldToScreenPoint(part.Position)
            
            if onScreen then
                frame.Position = UDim2.new(0, screenPoint.X, 0, screenPoint.Y)
                frame.Visible = true
            else
                frame.Visible = false
            end
        end
    end
end

function UILibrary.Modify(object, properties)
    for property, value in pairs(properties) do
        object[property] = value
    end
    return object
end

-- Notification System
function UILibrary.Notify(title, message, duration, notificationType)
    duration = duration or 3
    notificationType = notificationType or "Info"
    
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 300, 0, 80)
    notification.Position = UDim2.new(1, -320, 1, -100 - (#UILibrary.Data.Notifications * 90))
    notification.BackgroundColor3 = UILibrary.Data.Theme.Secondary
    notification.BorderSizePixel = 0
    notification.Parent = PlayerGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notification
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -20, 0, 25)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = UILibrary.Data.Theme.Text
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = notification
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -20, 0, 40)
    messageLabel.Position = UDim2.new(0, 10, 0, 30)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = UILibrary.Data.Theme.TextDark
    messageLabel.TextScaled = true
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextWrapped = true
    messageLabel.Parent = notification
    
    -- Color based on type
    local accentColor = UILibrary.Data.Theme.Accent
    if notificationType == "Success" then
        accentColor = UILibrary.Data.Theme.Success
    elseif notificationType == "Warning" then
        accentColor = UILibrary.Data.Theme.Warning
    elseif notificationType == "Error" then
        accentColor = UILibrary.Data.Theme.Error
    end
    
    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.Position = UDim2.new(0, 0, 0, 0)
    accent.BackgroundColor3 = accentColor
    accent.BorderSizePixel = 0
    accent.Parent = notification
    
    table.insert(UILibrary.Data.Notifications, notification)
    
    -- Animate in
    notification:TweenPosition(UDim2.new(1, -320, 1, -100 - ((#UILibrary.Data.Notifications - 1) * 90)), "Out", "Quad", 0.3, true)
    
    -- Auto remove
    game:GetService("Debris"):AddItem(notification, duration)
    
    spawn(function()
        wait(duration)
        for i, notif in ipairs(UILibrary.Data.Notifications) do
            if notif == notification then
                table.remove(UILibrary.Data.Notifications, i)
                break
            end
        end
    end)
end

-- Window Class
local Window = {}
Window.__index = Window

function UILibrary.CreateWindow(title, size)
    local self = setmetatable({}, Window)
    
    self.Name = title
    self.Tabs = {} -- Initialize tabs table here
    self.Components = {}
    self.Minimized = false
    self.Hidden = false
    
    -- Create main frame
    self.Frame = Instance.new("Frame")
    self.Frame.Name = title
    self.Frame.Size = size or UDim2.new(0, 500, 0, 400)
    self.Frame.Position = UDim2.new(0.5, -250, 0.5, -200)
    self.Frame.BackgroundColor3 = UILibrary.Data.Theme.Primary
    self.Frame.BorderSizePixel = 0
    self.Frame.Parent = PlayerGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = self.Frame
    
    -- Title bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, 30)
    self.TitleBar.Position = UDim2.new(0, 0, 0, 0)
    self.TitleBar.BackgroundColor3 = UILibrary.Data.Theme.Secondary
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Parent = self.Frame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = self.TitleBar
    
    -- Title label
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(1, -60, 1, 0)
    self.TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = title
    self.TitleLabel.TextColor3 = UILibrary.Data.Theme.Text
    self.TitleLabel.TextScaled = true
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.TitleBar
    
    -- Close button
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Name = "Close"
    self.CloseButton.Size = UDim2.new(0, 25, 0, 25)
    self.CloseButton.Position = UDim2.new(1, -30, 0, 2.5)
    self.CloseButton.BackgroundColor3 = UILibrary.Data.Theme.Error
    self.CloseButton.BorderSizePixel = 0
    self.CloseButton.Text = "×"
    self.CloseButton.TextColor3 = UILibrary.Data.Theme.Text
    self.CloseButton.TextScaled = true
    self.CloseButton.Font = Enum.Font.GothamBold
    self.CloseButton.Parent = self.TitleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = self.CloseButton
    
    -- Minimize button
    self.MinimizeButton = Instance.new("TextButton")
    self.MinimizeButton.Name = "Minimize"
    self.MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
    self.MinimizeButton.Position = UDim2.new(1, -60, 0, 2.5)
    self.MinimizeButton.BackgroundColor3 = UILibrary.Data.Theme.Warning
    self.MinimizeButton.BorderSizePixel = 0
    self.MinimizeButton.Text = "−"
    self.MinimizeButton.TextColor3 = UILibrary.Data.Theme.Text
    self.MinimizeButton.TextScaled = true
    self.MinimizeButton.Font = Enum.Font.GothamBold
    self.MinimizeButton.Parent = self.TitleBar
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 4)
    minimizeCorner.Parent = self.MinimizeButton
    
    -- Content frame
    self.Content = Instance.new("Frame")
    self.Content.Name = "Content"
    self.Content.Size = UDim2.new(1, 0, 1, -30)
    self.Content.Position = UDim2.new(0, 0, 0, 30)
    self.Content.BackgroundTransparency = 1
    self.Content.Parent = self.Frame
    
    -- Tab container
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(0, 150, 1, 0)
    self.TabContainer.Position = UDim2.new(0, 0, 0, 0)
    self.TabContainer.BackgroundColor3 = UILibrary.Data.Theme.Background
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.Parent = self.Content
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 2)
    tabLayout.Parent = self.TabContainer
    
    -- Main content area
    self.MainContent = Instance.new("Frame")
    self.MainContent.Name = "MainContent"
    self.MainContent.Size = UDim2.new(1, -150, 1, 0)
    self.MainContent.Position = UDim2.new(0, 150, 0, 0)
    self.MainContent.BackgroundTransparency = 1
    self.MainContent.Parent = self.Content
    
    -- Add dragging
    UILibrary.AddDraggingFunctionality(self.Frame, self.TitleBar)
    
    -- Button events
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    self.MinimizeButton.MouseButton1Click:Connect(function()
        if self.Minimized then
            self:Maximise()
        else
            self:Minimise()
        end
    end)
    
    table.insert(UILibrary.Data.Windows, self)
    return self
end

function Window:Hide()
    self.Frame.Visible = false
    self.Hidden = true
end

function Window:Unhide()
    self.Frame.Visible = true
    self.Hidden = false
end

function Window:Minimise()
    self.Content.Visible = false
    self.Frame.Size = UDim2.new(self.Frame.Size.X.Scale, self.Frame.Size.X.Offset, 0, 30)
    self.Minimized = true
    self.MinimizeButton.Text = "+"
end

function Window:Maximise()
    self.Content.Visible = true
    self.Frame.Size = UDim2.new(self.Frame.Size.X.Scale, self.Frame.Size.X.Offset, 0, 400)
    self.Minimized = false
    self.MinimizeButton.Text = "−"
end

function Window:UpdateTheme()
    self.Frame.BackgroundColor3 = UILibrary.Data.Theme.Primary
    self.TitleBar.BackgroundColor3 = UILibrary.Data.Theme.Secondary
    self.TitleLabel.TextColor3 = UILibrary.Data.Theme.Text
    self.TabContainer.BackgroundColor3 = UILibrary.Data.Theme.Background
    
    for _, tab in pairs(self.Tabs) do
        if tab.UpdateTheme then
            tab:UpdateTheme()
        end
    end
end

function Window:GetComponentValues()
    local values = {}
    for _, tab in pairs(self.Tabs) do
        if tab.GetComponentValues then
            values[tab.Name] = tab:GetComponentValues()
        end
    end
    return values
end

function Window:LoadComponentValues(values)
    for _, tab in pairs(self.Tabs) do
        if tab.LoadComponentValues and values[tab.Name] then
            tab:LoadComponentValues(values[tab.Name])
        end
    end
end

function Window:Destroy()
    for i, window in ipairs(UILibrary.Data.Windows) do
        if window == self then
            table.remove(UILibrary.Data.Windows, i)
            break
        end
    end
    self.Frame:Destroy()
end

-- Tab Class
local Tab = {}
Tab.__index = Tab

function Window:CreateTab(name)
    local self = setmetatable({}, Tab)
    
    self.Name = name
    self.Window = self
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
    self.Button.Parent = self.TabContainer
    
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
    self.Content.Parent = self.MainContent
    
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
    if #self.Tabs == 0 then
        self:Activate()
    end
    
    table.insert(self.Tabs, self)
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

-- Input Class
local Input = {}
Input.__index = Input

function Tab:CreateInput(name, placeholder, callback)
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

function Tab:CreateDropdown(name, options, default, callback)
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

function Tab:CreateColorPicker(name, default, callback)
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

function Tab:CreateKeybind(name, default, callback)
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

function Tab:CreateSection(name)
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

function Tab:CreateLabel(text)
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

function Tab:CreateParagraph(text)
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

-- Example Usage
local window = UILibrary.CreateWindow("UI Library Demo", UDim2.new(0, 600, 0, 450))

-- Create tabs
local mainTab = window:CreateTab("Main")
local settingsTab = window:CreateTab("Settings")

-- Main Tab Components
mainTab:CreateSection("Basic Components")

mainTab:CreateButton("Test Button", function()
    UILibrary.Notify("Button Clicked", "The test button was clicked!", 3, "Success")
end)

local testToggle = mainTab:CreateToggle("Enable Feature", false, function(value)
    print("Toggle value:", value)
end)

local testSlider = mainTab:CreateSlider("Volume", 0, 100, 50, function(value)
    print("Slider value:", value)
end)

mainTab:CreateSection("Input Components")

local testInput = mainTab:CreateInput("Username", "Enter your username", function(value)
    print("Input value:", value)
end)

local testDropdown = mainTab:CreateDropdown("Game Mode", {"Classic", "Hardcore", "Creative"}, "Classic", function(value)
    print("Dropdown value:", value)
end)

-- Settings Tab Components
settingsTab:CreateSection("Theme")

local colorPicker = settingsTab:CreateColorPicker("Accent Color", UILibrary.Data.Theme.Accent, function(color)
    UILibrary.ChangeTheme({Accent = color})
end)

settingsTab:CreateButton("Dark Theme", function()
    UILibrary.ChangeTheme({
        Primary = Color3.fromRGB(30, 30, 30),
        Secondary = Color3.fromRGB(40, 40, 40),
        Background = Color3.fromRGB(20, 20, 20),
        Accent = Color3.fromRGB(0, 162, 255)
    })
end)

settingsTab:CreateButton("Light Theme", function()
    UILibrary.ChangeTheme({
        Primary = Color3.fromRGB(240, 240, 240),
        Secondary = Color3.fromRGB(220, 220, 220),
        Background = Color3.fromRGB(200, 200, 200),
        Text = Color3.fromRGB(50, 50, 50),
        TextDark = Color3.fromRGB(100, 100, 100),
        Accent = Color3.fromRGB(0, 120, 215)
    })
end)

print("UI Library loaded successfully!")