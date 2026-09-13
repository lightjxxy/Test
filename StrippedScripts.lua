-- Scripts

function CreateBillboardESP(Name, Part, Color, TextSize)
  if not Part or Part:FindFirstChild(Name) then return nil end

  local BillboardGui = Instance.new("BillboardGui")
  local TextLabel = Instance.new("TextLabel")
  local TextStroke = Instance.new("UIStroke")

  BillboardGui.Parent = Part
  BillboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
  BillboardGui.Name = Name
  BillboardGui.AlwaysOnTop = true
  BillboardGui.LightInfluence = 1
  BillboardGui.Size = UDim2.new(0, 200, 0, 50)
  BillboardGui.StudsOffset = Vector3.new(0, 2.5, 0)
  BillboardGui.MaxDistance = 1000

  TextLabel.Parent = BillboardGui
  TextLabel.BackgroundTransparency = 1
  TextLabel.Size = UDim2.new(1, 0, 1, 0)
  TextLabel.TextScaled = false
  TextLabel.Font = Enum.Font.SourceSans
  TextLabel.TextSize = TextSize or 14
  TextLabel.TextColor3 = Color or Color3.fromRGB(255, 255, 255)

  TextStroke.Parent = TextLabel
  TextStroke.Thickness = 1
  TextStroke.Color = Color3.new(0, 0, 0)

  return BillboardGui
end

function UpdateBillboardESP(Name, Part, NameText, Color, TextSize, PartPosition)
  if not Part then return false end

  local esp = Part:FindFirstChild(Name)
  if esp and esp:FindFirstChildOfClass("TextLabel") then
    local label = esp:FindFirstChildOfClass("TextLabel")
    
    if Color then
      label.TextColor3 = Color
    end
    
    if TextSize then
      label.TextSize = TextSize
    end
    
    if PartPosition then
      local Pos 
      if typeof(PartPosition) == "Instance" and PartPosition:IsA("BasePart") then
        Pos = PartPosition.Position
      elseif typeof(PartPosition) == "Vector3" then
        Pos = PartPosition
      end

      if Pos then
        local distance = math.floor((Pos - Part.Position).Magnitude)
        local name = NameText or Part.Parent and Part.Parent.Name or Part.Name
        label.Text = string.format("%s - [ %d M ]", name, distance)
      end
    else
      local name = NameText or Part.Parent and Part.Parent.Name or Part.Name
      label.Text = name
    end    
    return true
  end
  return false
end

function DestroyBillboardESP(Name, Part)
  if not Part then return false end
  
  local esp = Part:FindFirstChild(Name)
  if esp then
    esp:Destroy()
    return true
  end
  
  return false
end

function CreateTracerESP(tracerTable, part, thickness, color)
  local tracer = Drawing.new("Line")
  tracer.Thickness = thickness or 2
  tracer.Color = color or Color3.fromRGB(255, 255, 255)
  tracer.Transparency = 1
  tracer.Visible = false
  tracerTable[part] = tracer
  return tracer
end

function UpdateTracerESP(tracerTable, part, color)
  local tracer = tracerTable[part]
  if not tracer then return end

  if typeof(part) ~= "Instance" then
    tracerTable[part] = nil
    return
  end
  
  if not part.Parent or not part:IsDescendantOf(workspace) then
    tracer.Visible = false
    DestroyTracerESP(tracerTable, part)
    return
  end

  local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(part.Position)  
  if onScreen then
    if color then tracer.Color = color end
    tracer.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
    tracer.To = Vector2.new(screenPos.X, screenPos.Y)
    tracer.Visible = true
  else
    tracer.Visible = false
  end
end

function DestroyTracerESP(tracerTable, part)
  if typeof(part) ~= "Instance" then
    tracerTable[part] = nil
    return
  end
  
  local tracer = tracerTable[part]
  if tracer then 
    if tracer.Remove then tracer:Remove() end
    tracerTable[part] = nil
  end 
end

function CreateHighlightESP(Name, Part, HighlightColor, OutlineColor, ShowHighlight)
  if not Part then return false end

  local Highlight = Instance.new("Highlight")
  Highlight.Name = Name
  Highlight.FillColor = HighlightColor or Color3.fromRGB(255, 255, 255)
  Highlight.OutlineColor = OutlineColor or Color3.fromRGB(0, 0, 0)

  if ShowHighlight then
    Highlight.FillTransparency = 0
  else
    Highlight.FillTransparency = 1
  end

  Highlight.OutlineTransparency = 0
  Highlight.Parent = Part

  return true
end

function UpdateHighlightESP(Name, Part, HighlightColor, OutlineColor, ShowHighlight)
  local Highlight = Part and Part:FindFirstChild(Name)

  if not Highlight or not Highlight:IsA("Highlight") then return false end

  if HighlightColor then Highlight.FillColor = HighlightColor end
  if OutlineColor then Highlight.OutlineColor = OutlineColor end

  if ShowHighlight ~= nil then
    Highlight.FillTransparency = ShowHighlight and 0 or 0.5
  end

  return true
end

function DestroyHighlightESP(Name, Part)
  local Highlight = Part and Part:FindFirstChild(Name)

  if Highlight and Highlight:IsA("Highlight") then
    Highlight:Destroy()
    return true
  end

  return false
end

