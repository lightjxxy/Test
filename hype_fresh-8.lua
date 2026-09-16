local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/StyearX/Script/refs/heads/main/Phantomwrym/Fluent-modded/Main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/StyearX/Script/refs/heads/main/Phantomwrym/Fluent-modded/SaveManager.lua"))()
local FBM = loadstring(game:HttpGet("https://raw.githubusercontent.com/StyearX/Script/refs/heads/main/Phantomwrym/Fluent-modded/FloatingButtonManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/StyearX/Script/refs/heads/main/Phantomwrym/Fluent-modded/InterfaceManager.lua"))()

if not Fluent or not SaveManager or not InterfaceManager or not FBM then return game.Players.LocalPlayer:Kick("Error: Interface didn't load") end

if _G.PhantomWyrmXIsAlreadyRunning then
   game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Script is already running!",
        Text = ""
    })
   return
end

_G.PhantomWyrmXIsAlreadyRunning = true

local Window = Fluent:CreateWindow({
    Title = "Hyperion X Hub - Evade Overhaul│Mobile",
    SubTitle = "Made By Lucaswyrm, Stincer and L1ght",
    TabWidth = 160,
    Size = UDim2.fromOffset(540, 390),
    Acrylic = false,
    Theme = "Darker",
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "rbxassetid://7733960981" }),
    AutoFarm = Window:AddTab({ Title = "Auto Farm", Icon = "rbxassetid://10709811110" }),
    Nextbots = Window:AddTab({ Title = "Anti Nextbots", Icon = "shield" }),
    Misc = Window:AddTab({ Title = "Movement", Icon = "rbxassetid://7734068321" }),
    Exploits = Window:AddTab({ Title = "Exploits", Icon = "bomb" }),
    Visual = Window:AddTab({ Title = "Visuals", Icon = "rbxassetid://10709819149" }),
    Info = Window:AddTab({ Title = "Info", Icon = "rbxassetid://10723415903" }),
    Settings = Window:AddTab({ Title = "Configuration", Icon = "rbxassetid://7734052335" }),
    Extension = Window:AddTab({ Title = "Extension", Icon = "rbxassetid://10734930886" }),
}

local Options = Fluent.Options

-- Services

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService('Lighting')
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local CAS = game:GetService("ContextActionService")

-- Optimize (1)

local function GetAutoDuration()
    local dt = RunService.RenderStepped:Wait()
    local fps = 1 / dt

    local duration = 60 / math.clamp(fps, 5, 60)
    return math.clamp(duration, 1, 6)
end

local Duration = GetAutoDuration()

-- Toggle Gui
local openshit = Instance.new("ScreenGui")
openshit.Name = "openshit"
openshit.Parent = game.CoreGui
openshit.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
openshit.ResetOnSpawn = false
openshit.DisplayOrder = 999
openshit.IgnoreGuiInset = true

local mainopen = Instance.new("TextButton")
mainopen.Name = "mainopen"
mainopen.Parent = openshit
mainopen.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainopen.BackgroundTransparency = 1
mainopen.Position = UDim2.new(0.101969875, 0, 0.110441767, 0)
mainopen.Size = UDim2.new(0, 64, 0, 42)
mainopen.Text = ""
mainopen.Visible = true

local mainopens = Instance.new("UICorner")
mainopens.Parent = mainopen

local SizeBackMulti = 0.1
local AssetsIcon = "rbxassetid://101872304462176"
local AssetsBackground = "rbxassetid://6031068421"

-- === ROTATING BACKGROUND IMAGE 
local backgroundImage = Instance.new("ImageLabel")
backgroundImage.Name = "RotatingBackground"
backgroundImage.Parent = mainopen
backgroundImage.Size = UDim2.new(1.8 + SizeBackMulti, 0, 1.8 + SizeBackMulti, 0)
backgroundImage.Position = UDim2.new(0.5, 0, 0.5, 0)
backgroundImage.AnchorPoint = Vector2.new(0.5, 0.5)
backgroundImage.BackgroundTransparency = 1
backgroundImage.Image = AssetsBackground
backgroundImage.SizeConstraint = Enum.SizeConstraint.RelativeXX
backgroundImage.ZIndex = 0

-- === STATIC FRONT IMAGE ===

local WIDTH = 0.85
local HEIGHT = 1
-- ====================================================

local frontImage = Instance.new("ImageLabel")
frontImage.Name = "StaticIcon"
frontImage.Parent = mainopen

frontImage.Size = UDim2.new(WIDTH, 0, HEIGHT, 0)
frontImage.Position = UDim2.new(0.5, 0, 0.5, 0)
frontImage.AnchorPoint = Vector2.new(0.5, 0.5)
frontImage.BackgroundTransparency = 1
frontImage.Image = AssetsIcon
frontImage.ZIndex = 1

frontImage.ScaleType = Enum.ScaleType.Stretch

local frontCorner = Instance.new("UICorner")
frontCorner.CornerRadius = UDim.new(1, 0)
frontCorner.Parent = frontImage

-- === ROTATION LOOP ===
local rotation = 0
local speed = 90 
local lastTime = tick()

task.spawn(function()
	while true do
		local now = tick()
		local delta = now - lastTime
		lastTime = now
		
		rotation = (rotation + speed * delta) % 360
		backgroundImage.Rotation = rotation

		task.wait()
	end
end)

local function MakeDraggable(topbarobject, object, locked)
    local Dragging = false
    local DragInput
    local DragStart
    local StartPosition

    local Holding = false
    local HoldTime = 1.0
    local MoveCancelThreshold = 6
    local HoldToken = 0

    object:SetAttribute("Locked", locked or false)

    local function Update(input)
        if object:GetAttribute("Locked") then return end
        local delta = input.Position - DragStart
        object.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + delta.Y
        )
    end

    local function ToggleLock()
        local newState = not object:GetAttribute("Locked")
        object:SetAttribute("Locked", newState)

        Fluent:Notify({
            Title = newState and "Button Locked" or "Button Unlocked",
            Content = newState and "This button is now locked in place." or "This button can now be moved.",
            Duration = 2
        })
    end

    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        Dragging = not object:GetAttribute("Locked")
        Holding = true
        DragStart = input.Position
        StartPosition = object.Position

        HoldToken += 1
        local token = HoldToken

        task.delay(HoldTime, function()
            if Holding and token == HoldToken then
                ToggleLock()
            end
        end)

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Dragging = false
                Holding = false
            end
        end)
    end)

    topbarobject.InputChanged:Connect(function(input)
        if not DragStart then return end

        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            if (input.Position - DragStart).Magnitude > MoveCancelThreshold then
                Holding = false
            end
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            Update(input)
        end
    end)
end

MakeDraggable(mainopen, mainopen, false)

local function playSound(soundId)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. soundId
    sound.Parent = game:GetService("SoundService")
    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

mainopen.MouseButton1Click:Connect(function()
local sounds = { "7127123605", "137566474343039", "438666542", "257001341", "257000833", "7127123554", "131607746976396", "97325669841459", "109312518223078" }
    playSound(sounds[math.random(#sounds)])
    Window:Minimize()

    local function smoothSpeed(target, duration)
        local start = speed
        local steps = 30
        for i = 1, steps do
            speed = start + (target - start) * (i / steps)
            task.wait(duration / steps)
        end
        speed = target
    end
    
    smoothSpeed(360, 0.4)
    task.wait(0.5)
    smoothSpeed(180, 0.4)
    task.wait(0.3)
    smoothSpeed(90, 0.4)
end)

-- Button Gradients
if not getgenv().ButtonGradients then
    getgenv().ButtonGradients = {
        Background = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(20,  20,  40)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40,  10,  80)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(10,  30,  60)),
        }),
        Stroke = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(120, 60,  220)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(60,  140, 255)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(120, 60,  220)),
        }),
    }
end

-- FPS Counter

local Stats = game:GetService("Stats")
local RunService = game:GetService("RunService")

local startTime = tick()
local FPS_Data = {
    GUI = nil,
    Connection = nil
}

local function ToggleFPSCounter(state)
    if not state then
        if FPS_Data.GUI then
            FPS_Data.GUI:Destroy()
            FPS_Data.GUI = nil
        end
        if FPS_Data.Connection then
            FPS_Data.Connection:Disconnect()
            FPS_Data.Connection = nil
        end
        return
    end

    if state and not FPS_Data.GUI then
        local fpsCounter = Instance.new("ScreenGui")
        fpsCounter.Name = "FPSCounter"
        fpsCounter.Parent = game.CoreGui
        fpsCounter.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        fpsCounter.ResetOnSpawn = false
        FPS_Data.GUI = fpsCounter

        local frame = Instance.new("Frame")
        frame.Parent = fpsCounter
        frame.Size = UDim2.new(0, 180, 0, 80)
        frame.Position = UDim2.new(0, 300, 0, 10)
        frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        frame.BackgroundTransparency = 0.7

        local corner = Instance.new("UICorner", frame)
        corner.CornerRadius = UDim.new(0, 15)

        local gradient = Instance.new("UIGradient", frame)
        gradient.Color = getgenv().ButtonGradients.Background

        local uiStroke = Instance.new("UIStroke", frame)
        uiStroke.Thickness = 2
        uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local gradientstroke = Instance.new("UIGradient", uiStroke)
        gradientstroke.Color = getgenv().ButtonGradients.Stroke

    
        task.spawn(function()
            while fpsCounter and fpsCounter.Parent do
                gradient.Rotation = (gradient.Rotation + 1) % 360
                gradient.Color = getgenv().ButtonGradients.Background 
                task.wait(0.03)
            end
        end)

        task.spawn(function()
            while fpsCounter and fpsCounter.Parent do
                gradientstroke.Rotation = (gradientstroke.Rotation + 0.5) % 360
                gradientstroke.Color = getgenv().ButtonGradients.Stroke
                task.wait()
            end
        end)

        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1, -10, 1, -10)
        label.Position = UDim2.new(0, 5, 0, 5)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.GothamBlack
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.TextYAlignment = Enum.TextYAlignment.Center
        label.Text = "Loading..."

        if typeof(MakeDraggable) == "function" then
            MakeDraggable(frame, frame, false)
        end

        local lastUpdateTime = tick()
        local frameCount = 0

        FPS_Data.Connection = RunService.RenderStepped:Connect(function()
            frameCount = frameCount + 1
            local now = tick()
            local dt = now - lastUpdateTime

            if dt >= 1 then
                local fps = math.round(frameCount / dt)
                local elapsed = now - startTime
                local h = math.floor(elapsed / 3600)
                local m = math.floor((elapsed % 3600) / 60)
                local s = math.floor(elapsed % 60)
                
                local ping = 0
                pcall(function()
                    ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                end)

                label.Text = string.format("FPS: %d | Ping: %d ms\nClient Timer: %dh %dm %ds", fps, ping, h, m, s)
                lastUpdateTime = now
                frameCount = 0
            end
        end)
    end
end

ToggleFPSCounter(true)


-- UNC Requirements (soft checks - hub loads regardless)

if not require then
    warn("Hyperion X Hub: require() not supported - some features may not work")
else
    print("Supported require()")
end

if not firetouchinterest then
    warn("Hyperion X Hub: firetouchinterest() not supported - some features may not work")
else
    print("Supported firetouchinterest()")
end

if not setfpscap then
    warn("Hyperion X Hub: setfpscap() not supported - FPS unlock may not work")
else
    setfpscap(500)
    print("Supported setfpscap()")
end

if game.Players then
   print("Advance Api")
else
   print("Common Api")
end


-- ============================================================
-- MAIN TAB LOGIC & FUNCTIONS
-- ============================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Config

local DConfiguration = {
    Main = {
        AntiAFK      = true,
        AutoRespawn  = false,
        RespawnType  = "Spawnpoint",
        AutoWhistle  = false,
        ShowTimer    = false,
        Fly          = false,
        FlySpeed     = 20,
        Noclip       = false,
    },
    Settings = {
        GuiScale = {
            Respawn = 0,
            Fly     = 0,
        },
    },
}

local Options = Fluent.Options

-- DFunctions

local DFunctions = {}

function DFunctions.AutoRespawn()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if char and char:GetAttribute("Downed") == true and DConfiguration.Main.RespawnType == "Spawnpoint" then
        game:GetService("ReplicatedStorage").Events.Player.ChangePlayerMode:FireServer(true)
    elseif char and char:GetAttribute("Downed") == true and DConfiguration.Main.RespawnType == "Fake Revive" then
        local PreviousPosition = LocalPlayer.Character.HumanoidRootPart.Position
        wait(0.2)
        game:GetService("ReplicatedStorage").Events.Player.ChangePlayerMode:FireServer(true)
        wait(1)
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(PreviousPosition)
    end
end

function DFunctions.Whistle()
    game:GetService("ReplicatedStorage").Events.Character.Whistle:FireServer()
end

function DFunctions.CreateTimer()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = LocalPlayer.PlayerGui
    screenGui.ResetOnSpawn = false
    screenGui.Name = "TimerGui"
    local timerLabel = Instance.new("TextLabel")
    timerLabel.Parent = screenGui
    timerLabel.Size = UDim2.new(0, 200, 0, 50)
    timerLabel.Position = UDim2.new(0.5, -100, 0.1, 0)
    timerLabel.BackgroundTransparency = 1
    timerLabel.TextScaled = true
    timerLabel.Font = Enum.Font.SourceSans
    timerLabel.TextColor3 = Color3.new(1, 1, 1)
end

function DFunctions.RemoveTimer()
    if LocalPlayer.PlayerGui:FindFirstChild("TimerGui") then
        LocalPlayer.PlayerGui.TimerGui:Destroy()
    end
end

function DFunctions.Noclip()
    pcall(function()
        for i, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") and v:IsA("MeshPart") then
                v.CanCollide = false
            end
        end
    end)
end

function DFunctions.CreateButton(ButtonName, Name, Size1, Size2, ScriptLogic, CircleMode)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = ButtonName
    screenGui.Parent = LocalPlayer.PlayerGui
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = -2147483648
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = false

    local frame = Instance.new("Frame")
    frame.Name = ButtonName
    frame.Size = UDim2.new(Size1, 0, Size2, 0)
    frame.Position = UDim2.new(0.5 - Size1 / 2, 0, 0.5 - Size2 / 2, 0)
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame.BackgroundTransparency = 0.7
    frame.ZIndex = -10
    frame.Parent = screenGui

    local gradient = Instance.new("UIGradient")
    gradient.Color = getgenv().ButtonGradients.Background
    gradient.Parent = frame

    task.spawn(function()
        while task.wait(0.03) do
            if not frame.Parent then break end
            gradient.Rotation = (gradient.Rotation + 1) % 360
            gradient.Color = getgenv().ButtonGradients.Background
        end
    end)

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Parent = frame

    local gradientstroke = Instance.new("UIGradient")
    gradientstroke.Color = getgenv().ButtonGradients.Stroke
    gradientstroke.Rotation = 0
    gradientstroke.Parent = stroke

    task.spawn(function()
        while frame.Parent do
            gradientstroke.Rotation = (gradientstroke.Rotation + 0.5) % 360
            gradientstroke.Color = getgenv().ButtonGradients.Stroke
            task.wait()
        end
    end)

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = Name
    button.Font = Enum.Font.SourceSansBold
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 24
    button.TextScaled = false
    button.ZIndex = -9
    button.Parent = frame

    local originalSize = UDim2.new(Size1, 0, Size2, 0)
    local isCircle = CircleMode ~= nil and CircleMode or false
    frame:SetAttribute("IsCircle", isCircle)

    MakeDraggable(button, frame, false)

    button.Activated:Connect(function()
        if ScriptLogic then ScriptLogic(button) end
    end)

    return button
end

function DFunctions.UpdateButton(Name, Size1, Size2)
    local gui = LocalPlayer.PlayerGui:FindFirstChild(Name)
    if gui then
        local frame = gui:FindFirstChild(Name)
        if frame then
            frame.Size = UDim2.new(Size1, 0, Size2, 0)
        end
    end
end

function DFunctions.DestroyButton(Name)
    local gui = LocalPlayer.PlayerGui:FindFirstChild(Name)
    if gui then gui:Destroy() end
end

-- Fly Setup

local LP = LocalPlayer
local RS = RunService

_G.Fly = false
_G.flySpeed = 20

local FLYING = false
local velocityHandlerName = "FlyVelocity"
local gyroHandlerName = "FlyGyro"
local mfly1, mfly2
local controlModule

local function getControlModule()
    if controlModule then return controlModule end
    local playerScripts = LP:FindFirstChild("PlayerScripts")
    local playerModule = playerScripts and playerScripts:FindFirstChild("PlayerModule")
    local CM = playerModule and playerModule:FindFirstChild("ControlModule")
    if CM then
        pcall(function() controlModule = require(CM) end)
        return controlModule
    end
    return nil
end

local function unmobilefly()
    FLYING = false
    local character = LP.Character
    if character then
        local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
        if root then
            local bv = root:FindFirstChild(velocityHandlerName)
            local bg = root:FindFirstChild(gyroHandlerName)
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
        end
    end
    if mfly1 then mfly1:Disconnect() mfly1 = nil end
    if mfly2 then mfly2:Disconnect() mfly2 = nil end
end

local function mobilefly()
    unmobilefly()
    FLYING = true
    local character = LP.Character
    if not character then return end
    local root = character:WaitForChild("HumanoidRootPart", 5) or character:WaitForChild("Torso", 5)
    if not root then return end
    local camera = workspace.CurrentCamera
    local v3zero = Vector3.new(0, 0, 0)
    local v3inf = Vector3.new(9e9, 9e9, 9e9)

    local bv = Instance.new("BodyVelocity")
    bv.Name = velocityHandlerName
    bv.Parent = root
    bv.MaxForce = v3inf
    bv.Velocity = v3zero

    local bg = Instance.new("BodyGyro")
    bg.Name = gyroHandlerName
    bg.Parent = root
    bg.MaxTorque = Vector3.new(9e9, 0, 9e9)
    bg.P = 1000
    bg.D = 50

    mfly1 = LP.CharacterAdded:Connect(function(newChar)
        unmobilefly()
        newChar:WaitForChild("HumanoidRootPart", 5)
        if _G.Fly then mobilefly() end
    end)

    mfly2 = RS.PreRender:Connect(function()
        if not _G.Fly then unmobilefly() return end
        local ch = LP.Character
        local r = ch and (ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("Torso"))
        local VelocityHandler = r and r:FindFirstChild(velocityHandlerName)
        local GyroHandler = r and r:FindFirstChild(gyroHandlerName)
        if r and VelocityHandler and GyroHandler then
            VelocityHandler.MaxForce = v3inf
            local camCFrame = camera.CFrame
            GyroHandler.CFrame = CFrame.new(r.Position) * CFrame.Angles(0, math.atan2(-camCFrame.LookVector.X, -camCFrame.LookVector.Z), 0)
            local moveVector = Vector3.new(0, 0, 0)
            local CM = getControlModule()
            if CM and CM.GetMoveVector then
                moveVector = CM:GetMoveVector()
            end
            if moveVector.X ~= 0 or moveVector.Z ~= 0 then
                local look = camera.CFrame.LookVector
                local right = camera.CFrame.RightVector
                local flyDirection = (right * moveVector.X - look * moveVector.Z).unit
                VelocityHandler.Velocity = flyDirection * (_G.flySpeed * 25)
            else
                VelocityHandler.Velocity = v3zero
            end
        end
    end)
