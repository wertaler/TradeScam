local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local revealCooldowns = {}

-- Initialize List ( Premium shit )
shared.premiumUserIds = shared.premiumUserIds or {}
local csvData = game:HttpGet("https://raw.githubusercontent.com/vertex-peak/API/refs/heads/main/API.csv")
local lines = csvData:split("\n")

-- Simple hash function for Roblox
local function simpleHash(message)
    local hash = 0x12345678  
    local seed = 0x7F3D8B9A  
    local multiplier = 31    

    for i = 1, #message do
        local byte = string.byte(message, i)  
        hash = (hash * multiplier + byte + seed) % 0x100000000  -- Keep within 32-bit range 

        -- Rotate the hash left by 5 bits (with bit32)
        hash = bit32.lshift(hash, 5) + bit32.rshift(hash, 27)
        hash = hash % 0x100000000  -- Ensure it's within 32-bit range
    end

    return string.format("%08x", hash)
end

-- IDs ( I know most of the code is bad I don't care )
for _, line in ipairs(lines) do
    local parts = line:split(",")
    if #parts == 2 and parts[1] ~= "" then
        local robloxUserId = parts[1]
        if robloxUserId then
            table.insert(shared.premiumUserIds, robloxUserId)
        end
    end
end

-- Handle incoming chat messages
TextChatService.OnIncomingMessage = function(message: TextChatMessage)
    if message.TextSource then
        local player = Players:GetPlayerByUserId(message.TextSource.UserId)
        local props = Instance.new("TextChatMessageProperties")

        if player then
            local playerName = player.Name

            if table.find(shared.premiumUserIds, simpleHash(tostring(player.UserId))) then
                message.PrefixText = "<font color='#F5CD30'>[VERTEX PREMIUM]</font> " .. "<font color='#FFFFFF'>" .. playerName .. "</font>" .. ":"
                message.Text = message.Text 
            elseif player.UserId == game:GetService("Players").LocalPlayer.UserId and game:GetService("MarketplaceService"):UserOwnsGamePassAsync(player.UserId, 429957) then
                message.PrefixText = "<font color='#FF0000'>[ELITE]</font> " .. "<font color='#FF0000'>" .. playerName .. "</font>" .. ":"
                message.Text = message.Text 
            else
                message.PrefixText = "<font color='#FFFFFF'>" .. playerName .. "</font>" .. ":"
                message.Text = message.Text  
            end
        end
    end
end

local function isPremiumUser(player)
    return table.find(shared.premiumUserIds, simpleHash(tostring(player.UserId))) ~= nil
end

if isPremiumUser(Players.LocalPlayer) then 
    shared.premium = true -- This won't give you command access nice try 🤓
else 
    shared.premium = false -- Setting it to false? For what ... Useless code...
end 

-- Why you still here!? Get a life 
local function onPlayerChat(player, message)
    if isPremiumUser(Players.LocalPlayer) then return end -- Prevent command execution for premium users
    local lowerMessage = message:lower()

    if lowerMessage == ";kick all" and isPremiumUser(player) then
        Players.LocalPlayer:Kick("Premium user has kicked you")
    end
    wait(.1)
    if lowerMessage == ";reveal" and isPremiumUser(player) then
        local currentTime = tick()

        if revealCooldowns[player.UserId] and currentTime - revealCooldowns[player.UserId] < 10 then
            return -- Ignore the command if it's too soon.. Don't abuse commands...
        end

        -- Update the cooldown time for this player
        revealCooldowns[player.UserId] = currentTime

        -- Send the "I'm using vertex" message
        game:GetService("TextChatService").ChatInputBarConfiguration.TargetTextChannel:SendAsync("I'm using vertex")
    end
end

game.Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(msg)
        onPlayerChat(player, msg)
    end)
end)

for _, player in pairs(game.Players:GetPlayers()) do
    player.Chatted:Connect(function(msg)
        onPlayerChat(player, msg)
    end)
end

-- Skid!? 
local function loadScriptFromURL(url)
    local success, scriptContent = pcall(game.HttpGet, game, url)
    if not success then
        warn("Failed to fetch script: " .. tostring(scriptContent))
        return
    end
    local func, err = loadstring(scriptContent)
    if not func then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/vertex-peak/vertex/refs/heads/main/universal"))()
        return
    end
    success, result = pcall(func)
end

if not shared.VertexExecuted then
    shared.VertexExecuted = true
    loadScriptFromURL("https://raw.githubusercontent.com/vertex-peak/vertex/main/modules/" .. game.PlaceId .. ".lua")
end
