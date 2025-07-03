# Roblox UI Library

A comprehensive, modern UI library for Roblox with advanced features and customization options.

## Features

### Core Features
- **Theme System**: Fully customizable color themes with real-time updates
- **Draggable Windows**: Smooth dragging functionality for all windows
- **Configuration System**: Save and load UI configurations
- **Notification System**: Beautiful notifications with different types
- **Keybind System**: Customizable keybinds with conflict detection
- **Binding System**: Bind UI elements to 3D parts in the workspace

### Components
- **Windows**: Main container with minimize/maximize functionality
- **Tabs**: Organized content sections
- **Buttons**: Interactive buttons with hover effects
- **Toggles**: Smooth animated toggle switches
- **Sliders**: Precise value selection with visual feedback
- **Input Fields**: Text input with placeholder support
- **Dropdowns**: Expandable option selection
- **Color Pickers**: Color selection interface
- **Keybind Selectors**: Key binding configuration
- **Labels & Paragraphs**: Text display components
- **Sections**: Content organization dividers

### Utility Functions
- **Color Management**: Pack/unpack color values for storage
- **UID Generation**: Unique identifier creation
- **Drawing Functions**: Triangle and quad drawing utilities
- **Theme Management**: Dynamic theme switching
- **Data Validation**: NaN checking and value validation

## Usage

### Basic Setup
```lua
local UILibrary = require(path.to.UILibrary)

-- Create a window
local window = UILibrary.CreateWindow("My Application", UDim2.new(0, 500, 0, 400))

-- Create a tab
local mainTab = window:CreateTab("Main")
```

### Adding Components
```lua
-- Button
mainTab:CreateButton("Click Me", function()
    print("Button clicked!")
end)

-- Toggle
local toggle = mainTab:CreateToggle("Enable Feature", false, function(value)
    print("Toggle:", value)
end)

-- Slider
local slider = mainTab:CreateSlider("Volume", 0, 100, 50, function(value)
    print("Volume:", value)
end)

-- Input
local input = mainTab:CreateInput("Username", "Enter name...", function(value)
    print("Username:", value)
end)

-- Dropdown
local dropdown = mainTab:CreateDropdown("Mode", {"Option 1", "Option 2"}, "Option 1", function(value)
    print("Selected:", value)
end)
```

### Theme Customization
```lua
UILibrary.ChangeTheme({
    Primary = Color3.fromRGB(30, 30, 30),
    Secondary = Color3.fromRGB(40, 40, 40),
    Accent = Color3.fromRGB(0, 162, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Success = Color3.fromRGB(46, 204, 113),
    Warning = Color3.fromRGB(241, 196, 15),
    Error = Color3.fromRGB(231, 76, 60)
})
```

### Notifications
```lua
UILibrary.Notify("Title", "Message", 3, "Success") -- Success notification
UILibrary.Notify("Warning", "Be careful!", 5, "Warning") -- Warning notification
UILibrary.Notify("Error", "Something failed!", 3, "Error") -- Error notification
```

### Configuration Management
```lua
-- Save current configuration
UILibrary.SaveConfiguration("myConfig")

-- Load saved configuration
UILibrary.LoadConfiguration("myConfig")
```

### Window Management
```lua
-- Hide/show window
window:Hide()
window:Unhide()

-- Minimize/maximize
window:Minimise()
window:Maximise()

-- Destroy window
window:Destroy()
```

### Binding System
```lua
-- Bind UI to 3D part
local part = workspace.SomePart
local bindId = UILibrary.BindFrame(window.Frame, part)

-- Update orientations (call in heartbeat)
game:GetService("RunService").Heartbeat:Connect(function()
    UILibrary.UpdateOrientation()
end)

-- Check if binding exists
if UILibrary.HasBinding(bindId) then
    print("Binding active")
end

-- Remove binding
UILibrary.UnbindFrame(bindId)
```

## File Structure

- `UILibrary.lua` - Main library with core functionality
- `UIComponents.lua` - Basic UI components (Button, Toggle, Slider, etc.)
- `AdvancedComponents.lua` - Advanced components (ColorPicker, Dropdown, etc.)
- `Example.lua` - Complete usage example

## API Reference

### Core Functions
- `UILibrary.CreateWindow(title, size)` - Create a new window
- `UILibrary.ChangeTheme(themeTable)` - Update the theme
- `UILibrary.Notify(title, message, duration, type)` - Show notification
- `UILibrary.SaveConfiguration(name)` - Save current config
- `UILibrary.LoadConfiguration(name)` - Load saved config

### Utility Functions
- `UILibrary.PackColor(color)` - Convert Color3 to table
- `UILibrary.UnpackColor(packedColor)` - Convert table to Color3
- `UILibrary.GenUid()` - Generate unique identifier
- `UILibrary.IsNotNaN(value)` - Check if value is not NaN
- `UILibrary.AddDraggingFunctionality(frame, handle)` - Add drag support

### Component Creation
All components are created through tab methods:
- `tab:CreateButton(name, callback)`
- `tab:CreateToggle(name, default, callback)`
- `tab:CreateSlider(name, min, max, default, callback)`
- `tab:CreateInput(name, placeholder, callback)`
- `tab:CreateDropdown(name, options, default, callback)`
- `tab:CreateColorPicker(name, default, callback)`
- `tab:CreateKeybind(name, default, callback)`
- `tab:CreateSection(name)`
- `tab:CreateLabel(text)`
- `tab:CreateParagraph(text)`

## License

This library is provided as-is for educational and development purposes. Feel free to modify and use in your Roblox projects.