-- Local Variables
local DFunctions = {}
local DConfiguration = {
    ESP = {
        Players = false,
        Nextbots = false,
        Tickets = false,
        Objective = false,
    },

    Tracers = {
        Players = false,
        Nextbots = false,
        Tickets = false,
        Objective = false,
    },
    
    Highlight = {
        Players = false,
        Nextbots = false,
        Tickets = false,
        Objective = false,
        OutlineOnly = false,
    },

    Boxes = {
        Players = false,
        Nextbots = false,
        Tickets = false,
        Objective = false,
    },

    Removals = {
        CameraShake = false,
        Vignette = false,
        InvisibleWalls = false,
        ReducingRewards = false,
        DamageParts = false,
    },

    Main = {
        AntiAFK = true,
        AutoRespawn = false,
        RespawnType = "Spawnpoint",
        AutoWhistle = false,
        ShowTimer = false,
        Fly = false,
        FlySpeed = 20,
        Noclip = false,
    },
    
    Battlepass = {
	    BypassTimer = false,
    },

    AutoFarm = {
        FarmingStates = {
            IsReviving = false,
            IsCompletingObjective = false,
            IsCollectingTickets = false,
        },

        AFKFarm = false,
        FarmTickets = false,
        CompleteObjective = false,
        FarmTokens = false,
        
        PurchaseAutomations = {
            Enabled = false,
	        Selected = "Cola",	        
        },
        
        VIPAutomations = {
            AutoVote = false,
            MapSection = 1,
            GamemodeSection = 1,
	        AutoMap = false,
	        MapInput = "DesertBus",
	        AutoSpecialRound = false,
	        SpecialRoundInput = "Plushie Hell",
	        AutoTimer = false,
	        TimerInput = "",
	        AutoProMode = false,
        },
    },

    Nextbots = {
        AntiNextbot = false,
        AntiNextbotRange = 15,
        AntiNextbotType = "Spawn",
    },

    Misc = {
        PlayerAdjustment = {
            Default = {
                Speed = 1500,
                JumpHeight = 3,
                JumpCap = 1,
                JumpAcceleration = 1.5,
                AirStrafe = 182,
                GroundAcceleration = 5,
            },

            Update = {
                Speed = 1500,
                JumpHeight = 3,
                JumpCap = 1,
                JumpAcceleration = 1.5,
                AirStrafe = 182,
                GroundAcceleration = 5,
            },

            Saved = {
                Speed = 1500,
                JumpHeight = 3,
                JumpCap = 1,
                JumpAcceleration = 1.5,
                AirStrafe = 182,
                GroundAcceleration = 5,
            },

            Tick = {
                Speed = 0,
                JumpHeight = 0,
                JumpCap = 0,
                JumpAcceleration = 0,
                AirStrafe = 0,
                GroundAcceleration = 0,
            },

            Debounce = {
                Speed = false,
                JumpHeight = false,
                JumpCap = false,
                JumpAcceleration = false,
                AirStrafe = false,
                GroundAcceleration = false,
            },
        },

        Humanoids = {
            WalkspeedCF = false,
            OriginalJumpHeight = false,
            CF = 5,
            JP = 20,
        },

        Utilities = {
            GetCurrentSpeed = 0,

            BounceModification = {
                Enabled = false,
                DefaultBounce = 80,
                EmoteBounce = 120,
                SuperBounce = false,
                SuperBounceStrength = -50,
            },
            
            EdgeTrimpModification = {
	            Enabled = false,
	            HeightMultiplier = 1.5,
	            DownThreshold = 4.5
            },

            LagSwitch = {
                MSDelay = 200,
                Mode = "Normal",
            },
        },

        CameraAdjustment = {
            StretchX = 1,
            StretchY = 1,
        },

        GunAdjustment = {
            v = nil,
        },

        GameAutomation = {
            Revive = {
                Enabled = false,
                FloatingButton = false,
                Keybind = false,
                WhileEmote = false,
                Delay = 0.1,
            },

            Carry = {
                Enabled = false,
                FloatingButton = false,
                Keybind = false,
                WhileEmote = false,
            },

            Macro = {
                SelectedEmote = "BoldMarch",
                FloatingButton = false,
                Keybind = false,
            },
        },

        MovementModification = {
            AggressiveEmoteDash = {
                Enabled = false,
                Type = "Blatant",
                Speed = 3000,
                Acceleration = -2,
            },

            SlideModification = {
                FloatingButton = false,
                Enabled = false,
                Acceleration = -3,
            },

            Gravity = {
                FloatingButton = false,
                Keybind = false,
                Value = 10,
            },

            BHOP = {
                Enabled = false,
                Keybind = false,
                FloatingButton = false,
                AutoAcceleration = false,
                MaxSpeed = 70,
                SpiderHop = false,
                Backwards = false,
                JumpButton = false,
                HipHeight1 = 0,
                HipHeight2 = 0,
                Type = "Acceleration",
                JumpType = "Simulated",
                Acceleration = -0.1,
                lastTick = 0.01,

                Crouch = {
                    FloatingButton = false,
                    Keybind = false,
                    Type = "Ground",
                    lastTick = 0.1,
                    lastReleaseTick = 0.1,
                },
            },
        },

        AntiLags = {
            Low = false,
            Moderate = false,
            High = false,
        },
    },
    
    Visual = {
        OriginalCosmetics = {
            Cosmetics1 = "",
            Cosmetics2 = "",
            Cosmetics3 = "",
            Cosmetics4 = "",
        },
        
        ModifyCosmetics = {
            Cosmetics1 = "",
            Cosmetics2 = "",
            Cosmetics3 = "",
            Cosmetics4 = "",
        },

        OriginalEmotes = {
            Emote1 = "",
            Emote2 = "",
            Emote3 = "",
            Emote4 = "",
            Emote5 = "",
            Emote6 = "",
            Emote7 = "",
            Emote8 = "",
            Emote9 = "",
            Emote10 = "",
            Emote11 = "",
            Emote12 = "",
        },

        ModifyEmotes = {
            Emote1 = "",
            Emote2 = "",
            Emote3 = "",
            Emote4 = "",
            Emote5 = "",
            Emote6 = "",
            Emote7 = "",
            Emote8 = "",
            Emote9 = "",
            Emote10 = "",
            Emote11 = "",
            Emote12 = "",
        },
    },

    Settings = {
        GuiScale = {
            Respawn = 0,
            SuperBounce = 0,
            AutoCarry = 0,
            InstantRevive = 0,
            AutoEmoteDash = 0,
            Gravity = 0,
            InfiniteSlide = 0,
            AutoJump = 0,
            AutoCrouch = 0,
            LagSwitch = 0,
        },
    },
}

-- Shit Buttons

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

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 28, 0, 28)
    toggle.Position = UDim2.new(1, 6, 0.5, -14)
    toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    toggle.Text = "○"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.Visible = false
    toggle.ZIndex = -8
    toggle.Parent = frame

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1, 0)
    tc.Parent = toggle

    local originalSize = UDim2.new(Size1, 0, Size2, 0)
    local holding = false
    local holdStart = 0
    local hideAt = 0

    frame:SetAttribute("IsCircle", false)

    local isCircle
    if CircleMode ~= nil then
        isCircle = CircleMode
    else
        isCircle = frame:GetAttribute("IsCircle")
    end

    local function applyShape(circle)
        frame:SetAttribute("IsCircle", circle)
        local s = math.min(frame.AbsoluteSize.X, frame.AbsoluteSize.Y)
        if circle then
            frame.Size = UDim2.new(0, s, 0, s)
            button.TextWrapped = true
            button.TextScaled = true
            button.TextSize = math.floor(s * 0.45)
            corner.CornerRadius = UDim.new(1, 0)
            toggle.Text = "▢"
        else
            frame.Size = originalSize
            button.TextWrapped = false
            button.TextScaled = false
            button.TextSize = 24
            corner.CornerRadius = UDim.new(0, 15)
            toggle.Text = "○"
        end
    end

    applyShape(isCircle)

    task.spawn(function()
        while task.wait(0.25) do
            if not frame.Parent then break end
            if toggle.Visible and tick() - hideAt >= 10 then
                toggle.Visible = false
            end
        end
    end)

    button.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            holding = true
            holdStart = tick()
        end
    end)

    button.InputEnded:Connect(function(i)
        if holding and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
            holding = false
            if tick() - holdStart >= 0.6 then
                toggle.Visible = true
                hideAt = tick()
            end
        end
    end)

    toggle.MouseButton1Click:Connect(function()
        hideAt = tick()
        local current = frame:GetAttribute("IsCircle")
        applyShape(not current)
    end)

    button.Activated:Connect(function()
        if ScriptLogic then
            ScriptLogic(button)
        end
    end)

    FBM:AddButton(ButtonName, frame, false)
    MakeDraggable(button, frame, false)

    return button
end

function DFunctions.UpdateButton(Name, Size1, Size2)
    local gui = LocalPlayer.PlayerGui:FindFirstChild(Name)
    if gui then
        local frame = gui:FindFirstChild(Name)
        if frame then
            frame.Size = UDim2.new(Size1, 0, Size2, 0)
            local isCircle = frame:GetAttribute("IsCircle")
            if isCircle then
                local s = math.min(frame.AbsoluteSize.X, frame.AbsoluteSize.Y)
                frame.Size = UDim2.new(0, s, 0, s)
            end
        end
    end
end

function DFunctions.DestroyButton(Name)
    local gui = LocalPlayer.PlayerGui:FindFirstChild(Name)
    if gui then
        gui:Destroy()
    end
end


-- main

