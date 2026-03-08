-- WindUI Boreal fork (yes i forked a forked version of windui)
local a = {
    cache = {},
    instances = {},
   protection = {}
}

do
    -- Anti-detection system
    local function getSecureParent()
        local success, parent = pcall(function()
            -- Try CoreGui first (harder to detect)
            local coreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
            if coreGui and not game:GetService("RunService"):IsStudio() then
                return coreGui
            end
        end)
        
        if success and parent then
            return parent
        end
        
        -- Fallback to PlayerGui
        local playerGui = game:GetService("Players").LocalPlayer and 
                         game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            return playerGui
        end
        
        -- Ultimate fallback
        return game:GetService("CoreGui")
    end

    -- Instance cloaking system
    local function cloakInstance(instance)
        if not instance then return instance end
        
        -- Remove from explorer if possible
        pcall(function()
            if syn and syn.protect_gui then
                syn.protect_gui(instance)
            end
            if gethui and not game:GetService("RunService"):IsStudio() then
                instance.Parent = gethui()
            end
        end)
        
        -- Randomize names
        local function randomName()
            local length = math.random(8, 16)
            local chars = {}
            for i = 1, length do
                chars[i] = string.char(math.random(97, 122))
            end
            return table.concat(chars)
        end
        
        instance.Name = randomName()
        
        return instance
    end

    -- Advanced cloaking for ScreenGuis
    local function createCloakedScreenGui(name)
        local parent = getSecureParent()
        local gui = Instance.new("ScreenGui")
        gui.Name = name or "UI"
        gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 999999
        
        -- Cloak the GUI
        cloakInstance(gui)
        gui.Parent = parent
        
        -- Add anti-detection measures
        if not game:GetService("RunService"):IsStudio() then
            -- Random screen insets to avoid pattern detection
            local insets = {"None", "Fullscreen", "CoreUI"}
            gui.ScreenInsets = Enum.ScreenInsets[insets[math.random(#insets)]]
            
            -- Periodic parent shuffling (less frequent)
            task.spawn(function()
                while gui and gui.Parent do
                    task.wait(math.random(300, 600))
                    if gui and not game:GetService("RunService"):IsStudio() then
                        local newParent = getSecureParent()
                        if newParent ~= gui.Parent then
                            gui.Parent = newParent
                        end
                    end
                end
            end)
        end
        
        return gui
    end

    -- Main UI initialization with protection
    local function init()
        local ui = {}
        
        -- Create protected GUIs
        ui.ScreenGui = createCloakedScreenGui("WindUI")
        ui.NotificationGui = createCloakedScreenGui("Notifications")
        ui.DropdownGui = createCloakedScreenGui("Dropdowns")
        ui.TooltipGui = createCloakedScreenGui("Tooltips")
        
        -- Create folders for organization
        local function createSecureFolder(parent, name)
            local folder = Instance.new("Folder")
            folder.Name = name
            cloakInstance(folder)
            folder.Parent = parent
            return folder
        end
        
        ui.WindowFolder = createSecureFolder(ui.ScreenGui, "Window")
        ui.KeySystemFolder = createSecureFolder(ui.ScreenGui, "KeySystem")
        ui.PopupsFolder = createSecureFolder(ui.ScreenGui, "Popups")
        
        return ui
    end

    a.protection = {
        getSecureParent = getSecureParent,
        cloakInstance = cloakInstance,
        createCloakedScreenGui = createCloakedScreenGui,
        init = init
    }
end

-- Visual enhancement module
do
    local visualEffects = {}
    
    -- Modern blur effect
    function visualEffects.createBlur(radius, parent)
        local blur = Instance.new("BlurEffect")
        blur.Name = "UIBlur"
        blur.Size = radius or 24
        blur.Enabled = true
        
        pcall(function()
            blur.Parent = parent or game:GetService("Lighting")
        end)
        
        return blur
    end
    
    -- Gradient backgrounds
    function visualEffects.createGradient(direction, colors)
        local gradient = Instance.new("UIGradient")
        local colorSeq = {}
        
        for i, colorData in ipairs(colors) do
            local pos = (i - 1) / (#colors - 1)
            table.insert(colorSeq, ColorSequenceKeypoint.new(pos, colorData.color or Color3.new(1,1,1)))
        end
        
        gradient.Color = ColorSequence.new(colorSeq)
        gradient.Rotation = direction or 45
        
        return gradient
    end
    
    -- Neon glow effect
    function visualEffects.createGlow(size, color, transparency)
        local glow = Instance.new("ImageLabel")
        glow.Name = "Glow"
        glow.Size = UDim2.new(1, size or 20, 1, size or 20)
        glow.Position = UDim2.new(0.5, 0, 0.5, 0)
        glow.AnchorPoint = Vector2.new(0.5, 0.5)
        glow.BackgroundTransparency = 1
        glow.Image = "rbxassetid://3570695787" -- Glow texture
        glow.ImageColor3 = color or Color3.new(1,1,1)
        glow.ImageTransparency = transparency or 0.5
        glow.ZIndex = -1
        
        return glow
    end
    
    -- Animated border
    function visualEffects.createAnimatedBorder(size, color, speed)
        local border = Instance.new("Frame")
        border.Size = UDim2.new(1, size or 2, 1, size or 2)
        border.Position = UDim2.new(0, 0, 0, 0)
        border.BackgroundTransparency = 1
        
        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, color or Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(0.5, Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(1, color or Color3.new(1,1,1))
        })
        gradient.Rotation = 0
        gradient.Parent = border
        
        -- Animate rotation
        task.spawn(function()
            local rot = 0
            while border and border.Parent do
                rot = (rot + (speed or 50) * task.wait()) % 360
                gradient.Rotation = rot
            end
        end)
        
        return border
    end
    
    -- Modern shadow with variable intensity
    function visualEffects.createShadow(intensity, blurSize)
        local shadow = Instance.new("ImageLabel")
        shadow.Name = "Shadow"
        shadow.Size = UDim2.new(1, blurSize or 20, 1, blurSize or 20)
        shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
        shadow.AnchorPoint = Vector2.new(0.5, 0.5)
        shadow.BackgroundTransparency = 1
        shadow.Image = "rbxassetid://13110644290" -- Soft shadow texture
        shadow.ImageColor3 = Color3.new(0, 0, 0)
        shadow.ImageTransparency = 1 - (intensity or 0.5)
        shadow.ZIndex = -2
        
        return shadow
    end
    
    a.visualEffects = visualEffects
end

-- Rest of the original code with improvements...
-- (Keep the existing functions but modify the creation methods to use protection)

-- Override the original New function to include cloaking
local originalNew = a.c and a.c().New
if originalNew then
    a.c().New = function(className, properties, children)
        local instance = originalNew(className, properties, children)
        if instance and instance:IsA("GuiObject") then
            a.protection.cloakInstance(instance)
        end
        return instance
    end
end

-- Override ScreenGui creation
local originalCreateScreenGui = a.protection and a.protection.createCloakedScreenGui
if originalCreateScreenGui then
    a.protection.createCloakedScreenGui = function(name)
        local gui = originalCreateScreenGui(name)
        
        -- Add visual enhancements
        if gui then
            -- Add subtle blur to the entire GUI if in CoreGui
            pcall(function()
                if gui.Parent == game:GetService("CoreGui") then
                    local blur = a.visualEffects.createBlur(8, game:GetService("Lighting"))
                    gui:SetAttribute("BlurEffect", blur)
                end
            end)
        end
        
        return gui
    end
end

-- Initialize the protected UI
local protectedUI = a.protection.init()
a.ScreenGui = protectedUI.ScreenGui
a.NotificationGui = protectedUI.NotificationGui
a.DropdownGui = protectedUI.DropdownGui
a.TooltipGui = protectedUI.TooltipGui

-- Rest of the original initialization
local am = a.c().New
local ao = a.c().Tween

-- Initialize acrylic effects
local ap = a.r()

-- Protect GUI functions
local aq = protectgui or (syn and syn.protect_gui) or function() end
local ar = gethui and gethui() or game:GetService("CoreGui")

-- Apply protection to all GUIs
aq(a.ScreenGui)
aq(a.NotificationGui)
aq(a.DropdownGui)
aq(a.TooltipGui)

-- Enhanced UIScale with smooth animation
local as = am("UIScale", {
    Scale = 1,
})

-- Add smooth scale transitions
function a.setScale(newScale, duration)
    duration = duration or 0.3
    local tween = ao(as, duration, {Scale = newScale}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    tween:Play()
    a.UIScale = newScale
    return tween
end

a.UIScaleObj = as

-- Modern theme with enhanced colors
a.Themes = a.t()(a)
a.Themes.Dark = {
    Name = "Dark Enhanced",
    Accent = Color3.fromHex("#7C3AED"), -- Purple accent
    AccentSecondary = Color3.fromHex("#EC4899"), -- Pink secondary
    Background = Color3.fromHex("#0F0F13"),
    Surface = Color3.fromHex("#1A1B1E"),
    SurfaceLight = Color3.fromHex("#2C2D32"),
    Text = Color3.fromHex("#FFFFFF"),
    TextSecondary = Color3.fromHex("#A0A0A8"),
    TextMuted = Color3.fromHex("#6B6B73"),
    Border = Color3.fromHex("#2E2F34"),
    Success = Color3.fromHex("#10B981"),
    Warning = Color3.fromHex("#F59E0B"),
    Error = Color3.fromHex("#EF4444"),
    Info = Color3.fromHex("#3B82F6"),
}

-- Initialize with enhanced theme
a:SetTheme("Dark Enhanced")

-- Enhanced notification system with animations
local at = a.NotificationModule.Init(a.NotificationGui)

function a.Notify(config)
    config = config or {}
    config.Holder = at.Frame
    config.Window = a.Window
    
    -- Add visual enhancements
    if not config.Icon and config.Type then
        local icons = {
            success = "check-circle",
            error = "x-circle",
            warning = "alert-triangle",
            info = "info"
        }
        config.Icon = icons[config.Type] or config.Icon
    end
    
    if not config.Duration and config.Duration ~= false then
        config.Duration = 5
    end
    
    return a.NotificationModule.New(config)
end

-- Return the enhanced UI library
return a
