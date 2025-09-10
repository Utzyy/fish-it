-- Fish It Webhook AFK Script (Delta Mobile Version)
-- Ringan & aman

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local connectionLost = false
local lastChatMessage = ""
local webhookUrl = ""

-- Island list
local ISLAND_LIST = {
    ["🎣Fisherman"] = Vector3.new(34, 15, 2828),
    ["🔮Esoteric Deeps"] = Vector3.new(3234, -1303, 1399),
    ["🌋Kohana Volcano"] = Vector3.new(-597, 46, 199),
    ["⚙️Weather Machine"] = Vector3.new(-1527, 2, 1905),
    ["🐠Koral Reefs"] = Vector3.new(-2811, 9, 2102),
    ["🌴Tropical Grove"] = Vector3.new(-2167, 53, 3666),
    ["✨Creater Island"] = Vector3.new(1000, 18, 5093),
    ["❄️Snow Island"] = Vector3.new(2160, 4, 3289),
    ["🗿Sisyphus Statue"] = Vector3.new(-3742, -136, -1008),
    ["💰Treasure Room"] = Vector3.new(-3598, -281, -1634)
}

-- Target ikan
local secretFish = {
    "Orca","Crystal Crab","Monster Shark","Eerie Shark","Great Whale",
    "Robot Kraken","King Crab","Kraken","Queen Crab","Blob shark","Ghost shark","armor","worm","giant squid"
}
local mythicFish = {
    "Dotted Stingray","Hammerhead Shark","Manta Ray","Prismy Seahorse",
    "Loggerhead Turtle","Blueflame Ray","Hawks Turtle","Abyss Seahorse",
    "Thresher Shark","Blob Fish"
}

