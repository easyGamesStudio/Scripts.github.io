local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    -- Set Center to true if you want the menu to appear in the center
    -- Set AutoShow to true if you want the menu to appear when it is created
    -- Position and Size are also valid options here
    -- but you do not need to define them unless you are changing them :)

    Title = 'KEY SYSTEM | Poke Haven 🔊 17+',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    -- Creates a new tab titled Main
    Key = Window:AddTab('KeySystem'),
}

_G.Key = ""

-- Creates Group
local KeyGroup = Tabs.Key:AddLeftGroupbox('KeySystem')

-- Key Input
KeyGroup:AddInput('KeyText', {
    Default = 'Enter your key here!',
    Numeric = false, -- true / false, only allows numbers
    Finished = false, -- true / false, only calls callback when you press enter

    Text = 'Input Key',
    Tooltip = 'Enter your key here!', -- Information shown when you hover over the textbox

    Placeholder = 'Enter your key here', -- placeholder text when the box is empty
    -- MaxLength is also an option which is the max length of the text

    Callback = function(Value)
        _G.Key = Value
    end
})

-- Check Key Button
local HttpService = game:GetService("HttpService")

local CheckKeyButton = KeyGroup:AddButton({
    Text = 'Check Key ✅',
    Func = function()
        -- Sjekk at brukeren faktisk har skrevet noe
        if not _G.Key or _G.Key == "" or tostring(_G.Key):match("^%s*$") then
            Library:Notify("⚠️ Ingen key oppgitt", 3)
            return
        end

        -- Bygg URL (legg til ?linkId=... hvis tjenesten krever det)
        local linkId = "64581" -- bytt om nødvendig
        local url = "https://work.ink/_api/v2/token/isValid/" .. tostring(_G.Key) .. "?linkId=" .. linkId

        -- Hent fra API trygt
        local ok, resp = pcall(function()
            return game:HttpGet(url)
        end)

        if not ok then
            Library:Notify("❌ HTTP-feil: " .. tostring(resp), 4)
            return
        end

        -- Hvis svaret er HTML (feil-side fra server / Cloudflare), gi beskjed
        if type(resp) == "string" and (resp:sub(1,1) == "<" or resp:find("Cannot GET") or resp:find("<!DOCTYPE html>")) then
            Library:Notify("❌ Server returnerte HTML — sjekk URL eller at nøkkelen er med i forespørselen", 5)
            print("Raw response (HTML):\n", resp)
            return
        end

        -- Prøv å parse JSON
        local parsedOk, data = pcall(function()
            return HttpService:JSONDecode(resp)
        end)

        if not parsedOk then
            Library:Notify("❌ Kunne ikke parse JSON: " .. tostring(resp), 4)
            print("Raw response:", resp)
            return
        end

        -- Valider feltene
        if data.valid then
            print("✅ Key valid!")
            loadstring(game:HttpGet("https://raw.githubusercontent.com/easyGamesStudio/PokeHaven.github.io/main/PokeHaven.lua"))()
            Library:Unload()
        else
            print("❌ Key invalid/expired")
            print("Key invalid response:", HttpService:JSONEncode(data))
        end
    end,
    DoubleClick = false,
    Tooltip = 'Check your key here!'
})



-- Get Key Button
local GetKeyButton = KeyGroup:AddButton({
    Text = 'Get key 🔑',
    Func = function()
        setclipboard("https://workink.net/277p/cm4zsefi")
    end,
    DoubleClick = false,
    Tooltip = 'Copy your key here!'
})