end

local function toggleFly(toggleValue)
    _G.Fly = toggleValue
    if toggleValue then mobilefly() else unmobilefly() end
end

-- ============================================================
-- MAIN TAB UI
-- ============================================================

Tabs.Main:AddSection("Respawn")

local AutoRespawnToggle = Tabs.Main:AddToggle("AutoRespawn", {Title = "Auto Respawn", Default = false})
AutoRespawnToggle:OnChanged(function(value)
    DConfiguration.Main.AutoRespawn = value
    while DConfiguration.Main.AutoRespawn and wait(0.1) do
        spawn(DFunctions.AutoRespawn)
    end
end)

local RespawnButtonToggle = Tabs.Main:AddToggle("RespawnButton", {Title = "Respawn (Button)", Default = false})
RespawnButtonToggle:OnChanged(function(State)
    if State then
        DFunctions.CreateButton("RespawnButton", "Respawn", 0.15 + DConfiguration.Settings.GuiScale.Respawn, 0.1 + DConfiguration.Settings.GuiScale.Respawn, function(btn)
            btn.Text = "Respawning..."
            spawn(DFunctions.AutoRespawn)
            wait(0.1)
            btn.Text = "Respawned!"
            wait(0.2)
            btn.Text = "Respawn"
        end)
    else
        DFunctions.DestroyButton("RespawnButton")
    end
end)

Tabs.Main:AddInput("RespawnButtonSize", {
    Title = "Respawn Button Size",
    Default = "0",
    Placeholder = "0",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value) or 0
        DConfiguration.Settings.GuiScale.Respawn = num * 0.01
        DFunctions.UpdateButton("RespawnButton", 0.15 + DConfiguration.Settings.GuiScale.Respawn, 0.1 + DConfiguration.Settings.GuiScale.Respawn)
    end
})

Tabs.Main:AddButton({
    Title = "Force Respawn",
    Description = "",
    Callback = function()
        game:GetService("ReplicatedStorage").Events.Player.ChangePlayerMode:FireServer(true)
    end
})

local RespawnDropdown = Tabs.Main:AddDropdown("RespawnType", {
    Title = "Respawn Type",
    Values = {"Spawnpoint", "Fake Revive"},
    Multi = false,
    Default = 1,
})
RespawnDropdown:OnChanged(function(value)
    DConfiguration.Main.RespawnType = value
end)

Tabs.Main:AddSection("Utilities")

local AutoWhistleToggle = Tabs.Main:AddToggle("AutoWhistle", {Title = "Auto Whistle", Default = false})
AutoWhistleToggle:OnChanged(function(value)
    DConfiguration.Main.AutoWhistle = value
    while task.wait(1) and DConfiguration.Main.AutoWhistle do
        DFunctions.Whistle()
    end
end)

local AntiAFKToggle = Tabs.Main:AddToggle("AntiAfk", {Title = "Anti-AFK", Default = true})
AntiAFKToggle:OnChanged(function()
    local vu = game:GetService("VirtualUser")
    repeat wait() until game:IsLoaded()
    LocalPlayer.Idled:connect(function()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new())
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end)
Options.AntiAfk:SetValue(true)

local ShowTimerToggle = Tabs.Main:AddToggle("ShowTimer", {Title = "Show Timer", Default = false})
ShowTimerToggle:OnChanged(function(State)
    DConfiguration.Main.ShowTimer = State
    if State then
        if not LocalPlayer.PlayerGui:FindFirstChild("TimerGui") then
            DFunctions.CreateTimer()
        end
        task.spawn(function()
            while DConfiguration.Main.ShowTimer do
                local gui = LocalPlayer.PlayerGui:FindFirstChild("TimerGui")
                local stats = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Stats")
                if gui and stats then
                    local seconds = stats:GetAttribute("Timer") or 0
                    local minutes = math.floor(seconds / 60)
                    local remainingSeconds = seconds % 60
                    gui.TextLabel.Text = string.format("%d:%02d", minutes, remainingSeconds)
                end
                task.wait(0.1)
                if not gui then break end
            end
        end)
    else
        DFunctions.RemoveTimer()
    end
end)

Tabs.Main:AddSection("Movement")

local NoclipToggle = Tabs.Main:AddToggle("Noclip", {Title = "Noclip", Default = false})
NoclipToggle:OnChanged(function(value)
    DConfiguration.Main.Noclip = value
    while DConfiguration.Main.Noclip and wait(0.1) do
        DFunctions.Noclip()
    end
end)
Options.Noclip:SetValue(false)

local FlyButtonToggle = Tabs.Main:AddToggle("FlyButtonToggle", {Title = "Fly (Button)", Default = false})
FlyButtonToggle:OnChanged(function(State)
    if State then
        local currentScale = DConfiguration.Settings.GuiScale.Fly or 0
        DFunctions.CreateButton("FlyButton", "Fly: OFF", 0.15 + currentScale, 0.1 + currentScale, function(btn)
            _G.Fly = not _G.Fly
            toggleFly(_G.Fly)
            btn.Text = _G.Fly and "Fly: ON" or "Fly: OFF"
        end)
    else
        DFunctions.DestroyButton("FlyButton")
        toggleFly(false)
    end
end)

Tabs.Main:AddInput("FlyButtonSize", {
    Title = "Fly Button Size",
    Default = "0",
    Placeholder = "0",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value) or 0
        DConfiguration.Settings.GuiScale.Fly = num * 0.01
        DFunctions.UpdateButton("FlyButton", 0.15 + DConfiguration.Settings.GuiScale.Fly, 0.1 + DConfiguration.Settings.GuiScale.Fly)
    end
})

Tabs.Main:AddInput("FlySpeedInput", {
    Title = "Fly Speed",
    Default = "20",
    Placeholder = "Enter fly speed",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        _G.flySpeed = tonumber(Value) or 20
    end
})


-- ============================================================
-- AUTO FARM TAB LOGIC & FUNCTIONS
-- ============================================================

-- Extend DConfiguration with AutoFarm
DConfiguration.AutoFarm = {
    FarmingStates = {
        IsReviving             = false,
        IsCompletingObjective  = false,
        IsCollectingTickets    = false,
    },
    AFKFarm          = false,
    FarmTickets      = false,
    CompleteObjective = false,
    FarmTokens       = false,
    PurchaseAutomations = {
        Enabled  = false,
        Selected = "Cola",
    },
    VIPAutomations = {
        AutoVote          = false,
        MapSection        = 1,
        GamemodeSection   = 1,
        AutoMap           = false,
        MapInput          = "DesertBus",
        AutoSpecialRound  = false,
        SpecialRoundInput = "Plushie Hell",
        AutoTimer         = false,
        TimerInput        = "",
        AutoProMode       = false,
    },
}

-- Helper functions

function DFunctions.GetDownedPlayer()
    for i, v in pairs(Workspace.Game.Players:GetChildren()) do
        if v:GetAttribute("Downed") then
            return v
        end
    end
end

