--[[
    Example Usage of the Roblox UI Library
    This demonstrates how to use all the components and features
]]

local UILibrary = require(script.Parent.UILibrary)

-- Create a window
local window = UILibrary.CreateWindow("My UI Library", UDim2.new(0, 600, 0, 450))

-- Create tabs
local mainTab = window:CreateTab("Main")
local settingsTab = window:CreateTab("Settings")
local testTab = window:CreateTab("Testing")

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
settingsTab:CreateSection("Keybinds")

local toggleKeybind = settingsTab:CreateKeybind("Toggle UI", Enum.KeyCode.RightShift, function()
    if window.Hidden then
        window:Unhide()
    else
        window:Hide()
    end
end)

settingsTab:CreateSection("Theme")

local colorPicker = settingsTab:CreateColorPicker("Accent Color", UILibrary.Data.Theme.Accent, function(color)
    UILibrary.ChangeTheme({Accent = color})
end)

settingsTab:CreateButton("Save Configuration", function()
    UILibrary.SaveConfiguration("myConfig")
    UILibrary.Notify("Configuration Saved", "Your settings have been saved!", 3, "Success")
end)

settingsTab:CreateButton("Load Configuration", function()
    if UILibrary.LoadConfiguration("myConfig") then
        UILibrary.Notify("Configuration Loaded", "Your settings have been loaded!", 3, "Success")
    else
        UILibrary.Notify("Load Failed", "No saved configuration found!", 3, "Error")
    end
end)

-- Testing Tab Components
testTab:CreateSection("Notifications")

testTab:CreateButton("Info Notification", function()
    UILibrary.Notify("Information", "This is an info notification", 3, "Info")
end)

testTab:CreateButton("Success Notification", function()
    UILibrary.Notify("Success", "Operation completed successfully!", 3, "Success")
end)

testTab:CreateButton("Warning Notification", function()
    UILibrary.Notify("Warning", "This is a warning message", 3, "Warning")
end)

testTab:CreateButton("Error Notification", function()
    UILibrary.Notify("Error", "Something went wrong!", 3, "Error")
end)

testTab:CreateSection("Theme Testing")

testTab:CreateButton("Dark Theme", function()
    UILibrary.ChangeTheme({
        Primary = Color3.fromRGB(30, 30, 30),
        Secondary = Color3.fromRGB(40, 40, 40),
        Background = Color3.fromRGB(20, 20, 20),
        Accent = Color3.fromRGB(0, 162, 255)
    })
end)

testTab:CreateButton("Light Theme", function()
    UILibrary.ChangeTheme({
        Primary = Color3.fromRGB(240, 240, 240),
        Secondary = Color3.fromRGB(220, 220, 220),
        Background = Color3.fromRGB(200, 200, 200),
        Text = Color3.fromRGB(50, 50, 50),
        TextDark = Color3.fromRGB(100, 100, 100),
        Accent = Color3.fromRGB(0, 120, 215)
    })
end)

testTab:CreateButton("Purple Theme", function()
    UILibrary.ChangeTheme({
        Primary = Color3.fromRGB(40, 30, 50),
        Secondary = Color3.fromRGB(50, 40, 60),
        Background = Color3.fromRGB(30, 20, 40),
        Accent = Color3.fromRGB(138, 43, 226)
    })
end)

testTab:CreateSection("Information")

testTab:CreateLabel("This is a simple label component")
testTab:CreateParagraph("This is a paragraph component that can contain longer text. It supports text wrapping and can be used to display detailed information or instructions to the user.")

-- Demonstrate some advanced features
print("UI Library loaded successfully!")
print("Available functions:")
print("- UILibrary.Notify(title, message, duration, type)")
print("- UILibrary.ChangeTheme(themeTable)")
print("- UILibrary.SaveConfiguration(name)")
print("- UILibrary.LoadConfiguration(name)")

-- Example of binding system (if you have parts in workspace)
--[[
local part = workspace:FindFirstChild("TestPart")
if part then
    local bindId = UILibrary.BindFrame(window.Frame, part)
    print("Bound window to part with ID:", bindId)
end
]]

-- Start the orientation update loop for bound frames
game:GetService("RunService").Heartbeat:Connect(function()
    UILibrary.UpdateOrientation()
end)