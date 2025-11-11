if game.PlaceId ~= 106992835022842 then
    local TeleportService = game:GetService("TeleportService")
    local targetPlaceId = 106992835022842
    TeleportService:Teleport(targetPlaceId)
end

-- ========== LIBRARY ========== --
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'IMPOSSIBLE Capybara Glass Bridge',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

-- ========== TABS ========== --
local Tabs = {
    -- Creates a new tab titled Main
    Main = Window:AddTab('Main'),
    Esp = Window:AddTab('Esp'),
    Player = Window:AddTab('Player'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- ========== GLOBAL VARIABLES ========== --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Player Esp
local Highlights = {}
_G.HighlightToggle = false
_G.HighlightColor = Color3.fromRGB(255, 0, 0)

-- Bridge Esp
local Outlines = {}
_G.OutlineToggle = true
_G.OutlineColor = Color3.fromRGB(255, 0, 0)
_G.OutlineTransparency = 0.3
_G.OutlineSizeOffset = 0.05
_G.OutlineZIndex = 10
_G.OutlineAlwaysOnTop = true

-- ========== MAIN TAB BOX 1 ========== --
local m_box1 = Tabs.Main:AddLeftGroupbox('Bridge Esp')
local m_box4 = Tabs.Main:AddLeftGroupbox('Autofarm')
local m_box2 = Tabs.Main:AddRightGroupbox('Teleport')
local m_box3 = Tabs.Main:AddRightGroupbox('Player Stats')

local player = Players.LocalPlayer

-- Konfigurer start- og målposisjon
local startPos = Vector3.new(712, 30.02, 179.59)
local targetPos = Vector3.new(720, 30.02, 179.59)
local goingToTarget = true

-- Toggle
_G.ToggleWalkLoop = false

-- Referanser til Humanoid og HRP
local humanoid, hrp

-- Funksjon for å hente Humanoid og HRP
local function getCharacterParts(character)
	character = character or player.Character or player.CharacterAdded:Wait()
	local h = character:WaitForChild("Humanoid")
	local r = character:WaitForChild("HumanoidRootPart")
	return h, r
end

-- Håndter respawn
player.CharacterAdded:Connect(function(char)
	humanoid, hrp = getCharacterParts(char)
	-- Hvis toggle er aktiv, teleportér til startPos på respawn
	if _G.ToggleWalkLoop then
		hrp.CFrame = CFrame.new(startPos)
		goingToTarget = true
	end
end)

-- Initial hent
humanoid, hrp = getCharacterParts()

-- Funksjon som starter loopen én gang
local function startLoopOnce()
	if humanoid and hrp then
		-- Teleporter spilleren til startPos når toggle settes på
		hrp.CFrame = CFrame.new(startPos)
		goingToTarget = true
	end
end

-- Sjekk toggle-endringer
local oldToggle = _G.ToggleWalkLoop
RunService.RenderStepped:Connect(function()
	-- Detect toggle aktivert
	if _G.ToggleWalkLoop and not oldToggle then
		startLoopOnce()
	end
	oldToggle = _G.ToggleWalkLoop

	-- Bevegelse frem og tilbake
	if _G.ToggleWalkLoop and humanoid and hrp then
		local goal = goingToTarget and targetPos or startPos
		humanoid:MoveTo(goal)
		if (hrp.Position - goal).Magnitude < 1 then
			goingToTarget = not goingToTarget
		end
	end
end)

m_box4:AddToggle('BridgeAutofarm', {
    Text = 'Autofarm Bridge',
    Default = false, -- Default value (true / false)
    Tooltip = 'Toggle autofarm bridge!', -- Information shown when you hover over the toggle

    Callback = function(Value)
        _G.ToggleWalkLoop = Value
    end
})


------------------------
-- BRIDGE ESP
--// 🔍 Finn alle Parts som IKKE har "Debounce"
local function getAllParts()
	local parts = {}
	local folder = workspace:FindFirstChild("GlassTiles")
	if folder then
		for _, group in ipairs(folder:GetChildren()) do
			for _, obj in ipairs(group:GetChildren()) do
				-- Finn parent-parten vi skal vurdere
				local targetPart = nil
				if obj:IsA("BasePart") then
					targetPart = obj
				elseif obj:IsA("Model") then
					targetPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
				end

				-- Bare fortsett hvis vi fant en faktisk part
				if targetPart then
					local hasDebounce = targetPart:FindFirstChild("Debounce") or obj:FindFirstChild("Debounce")
					-- Vi vil kun ha de som IKKE har Debounce
					if not hasDebounce then
						table.insert(parts, targetPart)
					end
				end
			end
		end
	end
	return parts
end

--// 💥 Fjern outlines som ikke trengs lenger
local function cleanOldOutlines()
	for part, box in pairs(Outlines) do
		if not part or not part.Parent then
			box:Destroy()
			Outlines[part] = nil
		end
	end
end

--// 🔧 Lag outlines for nye deler
local function ensureOutlines()
	local parts = getAllParts()
	for _, part in ipairs(parts) do
		if not Outlines[part] then
			local box = Instance.new("BoxHandleAdornment")
			box.Adornee = part
			box.Color3 = _G.OutlineColor
			box.Transparency = _G.OutlineTransparency
			box.Size = part.Size + Vector3.new(_G.OutlineSizeOffset, _G.OutlineSizeOffset, _G.OutlineSizeOffset)
			box.ZIndex = _G.OutlineZIndex
			box.AlwaysOnTop = _G.OutlineAlwaysOnTop
			box.AdornCullingMode = Enum.AdornCullingMode.Never
			box.Parent = game:GetService("CoreGui")
			Outlines[part] = box
		end
	end
end

--// 🔁 Oppdater alt automatisk hvert render-steg
RunService.RenderStepped:Connect(function()
	cleanOldOutlines()
	ensureOutlines()

	for part, box in pairs(Outlines) do
		if box then
			box.Visible = _G.OutlineToggle
			box.Color3 = _G.OutlineColor
			box.Transparency = _G.OutlineTransparency
			box.AlwaysOnTop = _G.OutlineAlwaysOnTop
			box.Size = part.Size + Vector3.new(_G.OutlineSizeOffset, _G.OutlineSizeOffset, _G.OutlineSizeOffset)
			box.ZIndex = _G.OutlineZIndex
		end
	end
end)

m_box1:AddToggle('BridgeEsp', {
    Text = 'Bridge Esp',
    Default = false, -- Default value (true / false)
    Tooltip = 'Toogle bridge esp!', -- Information shown when you hover over the toggle

    Callback = function(Value)
        _G.OutlineToggle = Value
    end
})

m_box1:AddSlider('TransBridge', {
    Text = 'Esp Transparency',
    Default = 0.3,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Compact = false,

    Callback = function(Value)
        _G.OutlineTransparency = Value
    end
})

m_box1:AddSlider('BridgeOffset', {
    Text = 'Glass Offset',
    Default = 0.05,
    Min = 0.01,
    Max = 0.5,
    Rounding = 1,
    Compact = false,

    Callback = function(Value)
        _G.OutlineSizeOffset = Value
    end
})

m_box1:AddToggle('AlwaysOnTop', {
    Text = 'Always on-top',
    Default = true, -- Default value (true / false)
    Tooltip = 'Set esp always on-top!', -- Information shown when you hover over the toggle

    Callback = function(Value)
        _G.OutlineAlwaysOnTop = Value
    end
})

m_box1:AddLabel('Color'):AddColorPicker('ColorPicker', {
    Default = _G.OutlineColor, -- Bright green
    Title = 'Some color', -- Optional. Allows you to have a custom color picker title (when you open it)
    Transparency = 0, -- Optional. Enables transparency changing for this color picker (leave as nil to disable)

    Callback = function(Value)
        _G.OutlineColor = Value
    end
})
------------------------


local PlayerStatsButton = m_box3:AddButton({
    Text = 'Player Stats',
    Func = function()
        print("\nPlayer Stats:\n")

        for number, i in ipairs(game.Players:GetChildren()) do
            print("#" .. number .. " player: " .. i.Name)
            for _, y in ipairs(i:FindFirstChild("leaderstats"):GetChildren()) do
                print(y.Name .. " : " .. y.Value)
            end
            print("\n===========================\n")
        end
    end,
    DoubleClick = false,
    Tooltip = 'Show Player Stats'
})

m_box3:AddLabel('Press F9 after the button "Player Stats" to show player stats', true)

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- Teleport-liste
local teleportList = {
    ["Normal Game"] = Vector3.new(91.66, 7.81, 149.63),
    ["100 Player"] = Vector3.new(118.13, 3.73, 226.30) -- eksempel
}

-- Standard teleport
_G.TeleportPlace = teleportList["Normal Game"]

-- Dropdown
m_box2:AddDropdown('ChooseTeleport', {
    Values = { 'Normal Game', '100 Player' },
    Default = 1,
    Multi = false,
    Text = 'Choose Teleport',
    Tooltip = 'Choose gamemode to teleport',
    Callback = function(Value)
        _G.TeleportPlace = teleportList[Value]
    end
})

-- Teleport-knapp
local TeleportButton = m_box2:AddButton({
    Text = 'Teleport Player',
    Func = function()
        if _G.TeleportPlace then
            hrp.CFrame = CFrame.new(_G.TeleportPlace)
        end
    end,
    DoubleClick = false,
    Tooltip = 'Teleport Player!'
})

-- ========== PLAYER TAB BOX 1 ========== --
local e_box1 = Tabs.Esp:AddLeftGroupbox('Esp')

local function createHighlight(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end

    -- Hvis highlight allerede finnes, oppdater farge og adornee
    if Highlights[player] then
        local hl = Highlights[player]
        hl.Adornee = char
        hl.FillColor = _G.HighlightColor
        return
    end

    -- Lag nytt highlight
    local hl = Instance.new("Highlight")
    hl.Adornee = char
    hl.FillColor = _G.HighlightColor
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.Parent = workspace

    Highlights[player] = hl
end

local function removeHighlight(player)
    local hl = Highlights[player]
    if hl then
        hl:Destroy()
        Highlights[player] = nil
    end
end

local function updateHighlightColors()
    for player, hl in pairs(Highlights) do
        if hl and hl.Parent then
            hl.FillColor = _G.HighlightColor
        else
            Highlights[player] = nil
        end
    end
end

local function toggleHighlights(state)
    _G.HighlightToggle = state
    for _, player in pairs(Players:GetPlayers()) do
        if state then
            createHighlight(player)
        else
            removeHighlight(player)
        end
    end
end

-- ========== EVENTS ==========
-- Når ny spiller spawner
Players.PlayerAdded:Connect(function(player)
    -- Oppdater highlight når karakteren spawner
    player.CharacterAdded:Connect(function()
        -- Kall alltid createHighlight hvis toggle er på
        if _G.HighlightToggle then
            createHighlight(player)
        end
    end)
    
    -- Hvis toggle allerede er på og spilleren har karakter ferdig, lag highlight umiddelbart
    if _G.HighlightToggle and player.Character then
        createHighlight(player)
    end
end)

-- Når spiller forlater
Players.PlayerRemoving:Connect(removeHighlight)

-- Init for eksisterende spillere
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        if player.Character and _G.HighlightToggle then
            createHighlight(player)
        end
        player.CharacterAdded:Connect(function()
            if _G.HighlightToggle then
                createHighlight(player)
            end
        end)
    end
end

-- Live oppdatering av farge
RunService.Heartbeat:Connect(function()
    if _G.HighlightToggle then
        updateHighlightColors()
    end
end)

e_box1:AddToggle('EspToogle', {
    Text = 'Toggle Esp',
    Default = false, -- Default value (true / false)
    Tooltip = 'Toogle esp on all players', -- Information shown when you hover over the toggle

    Callback = function(Value)
        _G.HighlightToggle = Value
        toggleHighlights(Value)
    end
})

-- ========== PLAYER TAB BOX 1 ========== --
local p_box1 = Tabs.Player:AddLeftGroupbox('Local Player')

p_box1:AddSlider('WalkspeedSlider', {
    Text = 'Change WalkSpeed!',
    Default = 16,
    Min = 1,
    Max = 100,
    Rounding = 1,
    Compact = false,

    Callback = function(Value)
        LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = Value
    end
})

p_box1:AddSlider('JumpheightSlider', {
    Text = 'Jump Height',
    Default = 7.2, -- standard for Roblox
    Min = 1,
    Max = 100,
    Rounding = 1,
    Compact = false,

    Callback = function(Value)
        local humanoid = LocalPlayer.Character:WaitForChild("Humanoid")
        humanoid.UseJumpPower = false -- sikrer at JumpHeight brukes
        humanoid.JumpHeight = Value
    end
})

local WalkSpeedButton = p_box1:AddButton({
    Text = 'Reset WalkSpeed',
    Func = function()
        LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = 16
        Options.WalkspeedSlider:SetValue(16)
    end,
    DoubleClick = false,
    Tooltip = 'Resets player walkspeed!'
})

local JumpHeightButton = p_box1:AddButton({
    Text = 'Reset JumpHeight',
    Func = function()
        local humanoid = LocalPlayer.Character:WaitForChild("Humanoid")
        humanoid.UseJumpPower = false
        humanoid.JumpHeight = 7.2
        Options.JumpheightSlider:SetValue(7.2)
    end,
    Tooltip = 'Resets player jumpheight!'
})