function DFunctions.AutoRespawn()
 	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	 if char and char:GetAttribute("Downed") == true and DConfiguration.Main.RespawnType == "Spawnpoint" then
		 game:GetService("ReplicatedStorage").Events.Player.ChangePlayerMode:FireServer(true)
     elseif char and char:GetAttribute("Downed") == true and DConfiguration.Main.RespawnType == "Fake Revive" then
	     local PreviousPosition
	     PreviousPosition = LocalPlayer.Character.HumanoidRootPart.Position
    	 wait(0.2)
	     game:GetService("ReplicatedStorage").Events.Player.ChangePlayerMode:FireServer(true)
	     wait(1)
	     LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(PreviousPosition)
	 end
end

function DFunctions.Whistle()
   game:GetService("ReplicatedStorage").Events.Character.Whistle:FireServer()
end

function DFunctions.RemoveDamagePart()
   local Map = game.Workspace.Game.Map
   
   for i, v in pairs(Map:GetDescendants()) do
     if v:IsA("BasePart") and v.CanTouch == true then
          v.CanTouch = false
       end
   end
end

function DFunctions.DisableTouch(t)
	for i, v in next, t:GetChildren() do
		if v.IsA(v, 'BasePart') then
			v.CanTouch = false
		end
	end
end

function DFunctions.DisableInvisParts(state)
    for i, v in pairs(Workspace.Game.Map.InvisParts:GetChildren()) do
       if v:IsA("BasePart") then
          v.CanCollide = state
       end
    end
end

function DFunctions.DisableCameraShake()
    local FOVAdjusters = LocalPlayer:FindFirstChild("PlayerScripts") and LocalPlayer.PlayerScripts:FindFirstChild("Camera") and LocalPlayer.PlayerScripts.Camera:FindFirstChild("FOVAdjusters")
    local CameraSet = LocalPlayer:FindFirstChild("PlayerScripts") and LocalPlayer.PlayerScripts:FindFirstChild("Camera") and LocalPlayer.PlayerScripts.Camera:FindFirstChild("Set")

    if FOVAdjusters and CameraSet then
       FOVAdjusters:SetAttribute("Fear", 1)
       CameraSet:Invoke("CFrameOffset", "Shake", CFrame.new())
    end
end

function DFunctions.DisableVignette()
	local HUD = LocalPlayer:FindFirstChild("Shared") and LocalPlayer.Shared:FindFirstChild("HUD")
	local NextbotNoise = HUD and HUD:FindFirstChild("NextbotNoise")
	
	if HUD and NextbotNoise then
	   NextbotNoise.ImageTransparency = 1
	   local Noise = NextbotNoise:FindFirstChild("Noise")
	   local Noise2 = NextbotNoise:FindFirstChild("Noise2")
	   
	   if Noise then
	       Noise.ImageTransparency = 1
	   elseif Noise2 then
	       Noise2.ImageTransparency = 1
	   end
	end
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

function DFunctions.GetDownedPlayer()
    for i,v in pairs(Workspace.Game.Players:GetChildren()) do
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
            if part then
                table.insert(Parts, part)
            end
        end
    end

    if #Parts == 0 then
        return nil
    end

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
	if section1 then
	    ReplicatedStorage.Events.Player.Vote:FireServer(section1)
	end
	
	if section2 then
	    ReplicatedStorage.Events.Player.Vote:FireServer(section1, true)
	end
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

local EmoteNames = {}
local LoadoutNames = {}

