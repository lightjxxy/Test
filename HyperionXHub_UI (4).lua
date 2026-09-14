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
openshit.Parent = LocalPlayer.PlayerGui
openshit.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
openshit.ResetOnSpawn = false

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
local AssetsIcon = "rbxassetid://128870297075007"
local AssetsBackground = "rbxassetid://135015813011627"

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

-- Select first tab
Window:SelectTab(1)