function DFunctions.GetObjective()
    local ObjectiveFolder = Workspace.Game.Map.Parts:FindFirstChild("Objectives")
    if not ObjectiveFolder then return nil end
    local Parts = {}
    for _, v in ipairs(ObjectiveFolder:GetChildren()) do
        if v:IsA("Model") then
            local part = v:FindFirstChildWhichIsA("BasePart")
            if part then table.insert(Parts, part) end
        end
    end
    if #Parts == 0 then return nil end
    return Parts[math.random(1, #Parts)]
end

local FarmPart

function DFunctions.AFKFarming()
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not FarmPart then
        FarmPart = Instance.new("Part")
        FarmPart.Size = Vector3.new(10, 1, 10)
        FarmPart.Anchored = true
        FarmPart.CanCollide = true
        FarmPart.Name = "AFKFarmPad"
        FarmPart.CFrame = CFrame.new(0, hrp.Position.Y + 10000, 0)
        FarmPart.Parent = workspace
    end
    hrp.CFrame = FarmPart.CFrame + Vector3.new(0, 3, 0)
end

function DFunctions.RevivePlayer()
    local downedplr = DFunctions.GetDownedPlayer()
    DConfiguration.AutoFarm.FarmingStates.IsReviving = false
    if downedplr and downedplr:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetHrp = downedplr:FindFirstChild("HumanoidRootPart")
        if hrp and targetHrp then
            hrp.CFrame = CFrame.new(targetHrp.Position + Vector3.new(0, 2, 0))
            local Interact = ReplicatedStorage.Events.Character.Interact
            Interact:FireServer("Revive", true, tostring(downedplr))
            Interact:FireServer("Revive", true, tostring(downedplr))
            Interact:FireServer("Revive", true, tostring(downedplr))
            DConfiguration.AutoFarm.FarmingStates.IsReviving = true
        end
    end
    if not DConfiguration.AutoFarm.FarmingStates.IsReviving then
        DFunctions.AFKFarming()
    end
end

function DFunctions.PointFarming()
    local Objective = DFunctions.GetObjective()
    DConfiguration.AutoFarm.FarmingStates.IsCompletingObjective = false
    if Objective then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(Objective.Position)
            LocalPlayer.PlayerScripts.Events.temporary_events.UseKeybind:Fire({Down = true, Key = "Interact"})
            DConfiguration.AutoFarm.FarmingStates.IsCompletingObjective = true
        end
    end
end

function DFunctions.TicketsFarming()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    DConfiguration.AutoFarm.FarmingStates.IsCollectingTickets = false
    for _, v in ipairs(Workspace.Game.Effects.Tickets:GetDescendants()) do
        if v:IsA("BasePart") and v.Name == "HumanoidRootPart" then
            hrp.CFrame = CFrame.new(v.Position)
            DConfiguration.AutoFarm.FarmingStates.IsCollectingTickets = true
            return
        end
    end
    DFunctions.AFKFarming()
end

function DFunctions.AutoVote(section1, section2)
    if section1 then ReplicatedStorage.Events.Player.Vote:FireServer(section1) end
    if section2 then ReplicatedStorage.Events.Player.Vote:FireServer(section1, true) end
end

function DFunctions.SetVIPCommands(map, specialround)
    local VIPCommand = ReplicatedStorage.Events.Admin.VIPCommand
    if typeof(map) == "string" and map ~= "" then
        VIPCommand:InvokeServer("!map " .. map)
    end
    if typeof(specialround) == "string" and specialround ~= "" then
        VIPCommand:InvokeServer("!specialround " .. specialround)
    end
end

function DFunctions.BuyItem(Name, Type)
    local Purchase = ReplicatedStorage.Events.Data.Purchase
    local Folder = ReplicatedStorage.Items[Type][Name]
    local ID = Folder:GetAttribute("ID")
    Purchase:InvokeServer(ID)
end

-- ============================================================
-- AUTO FARM TAB UI
-- ============================================================

Tabs.AutoFarm:AddSection("Farmings")

local FarmMoneyToggle = Tabs.AutoFarm:AddToggle("AutoFarmMoney", {Title = "Auto Farm Money", Default = false})
FarmMoneyToggle:OnChanged(function(State)
    DConfiguration.AutoFarm.FarmTokens = State
    while DConfiguration.AutoFarm.FarmTokens and wait(-2) do
        spawn(DFunctions.RevivePlayer)
    end
end)

local FarmTicketsToggle = Tabs.AutoFarm:AddToggle("AutoFarmTickets", {Title = "Auto Farm Tickets", Default = false})
FarmTicketsToggle:OnChanged(function(State)
    DConfiguration.AutoFarm.FarmTickets = State
    while DConfiguration.AutoFarm.FarmTickets and wait(-2) do
        spawn(DFunctions.TicketsFarming)
    end
end)

local AFKFarmToggle = Tabs.AutoFarm:AddToggle("AFKFarm", {Title = "AFK Farm", Default = false})
AFKFarmToggle:OnChanged(function(State)
    DConfiguration.AutoFarm.AFKFarm = State
    while DConfiguration.AutoFarm.AFKFarm and wait(-2) do
        spawn(DFunctions.AFKFarming)
    end
end)

Tabs.AutoFarm:AddSection("VIP Automations")

local AutoVoteToggle = Tabs.AutoFarm:AddToggle("AutoVote", {Title = "Auto Vote", Default = false})
AutoVoteToggle:OnChanged(function(State)
    DConfiguration.AutoFarm.VIPAutomations.AutoVote = State
    while DConfiguration.AutoFarm.VIPAutomations.AutoVote and wait(1) do
        DFunctions.AutoVote(
            DConfiguration.AutoFarm.VIPAutomations.MapSection,
            DConfiguration.AutoFarm.VIPAutomations.GamemodeSection
        )
    end
end)

local MapSectionDropdown = Tabs.AutoFarm:AddDropdown("MapSection", {
    Title = "Map Section",
    Values = {1, 2, 3, 4},
    Multi = false,
    Default = 1,
})
MapSectionDropdown:OnChanged(function(Value)
    DConfiguration.AutoFarm.VIPAutomations.MapSection = Value
end)

local GamemodeSectionDropdown = Tabs.AutoFarm:AddDropdown("GamemodeSection", {
    Title = "Gamemode Section",
    Values = {1, 2, 3, 4},
    Multi = false,
    Default = 1,
})
GamemodeSectionDropdown:OnChanged(function(Value)
    DConfiguration.AutoFarm.VIPAutomations.GamemodeSection = Value
end)

Tabs.AutoFarm:AddParagraph({Title = " ", Content = ""})

local AutoSetMapToggle = Tabs.AutoFarm:AddToggle("AutoSetMap", {Title = "Auto Set Map", Default = false})
AutoSetMapToggle:OnChanged(function(State)
    DConfiguration.AutoFarm.VIPAutomations.AutoMap = State
    if State then
        DFunctions.SetVIPCommands(DConfiguration.AutoFarm.VIPAutomations.MapInput, nil)
    end
end)

local AutoSpecialRoundToggle = Tabs.AutoFarm:AddToggle("AutoSetSpecialRound", {Title = "Auto Set Special Round", Default = false})
AutoSpecialRoundToggle:OnChanged(function(State)
    DConfiguration.AutoFarm.VIPAutomations.AutoSpecialRound = State
    if State then
        DFunctions.SetVIPCommands(nil, DConfiguration.AutoFarm.VIPAutomations.SpecialRoundInput)
    end
end)

local AutoProModeToggle = Tabs.AutoFarm:AddToggle("AutoProMode", {Title = "Auto Set Gamemode to Pro (RECOMMENDED)", Default = false})
AutoProModeToggle:OnChanged(function(State)
    DConfiguration.AutoFarm.VIPAutomations.AutoProMode = State
    if State then
        ReplicatedStorage.Events.CustomServers.Admin:FireServer("Gamemode", "Pro")
        wait(3)
        game:GetService("ReplicatedStorage").Events.Player.ChangePlayerMode:FireServer(true)
    end
end)

Tabs.AutoFarm:AddInput("MapInput", {
    Title = "Map Input",
    Default = "DesertBus",
    Placeholder = "DesertBus",
    Numeric = false,
    Finished = false,
    Description = "NO SPACE NEEDED",
    Callback = function(Value)
        DConfiguration.AutoFarm.VIPAutomations.MapInput = Value
    end
})

Tabs.AutoFarm:AddInput("SpecialRoundInput", {
    Title = "Special Round Input",
    Default = "Plushie Hell",
    Placeholder = "Plushie Hell",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        DConfiguration.AutoFarm.VIPAutomations.SpecialRoundInput = Value
    end
})

-- Auto-reapply VIP settings on respawn
LocalPlayer.CharacterAdded:Connect(function()
    local Map   = Workspace.Game:WaitForChild("Map", 9e9)
    local Stats = Workspace.Game:WaitForChild("Stats", 9e9)
    local Settings = Workspace.Game:WaitForChild("Settings", 9e9)

    if DConfiguration.AutoFarm.VIPAutomations.AutoMap and Map and Map:GetAttribute("Map") ~= DConfiguration.AutoFarm.VIPAutomations.MapInput then
        DFunctions.SetVIPCommands(DConfiguration.AutoFarm.VIPAutomations.MapInput, nil)
    end
    if DConfiguration.AutoFarm.VIPAutomations.AutoSpecialRound and Stats and not Stats:GetAttribute("NextSpecialRound") then
        DFunctions.SetVIPCommands(nil, DConfiguration.AutoFarm.VIPAutomations.SpecialRoundInput)
    end
    if DConfiguration.AutoFarm.VIPAutomations.AutoProMode and Settings and Settings:GetAttribute("Gamemode") ~= "Pro" then
        ReplicatedStorage.Events.CustomServers.Admin:FireServer("Gamemode", "Pro")
        wait(3)
        game:GetService("ReplicatedStorage").Events.Player.ChangePlayerMode:FireServer(true)
    end
end)

-- ============================================================
-- ANTI NEXTBOT TAB LOGIC & FUNCTIONS
-- ============================================================

DConfiguration.Nextbots = {
    AntiNextbot      = false,
    AntiNextbotRange = 15,
    AntiNextbotType  = "Spawn",
}

function DFunctions.AntiNextbot()
    if Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Players")
        and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then

        local playerTeam = Workspace.Game.Players[LocalPlayer.Name]:GetAttribute("Team")
        if playerTeam == "Nextbot" then return end

        for i, v in pairs(Workspace.Game.Players:GetDescendants()) do
            if v:IsA("Model") and v:GetAttribute("Team") == "Nextbot" then
                local humanoidRootPart = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("HRP")
                if humanoidRootPart then
                    if not LocalPlayer.Character or not LocalPlayer.Character.HumanoidRootPart then return end

                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude

                    if distance < DConfiguration.Nextbots.AntiNextbotRange then
                        if DConfiguration.Nextbots.AntiNextbotType == "Spawn" then
                            local parts = Workspace.Game.Map.ItemSpawns:GetChildren()
                            local randomPart = parts[math.random(1, #parts)]
                            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(randomPart.Position)
                        elseif DConfiguration.Nextbots.AntiNextbotType == "Players" then
                            local randomPlayer = game.Players:GetPlayers()[math.random(1, #game.Players:GetPlayers())]
                            if randomPlayer and randomPlayer.Character and randomPlayer.Character:FindFirstChild("Head") then
                                local head = randomPlayer.Character.Head
                                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(head.Position)
                            end
                        end
                    end
                end
            end
        end
    end
end

-- ============================================================
-- ANTI NEXTBOT TAB UI
-- ============================================================

Tabs.Nextbots:AddSection("Nextbot Modification")

local AntiNextbotToggle = Tabs.Nextbots:AddToggle("AntiNextbotToggle", {Title = "Anti Nextbot", Default = false})
AntiNextbotToggle:OnChanged(function(value)
    DConfiguration.Nextbots.AntiNextbot = value
    while DConfiguration.Nextbots.AntiNextbot and wait(0.1) do
        spawn(DFunctions.AntiNextbot)
    end
end)

local AntiNextbotTypeDropdown = Tabs.Nextbots:AddDropdown("AntiBotTeleport", {
    Title = "Teleport Type",
    Values = {"Spawn", "Players"},
    Multi = false,
    Default = 1,
})
AntiNextbotTypeDropdown:OnChanged(function(Value)
    DConfiguration.Nextbots.AntiNextbotType = Value
end)

Tabs.Nextbots:AddInput("NextbotDistance", {
    Title = "Trigger Distance",
    Default = "15",
    Placeholder = "15",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        DConfiguration.Nextbots.AntiNextbotRange = tonumber(Value) or 15
    end
})

-- ============================================================
-- MOVEMENT TAB LOGIC & FUNCTIONS
-- ============================================================

DConfiguration.Misc = {
    PlayerAdjustment = {
        Default = { Speed = 1500, JumpHeight = 3, JumpCap = 1, JumpAcceleration = 1.5, AirStrafeAcceleration = 182, GroundAcceleration = 5 },
        Update  = { Speed = 1500, JumpHeight = 3, JumpCap = 1, JumpAcceleration = 1.5, AirStrafeAcceleration = 182, GroundAcceleration = 5 },
        Saved   = { Speed = 1500, JumpHeight = 3, JumpCap = 1, JumpAcceleration = 1.5, AirStrafeAcceleration = 182, GroundAcceleration = 5 },
        Tick    = { Speed = 0, JumpHeight = 0, JumpCap = 0, JumpAcceleration = 0, AirStrafeAcceleration = 0, GroundAcceleration = 0 },
        Debounce = { Speed = false, JumpHeight = false, JumpCap = false, JumpAcceleration = false, AirStrafeAcceleration = false, GroundAcceleration = false },
    },
    Humanoids = { WalkspeedCF = false, OriginalJumpHeight = false, CF = 5, JP = 20 },
    Utilities = {
        GetCurrentSpeed = 0,
        BounceModification = { Enabled = false, DefaultBounce = 80, EmoteBounce = 120, SuperBounce = false, SuperBounceStrength = -50 },
        EdgeTrimpModification = { Enabled = false, HeightMultiplier = 1.5, DownThreshold = 4.5 },
        LagSwitch = { MSDelay = 200, Mode = "Normal" },
    },
    CameraAdjustment = { StretchX = 1, StretchY = 1 },
    GunAdjustment = { v = nil },
    GameAutomation = {
        Revive  = { Enabled = false, FloatingButton = false, Keybind = false, WhileEmote = false, Delay = 0.1 },
        Carry   = { Enabled = false, FloatingButton = false, Keybind = false, WhileEmote = false },
        Macro   = { SelectedEmote = "BoldMarch", FloatingButton = false, Keybind = false },
    },
    MovementModification = {
        AggressiveEmoteDash = { Enabled = false, Type = "Blatant", Speed = 3000, Acceleration = -2 },
        SlideModification   = { FloatingButton = false, Enabled = false, Acceleration = -3 },
        Gravity             = { FloatingButton = false, Keybind = false, Value = 10 },
        BHOP = {
            Enabled = false, Keybind = false, FloatingButton = false, AutoAcceleration = false,
            MaxSpeed = 70, SpiderHop = false, Backwards = false, JumpButton = false,
            HipHeight1 = 0, HipHeight2 = 0, Type = "Acceleration", JumpType = "Simulated",
            Acceleration = -0.1, lastTick = 0.01,
            Crouch = { FloatingButton = false, Keybind = false, Type = "Ground", lastTick = 0.1, lastReleaseTick = 0.1 },
        },
    },
}

DConfiguration.Settings.GuiScale.LagSwitch     = DConfiguration.Settings.GuiScale.LagSwitch     or 0
DConfiguration.Settings.GuiScale.SuperBounce   = DConfiguration.Settings.GuiScale.SuperBounce   or 0
DConfiguration.Settings.GuiScale.BounceBot     = DConfiguration.Settings.GuiScale.BounceBot     or 0
DConfiguration.Settings.GuiScale.EasyBounce    = DConfiguration.Settings.GuiScale.EasyBounce    or 0
DConfiguration.Settings.GuiScale.Gravity       = DConfiguration.Settings.GuiScale.Gravity       or 0
DConfiguration.Settings.GuiScale.AutoJump      = DConfiguration.Settings.GuiScale.AutoJump      or 0
DConfiguration.Settings.GuiScale.InfiniteSlide = DConfiguration.Settings.GuiScale.InfiniteSlide or 0
DConfiguration.Settings.GuiScale.InstantRevive = DConfiguration.Settings.GuiScale.InstantRevive or 0
DConfiguration.Settings.GuiScale.AutoCarry     = DConfiguration.Settings.GuiScale.AutoCarry     or 0
DConfiguration.Settings.GuiScale.AutoEmoteDash = DConfiguration.Settings.GuiScale.AutoEmoteDash or 0

-- BaseStats - used for speed, jump, etc inputs
local BaseStats = nil
pcall(function()
    BaseStats = require(game:GetService("ReplicatedStorage").Objects.Game.Character.Client.Movement.MoveStats.BaseStats)
end)

local function SyncBaseStats()
    if not BaseStats then return end
    pcall(function()
        BaseStats.Speed                 = DConfiguration.Misc.PlayerAdjustment.Update.Speed
        BaseStats.JumpHeight            = DConfiguration.Misc.PlayerAdjustment.Update.JumpHeight
        BaseStats.JumpCap               = DConfiguration.Misc.PlayerAdjustment.Update.JumpCap
        BaseStats.JumpSpeedMultiplier   = DConfiguration.Misc.PlayerAdjustment.Update.JumpAcceleration
        BaseStats.AirStrafeAcceleration = DConfiguration.Misc.PlayerAdjustment.Update.AirStrafe
        BaseStats.Friction              = DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration
    end)
end

local CurrentAdjustment = {}

function DFunctions.GetAdjustments()
    table.clear(CurrentAdjustment)
    local character = LocalPlayer.Character
    if not character then return end
    local gc = (getgc and getgc(true)) or {}
    for _, v in pairs(gc) do
        if type(v) == "table" then
            local char  = rawget(v, "Character")
            local stats  = rawget(v, "overrideMovementStats")
            local stats2 = rawget(v, "defaultMovementStats")
            if typeof(char) == "Instance" and char == character then
                if type(stats)  == "table" then table.insert(CurrentAdjustment, stats)  end
                if type(stats2) == "table" then table.insert(CurrentAdjustment, stats2) end
            end
        end
    end
end

function DFunctions.setTSpeed(newSpeed)
    local now = tick()
    if DConfiguration.Misc.PlayerAdjustment.Default.Speed ~= newSpeed and now - DConfiguration.Misc.PlayerAdjustment.Tick.Speed >= 0.1 then
        DConfiguration.Misc.PlayerAdjustment.Default.Speed = newSpeed
        DConfiguration.Misc.PlayerAdjustment.Tick.Speed = now
        for i = 1, #CurrentAdjustment do
            local stats = CurrentAdjustment[i]
            if rawget(stats, "Speed") then rawset(stats, "Speed", newSpeed) end
        end
    end
end

function DFunctions.setTJump(newJump)
    local now = tick()
    if DConfiguration.Misc.PlayerAdjustment.Default.JumpHeight ~= newJump and now - DConfiguration.Misc.PlayerAdjustment.Tick.JumpHeight >= 0.1 then
        DConfiguration.Misc.PlayerAdjustment.Default.JumpHeight = newJump
        DConfiguration.Misc.PlayerAdjustment.Tick.JumpHeight = now
        for i = 1, #CurrentAdjustment do
            local stats = CurrentAdjustment[i]
            if rawget(stats, "JumpHeight") then rawset(stats, "JumpHeight", newJump) end
        end
    end
end

function DFunctions.setTJumpCap(newJumpCap)
    local now = tick()
    if DConfiguration.Misc.PlayerAdjustment.Default.JumpCap ~= newJumpCap and now - DConfiguration.Misc.PlayerAdjustment.Tick.JumpCap >= 0.1 then
        DConfiguration.Misc.PlayerAdjustment.Default.JumpCap = newJumpCap
        DConfiguration.Misc.PlayerAdjustment.Tick.JumpCap = now
        for i = 1, #CurrentAdjustment do
            local stats = CurrentAdjustment[i]
            if rawget(stats, "JumpCap") then rawset(stats, "JumpCap", newJumpCap) end
        end
    end
end

function DFunctions.setTJumpAcceleration(newJumpAcce)
    local now = tick()
    if DConfiguration.Misc.PlayerAdjustment.Default.JumpAcceleration ~= newJumpAcce and now - DConfiguration.Misc.PlayerAdjustment.Tick.JumpAcceleration >= 0.1 then
        DConfiguration.Misc.PlayerAdjustment.Default.JumpAcceleration = newJumpAcce
        DConfiguration.Misc.PlayerAdjustment.Tick.JumpAcceleration = now
        for i = 1, #CurrentAdjustment do
            local stats = CurrentAdjustment[i]
            if rawget(stats, "JumpSpeedMultiplier") then rawset(stats, "JumpSpeedMultiplier", newJumpAcce) end
        end
    end
end

function DFunctions.setTFriction(newFriction)
    local now = tick()
    if DConfiguration.Misc.PlayerAdjustment.Default.GroundAcceleration ~= newFriction and now - DConfiguration.Misc.PlayerAdjustment.Tick.GroundAcceleration >= 0.1 then
        DConfiguration.Misc.PlayerAdjustment.Default.GroundAcceleration = newFriction
        DConfiguration.Misc.PlayerAdjustment.Tick.GroundAcceleration = now
        for i = 1, #CurrentAdjustment do
            local stats = CurrentAdjustment[i]
            if rawget(stats, "Friction") then rawset(stats, "Friction", newFriction) end
        end
    end
end

function DFunctions.setBhopEnabled(bool)
    for i = 1, #CurrentAdjustment do
        local stats = CurrentAdjustment[i]
        if rawget(stats, "BhopEnabled") ~= nil then rawset(stats, "BhopEnabled", bool) end
    end
end

function DFunctions.setStrafeAcceleration(newAcceleration)
    local now = tick()
    if DConfiguration.Misc.PlayerAdjustment.Default.AirStrafe ~= newAcceleration and now - (DConfiguration.Misc.PlayerAdjustment.Tick.AirStrafe or 0) >= 0.1 then
        DConfiguration.Misc.PlayerAdjustment.Default.AirStrafe = newAcceleration
        DConfiguration.Misc.PlayerAdjustment.Tick.AirStrafe = now
        for i = 1, #CurrentAdjustment do
            local stats = CurrentAdjustment[i]
            if rawget(stats, "AirStrafeAcceleration") then rawset(stats, "AirStrafeAcceleration", newAcceleration) end
            if rawget(stats, "AirAcceleration") then rawset(stats, "AirAcceleration", 3) end
        end
    end
end

function DFunctions.SetPreviousAdjustment()
    for i = 1, #CurrentAdjustment do
        local stats = CurrentAdjustment[i]
        if rawget(stats, "Speed")              then rawset(stats, "Speed",              DConfiguration.Misc.PlayerAdjustment.Default.Speed) end
        if rawget(stats, "JumpHeight")         then rawset(stats, "JumpHeight",         DConfiguration.Misc.PlayerAdjustment.Default.JumpHeight) end
        if rawget(stats, "JumpCap")            then rawset(stats, "JumpCap",            DConfiguration.Misc.PlayerAdjustment.Default.JumpCap) end
        if rawget(stats, "JumpSpeedMultiplier") then rawset(stats, "JumpSpeedMultiplier", DConfiguration.Misc.PlayerAdjustment.Default.JumpAcceleration) end
        if rawget(stats, "AirStrafeAcceleration") then rawset(stats, "AirStrafeAcceleration", DConfiguration.Misc.PlayerAdjustment.Default.AirStrafe) end
        if rawget(stats, "AirAcceleration")    then rawset(stats, "AirAcceleration",    3) end
    end
end

function DFunctions.AggressiveEmoteDashFunction()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if DConfiguration.Misc.MovementModification.AggressiveEmoteDash.Type == "Legit" and (char and char:GetAttribute("State") == "EmotingSlide") then
        DConfiguration.Misc.PlayerAdjustment.Debounce.GroundAcceleration = false
        DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = DConfiguration.Misc.MovementModification.AggressiveEmoteDash.Acceleration
    else
        DConfiguration.Misc.PlayerAdjustment.Debounce.GroundAcceleration = true
        if DConfiguration.Misc.PlayerAdjustment.Debounce.GroundAcceleration then
            DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = DConfiguration.Misc.PlayerAdjustment.Default.GroundAcceleration
        end
    end
    if DConfiguration.Misc.MovementModification.AggressiveEmoteDash.Type == "Blatant" and char and (char:GetAttribute("State") == "Emoting" or char:GetAttribute("State") == "EmotingAir" or char:GetAttribute("State") == "EmotingSlide" or char:GetAttribute("State") == "EmotingSlideAir") then
        DConfiguration.Misc.PlayerAdjustment.Update.Speed = DConfiguration.Misc.MovementModification.AggressiveEmoteDash.Speed
    else
        DConfiguration.Misc.PlayerAdjustment.Update.Speed = DConfiguration.Misc.PlayerAdjustment.Saved.Speed
    end
end

function DFunctions.InfiniteSlideFunction()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if char and (char:GetAttribute("State") == "Slide" or char:GetAttribute("State") == "EmotingSlide") then
        DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = DConfiguration.Misc.MovementModification.SlideModification.Acceleration
    else
        DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = 5
    end
end

function DFunctions.SuperBounce()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local HumanoidRootPart = char:FindFirstChild("HumanoidRootPart")
    local Humanoid = char:FindFirstChild("Humanoid")
    local PreviousHipHeight = char:FindFirstChild("R15Visual") and 0.75 or -1.25
    if not HumanoidRootPart or not Humanoid then return end
    HumanoidRootPart.CanCollide = false
    Humanoid.HipHeight = -100
    wait(2)
    HumanoidRootPart.CanCollide = true
    Humanoid.HipHeight = PreviousHipHeight
end

function DFunctions.BHOPFunction()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoidrootpart = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local speedometer = pcall(function() return DFunctions.GetSpeedometer() end) and DFunctions.GetSpeedometer() or nil
    if not char or not humanoidrootpart or not humanoid then return end

    if DConfiguration.Misc.MovementModification.BHOP.SpiderHop and char:GetAttribute("State") == "Wallrunning" then
        LocalPlayer.PlayerScripts.Events.temporary_events.EndJump:Fire()
        LocalPlayer.PlayerScripts.Events.temporary_events.JumpReact:Fire()
    end

    local debounce = 0.01
    if DConfiguration.Misc.MovementModification.BHOP.Type == "Acceleration" then
        local h2 = char:FindFirstChild("R15Visual") and (tonumber(speedometer and speedometer.Text) or 0) > 60 and 1 or 0.9
        if not char:FindFirstChild("R15Visual") then h2 = (tonumber(speedometer and speedometer.Text) or 0) > 60 and -1.05 or -1.10 end
        DConfiguration.Misc.MovementModification.BHOP.HipHeight2 = h2
        humanoid.HipHeight = h2
    elseif DConfiguration.Misc.MovementModification.BHOP.Type == "Ground Acceleration" then
        local h2 = char:FindFirstChild("R15Visual") and 0.5 or -2
        DConfiguration.Misc.MovementModification.BHOP.HipHeight2 = h2
        humanoid.HipHeight = h2
    elseif DConfiguration.Misc.MovementModification.BHOP.Type == "No Acceleration" then
        debounce = 0.125
    end

    if DConfiguration.Misc.MovementModification.BHOP.AutoAcceleration and speedometer then
        local Speed = tonumber(speedometer.Text) or 0
        local Threshold = math.clamp(Speed, 25, 50)
        local Devisor = math.clamp(Speed / Threshold, 0, 6)
        local Decrease = math.clamp(5 - (Devisor * 1.7), 0.01, 2)
        if Speed < DConfiguration.Misc.MovementModification.BHOP.MaxSpeed then
            DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = DConfiguration.Misc.MovementModification.BHOP.Acceleration
        else
            DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = Decrease
        end
    else
        DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = DConfiguration.Misc.MovementModification.BHOP.Acceleration
    end

    local now = tick()
    local grounded = humanoid.FloorMaterial ~= Enum.Material.Air

    if DConfiguration.Misc.MovementModification.BHOP.JumpType == "Simulated" then
        if grounded and (now - DConfiguration.Misc.MovementModification.BHOP.lastTick) > debounce then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            DConfiguration.Misc.MovementModification.BHOP.lastTick = now
        end
    elseif DConfiguration.Misc.MovementModification.BHOP.JumpType == "Realistic" then
        if grounded and (now - DConfiguration.Misc.MovementModification.BHOP.lastTick) > debounce then
            LocalPlayer.PlayerScripts.Events.temporary_events.EndJump:Fire()
            LocalPlayer.PlayerScripts.Events.temporary_events.JumpReact:Fire()
            DConfiguration.Misc.MovementModification.BHOP.lastTick = now
        end
    end

    if DConfiguration.Misc.MovementModification.BHOP.Backwards then
        local look = humanoidrootpart.CFrame.LookVector
        local vel = humanoidrootpart.AssemblyLinearVelocity
        if look:Dot(vel.Unit) < -0.45 then
            DFunctions.setBhopEnabled(true)
            RunService.Heartbeat:Wait()
            DFunctions.setBhopEnabled(false)
        end
    end
end

function DFunctions.ResetBHOP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local h1 = char:FindFirstChild("R15Visual") and 0.75 or -1.25
    local h2 = char:FindFirstChild("R15Visual") and 0.9 or -1.10
    DConfiguration.Misc.MovementModification.BHOP.HipHeight1 = h1
    DConfiguration.Misc.MovementModification.BHOP.HipHeight2 = h2
    if humanoid then
        humanoid.HipHeight = h1
        DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = 5
        wait(0.3)
        DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = 5
        DFunctions.setBhopEnabled(false)
    end
end

function DFunctions.CrouchFunction()
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if not Character then return end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not Humanoid or not HumanoidRootPart then return end
    local Config = DConfiguration.Misc.MovementModification.BHOP.Crouch
    local Type = Config.Type or "Ground"
    local isOnGround = Humanoid.FloorMaterial ~= Enum.Material.Air
    if Config.isHolding == nil then Config.isHolding = false end
    local shouldHold = (Type == "Normal") or (Type == "Ground" and isOnGround)
    if Type == "Air" then shouldHold = not isOnGround end
    if shouldHold and not Config.isHolding then
        Config.isHolding = true
        LocalPlayer.PlayerScripts.Events.temporary_events.UseKeybind:Fire({ Key = "Crouch", Down = true })
    elseif not shouldHold and Config.isHolding then
        Config.isHolding = false
        LocalPlayer.PlayerScripts.Events.temporary_events.UseKeybind:Fire({ Key = "Crouch", Down = false })
    end
end

-- Main player adjustment RunService loop
local NormalGravity = workspace.Gravity

RunService.Heartbeat:Connect(function()
    if not LocalPlayer.Character then return end
    DFunctions.GetAdjustments()

    -- Speed / Jump / Strafe
    DFunctions.setTSpeed(DConfiguration.Misc.PlayerAdjustment.Update.Speed)
    DFunctions.setTJump(DConfiguration.Misc.PlayerAdjustment.Update.JumpHeight)
    DFunctions.setTJumpCap(DConfiguration.Misc.PlayerAdjustment.Update.JumpCap)
    DFunctions.setTJumpAcceleration(DConfiguration.Misc.PlayerAdjustment.Update.JumpAcceleration)
    DFunctions.setStrafeAcceleration(DConfiguration.Misc.PlayerAdjustment.Update.AirStrafeAcceleration)
    DFunctions.setTFriction(DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration)

    -- Sync BaseStats module directly
    SyncBaseStats()

    -- Aggressive Emote Dash
    if DConfiguration.Misc.MovementModification.AggressiveEmoteDash.Enabled then
        DFunctions.AggressiveEmoteDashFunction()
    end

    -- Infinite Slide
    if DConfiguration.Misc.MovementModification.SlideModification.Enabled then
        DFunctions.InfiniteSlideFunction()
    end

    -- BHOP
    if DConfiguration.Misc.MovementModification.BHOP.Enabled then
        DFunctions.BHOPFunction()
    end

    -- BHOP Crouch
    if DConfiguration.Misc.MovementModification.BHOP.Crouch.FloatingButton then
        DFunctions.CrouchFunction()
    end

    -- Gravity
    if DConfiguration.Misc.MovementModification.Gravity.FloatingButton then
        workspace.Gravity = DConfiguration.Misc.MovementModification.Gravity.Value
    else
        workspace.Gravity = NormalGravity
    end

    -- Instant Revive (floating button)
    if DConfiguration.Misc.GameAutomation.Revive.FloatingButton then
        if DConfiguration.Misc.GameAutomation.Revive.WhileEmote then
            spawn(DFunctions.InstantRevive)
        else
            spawn(DFunctions.InstantReviveNoEmote)
        end
    end

    -- Auto Carry (floating button)
    if DConfiguration.Misc.GameAutomation.Carry.FloatingButton then
        spawn(DFunctions.CarryPlayer)
    end

    -- Edge Trimp
    if DConfiguration.Misc.Utilities.EdgeTrimpModification.Enabled then
        DFunctions.ModifyEdgeTrimp()
    end
end)

-- ============================================================
-- MOVEMENT TAB UI
-- ============================================================

local UserInputService = game:GetService("UserInputService")
local _SB = { Power = 100 }
getgenv().EasyBounce = getgenv().EasyBounce or { Enabled = false, Mode = "Forward", BaseSpeed = 50, ExtraSpeed = 100 }
local EB = getgenv().EasyBounce

Tabs.Misc:AddSection("Player Adjustments")

Tabs.Misc:AddInput("PlayerSpeed", {
    Title = "Player Speed", Default = "1500", Placeholder = "Speed Number",
    Numeric = false, Finished = false,
    Callback = function(Value)
        DConfiguration.Misc.PlayerAdjustment.Update.Speed = tonumber(Value) or 1500
        DConfiguration.Misc.PlayerAdjustment.Saved.Speed  = tonumber(Value) or 1500
    end
})

Tabs.Misc:AddInput("PlayerJump", {
    Title = "Player Jump", Default = "3", Placeholder = "Jump Number",
    Numeric = false, Finished = false,
    Callback = function(Value)
        DConfiguration.Misc.PlayerAdjustment.Update.JumpHeight = tonumber(Value) or 3
        DConfiguration.Misc.PlayerAdjustment.Saved.JumpHeight  = tonumber(Value) or 3
    end
})

Tabs.Misc:AddInput("PlayerJumpAcce", {
    Title = "Player Jump Acceleration", Default = "1.5", Placeholder = "1.5",
    Numeric = false, Finished = false,
    Callback = function(Value)
        DConfiguration.Misc.PlayerAdjustment.Update.JumpAcceleration = tonumber(Value) or 1.5
        DConfiguration.Misc.PlayerAdjustment.Saved.JumpAcceleration  = tonumber(Value) or 1.5
    end
})

Tabs.Misc:AddInput("PlayerJumpCap", {
    Title = "Player Jump Cap", Default = "1", Placeholder = "1",
    Numeric = false, Finished = false,
    Callback = function(Value)
        DConfiguration.Misc.PlayerAdjustment.Update.JumpCap = tonumber(Value) or 1
        DConfiguration.Misc.PlayerAdjustment.Saved.JumpCap  = tonumber(Value) or 1
    end
})

Tabs.Misc:AddInput("PlayerStrafeAcceleration", {
    Title = "Player Air Strafe Acceleration", Default = "182", Placeholder = "182",
    Numeric = false, Finished = false,
    Callback = function(Value)
        DConfiguration.Misc.PlayerAdjustment.Update.AirStrafeAcceleration = tonumber(Value) or 182
        DConfiguration.Misc.PlayerAdjustment.Saved.AirStrafeAcceleration  = tonumber(Value) or 182
    end
})

Tabs.Misc:AddInput("PlayerGroundAcceleration", {
    Title = "Player Ground Acceleration", Default = "5", Placeholder = "5",
    Numeric = false, Finished = false,
    Callback = function(Value)
        DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = tonumber(Value) or 5
        DConfiguration.Misc.PlayerAdjustment.Saved.GroundAcceleration  = tonumber(Value) or 5
    end
})

Tabs.Misc:AddParagraph({ Title = " ", Content = "" })

local WalkspeedToggle = Tabs.Misc:AddToggle("PlayerWalkspeed", {Title = "Walkspeed Toggle", Default = false})
WalkspeedToggle:OnChanged(function(State)
    DConfiguration.Misc.Humanoids.WalkspeedCF = State
    while DConfiguration.Misc.Humanoids.WalkspeedCF and wait(0.01) do
        local chr = LocalPlayer.Character
        local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
        if chr and hum and hum.MoveDirection.Magnitude > 0 then
            chr:TranslateBy(hum.MoveDirection * DConfiguration.Misc.Humanoids.CF * RunService.Heartbeat:Wait() * 10)
        end
    end
end)

Tabs.Misc:AddInput("PlayerWalkCf", {
    Title = "Player Walkspeed", Default = "5", Placeholder = "5",
    Numeric = false, Finished = false,
    Callback = function(Value) DConfiguration.Misc.Humanoids.CF = tonumber(Value) or 5 end
})

Tabs.Misc:AddSection("Utilities")

local LagToggle = Tabs.Misc:AddToggle("LagSwitch", {Title = "Lag Switch (Button)", Default = false})
LagToggle:OnChanged(function(State)
    if State then
        DFunctions.CreateButton("LagSwitchButton", "Start Lag", 0.15 + DConfiguration.Settings.GuiScale.LagSwitch, 0.1 + DConfiguration.Settings.GuiScale.LagSwitch, function(btn)
            task.spawn(function() DFunctions.StartLag(DConfiguration.Misc.Utilities.LagSwitch.MSDelay) end)
            btn.Text = "..." wait(0.1) btn.Text = "Start Lag"
        end)
    else
        DFunctions.DestroyButton("LagSwitchButton")
    end
end)

Tabs.Misc:AddInput("LagSwitchButtonSize", {
    Title = "Lag Switch Gui Size", Default = "0", Placeholder = "0", Numeric = true, Finished = false,
    Callback = function(Value)
        DConfiguration.Settings.GuiScale.LagSwitch = (tonumber(Value) or 0) * 0.01
        DFunctions.UpdateButton("LagSwitchButton", 0.15 + DConfiguration.Settings.GuiScale.LagSwitch, 0.1 + DConfiguration.Settings.GuiScale.LagSwitch)
    end
})

Tabs.Misc:AddInput("DelayMS", {
    Title = "Delay MS", Default = "200", Placeholder = "200", Numeric = false, Finished = false,
    Callback = function(Value) DConfiguration.Misc.Utilities.LagSwitch.MSDelay = tonumber(Value) or 200 end
})

Tabs.Misc:AddDropdown("LagMode", {
    Title = "Lag Mode", Values = {"Normal", "Demon", "FastFlag"}, Multi = false, Default = 1,
}):OnChanged(function(Value) DConfiguration.Misc.Utilities.LagSwitch.Mode = Value end)

Tabs.Misc:AddParagraph({ Title = " ", Content = "" })

local BounceToggle = Tabs.Misc:AddToggle("AdjustBounce", {Title = "Modify Bounce", Default = false})
BounceToggle:OnChanged(function(State)
    DConfiguration.Misc.Utilities.BounceModification.Enabled = State
    while DConfiguration.Misc.Utilities.BounceModification.Enabled and wait(0.1) do
        spawn(DFunctions.BounceFunction)
    end
end)

Tabs.Misc:AddInput("PlayerBounce", {
    Title = "Player Bounce", Default = "80", Placeholder = "80", Numeric = false, Finished = false,
    Callback = function(Value) DConfiguration.Misc.Utilities.BounceModification.DefaultBounce = tonumber(Value) or 80 end
})

Tabs.Misc:AddInput("EmoteBounce", {
    Title = "Emote Bounce", Default = "120", Placeholder = "120", Numeric = false, Finished = false,
    Callback = function(Value) DConfiguration.Misc.Utilities.BounceModification.EmoteBounce = tonumber(Value) or 120 end
})

Tabs.Misc:AddParagraph({ Title = " ", Content = "" })

local SuperBounceToggle = Tabs.Misc:AddToggle("SuperBounce", {Title = "Super Bounce (Button)", Default = false})
SuperBounceToggle:OnChanged(function(State)
    if State then
        DFunctions.CreateButton("SuperBounceButton", "Super Bounce", 0.1 + DConfiguration.Settings.GuiScale.SuperBounce, 0.1 + DConfiguration.Settings.GuiScale.SuperBounce, function(btn)
            DFunctions.SuperBounce() btn.Text = "..." wait(0.1) btn.Text = "Super Bounce"
        end)
    else
        DFunctions.DestroyButton("SuperBounceButton")
    end
end)

Tabs.Misc:AddInput("SuperBounceSize", {
    Title = "Super Bounce Size", Default = "0", Placeholder = "0", Numeric = true, Finished = false,
    Callback = function(Value)
        DConfiguration.Settings.GuiScale.SuperBounce = math.clamp((tonumber(Value) or 0) * 0.01, 0, 2)
        DFunctions.UpdateButton("SuperBounceButton", 0.1 + DConfiguration.Settings.GuiScale.SuperBounce, 0.1 + DConfiguration.Settings.GuiScale.SuperBounce)
    end
})

-- Bounce Button
local function TriggerBounce()
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if rootPart and humanoid then
        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Exclude
        rp.FilterDescendantsInstances = {character}
        rp.IgnoreWater = true
        local ray = workspace:Raycast(rootPart.Position, Vector3.new(0, -100, 0), rp)
        if ray and ray.Instance and ray.Instance:IsA("BasePart") and ray.Instance.CanCollide then
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            rootPart.AssemblyLinearVelocity = Vector3.new(rootPart.AssemblyLinearVelocity.X, math.clamp(_SB.Power, 0, 500), rootPart.AssemblyLinearVelocity.Z)
            task.defer(function() if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Freefall) end end)
        end
    end
end

Tabs.Misc:AddToggle("BounceBtnShow", {Title = "Bounce (Button)", Default = false}):OnChanged(function(S)
    if S then
        DFunctions.CreateButton("BounceBtn", "Rebound", 0.15 + DConfiguration.Settings.GuiScale.BounceBot, 0.1 + DConfiguration.Settings.GuiScale.BounceBot, function() TriggerBounce() end)
    else
        DFunctions.DestroyButton("BounceBtn")
    end
end)

Tabs.Misc:AddInput("BouncePowerInput", {
    Title = "Bounce Power", Default = "100", Placeholder = "100", Numeric = true, Finished = false,
    Callback = function(Value) _SB.Power = math.clamp(tonumber(Value) or 100, 0, 500) end
})

Tabs.Misc:AddInput("BounceBtnSize", {
    Title = "Bounce Button Size", Default = "0", Placeholder = "0", Numeric = true, Finished = false,
    Callback = function(Value)
        DConfiguration.Settings.GuiScale.BounceBot = math.clamp((tonumber(Value) or 0) * 0.01, 0, 2)
        DFunctions.UpdateButton("BounceBtn", 0.15 + DConfiguration.Settings.GuiScale.BounceBot, 0.1 + DConfiguration.Settings.GuiScale.BounceBot)
    end
})

Tabs.Misc:AddParagraph({ Title = " ", Content = "" })

-- Easy Bounce
local EBCam = workspace.CurrentCamera
local EBState = { speed = EB.BaseSpeed, last = tick(), airTick = 0, airSum = 0, airborne = false, bv = nil }

local function getEBMeter()
    local ok, v = pcall(function() return LocalPlayer.PlayerGui.Shared.HUD.Overlay.Default.CharacterInfo.Item.Speedometer.Players end)
    return ok and v or nil
end

RunService.RenderStepped:Connect(function()
    local ch = LocalPlayer.Character
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    local hum = ch and ch:FindFirstChild("Humanoid")
    if _G.Fly or not EB.Enabled then
        if EBState.bv then EBState.bv:Destroy() EBState.bv = nil end
        return
    end
    if not hrp or not hum then return end
    local dt = tick() - EBState.last
    EBState.last = tick()
    local inAir = hum.FloorMaterial == Enum.Material.Air
    if EBState.airborne and not inAir then
        EBState.speed = math.max(EB.BaseSpeed, EBState.speed - 10)
        EBState.airSum = 0
    end
    EBState.airborne = inAir
    if inAir then
        EBState.airSum = EBState.airSum + dt
        EBState.airTick = EBState.airTick + dt
        while EBState.airTick >= 0.04 do
            EBState.airTick = EBState.airTick - 0.04
            EBState.speed = math.min(EB.BaseSpeed + EB.ExtraSpeed, EBState.speed + 0.1)
        end
    else
        EBState.airTick, EBState.airSum = 0, 0
        EBState.speed = math.max(EB.BaseSpeed, EBState.speed - (2.5 * dt))
    end
    if not EBState.bv or EBState.bv.Parent ~= hrp then
        if EBState.bv then EBState.bv:Destroy() end
        EBState.bv = Instance.new("BodyVelocity")
        EBState.bv.Parent = hrp
    end
    local camDir = EBCam.CFrame.LookVector
    local moveDir = Vector3.new(camDir.X, 0, camDir.Z).Unit
    if EB.Mode == "Back" then moveDir = -moveDir end
    EBState.bv.Velocity = moveDir * EBState.speed
    EBState.bv.MaxForce = Vector3.new(4e5, 0, 4e5)
end)

Tabs.Misc:AddDropdown("EB_ModeDropdown", {
    Title = "Easy Bounce Mode", Values = {"Forward", "Back"}, Default = EB.Mode,
}):OnChanged(function(v) EB.Mode = v end)

Tabs.Misc:AddInput("EB_Base", {
    Title = "Base Speed", Default = tostring(EB.BaseSpeed), Numeric = true, Finished = true,
    Callback = function(v) EB.BaseSpeed = tonumber(v) or 50 end
})

Tabs.Misc:AddInput("EB_Extra", {
    Title = "Extra Speed (Boost)", Default = tostring(EB.ExtraSpeed), Numeric = true, Finished = true,
    Callback = function(v) EB.ExtraSpeed = tonumber(v) or 100 end
})

Tabs.Misc:AddToggle("EB_BtnShow", {Title = "Easy Bounce (Button)", Default = false}):OnChanged(function(s)
    if s then
        DFunctions.CreateButton("EB_Btn", EB.Enabled and "BOUNCE: ON" or "BOUNCE: OFF", 0.15 + DConfiguration.Settings.GuiScale.EasyBounce, 0.1 + DConfiguration.Settings.GuiScale.EasyBounce, function(btn)
            EB.Enabled = not EB.Enabled
            if btn and btn.Text then btn.Text = EB.Enabled and "BOUNCE: ON" or "BOUNCE: OFF" end
        end)
    else
        EB.Enabled = false
        DFunctions.DestroyButton("EB_Btn")
    end
end)

Tabs.Misc:AddInput("EB_ButtonSize", {
    Title = "Easy Bounce Button Size", Default = "0", Placeholder = "0", Numeric = true, Finished = false,
    Callback = function(Value)
        DConfiguration.Settings.GuiScale.EasyBounce = (tonumber(Value) or 0) * 0.01
        DFunctions.UpdateButton("EB_Btn", 0.15 + DConfiguration.Settings.GuiScale.EasyBounce, 0.1 + DConfiguration.Settings.GuiScale.EasyBounce)
    end
})

Tabs.Misc:AddParagraph({ Title = " ", Content = "" })

Tabs.Misc:AddToggle("AdjustEdgeTrimp", {Title = "Modify Edge Trimp", Default = false}):OnChanged(function(State)
    DConfiguration.Misc.Utilities.EdgeTrimpModification.Enabled = State
end)

Tabs.Misc:AddInput("EdgeTrimpHeight", {
    Title = "Height Multiplier", Default = "1.5", Placeholder = "1.5", Numeric = false, Finished = false,
    Callback = function(Value) DConfiguration.Misc.Utilities.EdgeTrimpModification.HeightMultiplier = tonumber(Value) or 1.5 end
})

Tabs.Misc:AddInput("DownThreshold", {
    Title = "Falling Threshold", Default = "4.5", Placeholder = "4.5", Numeric = false, Finished = false,
    Callback = function(Value) DConfiguration.Misc.Utilities.EdgeTrimpModification.DownThreshold = tonumber(Value) or 4.5 end
})

Tabs.Misc:AddSection("Camera Adjustments")

Tabs.Misc:AddInput("CamX", {
    Title = "Stretch Horizontal", Default = "1", Placeholder = "1", Numeric = false, Finished = false,
    Callback = function(Value) DConfiguration.Misc.CameraAdjustment.StretchX = tonumber(Value) or 1 end
})

Tabs.Misc:AddInput("CamY", {
    Title = "Stretch Vertical", Default = "1", Placeholder = "1", Numeric = false, Finished = false,
    Callback = function(Value) DConfiguration.Misc.CameraAdjustment.StretchY = tonumber(Value) or 1 end
})

Tabs.Misc:AddInput("PlayerFOV", {
    Title = "Player FOV", Default = "1", Placeholder = "1", Numeric = false, Finished = false,
    Callback = function(Value) LocalPlayer.PlayerScripts.Camera.FOVAdjusters.Zoom.Value = Value end
})

Tabs.Misc:AddButton({
    Title = "Set Camera Stretch",
    Description = "(Warning: Stretch settings can make billboards look weird or disappear from far away.)",
    Callback = function()
        LocalPlayer:SetAttribute("StretchX", DConfiguration.Misc.CameraAdjustment.StretchX)
        LocalPlayer:SetAttribute("StretchY", DConfiguration.Misc.CameraAdjustment.StretchY)
    end
})

Tabs.Misc:AddToggle("FrontCameraToggle", {Title = "Front Camera (Button)", Default = false}):OnChanged(function(State)
    if State then
        local isCameraOn = false
        DFunctions.CreateButton("FrontCameraButton", "Front Camera: OFF", 0.15, 0.1, function(btn)
            isCameraOn = not isCameraOn
            pcall(function()
                LocalPlayer.PlayerScripts.Events.temporary_events.UseKeybind:Fire({ Key = "Reload", Down = isCameraOn })
            end)
            btn.Text = isCameraOn and "Front Camera: ON" or "Front Camera: OFF"
        end)
    else
        DFunctions.DestroyButton("FrontCameraButton")
    end
end)

Tabs.Misc:AddToggle("ZoomToggle", {Title = "Zoom (Button)", Default = false}):OnChanged(function(State)
    if State then
        local isZoomOn = false
        DFunctions.CreateButton("ZoomButton", "Zoom: OFF", 0.15, 0.1, function(btn)
            isZoomOn = not isZoomOn
            pcall(function()
                LocalPlayer.PlayerScripts.Events.temporary_events.UseKeybind:Fire({ Key = "Secondary", Down = isZoomOn })
            end)
            btn.Text = isZoomOn and "Zoom: ON" or "Zoom: OFF"
        end)
    else
        DFunctions.DestroyButton("ZoomButton")
    end
end)

Tabs.Misc:AddSection("Game Automations")

Tabs.Misc:AddToggle("InstantReviveButton", {Title = "Instant Revive (Button)", Default = false}):OnChanged(function(State)
    if State then
        DFunctions.CreateButton("InstantReviveButton", "Instant Revive: OFF", 0.15 + DConfiguration.Settings.GuiScale.InstantRevive, 0.1 + DConfiguration.Settings.GuiScale.InstantRevive, function(btn)
            DConfiguration.Misc.GameAutomation.Revive.FloatingButton = not DConfiguration.Misc.GameAutomation.Revive.FloatingButton
            btn.Text = DConfiguration.Misc.GameAutomation.Revive.FloatingButton and "Instant Revive: ON" or "Instant Revive: OFF"
        end)
    else
        DFunctions.DestroyButton("InstantReviveButton")
    end
end)

Tabs.Misc:AddToggle("InstantRevive", {Title = "Instant Revive", Default = false}):OnChanged(function(State)
    DConfiguration.Misc.GameAutomation.Revive.Enabled = State
    while DConfiguration.Misc.GameAutomation.Revive.Enabled and wait(DConfiguration.Misc.GameAutomation.Revive.Delay) do
        if DConfiguration.Misc.GameAutomation.Revive.WhileEmote then spawn(DFunctions.InstantRevive)
        else spawn(DFunctions.InstantReviveNoEmote) end
    end
end)

Tabs.Misc:AddToggle("InsQua", {Title = "Instant Revive While Emote", Default = false}):OnChanged(function(State)
    DConfiguration.Misc.GameAutomation.Revive.WhileEmote = State
end)

Tabs.Misc:AddSlider("ReviveDelay", {
    Title = "Revive Delay", Default = 0.1, Min = 0, Max = 5, Rounding = 1,
    Callback = function(v) DConfiguration.Misc.GameAutomation.Revive.Delay = v end
})

Tabs.Misc:AddInput("InstantReviveButtonSize", {
    Title = "Instant Revive Gui Size", Default = "0", Placeholder = "0", Numeric = true, Finished = false,
    Callback = function(Value)
        DConfiguration.Settings.GuiScale.InstantRevive = (tonumber(Value) or 0) * 0.01
        DFunctions.UpdateButton("InstantReviveButton", 0.15 + DConfiguration.Settings.GuiScale.InstantRevive, 0.1 + DConfiguration.Settings.GuiScale.InstantRevive)
    end
})

Tabs.Misc:AddParagraph({ Title = " ", Content = "" })

Tabs.Misc:AddToggle("AutoCarry", {Title = "Auto Carry (Button)", Default = false}):OnChanged(function(State)
    if State then
        DFunctions.CreateButton("AutoCarryGui", "Auto Carry: OFF", 0.15 + DConfiguration.Settings.GuiScale.AutoCarry, 0.1 + DConfiguration.Settings.GuiScale.AutoCarry, function(btn)
            DConfiguration.Misc.GameAutomation.Carry.FloatingButton = not DConfiguration.Misc.GameAutomation.Carry.FloatingButton
            btn.Text = DConfiguration.Misc.GameAutomation.Carry.FloatingButton and "Auto Carry: ON" or "Auto Carry: OFF"
        end)
    else
        DFunctions.DestroyButton("AutoCarryGui")
    end
end)

Tabs.Misc:AddToggle("EmoteCarry", {Title = "Carry While Emote", Default = false}):OnChanged(function(State)
    DConfiguration.Misc.GameAutomation.Carry.WhileEmote = State
end)

Tabs.Misc:AddInput("CarryButtonSize", {
    Title = "Auto Carry Gui Size", Default = "0", Placeholder = "0", Numeric = true, Finished = false,
    Callback = function(Value)
        DConfiguration.Settings.GuiScale.AutoCarry = (tonumber(Value) or 0) * 0.01
        DFunctions.UpdateButton("AutoCarryGui", 0.15 + DConfiguration.Settings.GuiScale.AutoCarry, 0.1 + DConfiguration.Settings.GuiScale.AutoCarry)
    end
})

Tabs.Misc:AddParagraph({ Title = " ", Content = "" })

Tabs.Misc:AddSection("Movement Modification")

Tabs.Misc:AddToggle("AggressiveEmoteDash", {Title = "Aggressive Emote Dash", Default = false}):OnChanged(function(State)
    DConfiguration.Misc.MovementModification.AggressiveEmoteDash.Enabled = State
    if not State then
        DConfiguration.Misc.PlayerAdjustment.Debounce.GroundAcceleration = false
        DFunctions.setTSpeed(DConfiguration.Misc.PlayerAdjustment.Saved.Speed)
    end
end)

Tabs.Misc:AddDropdown("AggressiveEmoteType", {
    Title = "Aggressive Emote Type", Values = {"Legit", "Blatant"}, Multi = false, Default = 2,
}):OnChanged(function(Value) DConfiguration.Misc.MovementModification.AggressiveEmoteDash.Type = Value end)

Tabs.Misc:AddInput("EmoteSpeed", {
    Title = "Aggressive Emote Speed", Default = "3000", Placeholder = "3000", Numeric = false, Finished = false,
    Callback = function(Value) DConfiguration.Misc.MovementModification.AggressiveEmoteDash.Speed = tonumber(Value) or 3000 end
})

Tabs.Misc:AddInput("EmoteAcceleration", {
    Title = "Aggressive Emote Acceleration (Negative Only)", Default = "-2", Placeholder = "-2", Numeric = false, Finished = false,
    Callback = function(Value) DConfiguration.Misc.MovementModification.AggressiveEmoteDash.Acceleration = tonumber(Value) or -2 end
})

Tabs.Misc:AddParagraph({ Title = " ", Content = "" })

Tabs.Misc:AddToggle("InfiniteSlide", {Title = "Infinite Slide", Default = false}):OnChanged(function(State)
    DConfiguration.Misc.MovementModification.SlideModification.Enabled = State
    if not State then
        DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = 5
        wait(0.1)
        DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = 5
    end
end)

Tabs.Misc:AddToggle("InfiniteSlideButton", {Title = "Infinite Slide (Button)", Default = false}):OnChanged(function(State)
    if State then
        DFunctions.CreateButton("InfiniteSlideButton", "Infinite Slide: OFF", 0.15 + DConfiguration.Settings.GuiScale.InfiniteSlide, 0.1 + DConfiguration.Settings.GuiScale.InfiniteSlide, function(btn)
            DConfiguration.Misc.MovementModification.SlideModification.FloatingButton = not DConfiguration.Misc.MovementModification.SlideModification.FloatingButton
            DConfiguration.Misc.MovementModification.SlideModification.Enabled = DConfiguration.Misc.MovementModification.SlideModification.FloatingButton
            btn.Text = DConfiguration.Misc.MovementModification.SlideModification.FloatingButton and "Infinite Slide: ON" or "Infinite Slide: OFF"
            if not DConfiguration.Misc.MovementModification.SlideModification.FloatingButton then
                DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = 5
            end
        end)
    else
        DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = 5
        DFunctions.DestroyButton("InfiniteSlideButton")
    end
end)

Tabs.Misc:AddInput("InfiniteSlideButtonSize", {
    Title = "Infinite Slide Gui Size", Default = "0", Placeholder = "0", Numeric = true, Finished = false,
    Callback = function(Value)
        DConfiguration.Settings.GuiScale.InfiniteSlide = (tonumber(Value) or 0) * 0.01
        DFunctions.UpdateButton("InfiniteSlideButton", 0.15 + DConfiguration.Settings.GuiScale.InfiniteSlide, 0.1 + DConfiguration.Settings.GuiScale.InfiniteSlide)
    end
})

Tabs.Misc:AddInput("SlideSpeed", {
    Title = "Slide Speed (Negative Only)", Default = "-3", Placeholder = "-3", Numeric = false, Finished = false,
    Callback = function(Value) DConfiguration.Misc.MovementModification.SlideModification.Acceleration = tonumber(Value) or -3 end
})

Tabs.Misc:AddParagraph({ Title = " ", Content = "" })

Tabs.Misc:AddToggle("GravityToggle", {Title = "Gravity (Button)", Default = false}):OnChanged(function(State)
    if State then
        DFunctions.CreateButton("GravityGui", "Gravity: OFF", 0.15 + DConfiguration.Settings.GuiScale.Gravity, 0.1 + DConfiguration.Settings.GuiScale.Gravity, function(btn)
            DConfiguration.Misc.MovementModification.Gravity.FloatingButton = not DConfiguration.Misc.MovementModification.Gravity.FloatingButton
            btn.Text = DConfiguration.Misc.MovementModification.Gravity.FloatingButton and "Gravity: ON" or "Gravity: OFF"
        end)
    else
        DFunctions.DestroyButton("GravityGui")
    end
end)

Tabs.Misc:AddInput("GravityButtonSize", {
    Title = "Gravity Gui Size", Default = "0", Placeholder = "0", Numeric = true, Finished = false,
    Callback = function(Value)
        DConfiguration.Settings.GuiScale.Gravity = (tonumber(Value) or 0) * 0.01
        DFunctions.UpdateButton("GravityGui", 0.15 + DConfiguration.Settings.GuiScale.Gravity, 0.1 + DConfiguration.Settings.GuiScale.Gravity)
    end
})

Tabs.Misc:AddInput("GravityAdjust", {
    Title = "Gravity Value", Default = "10", Placeholder = "10", Numeric = false, Finished = false,
    Callback = function(Value) DConfiguration.Misc.MovementModification.Gravity.Value = tonumber(Value) or 10 end
})

Tabs.Misc:AddParagraph({ Title = " ", Content = "" })

Tabs.Misc:AddToggle("BHOPToggle", {Title = "BHOP (Button)", Default = false}):OnChanged(function(State)
    if State then
        DFunctions.CreateButton("BHOPGui", "Auto Jump: OFF", 0.15 + DConfiguration.Settings.GuiScale.AutoJump, 0.1 + DConfiguration.Settings.GuiScale.AutoJump, function(btn)
            DConfiguration.Misc.MovementModification.BHOP.FloatingButton = not DConfiguration.Misc.MovementModification.BHOP.FloatingButton
            btn.Text = DConfiguration.Misc.MovementModification.BHOP.FloatingButton and "Auto Jump: ON" or "Auto Jump: OFF"
            DConfiguration.Misc.MovementModification.BHOP.Enabled = DConfiguration.Misc.MovementModification.BHOP.FloatingButton
            if not DConfiguration.Misc.MovementModification.BHOP.FloatingButton then
                spawn(DFunctions.ResetBHOP) wait(0.1) spawn(DFunctions.ResetBHOP)
            end
        end)
    else
        DFunctions.DestroyButton("BHOPGui")
    end
end)

Tabs.Misc:AddToggle("BHOPJumpButton", {Title = "BHOP (Jump Button)", Default = false}):OnChanged(function(State)
    DConfiguration.Misc.MovementModification.BHOP.JumpButton = State
end)

if UserInputService.TouchEnabled then
    local JumpButton = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("TouchGui"):WaitForChild("TouchControlFrame"):FindFirstChild("JumpButton")
    if JumpButton then
        local isJumping = false
        JumpButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch and DConfiguration.Misc.MovementModification.BHOP.JumpButton then
                if not isJumping then isJumping = true DConfiguration.Misc.MovementModification.BHOP.Enabled = true end
            end
        end)
        JumpButton.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch and DConfiguration.Misc.MovementModification.BHOP.JumpButton and not DConfiguration.Misc.MovementModification.BHOP.FloatingButton then
                if isJumping then
                    isJumping = false
                    DConfiguration.Misc.MovementModification.BHOP.Enabled = false
                    spawn(DFunctions.ResetBHOP) wait(0.1) spawn(DFunctions.ResetBHOP)
                end
            end
        end)
    end
end

Tabs.Misc:AddInput("BHOPButtonSize", {
    Title = "BHOP Gui Size", Default = "0", Placeholder = "0", Numeric = true, Finished = false,
    Callback = function(Value)
        DConfiguration.Settings.GuiScale.AutoJump = (tonumber(Value) or 0) * 0.01
        DFunctions.UpdateButton("BHOPGui", 0.15 + DConfiguration.Settings.GuiScale.AutoJump, 0.1 + DConfiguration.Settings.GuiScale.AutoJump)
    end
})

Tabs.Misc:AddDropdown("BHOPVersion", {
    Title = "BHOP Version", Values = {"Acceleration", "Ground Acceleration", "No Acceleration"}, Multi = false, Default = 1,
}):OnChanged(function(Value) DConfiguration.Misc.MovementModification.BHOP.Type = Value end)

Tabs.Misc:AddDropdown("JumpType", {
    Title = "Jump Type", Values = {"Simulated", "Realistic"}, Multi = false, Default = 1,
}):OnChanged(function(Value) DConfiguration.Misc.MovementModification.BHOP.JumpType = Value end)

Tabs.Misc:AddToggle("BackwardBHOP", {Title = "BHOP Backward", Default = false}):OnChanged(function(State)
    DConfiguration.Misc.MovementModification.BHOP.Backwards = State
end)

Tabs.Misc:AddToggle("SpiderHop", {Title = "Spider Hop", Default = false}):OnChanged(function(State)
    DConfiguration.Misc.MovementModification.BHOP.SpiderHop = State
end)

Tabs.Misc:AddToggle("AutoAcceleration", {Title = "Auto Acceleration", Default = false}):OnChanged(function(State)
    DConfiguration.Misc.MovementModification.BHOP.AutoAcceleration = State
end)

Tabs.Misc:AddInput("BHOPMaxSpeed", {
    Title = "BHOP Max Speed", Default = "70", Placeholder = "70", Numeric = false, Finished = false,
    Callback = function(Value) DConfiguration.Misc.MovementModification.BHOP.MaxSpeed = tonumber(Value) or 70 end
})

Tabs.Misc:AddInput("BHOPAcceleration", {
    Title = "BHOP Acceleration (Negative Only)", Default = "-0.1", Placeholder = "-0.1", Numeric = false, Finished = false,
    Callback = function(Value) DConfiguration.Misc.MovementModification.BHOP.Acceleration = tonumber(Value) or -0.1 end
})

-- Auto Crouch

local function GetCrouchConfig()
    if not DConfiguration.Misc.MovementModification.BHOP.Crouch then
        DConfiguration.Misc.MovementModification.BHOP.Crouch = {
            FloatingButton = false,
            Type = "Ground",
            debounce = 0.1,
            lastTick = 0,
            isHolding = false,
        }
    end
    return DConfiguration.Misc.MovementModification.BHOP.Crouch
end

Tabs.Misc:AddParagraph({ Title = " ", Content = "" })

Tabs.Misc:AddToggle("AutoCrouch", {Title = "Auto Crouch (Button)", Default = false}):OnChanged(function(State)
    if State then
        local scale = DConfiguration.Settings.GuiScale.AutoCrouch or 0
        DFunctions.CreateButton("AutoCrouchGui", "Auto Crouch: OFF", 0.15 + scale, 0.1 + scale, function(btn)
            local Config = GetCrouchConfig()
            Config.FloatingButton = not Config.FloatingButton
            btn.Text = Config.FloatingButton and "Auto Crouch: ON" or "Auto Crouch: OFF"
            if not Config.FloatingButton then
                LocalPlayer.PlayerScripts.Events.temporary_events.UseKeybind:Fire({Key = "Crouch", Down = false})
                task.wait(0.1)
                LocalPlayer.PlayerScripts.Events.temporary_events.UseKeybind:Fire({Key = "Crouch", Down = false})
            end
        end)
    else
        DFunctions.DestroyButton("AutoCrouchGui")
    end
end)

Tabs.Misc:AddInput("CrouchButtonSize", {
    Title = "Auto Crouch Gui Size", Default = "0", Placeholder = "0", Numeric = true, Finished = false,
    Callback = function(Value)
        local num = tonumber(Value) or 0
        DConfiguration.Settings.GuiScale.AutoCrouch = num * 0.01
        DFunctions.UpdateButton("AutoCrouchGui", 0.15 + DConfiguration.Settings.GuiScale.AutoCrouch, 0.1 + DConfiguration.Settings.GuiScale.AutoCrouch)
    end
})

Tabs.Misc:AddDropdown("CrouchType", {
    Title = "Crouch Type",
    Values = {"Rapid", "Ground", "Air", "Normal"},
    Default = 2,
}):OnChanged(function(Value)
    GetCrouchConfig().Type = Value
end)

Tabs.Misc:AddInput("CrouchDebounce", {
    Title = "Crouch Speed (Debounce)", Default = "0.1", Placeholder = "0.1", Numeric = true, Finished = false,
    Callback = function(Value)
        GetCrouchConfig().debounce = tonumber(Value) or 0.1
    end
})


-- ============================================================
-- EXTEND DConfiguration with Visual and full Settings.GuiScale
-- ============================================================

DConfiguration.Visual = DConfiguration.Visual or {
    OriginalCosmetics = { Cosmetics1="", Cosmetics2="", Cosmetics3="", Cosmetics4="" },
    ModifyCosmetics   = { Cosmetics1="", Cosmetics2="", Cosmetics3="", Cosmetics4="" },
    OriginalEmotes    = { Emote1="",Emote2="",Emote3="",Emote4="",Emote5="",Emote6="",Emote7="",Emote8="",Emote9="",Emote10="",Emote11="",Emote12="" },
    ModifyEmotes      = { Emote1="",Emote2="",Emote3="",Emote4="",Emote5="",Emote6="",Emote7="",Emote8="",Emote9="",Emote10="",Emote11="",Emote12="" },
}

DConfiguration.Settings.GuiScale.SuperBounce   = DConfiguration.Settings.GuiScale.SuperBounce   or 0
DConfiguration.Settings.GuiScale.AutoCarry     = DConfiguration.Settings.GuiScale.AutoCarry     or 0
DConfiguration.Settings.GuiScale.InstantRevive = DConfiguration.Settings.GuiScale.InstantRevive or 0
DConfiguration.Settings.GuiScale.AutoEmoteDash = DConfiguration.Settings.GuiScale.AutoEmoteDash or 0
DConfiguration.Settings.GuiScale.Gravity       = DConfiguration.Settings.GuiScale.Gravity       or 0
DConfiguration.Settings.GuiScale.InfiniteSlide = DConfiguration.Settings.GuiScale.InfiniteSlide or 0
DConfiguration.Settings.GuiScale.AutoJump      = DConfiguration.Settings.GuiScale.AutoJump      or 0
DConfiguration.Settings.GuiScale.AutoCrouch    = DConfiguration.Settings.GuiScale.AutoCrouch    or 0
DConfiguration.Settings.GuiScale.LagSwitch     = DConfiguration.Settings.GuiScale.LagSwitch     or 0
DConfiguration.Settings.GuiScale.ColaScale     = DConfiguration.Settings.GuiScale.ColaScale     or 0
DConfiguration.Settings.GuiScale.EasyBounce    = DConfiguration.Settings.GuiScale.EasyBounce    or 0

local Lighting  = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local IsCurrentPlaying = false
local _SB = _SB or { Power = 100 }
local EmoteNames = {}
local SelectedVersion = "A"

-- Emote names (for Movement tab emote selector)
pcall(function()
    local EmotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Items"):WaitForChild("Emotes")
    for _, v in pairs(EmotesFolder:GetChildren()) do
        table.insert(EmoteNames, v.Name)
    end
end)

-- ============================================================
-- EXPLOITS TAB
-- ============================================================

local FakeSection = Tabs.Exploits:AddSection("Pads")

do
    local TeleportModule = { SelectedTP = nil, AvailableTPs = {}, LastCount = 0 }
    local deployables = workspace:WaitForChild("Game"):WaitForChild("Effects"):WaitForChild("Deployables")
    local event = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Other"):WaitForChild("DeployableUsed")

    local tpDropdown = Tabs.Exploits:AddDropdown("TeleporterList", {
        Title = "Select Teleporter", Values = {"None"}, Default = 1,
        Callback = function(Value) TeleportModule.SelectedTP = Value end
    })

    Tabs.Exploits:AddButton({
        Title = "Teleport",
        Description = "Must be standing on a teleporter",
        Callback = function()
            if TeleportModule.SelectedTP and TeleportModule.SelectedTP ~= "None" then
                for _, obj in pairs(deployables:GetChildren()) do
                    if obj.Name == "Teleporter" and tostring(obj:GetDebugId()) == TeleportModule.SelectedTP then
                        event:FireServer(obj) break
                    end
                end
            end
        end
    })

    RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local currentList = {}
        local nearTP = false
        for _, obj in pairs(deployables:GetChildren()) do
            if obj.Name == "Teleporter" then
                local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if primary then
                    if (root.Position - primary.Position).Magnitude < 7 then nearTP = true end
                    table.insert(currentList, tostring(obj:GetDebugId()))
                end
            end
        end
        if nearTP then
            if #currentList ~= TeleportModule.LastCount then
                TeleportModule.LastCount = #currentList
                tpDropdown:SetValues(currentList)
            end
        else
            if TeleportModule.LastCount > 0 then
                TeleportModule.LastCount = 0
                TeleportModule.SelectedTP = nil
                tpDropdown:SetValues({"None"})
            end
        end
    end)
end

do
    local boostEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Character"):WaitForChild("SpeedBoost").OnClientEvent
    local settings = { SpeedEnabled=false, SpeedValue=1.3, SpeedDuration=2, JumpEnabled=false, JumpPower=50 }
    local activeConnections, lastBoosts = {}, {}

    local function getDeployables()
        local g = workspace:FindFirstChild("Game")
        local e = g and g:FindFirstChild("Effects")
        return e and e:FindFirstChild("Deployables")
    end

    local function handlePad(pad)
        local name = pad.Name:lower()
        local isSpeed, isJump = name:find("speed"), name:find("jump")
        if not (isSpeed or isJump) then return end
        activeConnections[pad] = RunService.Heartbeat:Connect(function()
            if not pad.Parent then activeConnections[pad]:Disconnect(); activeConnections[pad] = nil; return end
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local dist = (hrp.Position - pad:GetPivot().Position).Magnitude
            if isSpeed and settings.SpeedEnabled and dist <= 9 then
                local now = os.clock()
                if now - (lastBoosts[pad] or 0) > 1 then
                    lastBoosts[pad] = now
                    pcall(firesignal, boostEvent, "SpeedPad", settings.SpeedValue, settings.SpeedDuration, Color3.new(0.49,0.6,1))
                end
            elseif isJump and settings.JumpEnabled and dist <= 7 then
                hrp.Velocity = Vector3.new(hrp.Velocity.X, settings.JumpPower, hrp.Velocity.Z)
            end
        end)
    end

    local function init()
        for _, conn in pairs(activeConnections) do conn:Disconnect() end
        activeConnections = {}
        local container = getDeployables()
        if not container then return end
        for _, pad in ipairs(container:GetChildren()) do handlePad(pad) end
        if not activeConnections._childAdded then
            activeConnections._childAdded = container.ChildAdded:Connect(function(child) task.wait(0.2); handlePad(child) end)
        end
    end

    Tabs.Exploits:AddToggle("SpeedPadToggle", { Title="SpeedPad Booster", Default=false, Callback=function(s) settings.SpeedEnabled=s; if s then init() end end })
    Tabs.Exploits:AddInput("SpeedValueInput", { Title="Speed Multiplier", Default="1.3", Numeric=true, Callback=function(t) settings.SpeedValue=tonumber(t) or 1.3 end })
    Tabs.Exploits:AddInput("SpeedDurationInput", { Title="Duration", Default="2", Numeric=true, Callback=function(t) settings.SpeedDuration=tonumber(t) or 2 end })
    Tabs.Exploits:AddToggle("JumpPadToggle", { Title="Jump Pad Booster", Default=false, Callback=function(s) settings.JumpEnabled=s; if s then init() end end })
    Tabs.Exploits:AddInput("JumpInput", { Title="Jump Power", Default="50", Numeric=true, Callback=function(v) settings.JumpPower=tonumber(v) or 50 end })

    LocalPlayer.CharacterAdded:Connect(function() task.wait(1); if settings.SpeedEnabled or settings.JumpEnabled then init() end end)
end

local oldTestHit, oldTestCollision
Tabs.Exploits:AddToggle("BuildAnywhere", { Title="Pads Build Bypass", Default=false,
    Callback=function(State)
        local buildModule = getrenv().require(game:GetService("ReplicatedStorage").Modules.Character.Tools.Modules.Methods.Build)
        if State then
            if not oldTestHit then oldTestHit = buildModule.TestHit end
            if not oldTestCollision then oldTestCollision = buildModule.TestCollision end
            buildModule.TestHit = function(...) return true end
            buildModule.TestCollision = function(...) return false, select(2, oldTestCollision(...)) end
        else
            if oldTestHit then buildModule.TestHit = oldTestHit end
            if oldTestCollision then buildModule.TestCollision = oldTestCollision end
        end
    end
})

Tabs.Exploits:AddSection("Grenade")

Tabs.Exploits:AddToggle("ReviveGrenadeToggle", { Title="Revive Grenade", Default=false,
    Callback=function(State)
        pcall(function()
            local RG = require(game:GetService("ReplicatedStorage").Tools["ReviveGrenade"])
            local t = RG.Tasks[1].Functions[1].Activations[1].Methods[1]
            local e = RG.Tasks[1].AutomaticFunctions[1].Methods[1]
            local u = RG.Tasks[1].AutomaticFunctions[2].Methods[1]
            if State then
                RG.RequiresOwnedItem=false; t.ItemUseIncrement={"ReviveGrenade",0}; t.Info.Cooldown=0.05
                t.Info.ThrowVelocity=200; RG.Tasks[1].Functions[1].Activations[1].CanHoldDown=true
                t.Info.SmokeDuration=999; t.Info.SmokeRadius=100; t.Info.FadeTime=60
                e.Info.Cooldown=0.1; u.Info.Cooldown=0.1; t.GlobalPriority=500; t.CooldownInfo={}
                RG.HUD.ShowAmount=false; t.Info.Density=0.9; t.Info.Color=Color3.new(0,1,0.5)
                t.Info.ExplosionRadius=20; t.CooldownInfo.ActivatePhrase=nil
                game:GetService("ReplicatedStorage").Events.Character.ToolAction:FireServer(0, 22)
            else
                RG.RequiresOwnedItem=true; t.ItemUseIncrement={"ReviveGrenade",1}; t.Info.Cooldown=1
                RG.Tasks[1].Functions[1].Activations[1].CanHoldDown=false
                t.Info.SmokeDuration=15; t.Info.SmokeRadius=15; RG.HUD.ShowAmount=true
            end
        end)
    end
})

Tabs.Exploits:AddToggle("SmokeGrenadeToggle", { Title="Smoke Grenade", Default=false,
    Callback=function(State)
        pcall(function()
            local SG = require(game:GetService("ReplicatedStorage").Tools["SmokeGrenade"])
            local t = SG.Tasks[1].Functions[1].Activations[1].Methods[1]
            local e = SG.Tasks[1].AutomaticFunctions[1].Methods[1]
            local u = SG.Tasks[1].AutomaticFunctions[2].Methods[1]
            if State then
                SG.RequiresOwnedItem=false; t.ItemUseIncrement={"SmokeGrenade",0}; t.Info.Cooldown=0.05
                t.Info.ThrowVelocity=200; SG.Tasks[1].Functions[1].Activations[1].CanHoldDown=true
                t.Info.SmokeDuration=999; t.Info.SmokeRadius=100; t.Info.FadeTime=60
                e.Info.Cooldown=0.1; u.Info.Cooldown=0.1; t.GlobalPriority=500; t.CooldownInfo={}
                SG.HUD.ShowAmount=false; t.Info.Density=0.9; t.Info.Color=Color3.new(0.7,0.7,0.7)
                t.Info.ExplosionRadius=20; t.CooldownInfo.ActivatePhrase=nil
                game:GetService("ReplicatedStorage").Events.Character.ToolAction:FireServer(0, 20)
            else
                SG.RequiresOwnedItem=true; t.ItemUseIncrement={"SmokeGrenade",1}; t.Info.Cooldown=1
                SG.Tasks[1].Functions[1].Activations[1].CanHoldDown=false
                t.Info.SmokeDuration=20; t.Info.SmokeRadius=15; SG.HUD.ShowAmount=true
            end
        end)
    end
})

Tabs.Exploits:AddSection("Cola Adjustments")

do
    local SpeedBoostEvent = ReplicatedStorage.Events.Character.SpeedBoost
    local ColaModule = pcall and (function() return require(ReplicatedStorage.Tools.Cola) end)() or nil
    pcall(function() ColaModule = require(ReplicatedStorage.Tools.Cola) end)

    local ColaCheat = { FixColaAnimation=true, UnlimitedCola=false, ModifyStats=true, CustomSpeed=1.4, CustomDuration=3.5 }

    local function GetSpeedBoostData()
        if not ColaModule then return nil end
        for _, task in ipairs(ColaModule.Tasks or {}) do
            for _, func in ipairs(task.AutomaticFunctions or {}) do
                if func.Phrase == "FinishDrink" then
                    for _, method in ipairs(func.Methods or {}) do
                        if method.Info then
                            if ColaCheat.ModifyStats then return ColaCheat.CustomSpeed, ColaCheat.CustomDuration, method.Info.Color
                            else return method.Info.SpeedBoost, method.Info.Duration, method.Info.Color end
                        end
                    end
                end
            end
        end
    end

    pcall(function()
        local UsePhrase = LocalPlayer.PlayerScripts.Events.UsePhrase
        local parent, name = UsePhrase.Parent, UsePhrase.Name
        local newFunction = Instance.new("BindableFunction")
        newFunction.Name = name; newFunction.Parent = parent
        newFunction.OnInvoke = function(...)
            local args = {...}
            if args[1] and type(args[1])=="table" and args[1].Phrase=="FinishDrink" then
                if ColaCheat.UnlimitedCola then
                    local tagValue = (LocalPlayer.Character or {}):GetAttribute and LocalPlayer.Character:GetAttribute("Tag")
                    if tagValue then
                        local speed, duration, color = GetSpeedBoostData()
                        if speed then pcall(firesignal, SpeedBoostEvent.OnClientEvent, "Drink", speed, duration, color) end
                        task.wait(2.25)
                        firesignal(ReplicatedStorage.Events.Character.PassCharacterInfo.OnClientEvent, buffer.fromstring(string.char(tagValue).."\18"), {"Weaponless"})
                    end
                    return nil
                else
                    if ColaCheat.ModifyStats then
                        firesignal(SpeedBoostEvent.OnClientEvent, "Drink", ColaCheat.CustomSpeed, ColaCheat.CustomDuration, Color3.new(0.78,0.55,0.36))
                    end
                    return UsePhrase:Invoke(...)
                end
            end
            return UsePhrase:Invoke(...)
        end
        UsePhrase:Destroy()
    end)

    do
        local ColaConfig = { Name="ColaButtonGui", Text="Cola", Event=ReplicatedStorage:WaitForChild("Events"):WaitForChild("Character"):WaitForChild("ToolAction") }
        Tabs.Exploits:AddToggle("ColaToggle", { Title="Cola Button", Default=false,
            Callback=function(State)
                if State then DFunctions.CreateButton(ColaConfig.Name, ColaConfig.Text, 0.15+DConfiguration.Settings.GuiScale.ColaScale, 0.1+DConfiguration.Settings.GuiScale.ColaScale, function() ColaConfig.Event:FireServer(0,20) end)
                else DFunctions.DestroyButton(ColaConfig.Name) end
            end
        })
        Tabs.Exploits:AddInput("ColaSizeInput", { Title="Cola Gui Size", Default="1", Numeric=true, Finished=false,
            Callback=function(Value)
                local num = tonumber(Value)
                if num then
                    DConfiguration.Settings.GuiScale.ColaScale = num * 0.01
                    DFunctions.UpdateButton(ColaConfig.Name, 0.15+DConfiguration.Settings.GuiScale.ColaScale, 0.1+DConfiguration.Settings.GuiScale.ColaScale)
                end
            end
        })
    end

    local featureStates = { AutoDrink=false, DrinkDelay=0.5 }
    local AutoDrinkThread = nil

    Tabs.Exploits:AddToggle("AutoDrinkToggle", { Title="Auto Drink Cola", Default=false,
        Callback=function(state)
            featureStates.AutoDrink = state
            if AutoDrinkThread then task.cancel(AutoDrinkThread); AutoDrinkThread=nil end
            if state then
                AutoDrinkThread = task.spawn(function()
                    while featureStates.AutoDrink do
                        pcall(function()
                            LocalPlayer.PlayerScripts.Events.temporary_events.UseKeybind:Fire({Forced=true,Key="Cola",Down=true})
                        end)
                        task.wait(featureStates.DrinkDelay)
                    end
                end)
            end
        end
    })

    Tabs.Exploits:AddInput("DrinkDelayInput", { Title="Drink Delay (seconds)", Default="0.5", Numeric=true, Finished=false,
        Callback=function(Value) local n=tonumber(Value); if n and n>0 then featureStates.DrinkDelay=n end end
    })

    Tabs.Exploits:AddParagraph({ Title=" ", Content="" })

    Tabs.Exploits:AddToggle("UnlimitedColaToggle", { Title="Infinite Cola", Default=false,
        Callback=function(state) ColaCheat.UnlimitedCola=state end
    })
    Tabs.Exploits:AddInput("ColaSpeedInput", { Title="Speed Value", Default="1.4", Placeholder="1.4", Numeric=true,
        Callback=function(value) local n=tonumber(value); if n and n>0 then ColaCheat.CustomSpeed=n end end
    })
    Tabs.Exploits:AddInput("ColaDurationInput", { Title="Duration", Default="3.5", Placeholder="3.5", Numeric=true,
        Callback=function(value) local n=tonumber(value); if n and n>0 then ColaCheat.CustomDuration=n end end
    })
end

-- ============================================================
-- VISUAL TAB
-- ============================================================

Tabs.Visual:AddSection("Character")

do
    local currentCarryAnim, selectedCarryAnim = "", ""
    local lastCurrentCarryAnim, lastSelectedCarryAnim = "", ""
    local isSwapped = false

    local function normalizeString(str) return str:gsub("%s+",""):lower() end
    local function isValidCarryAnimation(name)
        local folder = game:GetService("ReplicatedStorage"):FindFirstChild("Items")
        local caFolder = folder and folder:FindFirstChild("CarryAnimations")
        if not caFolder then return false end
        local n = normalizeString(name)
        for _, anim in ipairs(caFolder:GetChildren()) do
            if normalizeString(anim.Name) == n then return true, anim.Name end
        end
        return false
    end

    local function revertPreviousSwap()
        if lastCurrentCarryAnim~="" and lastSelectedCarryAnim~="" and isSwapped then
            local caFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Items") and game:GetService("ReplicatedStorage").Items:FindFirstChild("CarryAnimations")
            if caFolder then
                pcall(function()
                    local _, cA = isValidCarryAnimation(lastCurrentCarryAnim)
                    local _, sA = isValidCarryAnimation(lastSelectedCarryAnim)
                    if cA and sA then
                        local cF, sF = caFolder:FindFirstChild(cA), caFolder:FindFirstChild(sA)
                        if cF and sF then
                            local tmp = Instance.new("Folder"); tmp.Parent = caFolder
                            local tc, ts = Instance.new("Folder",tmp), Instance.new("Folder",tmp)
                            for _, c in ipairs(cF:GetChildren()) do c.Parent = tc end
                            for _, c in ipairs(sF:GetChildren()) do c.Parent = ts end
                            for _, c in ipairs(tc:GetChildren()) do c.Parent = sF end
                            for _, c in ipairs(ts:GetChildren()) do c.Parent = cF end
                            tmp:Destroy()
                        end
                    end
                end)
            end
            isSwapped = false
        end
    end

    local CCAInput = Tabs.Visual:AddInput("CurrentCarryAnimInput", { Title="Current CarryAnimation", Default="", Placeholder="Enter current carry animation name", Finished=false,
        Callback=function(Value) if Value~=currentCarryAnim and currentCarryAnim~="" then revertPreviousSwap() end; currentCarryAnim=Value end
    })
    local SCAInput = Tabs.Visual:AddInput("SelectedCarryAnimInput", { Title="Selected CarryAnimation", Default="", Placeholder="Enter selected carry animation name", Finished=false,
        Callback=function(Value) if Value~=selectedCarryAnim and selectedCarryAnim~="" then revertPreviousSwap() end; selectedCarryAnim=Value end
    })
    Tabs.Visual:AddButton({ Title="Apply CarryAnimation Swap", Callback=function()
        if normalizeString(currentCarryAnim)==normalizeString(selectedCarryAnim) or currentCarryAnim=="" or selectedCarryAnim=="" then return end
        local caFolder = game:GetService("ReplicatedStorage").Items:FindFirstChild("CarryAnimations")
        if not caFolder then return end
        local ok1,cA = isValidCarryAnimation(currentCarryAnim)
        local ok2,sA = isValidCarryAnimation(selectedCarryAnim)
        if not ok1 or not ok2 then return end
        pcall(function()
            revertPreviousSwap()
            local cF,sF = caFolder:FindFirstChild(cA), caFolder:FindFirstChild(sA)
            if not cF or not sF then return end
            local tmp = Instance.new("Folder"); tmp.Parent = caFolder
            local tc,ts = Instance.new("Folder",tmp), Instance.new("Folder",tmp)
            for _, c in ipairs(cF:GetChildren()) do c.Parent = tc end
            for _, c in ipairs(sF:GetChildren()) do c.Parent = ts end
            for _, c in ipairs(tc:GetChildren()) do c.Parent = sF end
            for _, c in ipairs(ts:GetChildren()) do c.Parent = cF end
            tmp:Destroy()
            lastCurrentCarryAnim=currentCarryAnim; lastSelectedCarryAnim=selectedCarryAnim; isSwapped=true
        end)
    end})
    Tabs.Visual:AddButton({ Title="Reset All CarryAnimations", Callback=function()
        revertPreviousSwap()
        currentCarryAnim=""; selectedCarryAnim=""; lastCurrentCarryAnim=""; lastSelectedCarryAnim=""; isSwapped=false
        CCAInput:SetValue(""); SCAInput:SetValue("")
    end})
end

Tabs.Visual:AddParagraph({ Title=" ", Content="" })

-- Visual Nametag
pcall(function()
    local nametagValues = {"Ignore","None"}
    local nametagsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Items"):WaitForChild("Nametags")
    for _, mod in ipairs(nametagsFolder:GetChildren()) do
        local ok, data = pcall(require, mod)
        if ok and data.AppearanceInfo then table.insert(nametagValues, data.AppearanceInfo.Name) end
    end
    local TagDropdown = Tabs.Visual:AddDropdown("VisualNametag", {
        Title="Visual Nametag", Values=nametagValues, Default="Ignore",
        Callback=function(Value)
            local folder = workspace.Game.Players:FindFirstChild(game.Players.LocalPlayer.Name)
            if folder then
                if Value=="None" then folder:SetAttribute("Nametag",nil)
                elseif Value~="Ignore" then folder:SetAttribute("Nametag",Value:gsub("%s+","")) end
            end
        end
    })
    game:GetService("RunService").Heartbeat:Connect(function()
        local val = TagDropdown.Value
        if val and val~="Ignore" then
            local folder = workspace.Game.Players:FindFirstChild(game.Players.LocalPlayer.Name)
            if folder then
                local clean = (val=="None") and nil or val:gsub("%s+","")
                if folder:GetAttribute("Nametag")~=clean then folder:SetAttribute("Nametag",clean) end
            end
        end
    end)
end)

-- Fake Statistics
local FakeSection = Tabs.Visual:AddSection("Fake Statistics")
local streakValue = 0
FakeSection:AddInput("StreakInput", { Title="Enter Streak Amount", Default="0", Placeholder="Number", Callback=function(Value) streakValue=tonumber(Value) end })
FakeSection:AddButton({ Title="Apply Fake Streak", Callback=function() if streakValue then game.Players.LocalPlayer:SetAttribute("Streak",streakValue) end end })

-- Cosmetics Changer
Tabs.Visual:AddSection("Cosmetics Changer")
for _, v in ipairs({"1","2"}) do
    Tabs.Visual:AddInput("O_C"..v, { Title="Current Cosmetics "..v, Default=" ", Placeholder="", Finished=false, Callback=function(Value) DConfiguration.Visual.OriginalCosmetics["Cosmetics"..v]=Value end })
end
Tabs.Visual:AddInput("O_C3", { Title="Current Effect", Default=" ", Placeholder="", Finished=false, Callback=function(Value) DConfiguration.Visual.OriginalCosmetics.Cosmetics3=Value end })
Tabs.Visual:AddInput("O_C4", { Title="Current Character", Default=" ", Placeholder="", Finished=false, Callback=function(Value) DConfiguration.Visual.OriginalCosmetics.Cosmetics4=Value end })
Tabs.Visual:AddParagraph({ Title=" ", Content="" })
for _, v in ipairs({"1","2"}) do
    Tabs.Visual:AddInput("M_C"..v, { Title="Select Cosmetics "..v, Default=" ", Placeholder="", Finished=false, Callback=function(Value) DConfiguration.Visual.ModifyCosmetics["Cosmetics"..v]=Value end })
end
Tabs.Visual:AddInput("M_C3", { Title="Select Effect", Default=" ", Placeholder="", Finished=false, Callback=function(Value) DConfiguration.Visual.ModifyCosmetics.Cosmetics3=Value end })
Tabs.Visual:AddInput("M_C4", { Title="Select Character", Default=" ", Placeholder="", Finished=false, Callback=function(Value) DConfiguration.Visual.ModifyCosmetics.Cosmetics4=Value end })
Tabs.Visual:AddButton({ Title="Apply Cosmetics", Callback=function()
    spawn(function()
        DFunctions.RestoreCosmetics(); wait(0.1)
        for i=1,4 do DFunctions.ChangeCosmetics(DConfiguration.Visual.OriginalCosmetics["Cosmetics"..i], DConfiguration.Visual.ModifyCosmetics["Cosmetics"..i]) end
    end)
end})
Tabs.Visual:AddButton({ Title="Restore Cosmetics", Callback=function() spawn(DFunctions.RestoreCosmetics) end })

-- Color Effect
Tabs.Visual:AddSection("Color Effect")
do
    local originalColors,originalSizes,originalGlow,affectedObjects = {},{},{},{}
    local rainbowConnection, rainbowSpeed, hue = nil, 1, 0

    local function isVisualEffect(o) return o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam") or o:IsA("Light") or o:IsA("SelectionBox") end
    local function applyThickness(o, m)
        pcall(function()
            if o:IsA("Trail") or o:IsA("Beam") then
                if not originalSizes[o] then originalSizes[o]={w0=o.Width0,w1=o.Width1} end
                o.Width0=originalSizes[o].w0*m; o.Width1=originalSizes[o].w1*m
            elseif o:IsA("ParticleEmitter") then
                if not originalSizes[o] then originalSizes[o]={size=o.Size} end
                if typeof(originalSizes[o].size)=="NumberSequence" then
                    local kps={}; for _,kp in ipairs(originalSizes[o].size.Keypoints) do table.insert(kps,NumberSequenceKeypoint.new(kp.Time,math.clamp(kp.Value*m,0,100))) end
                    o.Size=NumberSequence.new(kps)
                else o.Size=originalSizes[o].size*m end
            end
        end)
    end
    local function applyColor(o, col)
        if not (isVisualEffect(o) or o:IsA("BasePart")) then return end
        table.insert(affectedObjects,o)
        if not originalColors[o] then originalColors[o]=o.Color end
        pcall(function()
            if o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam") then
                o.Color = ColorSequence.new(col)
            else o.Color=col end
        end)
        applyThickness(o, DConfiguration.Visual.ModifyCosmetics.Thickness or 1)
    end
    local function refreshVisuals()
        if rainbowConnection then rainbowConnection:Disconnect(); rainbowConnection=nil end
        if not DConfiguration.Visual.ModifyCosmetics.ToggleEnabled then
            for obj,col in pairs(originalColors) do pcall(function() if obj and obj.Parent then obj.Color=col end end) end
            table.clear(originalColors); table.clear(originalSizes); table.clear(originalGlow); table.clear(affectedObjects)
            return
        end
        table.clear(affectedObjects)
        if DConfiguration.Visual.ModifyCosmetics.DynamicRainbowEnabled then
            for _,o in ipairs((LocalPlayer.Character or {}):GetDescendants() or {}) do pcall(function() if not originalColors[o] then originalColors[o]=o.Color end end) end
            rainbowConnection = RunService.Heartbeat:Connect(function(dt)
                if DConfiguration.Visual.ModifyCosmetics.ToggleEnabled and DConfiguration.Visual.ModifyCosmetics.DynamicRainbowEnabled then
                    hue=(hue+dt*(rainbowSpeed*0.1))%1
                    local c = Color3.fromHSV(hue,1,1)
                    for _,o in ipairs((LocalPlayer.Character or {}):GetDescendants() or {}) do applyColor(o,c) end
                end
            end)
        else
            local col = DConfiguration.Visual.ModifyCosmetics.SelectedColor or Color3.fromRGB(0,255,120)
            for _,o in ipairs((LocalPlayer.Character or {}):GetDescendants() or {}) do applyColor(o,col) end
        end
    end
    LocalPlayer.CharacterAdded:Connect(function() if DConfiguration.Visual.ModifyCosmetics.ToggleEnabled then task.wait(0.5); refreshVisuals() end end)

    Tabs.Visual:AddToggle("CosmeticsToggle", { Title="Enable Custom Color", Default=false, Callback=function(v) DConfiguration.Visual.ModifyCosmetics.ToggleEnabled=v; refreshVisuals() end })
    Tabs.Visual:AddColorpicker("EffectColor", { Title="Effect Color", Default=Color3.fromRGB(0,255,120),
        Callback=function(v) DConfiguration.Visual.ModifyCosmetics.SelectedColor=v; if DConfiguration.Visual.ModifyCosmetics.ToggleEnabled then refreshVisuals() end end
    })
    Tabs.Visual:AddInput("ThicknessInput", { Title="Effects Size", Default="1", Placeholder="1", Numeric=true, Finished=false,
        Callback=function(v) local n=tonumber(v); if n then DConfiguration.Visual.ModifyCosmetics.Thickness=n; if DConfiguration.Visual.ModifyCosmetics.ToggleEnabled then refreshVisuals() end end end
    })
    Tabs.Visual:AddToggle("StaticRainbowToggle", { Title="Static Rainbow (No Lag)", Default=false,
        Callback=function(v) DConfiguration.Visual.ModifyCosmetics.StaticRainbowEnabled=v; if v then DConfiguration.Visual.ModifyCosmetics.DynamicRainbowEnabled=false end; refreshVisuals() end
    })
    Tabs.Visual:AddToggle("DynamicRainbowToggle", { Title="Dynamic Rainbow (Laggy)", Default=false,
        Callback=function(v) DConfiguration.Visual.ModifyCosmetics.DynamicRainbowEnabled=v; if v then DConfiguration.Visual.ModifyCosmetics.StaticRainbowEnabled=false end; refreshVisuals() end
    })
    Tabs.Visual:AddInput("RainbowSpeedInput", { Title="Rainbow Speed", Default="1", Numeric=true, Finished=false,
        Callback=function(v) local n=tonumber(v); if n then rainbowSpeed=n end end
    })
end

-- Emote Changer
Tabs.Visual:AddSection("Emote Changer")
for i=1,12 do
    Tabs.Visual:AddInput("O_E"..i, { Title="Current Emote "..i, Default="", Finished=false, Callback=function(Value) DConfiguration.Visual.OriginalEmotes["Emote"..i]=Value end })
end
Tabs.Visual:AddParagraph({ Title=" ", Content="" })
for i=1,12 do
    Tabs.Visual:AddInput("M_E"..i, { Title="Select Emote "..i, Default="", Finished=false, Callback=function(Value) DConfiguration.Visual.ModifyEmotes["Emote"..i]=Value end })
end
Tabs.Visual:AddDropdown("EmoteOption", { Title="Select Animation Type", Values={"A","B","C","D"}, Multi=false, Default=1, Callback=function(Value) SelectedVersion=Value end })
Tabs.Visual:AddButton({ Title="Change Emotes", Callback=function()
    task.spawn(function()
        DFunctions.ResetEmoteChanges(); task.wait(0.1)
        for i=1,12 do DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes["Emote"..i], DConfiguration.Visual.ModifyEmotes["Emote"..i]) end
    end)
end})
Tabs.Visual:AddButton({ Title="Restore Emotes", Description="Having Trouble?", Callback=function() DFunctions.ResetEmoteChanges() end })

-- ============================================================
-- INFO TAB
-- ============================================================

Tabs.Info:AddParagraph({ Title="Hyperion X Hub - Evade Overhaul", Content="Created by Lucaswyrm, Stincer and L1ght" })
Tabs.Info:AddParagraph({ Title="Adjustments / Movement Modification", Content="Original system by Carey" })
Tabs.Info:AddParagraph({ Title="UI: Fluent", Content="Created by dawidscripts" })
Tabs.Info:AddButton({ Title="Discord Server", Description="Click to copy link", Callback=function() setclipboard("https://discord.gg/DzgZSV8gk5") end })

-- ============================================================
-- EXTENSION TAB
-- ============================================================

Tabs.Extension:AddSection("Character Extension")

-- Korblox / Headless toggles
DFunctions.KorbloxR = false
DFunctions.KorbloxL = false
DFunctions.Headless = false

Tabs.Extension:AddToggle("KorbloxRToggle", { Title="Korblox (Right)", Default=false, Callback=function(Value) DFunctions.KorbloxR=Value; DFunctions.UpdateVisuals() end })
Tabs.Extension:AddToggle("KorbloxLToggle", { Title="Korblox (Left)",  Default=false, Callback=function(Value) DFunctions.KorbloxL=Value; DFunctions.UpdateVisuals() end })
Tabs.Extension:AddToggle("HeadlessToggle",  { Title="Headless",        Default=false, Callback=function(Value) DFunctions.Headless=Value;  DFunctions.UpdateVisuals() end })
Tabs.Extension:AddParagraph({ Title=" ", Content="" })

-- Accessory Extensions
_G.Players = game:GetService("Players")
_G.LPlayer = _G.Players.LocalPlayer
_G.ExtStates = { Wings=false, Poison=false, Frozen=false, Fire=false, Doomsekkar=false, Frostsekkar=false, Infernosekkar=false, PoisonDusekkar=false }

_G.ApplySingleExt = function(id, name, state)
    if not state then
        if _G.LPlayer.Character and _G.LPlayer.Character:FindFirstChild(name) then _G.LPlayer.Character[name]:Destroy() end
        return
    end
    local char = _G.LPlayer.Character
    if not char or char:FindFirstChild(name) then return end
    local s, obj = pcall(function() return game:GetObjects("rbxassetid://"..id)[1] end)
    if s and obj then
        obj.Name=name; obj.Parent=char
        local h = obj:FindFirstChild("Handle")
        if h and h:IsA("BasePart") then
            h.CanCollide=false
            local w = Instance.new("Weld"); w.Part0=h
            if name=="Wings_Acc" then
                local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                w.Part1 = torso or char:FindFirstChild("Head")
                w.C0=obj.AttachmentPoint; w.C1=torso and CFrame.new(0,1.7,0.3) or CFrame.new(0,0.5,0)
            else w.Part1=char:FindFirstChild("Head"); w.C0=obj.AttachmentPoint; w.C1=CFrame.new(0,0.5,0) end
            w.Parent=h
        end
    end
end

_G.RefreshExts = function()
    if _G.ExtStates.Wings        then _G.ApplySingleExt(192557913,  "Wings_Acc",        true) end
    if _G.ExtStates.Poison       then _G.ApplySingleExt(1744060292, "Poison_Acc",       true) end
    if _G.ExtStates.Frozen       then _G.ApplySingleExt(74891470,   "Frozen_Acc",       true) end
    if _G.ExtStates.Fire         then _G.ApplySingleExt(215718515,  "Fire_Acc",         true) end
    if _G.ExtStates.Doomsekkar  then _G.ApplySingleExt(132809431,  "Doomsekkar_Acc",  true) end
    if _G.ExtStates.Frostsekkar then _G.ApplySingleExt(182672520,  "Frostsekkar_Acc", true) end
    if _G.ExtStates.Infernosekkar   then _G.ApplySingleExt(319643443, "Infernosekkar_Acc",   true) end
    if _G.ExtStates.PoisonDusekkar  then _G.ApplySingleExt(174405374, "PoisonDusekkar_Acc",  true) end
end

_G.LPlayer.CharacterAdded:Connect(function() task.wait(1.5); _G.RefreshExts() end)

Tabs.Extension:AddToggle("TogWings",      { Title="Angelic Wings",    Default=false, Callback=function(s) _G.ExtStates.Wings=s;        _G.ApplySingleExt(192557913,  "Wings_Acc",        s) end })
Tabs.Extension:AddToggle("TogPoison",     { Title="Poisonous Horns",  Default=false, Callback=function(s) _G.ExtStates.Poison=s;       _G.ApplySingleExt(1744060292, "Poison_Acc",       s) end })
Tabs.Extension:AddToggle("TogFrozen",     { Title="Frozen Horn",      Default=false, Callback=function(s) _G.ExtStates.Frozen=s;       _G.ApplySingleExt(74891470,   "Frozen_Acc",       s) end })
Tabs.Extension:AddToggle("TogFire",       { Title="Fire Horn",        Default=false, Callback=function(s) _G.ExtStates.Fire=s;         _G.ApplySingleExt(215718515,  "Fire_Acc",         s) end })
Tabs.Extension:AddToggle("TogDoomsekkar", { Title="Doomsekkar",       Default=false, Callback=function(s) _G.ExtStates.Doomsekkar=s;  _G.ApplySingleExt(132809431,  "Doomsekkar_Acc",  s) end })
Tabs.Extension:AddParagraph({ Title=" ", Content="" })

-- Remove Accessories
_G.DeleteHatsEnabled = false
task.spawn(function()
    while true do
        if _G.DeleteHatsEnabled then
            local char = LocalPlayer.Character
            if char then for _,v in ipairs(char:GetChildren()) do if v:IsA("Accessory") then v:Destroy() end end end
        end
        task.wait(0.1)
    end
end)
Tabs.Extension:AddToggle("DeleteHats", { Title="Remove Accessories", Default=false, Callback=function(Value) _G.DeleteHatsEnabled=Value end })
Tabs.Extension:AddButton({ Title="AvatarChanger", Description="By Byteed", Callback=function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-client-avatar-changer-92130"))() end })

Tabs.Extension:AddSection("Camera Extension")
Tabs.Extension:AddButton({ Title="Sensitivity", Description="", Callback=function() loadstring(game:HttpGet("https://raw.githubusercontent.com/inuaposzoawjsjs-glitch/.githubasset/refs/heads/master/MODDEDFLUENT/Sensitivity.lua"))() end })

Tabs.Extension:AddSection("Shader Extension")

local function ClearLighting()
    for _, child in ipairs(Lighting:GetChildren()) do
        if child.Name ~= "MenuBlur" then child:Destroy() end
    end
end

local function ApplyShader(props, effects)
    ClearLighting()
    for k,v in pairs(props) do Lighting[k]=v end
    for _, e in ipairs(effects) do
        local inst = Instance.new(e.Class)
        for k,v in pairs(e) do if k~="Class" then inst[k]=v end end
        inst.Parent=Lighting
    end
end

Tabs.Extension:AddButton({ Title="Day", Description="", Callback=function()
    ApplyShader(
        {Ambient=Color3.new(0,0,0),OutdoorAmbient=Color3.fromRGB(145,128,95),Brightness=3.13,ClockTime=14.5,FogEnd=3000,FogStart=300,GlobalShadows=true,Technology=Enum.Technology.ShadowMap,TimeOfDay="14:30:00"},
        {{Class="Sky",SkyboxBk="rbxassetid://6444884337",SkyboxDn="rbxassetid://6444884785",SkyboxFt="rbxassetid://6444884337",SkyboxLf="rbxassetid://6444884337",SkyboxRt="rbxassetid://6444884337",SkyboxUp="rbxassetid://6412503613",Name="Sky"},
         {Class="BloomEffect",Name="Bloom",Enabled=true,Intensity=1,Threshold=2,Size=90},
         {Class="ColorCorrectionEffect",Name="ColorCorrection",Enabled=true,Brightness=0.04,Contrast=0.19,Saturation=0.12,TintColor=Color3.new(1,1,1)}}
    )
end})

Tabs.Extension:AddButton({ Title="Night", Description="", Callback=function()
    ApplyShader(
        {Ambient=Color3.new(0,0,0),OutdoorAmbient=Color3.new(0,0,0),Brightness=2,ClockTime=3,FogEnd=100000,GlobalShadows=true,Technology=Enum.Technology.Future,TimeOfDay="03:00:00"},
        {{Class="Sky",Name="Sky",CelestialBodiesShown=true,SkyboxBk="rbxasset://textures/sky/sky512_bk.tex",SkyboxDn="rbxasset://textures/sky/sky512_dn.tex",SkyboxFt="rbxasset://textures/sky/sky512_ft.tex",SkyboxLf="rbxasset://textures/sky/sky512_lf.tex",SkyboxRt="rbxasset://textures/sky/sky512_rt.tex",SkyboxUp="rbxasset://textures/sky/sky512_up.tex",StarCount=5000},
         {Class="BlurEffect",Name="Blur",Enabled=true,Size=0},
         {Class="Atmosphere",Name="Atmosphere",Density=0.56,Color=Color3.new(0,0,0)}}
    )
end})

Tabs.Extension:AddButton({ Title="Sunset", Description="", Callback=function()
    ApplyShader(
        {Ambient=Color3.fromRGB(172,172,172),Brightness=3.8,ClockTime=7.1,GlobalShadows=true,Technology=Enum.Technology.Future,TimeOfDay="07:06:00"},
        {{Class="Sky",Name="Sky",CelestialBodiesShown=true,SkyboxBk="rbxassetid://1009082031",SkyboxDn="rbxassetid://1009082487",SkyboxFt="rbxassetid://1009082252",SkyboxLf="rbxassetid://1009082137",SkyboxRt="rbxassetid://1009081946",SkyboxUp="rbxassetid://1009082428",SunAngularSize=9},
         {Class="BloomEffect",Name="Bloom",Enabled=true,Intensity=1,Threshold=1.82,Size=56},
         {Class="ColorCorrectionEffect",Name="ColorCorrection",Enabled=true,Contrast=0.1,Saturation=-0.2,TintColor=Color3.new(1,1,1)}}
    )
end})

Tabs.Extension:AddButton({ Title="Cloudy", Description="", Callback=function()
    ApplyShader(
        {Brightness=5.63,ClockTime=17.63,GlobalShadows=true,Technology=Enum.Technology.ShadowMap,TimeOfDay="17:37:44"},
        {{Class="Sky",Name="Sky",CelestialBodiesShown=true,SkyboxBk="rbxassetid://2177969403",SkyboxDn="rbxassetid://2177972406",SkyboxFt="rbxassetid://2177970251",SkyboxLf="rbxassetid://2177969836",SkyboxRt="rbxassetid://2177968823",SkyboxUp="rbxassetid://2177971305",StarCount=500},
         {Class="BloomEffect",Name="Bloom",Enabled=true,Intensity=1,Threshold=2,Size=90},
         {Class="ColorCorrectionEffect",Name="ColorCorrection",Enabled=true,Brightness=0.04,Contrast=0.15,Saturation=0.2,TintColor=Color3.new(1,1,1)}}
    )
end})

Tabs.Extension:AddSection("Custom Sky")
task.spawn(function()
    local skyData = {
        Default="", BlackHole3D="rbxassetid://80849072113452", BlackHole2D="rbxassetid://107612473658715",
        Galaxy="rbxassetid://103103587555183", Saturn="rbxassetid://78498232605923", Moon="rbxassetid://130749862399911",
        Retro="rbxassetid://103427685372239", BlueEye="rbxassetid://127514067186397",
        RetroDiscord="rbxassetid://89057708562209", Cat="rbxassetid://120407577036889", Cat2="rbxassetid://127289321458446",
    }
    local skyNames = {}
    for n in pairs(skyData) do table.insert(skyNames, n) end
    table.sort(skyNames)
    Tabs.Extension:AddDropdown("SkyboxChanger", { Title="Skybox Selection", Values=skyNames, Default="Default",
        Callback=function(v)
            local oldSky = Lighting:FindFirstChild("CustomSkybox")
            if oldSky then oldSky:Destroy() end
            if v~="Default" and skyData[v] and skyData[v]~="" then
                local newCs = Instance.new("Sky"); newCs.Name="CustomSkybox"
                for _, side in ipairs({"SkyboxBk","SkyboxDn","SkyboxFt","SkyboxLf","SkyboxRt","SkyboxUp"}) do newCs[side]=skyData[v] end
                newCs.Parent=Lighting
            end
        end
    })

    Tabs.Extension:AddSection("Ambient Extension")
    Tabs.Extension:AddToggle("RainbowAmbient", { Title="Rainbow Ambient", Default=false,
        Callback=function(Value)
            if DFunctions.rbConn then DFunctions.rbConn:Disconnect() end
            if Value then
                DFunctions.rbConn = game:GetService("RunService").RenderStepped:Connect(function()
                    local c = Color3.fromHSV((tick()*0.2)%1, 0.8, 1)
                    Lighting.Ambient=c; Lighting.OutdoorAmbient=c
                end)
            else Lighting.Ambient=Color3.fromRGB(127,127,127); Lighting.OutdoorAmbient=Color3.fromRGB(128,128,128) end
        end
    })
end)

-- Full Bright & Fog
do
    local fbConnection, fogConnection = nil, nil
    local OriginalFogEnd = Lighting.FogEnd
    getgenv().FbBrightnessValue = 2

    local function applyFullBright()
        Lighting.Ambient=Color3.new(1,1,1); Lighting.ColorShift_Bottom=Color3.new(1,1,1)
        Lighting.ColorShift_Top=Color3.new(1,1,1); Lighting.FogEnd=100000
        Lighting.GlobalShadows=false; Lighting.ClockTime=14; Lighting.Brightness=getgenv().FbBrightnessValue
    end

    local FBToggle = Tabs.Extension:AddToggle("FullBright", { Title="Full Bright", Default=false })
    local FBInput  = Tabs.Extension:AddInput("FbBrightnessInput", { Title="Full Bright Brightness", Default="2", Placeholder="Enter brightness level...", Numeric=true, Finished=false })

    FBToggle:OnChanged(function(state)
        if fbConnection then fbConnection:Disconnect(); fbConnection=nil end
        if state then
            applyFullBright()
            fbConnection = Lighting.Changed:Connect(function(p)
                if p=="Ambient" or p=="Brightness" or p=="FogEnd" or p=="GlobalShadows" then applyFullBright() end
            end)
        else
            Lighting.GlobalShadows=true; Lighting.Ambient=Color3.fromRGB(128,128,128); Lighting.Brightness=1; Lighting.FogEnd=1000
        end
    end)
    FBInput:OnChanged(function()
        local v = tonumber(FBInput.Value)
        getgenv().FbBrightnessValue = v or 2
        if Options.FullBright.Value then applyFullBright() end
    end)

    Tabs.Extension:AddToggle("NoFogToggle", { Title="Disable Fog", Default=false,
        Callback=function(Value)
            if fogConnection then fogConnection:Disconnect(); fogConnection=nil end
            if Value then
                Lighting.FogEnd=100000
                local A=Lighting:FindFirstChildOfClass("Atmosphere")
                if A then A.Density=0; A.Glare=0; A.Haze=0 end
                fogConnection = Lighting:GetPropertyChangedSignal("FogEnd"):Connect(function() Lighting.FogEnd=100000 end)
            else Lighting.FogEnd=OriginalFogEnd or 1000 end
        end
    })
end

Tabs.Extension:AddSection("Anti Lags Extension")
Tabs.Extension:AddToggle("Anti_Lag1", { Title="Anti Lag 1", Default=false,
    Callback=function(Value)
        if Value then
            for _,v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
                    v.Material=Enum.Material.SmoothPlastic
                    if v:IsA("Texture") then v:Destroy() end
                end
            end
        end
    end
})
Tabs.Extension:AddToggle("Anti_Lag2", { Title="Anti Lag 2", Default=false,
    Callback=function(Value)
        if Value then
            local g=game; local l=g.Lighting; local t=workspace.Terrain
            t.WaterWaveSize=0; t.WaterWaveSpeed=0; t.WaterReflectance=0; t.WaterTransparency=0
            l.GlobalShadows=false; l.FogEnd=9e9; l.Brightness=0
            settings().Rendering.QualityLevel="Level01"
            wait(1)
            for _,v in pairs(g:GetDescendants()) do
                if v:IsA("Part") or v:IsA("Union") or v:IsA("MeshPart") then v.Material="Plastic"; v.Reflectance=0
                elseif v:IsA("Decal") then v.Transparency=1
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Lifetime=NumberRange.new(0) end
            end
        end
    end
})
Tabs.Extension:AddToggle("Anti_Lag3", { Title="Anti Lag 3", Default=false,
    Callback=function(Value)
        if Value then
            local l=Lighting; local t=workspace.Terrain
            pcall(sethiddenproperty, l, "Technology", 2)
            t.WaterWaveSize=0; t.WaterWaveSpeed=0; l.GlobalShadows=false; l.FogEnd=9e9; l.Brightness=0
            settings().Rendering.QualityLevel="Level01"
            for _,v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") then v.Material="Plastic"; v.Reflectance=0
                elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency=1
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Lifetime=NumberRange.new(0) end
            end
        end
    end
})
Tabs.Extension:AddButton({ Title="No Render", Description="", Callback=function()
    Lighting.GlobalShadows=false; Lighting.FogEnd=1e10; Lighting.Brightness=1
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then obj.Material=Enum.Material.Plastic; obj.Reflectance=0
        elseif obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("ParticleEmitter") or obj:IsA("Trail") then obj:Destroy() end
    end
end})

task.spawn(function()
    Tabs.Extension:AddToggle("ShadowsToggle", { Title="Remove All Shadows", Default=false,
        Callback=function(state)
            Lighting.GlobalShadows=not state
            for _,obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then obj.CastShadow=not state end
            end
        end
    })
end)

task.spawn(function()
    Tabs.Extension:AddToggle("DarknessToggle", { Title="Disable Light", Default=false,
        Callback=function(state)
            for _,light in ipairs(workspace:GetDescendants()) do
                if light:IsA("Light") then light.Enabled=not state; task.wait() end
            end
        end
    })
end)

task.spawn(function()
    local FpsConfig = { Enabled=false }
    local function updateFps()
        pcall(function()
            local target = FpsConfig.Enabled and 9999 or 60
            if setfflag then setfflag("TaskSchedulerTargetFps",tostring(target)); setfflag("DFIntTaskSchedulerTargetFps",tostring(target)) end
            if setfpscap then setfpscap(target) end
        end)
    end

    local AntiGPTPause = Tabs.Extension:AddToggle("AntiNetworkPause", { Title="Anti Gameplay Paused", Default=false })
    AntiGPTPause:OnChanged(function(Value)
        if Value then
            pcall(function()
                local RobloxGui = game:GetService("CoreGui"):WaitForChild("RobloxGui")
                local current = RobloxGui:FindFirstChild("CoreScripts/NetworkPause")
                if current then current:Destroy() end
                RobloxGui.ChildAdded:Connect(function(obj) if obj.Name=="CoreScripts/NetworkPause" then task.wait(); obj:Destroy() end end)
            end)
        end
    end)

    Tabs.Extension:AddToggle("FpsUnlockToggle", { Title="Unlock FPS", Default=false, Callback=function(Value) FpsConfig.Enabled=Value; updateFps() end })

    while true do if FpsConfig.Enabled then updateFps() end; task.wait(5) end
end)

Tabs.Extension:AddSection("Fast Flag Extension")
if setfflag then
    Tabs.Extension:AddButton({ Title="Blox Strap Script", Description="", Callback=function() loadstring(game:HttpGet('https://raw.githubusercontent.com/qwertyui-is-back/Bloxstrap/main/Initiate.lua'),'lol')() end })
end

-- ============================================================
-- CONFIGURATION / SETTINGS TAB
-- ============================================================

Tabs.Settings:AddParagraph({ Title="Configuration", Content=" " })
Tabs.Settings:AddToggle("FPSCounterToggle", { Title="FPS & Ping Counter", Default=true, Callback=function(Value) ToggleFPSCounter(Value) end })

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("HyperionXHub/Evade")
SaveManager:SetFolder("HyperionXHub/Evade")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- ============================================================
-- AUTO LOAD & CHARACTER HOOKS
-- ============================================================

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()

local IsPCMode = false

LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)
    if child.Name == "Shared" then IsCurrentPlaying = true end
end)

if UserInputService.TouchEnabled then
    pcall(function()
        local returnValues = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Character"):WaitForChild("CharacterTable"):WaitForChild("CharacterController"):WaitForChild("Local"):WaitForChild("Movement"):WaitForChild("returnValues"))
        local old = returnValues.new
        returnValues.new = function(...)
            local result = {old(...)}
            task.delay(1, function()
                table.clear(CurrentAdjustment)
                local unpacked = table.unpack(result)
                for i,v in pairs(unpacked) do
                    if i=="overrideMovementStats" or i=="defaultMovementStats" then table.insert(CurrentAdjustment, v) end
                end
                if #CurrentAdjustment > 0 then DFunctions.SetPreviousAdjustment() end
            end)
            return table.unpack(result)
        end
    end)
else
    IsPCMode = true
end

local lastRespawn = 0

LocalPlayer.CharacterRemoving:Connect(function()
    if IsCurrentPlaying then IsCurrentPlaying=false; DFunctions.ResetEmoteChanges() end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    lastRespawn = tick()
    IsCurrentPlaying = true
    task.delay(3, function()
        if IsPCMode and LocalPlayer.Character then
            table.clear(CurrentAdjustment); DFunctions.GetAdjustments(); task.wait(1)
            if #CurrentAdjustment > 0 then DFunctions.SetPreviousAdjustment() end
        end
        local currentSpawnTime = lastRespawn
        repeat task.wait(1) until LocalPlayer.PlayerGui:FindFirstChild("Shared") or lastRespawn~=currentSpawnTime
        if lastRespawn==currentSpawnTime then DFunctions.RestoreEmoteChanges() end
    end)
end)

if LocalPlayer.Character then
    DFunctions.UpdateVisuals()
end

-- ============================================================
-- INFO TAB
-- ============================================================

Tabs.Info:AddParagraph({ Title = "Hyperion X Hub - Evade Overhaul", Content = "Made by Lucaswyrm, Stincer and L1ght" })
Tabs.Info:AddParagraph({ Title = "Adjustments / Movement Modification", Content = "Original systems by Carey" })
Tabs.Info:AddParagraph({ Title = "UI: Fluent", Content = "Created by dawidscripts" })
Tabs.Info:AddButton({
    Title = "Discord Server",
    Description = "Click to copy link",
    Callback = function()
        setclipboard("https://discord.gg/DzgZSV8gk5")
    end
})