function DFunctions.GetEmotesName()
    EmoteNames = {}
    local emotesFolder = game:GetService("ReplicatedStorage").Items.Emotes

    for _, thing in ipairs(emotesFolder:GetChildren()) do
        if thing:IsA("LocalScript") or thing:IsA("ModuleScript") then
            EmoteNames[#EmoteNames + 1] = thing.Name 
        end
        if _ % 50 == 0 then
            task.wait(3)
        end
    end

    return EmoteNames
end

function DFunctions.GetLoadoutName()
    LoadoutNames = {}
    local loadoutFolder = game:GetService("ReplicatedStorage").Items.Loadout

    for _, thing in ipairs(loadoutFolder:GetChildren()) do
        if thing:IsA("LocalScript") or thing:IsA("ModuleScript") then
            LoadoutNames[#LoadoutNames + 1] = thing.Name 
        end
        if _ % 50 == 0 then
            task.wait(3)
        end
    end

    return LoadoutNames
end

DFunctions.GetEmotesName()
DFunctions.GetLoadoutName()

function DFunctions.AntiNextbot()
    if Workspace:FindFirstChild("Game") and game.Workspace.Game:FindFirstChild("Players") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
    
        local playerTeam = Workspace.Game.Players[LocalPlayer.Name]:GetAttribute("Team")
        if playerTeam == "Nextbot" then
            return 
        end
    
        for i, v in pairs(Workspace.Game.Players:GetDescendants()) do
            if v:IsA("Model") and v:GetAttribute("Team") == "Nextbot" then
                local humanoidRootPart = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("HRP")
                if humanoidRootPart then
                    if not LocalPlayer.Character and not LocalPlayer.Character.HumanoidRootPart then 
                        return
                    end
                    
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                    
                    if distance < DConfiguration.Nextbots.AntiNextbotRange then
                        if DConfiguration.Nextbots.AntiNextbotType == "Spawn" then
                            local parts = workspace.Game.Map.ItemSpawns:GetChildren()
                            local randomPart = parts[math.random(1, #parts)]
                            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(randomPart.Position)
                        elseif DConfiguration.Nextbots.AntiNextbotType == "Players" then
                            local randomPlayer = Players:GetPlayers()[math.random(1, #game.Players:GetPlayers())]
                            if randomPlayer then
                              LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(randomPlayer.Character.Head.Position.X, randomPlayer.Character.Head.Position.Y, randomPlayer.Character.Head.Position.Z)
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Player Adjustment

local CurrentAdjustment = {}

function DFunctions.GetAdjustments()
	table.clear(CurrentAdjustment)
	local character = LocalPlayer.Character
	if not character then
		return
	end

	for _, v in pairs(getgc(true)) do
		if type(v) == "table" then
			local char = rawget(v, "Character")
			local stats = rawget(v, "overrideMovementStats")
			local stats2 = rawget(v, "defaultMovementStats")

			if typeof(char) == "Instance" and char == character then
				if type(stats) == "table" then
					table.insert(CurrentAdjustment, stats)
				end
				if type(stats2) == "table" then
					table.insert(CurrentAdjustment, stats2)
				end
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
            if rawget(stats, "Speed") then
                rawset(stats, "Speed", newSpeed)
            end
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
            if rawget(stats, "JumpHeight") then
                rawset(stats, "JumpHeight", newJump)
            end
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
            if rawget(stats, "JumpCap") then
                rawset(stats, "JumpCap", newJumpCap)
            end
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
            if rawget(stats, "JumpSpeedMultiplier") then
                rawset(stats, "JumpSpeedMultiplier", newJumpAcce)
            end
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
            if rawget(stats, "Friction") then
                rawset(stats, "Friction", newFriction)
            end
        end
    end
end

function DFunctions.setBhopEnabled(bool)
    for i = 1, #CurrentAdjustment do
        local stats = CurrentAdjustment[i]
        if rawget(stats, "BhopEnabled") ~= nil then
            rawset(stats, "BhopEnabled", bool)
        end
    end
end

function DFunctions.setStrafeAcceleration(newAcceleration)
    local now = tick()
    if DConfiguration.Misc.PlayerAdjustment.Default.AirStrafe ~= newAcceleration and now - DConfiguration.Misc.PlayerAdjustment.Tick.AirStrafe >= 0.1 then
        DConfiguration.Misc.PlayerAdjustment.Default.AirStrafe = newAcceleration
        DConfiguration.Misc.PlayerAdjustment.Tick.AirStrafe = now

        for i = 1, #CurrentAdjustment do
            local stats = CurrentAdjustment[i]
            if rawget(stats, "AirStrafeAcceleration") then
                rawset(stats, "AirStrafeAcceleration", newAcceleration)
            end
            if rawget(stats, "AirAcceleration") then
                rawset(stats, "AirAcceleration", 3)
            end
        end
    end
end

function DFunctions.SetPreviousAdjustment()
    for i = 1, #CurrentAdjustment do
        local stats = CurrentAdjustment[i]

        if rawget(stats, "Speed") then
            rawset(stats, "Speed", DConfiguration.Misc.PlayerAdjustment.Default.Speed)
        end
        if rawget(stats, "JumpHeight") then
            rawset(stats, "JumpHeight", DConfiguration.Misc.PlayerAdjustment.Default.JumpHeight)
        end
        if rawget(stats, "JumpCap") then
            rawset(stats, "JumpCap", DConfiguration.Misc.PlayerAdjustment.Default.JumpCap)
        end
        if rawget(stats, "JumpSpeedMultiplier") then
            rawset(stats, "JumpSpeedMultiplier", DConfiguration.Misc.PlayerAdjustment.Default.JumpAcceleration)
        end
        if rawget(stats, "AirStrafeAcceleration") then
            rawset(stats, "AirStrafeAcceleration", DConfiguration.Misc.PlayerAdjustment.Default.AirStrafe)
        end
        if rawget(stats, "AirAcceleration") then
            rawset(stats, "AirAcceleration", 3)
        end
    end
end

function DFunctions.GetSpeedometer()
    local shared = LocalPlayer.PlayerGui:WaitForChild("Shared", 9e9)
    local speedometer = shared.HUD.Overlay.Default.CharacterInfo.Item:WaitForChild("Speedometer", 9e9)
    local player = speedometer.Players
    
    return player
end

function DFunctions.SuperBounce()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local HumanoidRootPart = char:FindFirstChild("HumanoidRootPart")
    local Humanoid = char:FindFirstChild("Humanoid")
    local PreviousHipHeight = 0
    
    if char:FindFirstChild("R15Visual") then
        PreviousHipHeight = 0.75
    else
	    PreviousHipHeight = -1.25
    end
   
    if not HumanoidRootPart or not Humanoid then return end
    
    HumanoidRootPart.CanCollide = false
    Humanoid.HipHeight = -100
    wait(2)
    HumanoidRootPart.CanCollide = true
    Humanoid.HipHeight = PreviousHipHeight
end

local CachedRayParams = RaycastParams.new()
CachedRayParams.FilterType = Enum.RaycastFilterType.Exclude

function DFunctions.StartLag(ms)
	local LagTime = ms * 0.002
	local mode = DConfiguration.Misc.Utilities.LagSwitch.Mode
	local character = LocalPlayer.Character
	if not character then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local storedVelocity = hrp.AssemblyLinearVelocity
	if storedVelocity.Magnitude < 1 then return end

	local start = tick()
	while tick() - start < LagTime do end
	
	if mode == "FastFlag" or LagTime < 0.2 then
	   setfflag("MaxMissedWorldStepsRemembered", "9999")
	   return
	end
	
	if mode ~= "Demon" or LagTime < 0.2 then return end

	CachedRayParams.FilterDescendantsInstances = {character}
	local multiplier = math.random(2, 4)
	local horizontalVelocity = Vector3.new(storedVelocity.X, 0, storedVelocity.Z)
	local direction = horizontalVelocity.Magnitude > 0 and horizontalVelocity.Unit or hrp.CFrame.LookVector
	local distance = math.min(horizontalVelocity.Magnitude * LagTime * multiplier, 30)
	local forwardPos = hrp.Position + direction * distance
	local targetPos = forwardPos

	local forwardResult = workspace:Raycast(hrp.Position, forwardPos - hrp.Position, CachedRayParams)
	if forwardResult then
		targetPos = forwardResult.Position - direction * 2
	end

	local function detectSlope(dir, dist)
		return workspace:Raycast(hrp.Position + dir * dist, Vector3.new(0, -60, 0), CachedRayParams)
	end

	local longSlopeCheck = detectSlope(direction, 50)
	local shortSlopeCheck = nil

	for i = 2, 20, 2 do
		local result = detectSlope(direction, i)
		if result then
			shortSlopeCheck = result
			break
		end
	end

	local slopeLengthBoost, shortSlopeBoost = 1, 1
	local slopeDirBoost = 1
	local hoverBuffer = 0
	local slopeAngle = 0
	local earlyBounce = false

	if longSlopeCheck then
		local normal = longSlopeCheck.Normal
		slopeAngle = math.deg(math.acos(normal:Dot(Vector3.new(0, 1, 0))))
		if slopeAngle >= 20 and slopeAngle <= 80 then
			slopeLengthBoost = math.clamp(slopeAngle / 25, 1, 2.2)
			slopeDirBoost = math.clamp(slopeAngle / 40, 1, 2)
			hoverBuffer = math.clamp((slopeAngle - 20) * 0.06, 0, 3)
			if slopeAngle < 35 then
				targetPos = targetPos + Vector3.new(0, 3, 0) + direction * (2 * slopeDirBoost)
			else
				targetPos = targetPos + Vector3.new(0, slopeAngle * 0.3 + hoverBuffer, 0)
			end
		end
	end

	if shortSlopeCheck then
		local normal = shortSlopeCheck.Normal
		slopeAngle = math.deg(math.acos(normal:Dot(Vector3.new(0, 1, 0))))
		if slopeAngle >= 20 and slopeAngle <= 80 then
			shortSlopeBoost = math.clamp(slopeAngle / 22, 1, 2.5)
			slopeDirBoost = slopeDirBoost + math.clamp(slopeAngle / 50, 0, 1.6)
			hoverBuffer = hoverBuffer + math.clamp((slopeAngle - 20) * 0.05, 0, 3)
			local verticalDist = hrp.Position.Y - shortSlopeCheck.Position.Y
			local minForward = 4
			local minUp = 4
			if slopeAngle >= 50 and verticalDist < 3 then
				earlyBounce = true
				targetPos = targetPos + direction * minForward + Vector3.new(0, minUp, 0)
			else
				if slopeAngle < 35 then
					targetPos = targetPos + Vector3.new(0, 3, 0) + direction * (2 * slopeDirBoost)
				else
					targetPos = targetPos + Vector3.new(0, slopeAngle * 0.4 + hoverBuffer, 0)
				end
			end
		end
	end

	if slopeAngle >= 35 then
		targetPos = targetPos + direction * (5 * slopeDirBoost)
	end

	local safetyCheck = workspace:Raycast(hrp.Position, targetPos - hrp.Position, CachedRayParams)
	if safetyCheck then
		targetPos = safetyCheck.Position + Vector3.new(0, 2, 0) - direction * 2
	end

	if shortSlopeCheck or longSlopeCheck then
		local hitPos = (shortSlopeCheck or longSlopeCheck).Position
		local verticalDist = hrp.Position.Y - hitPos.Y
		if verticalDist < 2 then
			targetPos = hrp.Position + direction * 2 + Vector3.new(0, 2, 0)
		end
	end

	hrp.CFrame = CFrame.new(targetPos, targetPos + hrp.CFrame.LookVector)

	local delta = targetPos - hrp.Position
	local speed = storedVelocity.Magnitude
	local forwardBoost = math.clamp(speed * 0.4, 4, 20)
	local safeDir = delta.Magnitude > 0 and delta.Unit or direction
	local safeCheck = workspace:Raycast(hrp.Position, safeDir * forwardBoost, CachedRayParams)

	if not safeCheck then
		hrp.AssemblyLinearVelocity += safeDir * forwardBoost
	else
		local safeDist = (safeCheck.Position - hrp.Position).Magnitude
		if safeDist > 3 then
			hrp.AssemblyLinearVelocity += safeDir * (safeDist * 0.6)
		end
	end

	local bounceMultiplier = 1.2
	if slopeAngle >= 45 then
		local angleBoost = math.clamp((slopeAngle - 45) / 20, 0, 1.0)
		bounceMultiplier = 1.2 + angleBoost
	end

	if storedVelocity.Y < -60 then
		bounceMultiplier *= 0.9 * slopeLengthBoost * shortSlopeBoost
	elseif storedVelocity.Y < -30 then
		bounceMultiplier *= 1.0 * slopeLengthBoost * shortSlopeBoost
	end

	if storedVelocity.Y < -10 then
		local angleFactor = math.clamp((slopeAngle - 20) / 40, 0, 1)
		local bounceY = math.abs(storedVelocity.Y) * (1.1 + angleFactor * 0.9)
		bounceY = bounceY + storedVelocity.Magnitude * (0.3 + angleFactor * 0.5)
		bounceY = math.clamp(bounceY * bounceMultiplier * 1.0, 0, 60 + storedVelocity.Magnitude * 0.4)

		hrp.AssemblyLinearVelocity = Vector3.new(
			storedVelocity.X * slopeDirBoost,
			bounceY,
			storedVelocity.Z * slopeDirBoost
		)

		if earlyBounce then
			local forwardBoost = math.clamp(5 + storedVelocity.Magnitude * 0.1, 6, 20)
			local forwardCheck = workspace:Raycast(hrp.Position, direction * forwardBoost, CachedRayParams)
			if not forwardCheck then
				hrp.CFrame = hrp.CFrame + direction * forwardBoost
			else
				local safeDist = (forwardCheck.Position - hrp.Position).Magnitude
				if safeDist > 3 then
					hrp.CFrame = hrp.CFrame + direction * (safeDist * 0.5)
				end
			end
		end
	end

	hrp.Size = Vector3.new(3, 20, 3)
end

function DFunctions.BounceFunction()
    local speedometer = DFunctions.GetSpeedometer()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = char and char:FindFirstChild("Humanoid")

    if speedometer then
        DConfiguration.Misc.Utilities.GetCurrentSpeed = tonumber(speedometer.Text)
    end

    if not DConfiguration.Misc.Utilities.BounceModification.Enabled and humanoid then
        humanoid.WalkSpeed = 0
        return
    end
     
    if char and humanoid then
        if char:GetAttribute("State") == "Default" or char:GetAttribute("State") == "Downed" or not DConfiguration.Misc.Utilities.BounceModification.Enabled then
            humanoid.WalkSpeed = 0
        elseif char:GetAttribute("State") == "Emoting" or char:GetAttribute("State") == "EmotingAir" or char:GetAttribute("State") == "EmotingSlide" or char:GetAttribute("State") == "EmotingSlideAir" then
            humanoid.WalkSpeed = DConfiguration.Misc.Utilities.BounceModification.EmoteBounce + DConfiguration.Misc.Utilities.GetCurrentSpeed
        elseif DConfiguration.Misc.Utilities.GetCurrentSpeed < 15 or char:GetAttribute("State") == "Default" then
            humanoid.WalkSpeed = 0
        else
            humanoid.WalkSpeed = DConfiguration.Misc.Utilities.BounceModification.DefaultBounce + DConfiguration.Misc.Utilities.GetCurrentSpeed
        end
    end
end

local WorkspacePlayers = game:GetService("Workspace").Game.Players

function DFunctions.getNearestDownedPlayer()
    local nearestPlayer = nil
    local nearestDistance = 10
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local localPos = hrp.Position

    for _, player in pairs(WorkspacePlayers:GetChildren()) do
        local targetHRP = player:FindFirstChild("HumanoidRootPart")
        if player:GetAttribute("Downed") and targetHRP and not targetHRP.Anchored then
            local distance = (localPos - targetHRP.Position).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestPlayer = player
            end
        end
    end

    return nearestPlayer
end

local EdgeParams = RaycastParams.new()
EdgeParams.FilterType = Enum.RaycastFilterType.Blacklist
EdgeParams.FilterDescendantsInstances = {}

function DFunctions.ModifyEdgeTrimp()
    local Character = LocalPlayer.Character
    if not Character then return end

    local Root = Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Root or not Humanoid then return end

    local Velocity = Root.AssemblyLinearVelocity
    local HorizontalVel = Vector3.new(Velocity.X, 0, Velocity.Z)
    local Speed = HorizontalVel.Magnitude
    if Speed < 22 then return end

    local MoveDir = HorizontalVel.Unit
    local LookDir = Root.CFrame.LookVector.Unit

    EdgeParams.FilterDescendantsInstances = {Character}

    local PredictTime = math.clamp(Speed / 110, 0.14, 0.24)
    local EarlyOffset = 2.5

    local FutureMovePos = Root.Position + HorizontalVel * PredictTime + MoveDir * EarlyOffset
    local FutureLookPos = Root.Position + HorizontalVel * PredictTime + LookDir * EarlyOffset

    if Velocity.Y > 5 then return end

    local validEdge = false
    local minRaysForTrigger = 2
    local maxSlope = 0.8
    local minHeightDiff = 1.5

    local fanOffsets = {
        Vector3.new(0,0,0),
        Vector3.new(0.25,0,0.25),
        Vector3.new(-0.25,0,-0.25),
        Vector3.new(0.25,0,-0.25),
        Vector3.new(-0.25,0,0.25)
    }

    local moveHits = 0
    local lookHits = 0

    for _, offset in ipairs(fanOffsets) do
        local startMove = FutureMovePos + offset
        local forwardHitMove = workspace:Raycast(startMove + Vector3.new(0,2,0), MoveDir * 3.5, EdgeParams)

        if forwardHitMove and forwardHitMove.Normal.Y < 0.2 then
            local topCheckMove = workspace:Raycast(
                forwardHitMove.Position + Vector3.new(0,2.2,0),
                Vector3.new(0,-5,0),
                EdgeParams
            )

            if topCheckMove and topCheckMove.Normal.Y >= maxSlope then
                if topCheckMove.Position.Y - Root.Position.Y > minHeightDiff then
                    moveHits += 1
                end
            end
        end

        local startLook = FutureLookPos + offset
        local forwardHitLook = workspace:Raycast(startLook + Vector3.new(0,2,0), LookDir * 3.5, EdgeParams)

        if forwardHitLook and forwardHitLook.Normal.Y < 0.2 then
            local topCheckLook = workspace:Raycast(
                forwardHitLook.Position + Vector3.new(0,2.2,0),
                Vector3.new(0,-5,0),
                EdgeParams
            )

            if topCheckLook and topCheckLook.Normal.Y >= maxSlope then
                if topCheckLook.Position.Y - Root.Position.Y > minHeightDiff then
                    lookHits += 1
                end
            end
        end
    end

    if moveHits >= 1 and lookHits >= 1 then
        validEdge = true
    end

    local downVotes = 0
    local earlyForward = MoveDir * 2
    local dropThreshold = DConfiguration.Misc.Utilities.EdgeTrimpModification.DownThreshold
    local halfDepth = Root.Size.Z / 2
    local forwardDistances = {
	    halfDepth + 0.1,
	    halfDepth + 0.4,
	    halfDepth + 0.7,
	    halfDepth + 1
    }

    for _, offset in ipairs(fanOffsets) do
        local startPos = FutureMovePos + offset + earlyForward

        local downHit = workspace:Raycast(
            startPos + Vector3.new(0,2,0),
            Vector3.new(0,-6,0),
            EdgeParams
        )

        if downHit then
            local drop = Root.Position.Y - downHit.Position.Y

            local edgeFound = false

            for _, dist in ipairs(forwardDistances) do
                local check = workspace:Raycast(
                    Root.Position + MoveDir * dist,
                    Vector3.new(0,-6,0),
                    EdgeParams
                )

                if not check then
                    edgeFound = true
                    break
                end
            end

            if drop >= dropThreshold and edgeFound then
                downVotes += 1
            end
        end
    end

    if downVotes >= minRaysForTrigger then
        validEdge = true
    end

    if not validEdge then return end

    Root.AssemblyLinearVelocity =
        HorizontalVel * 1.05 +
        Vector3.new(0, math.clamp(Speed * 0.7, 22, 85), 0) *
        DConfiguration.Misc.Utilities.EdgeTrimpModification.HeightMultiplier
end

local WorkspacePlayers = game:GetService("Workspace").Game.Players

function DFunctions.getNearestDownedPlayer()
    local nearestPlayer = nil
    local nearestDistance = 10
    local HumanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then return nil end

    for _, v in pairs(WorkspacePlayers:GetChildren()) do
        local targetRoot = v:FindFirstChild("HumanoidRootPart")
        if v:GetAttribute("Downed") and targetRoot and not targetRoot.Anchored then
            local distance = (HumanoidRootPart.Position - targetRoot.Position).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestPlayer = v
            end
        end
    end

    return nearestPlayer
end

function DFunctions.InstantRevive()
    local nearestPlayer = DFunctions.getNearestDownedPlayer()
    if not nearestPlayer then return end

    local state = LocalPlayer.Character:GetAttribute("State")
    local allowWhileEmote = DConfiguration.Misc.GameAutomation.Revive.WhileEmote or (state == "Run" or state == "Air" or state == "Slide" or state == "Fall" or state == "Jump" or state == "Crouch")

    if allowWhileEmote then
        for i = 1, 7 do
            ReplicatedStorage.Events.Character.Interact:FireServer("Revive", nil, tostring(nearestPlayer))
            ReplicatedStorage.Events.Character.Interact:FireServer("Revive", false, tostring(nearestPlayer))
            ReplicatedStorage.Events.Character.Interact:FireServer("Revive", true, tostring(nearestPlayer))
        end
    end
end

function DFunctions.CarryPlayer()
    local nearestPlayer = DFunctions.getNearestDownedPlayer()
    if not nearestPlayer then return end

    local state = LocalPlayer.Character:GetAttribute("State")
    local allowWhileEmote = DConfiguration.Misc.GameAutomation.Carry.WhileEmote or (state == "Run" or state == "Air" or state == "Slide" or state == "Fall" or state == "Jump" or state == "Crouch")

    if allowWhileEmote then
        for i = 1, 7 do
            ReplicatedStorage.Events.Character.Interact:FireServer("Carry", nil, tostring(nearestPlayer))
            ReplicatedStorage.Events.Character.Interact:FireServer("Carry", false, tostring(nearestPlayer))
            ReplicatedStorage.Events.Character.Interact:FireServer("Carry", true, tostring(nearestPlayer))
        end
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
	
	if DConfiguration.Misc.MovementModification.AggressiveEmoteDash.Type == "Blatant" and (char and char:GetAttribute("State") == "Emoting" or char:GetAttribute("State") == "EmotingAir" or char:GetAttribute("State") == "EmotingSlide" or char:GetAttribute("State") == "EmotingSlideAir") then
		DConfiguration.Misc.PlayerAdjustment.Update.Speed = DConfiguration.Misc.MovementModification.AggressiveEmoteDash.Speed
	else
	    DConfiguration.Misc.PlayerAdjustment.Update.Speed = DConfiguration.Misc.PlayerAdjustment.Saved.Speed
	end
end

function DFunctions.InfiniteSlideFunction()
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	
	if char and char:GetAttribute("State") == "Slide" or char:GetAttribute("State") == "EmotingSlide" then
		DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = DConfiguration.Misc.MovementModification.SlideModification.Acceleration
	else
		DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = 5
	end
end

function DFunctions.BHOPFunction()
    local speedometer = DFunctions.GetSpeedometer()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoidrootpart = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local debounce
    
    if not char then return end
    if not humanoidrootpart then return end
    if not humanoid then return end
    
    if DConfiguration.Misc.MovementModification.BHOP.SpiderHop and char and char:GetAttribute("State") == "Wallrunning" then
        LocalPlayer.PlayerScripts.Events.temporary_events.EndJump:Fire()
        LocalPlayer.PlayerScripts.Events.temporary_events.JumpReact:Fire()
    end
    
    if DConfiguration.Misc.MovementModification.BHOP.Type == "Acceleration" then
        if tonumber(speedometer.Text) > 60 then
            if char:FindFirstChild("R15Visual") then
                DConfiguration.Misc.MovementModification.BHOP.HipHeight2 = 1
            else
                DConfiguration.Misc.MovementModification.BHOP.HipHeight2 = -1.05
            end
        else
            if char:FindFirstChild("R15Visual") then
                DConfiguration.Misc.MovementModification.BHOP.HipHeight2 = 0.9
            else
                DConfiguration.Misc.MovementModification.BHOP.HipHeight2 = -1.10
            end
        end
        
        debounce = 0.01
        humanoid.HipHeight = DConfiguration.Misc.MovementModification.BHOP.HipHeight2
    elseif DConfiguration.Misc.MovementModification.BHOP.Type == "Ground Acceleration" then
        if char:FindFirstChild("R15Visual") then
           DConfiguration.Misc.MovementModification.BHOP.HipHeight2 = 0.5
        else
           DConfiguration.Misc.MovementModification.BHOP.HipHeight2 = -2
        end
        
        humanoid.HipHeight = DConfiguration.Misc.MovementModification.BHOP.HipHeight2
        debounce = 0.01      
    elseif DConfiguration.Misc.MovementModification.BHOP.Type == "No Acceleration" then
        debounce = 0.125
    end
    
    local CanBHOPBackwards = true
    
    if DConfiguration.Misc.MovementModification.BHOP.AutoAcceleration then
        local Speed = tonumber(speedometer.Text)
        local Threshold = math.clamp(Speed, 25, 50)
        local Devisor = math.clamp(Speed / Threshold, 0, 6) 
        local Decrease = math.clamp(5 - (Devisor * 1.7), 0.01, 2)
        
        if Speed < DConfiguration.Misc.MovementModification.BHOP.MaxSpeed then
            DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = DConfiguration.Misc.MovementModification.BHOP.Acceleration
            CanBHOPBackwards = true
        else 
            DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = Decrease
            CanBHOPBackwards = false
        end
    else
        DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = DConfiguration.Misc.MovementModification.BHOP.Acceleration
    end
    
    local now = tick()
    local lastGrounded = 0

    if humanoid.FloorMaterial ~= Enum.Material.Air then
        lastGrounded = now
    end

    local grounded = (now - lastGrounded) < 0.06
    
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

        local movingBackwards = (look:Dot(vel.Unit) < -0.45)

        if movingBackwards then
            DFunctions.setBhopEnabled(CanBHOPBackwards)
            RunService.Heartbeat:Wait()
            DFunctions.setBhopEnabled(false)
        end
    end
end

function DFunctions.ResetBHOP()
   local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
   local humanoid = char:FindFirstChildOfClass("Humanoid")
   
   if char:FindFirstChild("R15Visual") then
       DConfiguration.Misc.MovementModification.BHOP.HipHeight1 = 0.75
       DConfiguration.Misc.MovementModification.BHOP.HipHeight2 = 0.9
   else
       DConfiguration.Misc.MovementModification.BHOP.HipHeight1 = -1.25
       DConfiguration.Misc.MovementModification.BHOP.HipHeight2 = -1.10
   end
           
   if humanoid then
       humanoid.HipHeight = DConfiguration.Misc.MovementModification.BHOP.HipHeight1
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

    local Config = DConfiguration.Misc.MovementModification.Crouch
    local Type = Config.Type or "Normal"
    local now = tick()

    if Type == "Rapid" then
        Config.isHolding = Config.isHolding or false
        Config.lastTick = Config.lastTick or 0

        if (now - Config.lastTick) >= Config.debounce then
            Config.isHolding = not Config.isHolding
            LocalPlayer.PlayerScripts.Events.temporary_events.UseKeybind:Fire({
                Key = "Crouch",
                Down = Config.isHolding
            })
            Config.lastTick = now
        end
        return
    end

    local isOnGround = Humanoid.FloorMaterial ~= Enum.Material.Air

    if Type == "Air" then
        if Config.isHolding == nil then Config.isHolding = false end

        if not isOnGround then
            if not Config.isHolding then
                Config.isHolding = true
                LocalPlayer.PlayerScripts.Events.temporary_events.UseKeybind:Fire({ Key = "Crouch", Down = true })
            end
        else
            if Config.isHolding then
                Config.isHolding = false
                LocalPlayer.PlayerScripts.Events.temporary_events.UseKeybind:Fire({ Key = "Crouch", Down = false })
            end
        end
        return
    end

    local shouldHold = false

    if Type == "Ground" then
        if isOnGround then
            shouldHold = true
        end
    elseif Type == "Normal" then
        shouldHold = true
    end

    if Config.isHolding == nil then Config.isHolding = false end

    if shouldHold then
        if not Config.isHolding then
            Config.isHolding = true
            LocalPlayer.PlayerScripts.Events.temporary_events.UseKeybind:Fire({ Key = "Crouch", Down = true })
        end
    else
        if Config.isHolding then
            Config.isHolding = false
            LocalPlayer.PlayerScripts.Events.temporary_events.UseKeybind:Fire({ Key = "Crouch", Down = false })
        end
    end
end



local Folder = Instance.new("Folder", ReplicatedStorage.Items)
Folder.Name = "D-Folder"

function DFunctions.Normalize(input)
	return input:lower():gsub("%s+", "") 
end

function DFunctions.FindRealName(folder, userInput)
	local normalizedInput = DFunctions.Normalize(userInput)
	for _, item in ipairs(folder:GetChildren()) do
		if DFunctions.Normalize(item.Name) == normalizedInput then
			return item.Name
		end
	end
	return nil
end

function DFunctions.ChangeCosmetics(Name1, Name2)
	local Cosmetics = ReplicatedStorage.Items.Cosmetics
	local RealName1 = DFunctions.FindRealName(Cosmetics, Name1)
	local RealName2 = DFunctions.FindRealName(Cosmetics, Name2)
	if not (RealName1 and RealName2) then return end

	local I = Cosmetics:FindFirstChild(RealName1)
	local V = Cosmetics:FindFirstChild(RealName2)
	if not (I and V) then return end

	if I:FindFirstChild("OriginalName") or V:FindFirstChild("OriginalName") then
		return
	end

	local s1 = Instance.new("StringValue")
	s1.Name = "OriginalName"
	s1.Value = I.Name
	s1.Parent = I

	local s2 = Instance.new("StringValue")
	s2.Name = "OriginalName"
	s2.Value = V.Name
	s2.Parent = V

	for _, partName in ipairs({ "Character", "CharacterClassic", "Viewmodel" }) do
		local a = I:FindFirstChild(partName)
		local b = V:FindFirstChild(partName)

		if a and not a:FindFirstChild("OriginalParent") then
			local p = Instance.new("StringValue")
			p.Name = "OriginalParent"
			p.Value = I.Name
			p.Parent = a
		end

		if b and not b:FindFirstChild("OriginalParent") then
			local p = Instance.new("StringValue")
			p.Name = "OriginalParent"
			p.Value = V.Name
			p.Parent = b
		end

		if a then a.Parent = Folder end
		if b then b.Parent = I end
		if a then a.Parent = V end
	end
end

function DFunctions.RestoreCosmetics()
	local Cosmetics = ReplicatedStorage.Items.Cosmetics

	for _, cosmetic in ipairs(Cosmetics:GetChildren()) do
		for _, container in ipairs(cosmetic:GetChildren()) do
			local op = container:FindFirstChild("OriginalParent")
			if op then
				local original = Cosmetics:FindFirstChild(op.Value)
				if original then
					container.Parent = original
				end
				op:Destroy()
			end
		end
	end

	for _, container in ipairs(Folder:GetChildren()) do
		local op = container:FindFirstChild("OriginalParent")
		if op then
			local original = Cosmetics:FindFirstChild(op.Value)
			if original then
				container.Parent = original
			end
			op:Destroy()
		end
	end

	for _, cosmetic in ipairs(Cosmetics:GetChildren()) do
		local sv = cosmetic:FindFirstChild("OriginalName")
		if sv then
			sv:Destroy()
		end
	end
end

local SelectedVersion = "A"
local IsCurrentPlaying = false

function DFunctions.ChangeAnimation(EmoteFolder, Version)
	if not EmoteFolder then return end

	local options = EmoteFolder:FindFirstChild("PossibleOptions")
	local optionsClassic = EmoteFolder:FindFirstChild("PossibleOptionsClassic")
	if not options and not optionsClassic then return end

	local chosenR15 = options and options:FindFirstChild(Version)
	local chosenR6  = optionsClassic and optionsClassic:FindFirstChild(Version)

	local animR15 = chosenR15 and chosenR15:FindFirstChildWhichIsA("Animation")
	local animR6  = chosenR6 and chosenR6:FindFirstChildWhichIsA("Animation")

	if animR15 and EmoteFolder:FindFirstChild("Animation") then
		local tag = Instance.new("StringValue")
		tag.Name = "OriginalAnimId"
		tag.Value = EmoteFolder.Animation.AnimationId
		tag.Parent = EmoteFolder
		EmoteFolder.Animation.AnimationId = animR15.AnimationId
	end

	if animR6 and EmoteFolder:FindFirstChild("AnimationClassic") then
		local tag = Instance.new("StringValue")
		tag.Name = "OriginalAnimIdClassic"
		tag.Value = EmoteFolder.AnimationClassic.AnimationId
		tag.Parent = EmoteFolder
		EmoteFolder.AnimationClassic.AnimationId = animR6.AnimationId
	end
end

function DFunctions.ChangeEmotes(Name1, Name2)
	local EmotesFolder = ReplicatedStorage.Items.Emotes
	if not EmotesFolder then return end

	local RealName1 = DFunctions.FindRealName(EmotesFolder, Name1)
	local RealName2 = DFunctions.FindRealName(EmotesFolder, Name2)
	if not RealName1 or not RealName2 then return end
	if not IsCurrentPlaying then return end

	local Emote1 = EmotesFolder:FindFirstChild(RealName1)
	local Emote2 = EmotesFolder:FindFirstChild(RealName2)
	if not Emote1 or not Emote2 then return end

	if not Emote1:FindFirstChild("OriginalName") then
		local t = Instance.new("StringValue")
		t.Name = "OriginalName"
		t.Value = Emote1.Name
		t.Parent = Emote1
	end

	if not Emote2:FindFirstChild("OriginalName") then
		local t = Instance.new("StringValue")
		t.Name = "OriginalName"
		t.Value = Emote2.Name
		t.Parent = Emote2
	end

	if not Emote1:FindFirstChild("OriginalParent") then
		local t = Instance.new("StringValue")
		t.Name = "OriginalParent"
		t.Value = Emote1.Parent:GetFullName()
		t.Parent = Emote1
	end

	if not Emote2:FindFirstChild("OriginalParent") then
		local t = Instance.new("StringValue")
		t.Name = "OriginalParent"
		t.Value = Emote2.Parent:GetFullName()
		t.Parent = Emote2
	end

	local hasOptions = Emote2:FindFirstChild("PossibleOptions")
	local hasOptionsClassic = Emote2:FindFirstChild("PossibleOptionsClassic")

	if not hasOptions and not hasOptionsClassic or hasOptions:FindFirstChild("Sun") and hasOptions:FindFirstChild("Moon") then
		local n1, n2 = Emote1.Name, Emote2.Name
		Emote1.Name = n2
		Emote2.Name = n1
		return
	end

	local function MoveModule(obj, parentName)
		if obj and not obj:FindFirstChild("OriginalParent") then
			local t = Instance.new("StringValue")
			t.Name = "OriginalParent"
			t.Value = parentName
			t.Parent = obj
			obj.Parent = Folder
		end
	end

	MoveModule(Emote2:FindFirstChild("EmoteModule"), Emote2.Name)
	MoveModule(Emote2:FindFirstChild("EmoteModuleClassic"), Emote2.Name)

	if Emote1.Parent ~= Folder then
		Emote1.Parent = Folder
	end

	Emote2.Name = Emote1:FindFirstChild("OriginalName").Value

	DFunctions.ChangeAnimation(Emote2, SelectedVersion)
end

function DFunctions.ResetEmoteChanges()
	local Emotes = ReplicatedStorage.Items.Emotes

	for _, emote in ipairs(Emotes:GetChildren()) do
		local originalTag = emote:FindFirstChild("OriginalName")
		if originalTag then
			if emote.Name ~= originalTag.Value then
				emote.Name = originalTag.Value
			end
			originalTag:Destroy()
		end
	end

	for _, emote in ipairs(Folder:GetChildren()) do
		local ptag = emote:FindFirstChild("OriginalParent")
		if ptag then
			local parent = ReplicatedStorage.Items:FindFirstChild(ptag.Value)
			if parent then
				emote.Parent = parent
			else
				emote.Parent = Emotes
			end
			ptag:Destroy()
		end
	end
	
	for _, obj in ipairs(Folder:GetChildren()) do
		if obj:IsA("ModuleScript") then
			local originalParentTag = obj:FindFirstChild("OriginalParent")
			if originalParentTag then
				local parentEmote = Emotes:FindFirstChild(originalParentTag.Value)
				if parentEmote then
					obj.Parent = parentEmote
				else
					obj.Parent = Emotes
				end
				originalParentTag:Destroy()
			end
		end
	end
end

function DFunctions.RestoreEmoteChanges()
    DFunctions.ResetEmoteChanges() 
    wait(0.1)
    DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote1, DConfiguration.Visual.ModifyEmotes.Emote1)
    DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote2, DConfiguration.Visual.ModifyEmotes.Emote2)
    DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote3, DConfiguration.Visual.ModifyEmotes.Emote3)
    DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote4, DConfiguration.Visual.ModifyEmotes.Emote4)
    DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote5, DConfiguration.Visual.ModifyEmotes.Emote5)
    DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote6, DConfiguration.Visual.ModifyEmotes.Emote6)
    DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote7, DConfiguration.Visual.ModifyEmotes.Emote7)
    DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote8, DConfiguration.Visual.ModifyEmotes.Emote8)
    DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote9, DConfiguration.Visual.ModifyEmotes.Emote9)
    DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote10, DConfiguration.Visual.ModifyEmotes.Emote10)
    DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote11, DConfiguration.Visual.ModifyEmotes.Emote11)
    DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote12, DConfiguration.Visual.ModifyEmotes.Emote12)