-- Kirim webhook
local function sendToDiscord(fishName, rarity, weight)
    if webhookUrl == "" then return end
    local color = rarity == "Secret" and 0x00ffff or 0xff0000
    local data = {
        ["content"] = "@everyone",
        ["embeds"] = { {
            ["title"] = "🎣 IKAN LANGKA TERTANGKAP!",
            ["description"] = string.format("**%s** mendapat ikan langka!", player.Name),
            ["color"] = color,
            ["fields"] = {
                {["name"] = "🐟 Nama Ikan", ["value"] = fishName, ["inline"] = true},
                {["name"] = "⭐ Rarity", ["value"] = rarity, ["inline"] = true},
                {["name"] = "⚖️ Berat", ["value"] = string.format("%.2f kg", weight), ["inline"] = true}
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            ["footer"] = {["text"] = "Fish It Auto Webhook"}
        } }
    }
    local body = HttpService:JSONEncode(data)
    local requestFunc = (http_request or request or syn and syn.request)
    if requestFunc then
        pcall(function()
            requestFunc({
                Url = webhookUrl,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = body
            })
        end)
    end
end

-- Test webhook
local function testWebhook()
    if webhookUrl == "" then
        warn("⚠️ Webhook kosong!")
        return
    end
    local data = {
        ["content"] = "@everyone",
        ["embeds"] = { {
            ["title"] = "🔔 TEST WEBHOOK BERHASIL!",
            ["description"] = "Pesan ini dikirim dari Delta Mobile.",
            ["color"] = 0x00ff00,
            ["fields"] = {
                {["name"] = "Status", ["value"] = "✅ Webhook aktif", ["inline"] = true},
                {["name"] = "Waktu", ["value"] = os.date("%Y-%m-%d %H:%M:%S"), ["inline"] = true}
            },
            ["footer"] = {["text"] = "Fish It Webhook Tester"}
        } }
    }
    local body = HttpService:JSONEncode(data)
    local requestFunc = (http_request or request or syn and syn.request)
    if requestFunc then
        pcall(function()
            requestFunc({
                Url = webhookUrl,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = body
            })
        end)
        print("✅ Tes webhook terkirim ke Discord!")
    end
end

-- Deteksi chat ikan
local function setupChatDetection()
    local playerGui = player:WaitForChild("PlayerGui")
    local chatFrame = playerGui:WaitForChild("Chat"):WaitForChild("Frame")
        :WaitForChild("ChatChannelParentFrame"):WaitForChild("Frame_MessageLogDisplay"):WaitForChild("Scroller")

    chatFrame.ChildAdded:Connect(function(child)
        if child:IsA("Frame") and child:FindFirstChild("TextLabel") then
            task.wait(0.1)
            local msg = child.TextLabel.Text
            if msg ~= lastChatMessage then
                lastChatMessage = msg
                local fishName, weight = msg:match("obtained a (.-)%s*%(([%d%.]+)kg%)")
                if fishName and weight then
                    weight = tonumber(weight)
                    local rarity
                    for _, name in ipairs(secretFish) do
                        if fishName:lower():find(name:lower()) then
                            rarity = "Secret"
                            break
                        end
                    end
                    if not rarity then
                        for _, name in ipairs(mythicFish) do
                            if fishName:lower():find(name:lower()) then
                                rarity = "Mythic"
                                break
                            end
                        end
                    end
                    if rarity then
                        sendToDiscord(fishName, rarity, weight)
                    end
                end
            end
        end
    end)
end

-- Auto rejoin + webhook notif
local function setupAutoRejoin()
    spawn(function()
        while true do
            if connectionLost then
                TeleportService:Teleport(game.PlaceId, player)
                task.wait(5)
                if webhookUrl ~= "" then
                    local data = {
                        ["content"] = "@everyone",
                        ["embeds"] = { {
                            ["title"] = "🔄 Rejoin Berhasil",
                            ["description"] = string.format("Player **%s** berhasil rejoin.", player.Name),
                            ["color"] = 0x00ff00,
                            ["fields"] = {
                                {["name"] = "Waktu", ["value"] = os.date("%Y-%m-%d %H:%M:%S"), ["inline"] = true}
                            },
                            ["footer"] = {["text"] = "Fish It Auto Rejoin"}
                        } }
                    }
                    local body = HttpService:JSONEncode(data)
                    local requestFunc = (http_request or request or syn and syn.request)
                    if requestFunc then
                        pcall(function()
                            requestFunc({
                                Url = webhookUrl,
                                Method = "POST",
                                Headers = {["Content-Type"] = "application/json"},
                                Body = body
                            })
                        end)
                    end
                end
            end
            task.wait(1)
        end
    end)
end

-- Teleport + notif
local function teleportTo(position, name)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        Rayfield:Notify({Title="Teleport",Content="🚀 Teleport sedang berlangsung...",Duration=3})
        local safePos = Vector3.new(position.X, position.Y + 5, position.Z)
        player.Character.HumanoidRootPart.CFrame = CFrame.new(safePos)
        Rayfield:Notify({Title="Teleport",Content="✅ Teleport berhasil ke " .. name,Duration=3})
    end
end

-- UI
local Window = Rayfield:CreateWindow({
    Name = "Helper Fish it (Delta Mobile)",
    LoadingTitle = "Fish It",
    LoadingSubtitle = "by Notzyhere",
    KeySystem = false
})

local MainTab = Window:CreateTab("Main")
local IslandListTab = Window:CreateTab("Island List")

MainTab:CreateInput({
    Name = "Webhook URL",
    PlaceholderText = "Masukkan link webhook",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        webhookUrl = Text
    end,
})

MainTab:CreateButton({
    Name = "🔔 Test Webhook",
    Callback = function()
        testWebhook()
    end,
})

-- Tombol pulau
for name, pos in pairs(ISLAND_LIST) do
    IslandListTab:CreateButton({
        Name = name,
        Callback = function()
            teleportTo(pos, name)
        end
    })
end

-- Init
setupChatDetection()
setupAutoRejoin()
print("✅ Fish It Webhook siap jalan (Delta Mobile)")
