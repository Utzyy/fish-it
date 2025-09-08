-- Script Tes Webhook untuk Executor (Xeno, Delta, Synapse, dsb.)
local HttpService = game:GetService("HttpService")

-- Ganti dengan webhook kamu
local webhookUrl = "https://discord.com/api/webhooks/1414541460719669268/PzPaHEdYGkhQZNPSQfgeKB0TLUUai0RWL67QWV2jk-JJzuIbWveqYtmgQZpM8xl08XTX"

local function sendWebhook()
    local data = {
        ["content"] = "",
        ["embeds"] = {{
            ["title"] = "🔔 TEST WEBHOOK BERHASIL!",
            ["description"] = "Pesan ini dikirim dari executor.",
            ["color"] = 0x00ff00,
            ["fields"] = {
                {["name"] = "Status", ["value"] = "✅ Webhook aktif & bisa dipakai", ["inline"] = true},
                {["name"] = "Waktu", ["value"] = os.date("%Y-%m-%d %H:%M:%S"), ["inline"] = true}
            },
            ["footer"] = {["text"] = "Fish It Webhook Tester"}
        }}
    }

    local body = HttpService:JSONEncode(data)

    local requestFunc = (http_request or request or syn and syn.request)
    if requestFunc then
        requestFunc({
            Url = webhookUrl,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = body
        })
        print("✅ Tes webhook terkirim lewat executor!")
    else
        warn("⚠️ Executor tidak mendukung http_request/request/syn.request")
    end
end

sendWebhook()