end



local Players = game:GetService("Players")
local player = Players.LocalPlayer

DFunctions.KorbloxR = false
DFunctions.KorbloxL = false
DFunctions.Headless = false

function DFunctions.ApplyKorblox(side, meshId)
    local char = player.Character
    if not char then return end
    
    local legName = (side == "Right") 
        and (char:FindFirstChild("Right Leg") and "Right Leg" or "RightUpperLeg") 
        or (char:FindFirstChild("Left Leg") and "Left Leg" or "LeftUpperLeg")
        
    local leg = char:FindFirstChild(legName)
    if leg then
        for _, child in ipairs(leg:GetChildren()) do
            if child:IsA("SpecialMesh") then child:Destroy() end
        end
        leg.Color = Color3.fromRGB(50, 50, 50)
        local mesh = Instance.new("SpecialMesh")
        mesh.Name = "KorbloxMesh"
        mesh.MeshType = Enum.MeshType.FileMesh
        mesh.MeshId = meshId
        mesh.Parent = leg
    end
end

function DFunctions.ApplyHeadless()
    local char = player.Character
    local head = char and char:FindFirstChild("Head")
    if head then
        head.Transparency = 1
        if head:FindFirstChild("face") then head.face:Destroy() end
        
        if not head:FindFirstChild("HeadlessMesh") then
            local mesh = Instance.new("SpecialMesh")
            mesh.Name = "HeadlessMesh"
            mesh.MeshType = Enum.MeshType.FileMesh
            mesh.MeshId = "rbxassetid://1095708"
            mesh.Scale = Vector3.new(0.001, 0.001, 0.001)
            mesh.Parent = head
        end
    end
end

function DFunctions.UpdateVisuals()
    if DFunctions.KorbloxR then DFunctions.ApplyKorblox("Right", "rbxassetid://101851696") end
    if DFunctions.KorbloxL then DFunctions.ApplyKorblox("Left", "rbxassetid://101851582") end
    if DFunctions.Headless then DFunctions.ApplyHeadless() end
end

player.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(1)
    DFunctions.UpdateVisuals()
end)

if player.Character then
    DFunctions.UpdateVisuals()
end



