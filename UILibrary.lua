--[[
    Roblox UI Library
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
local CoreGui = game:GetService("CoreGui")

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
    self.Tabs = {}
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
        tab:UpdateTheme()
    end
end

function Window:GetComponentValues()
    local values = {}
    for _, tab in pairs(self.Tabs) do
        values[tab.Name] = tab:GetComponentValues()
    end
    return values
end

function Window:LoadComponentValues(values)
    for _, tab in pairs(self.Tabs) do
        if values[tab.Name] then
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

return UILibrary