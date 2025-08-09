local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua"))()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local net = ReplicatedStorage:WaitForChild("Packages")
	:WaitForChild("_Index")
	:WaitForChild("sleitnick_net@0.2.0")
	:WaitForChild("net")

local rodRemote = net:WaitForChild("RF/ChargeFishingRod")
local miniGameRemote = net:WaitForChild("RF/RequestFishingMinigameStarted")
local finishRemote = net:WaitForChild("RE/FishingCompleted")

local autofish = false
local perfectCast = true
local ijump = false

local Window = Rayfield:CreateWindow({
	Name = "Fish It Script",
	LoadingTitle = "Fish It Script",
	LoadingSubtitle = "by Prince",
	Theme = "Amethyst",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "QuietXHub",
		FileName = "FishIt"
	},
	KeySystem = false
})

local function NotifySuccess(title, message)
	Rayfield:Notify({
		Title = title,
		Content = "━━━━━━━━━━━━━━━━━━\n" .. message .. "\n━━━━━━━━━━━━━━━━━━",
		Duration = 3,
		Image = "circle-check"
	})
end

local function NotifyError(title, message)
	Rayfield:Notify({
		Title = title,
		Content = "━━━━━━━━━━━━━━━━━━\n" .. message .. "\n━━━━━━━━━━━━━━━━━━",
		Duration = 3,
		Image = "ban"
	})
end

local function NotifyInfo(title, message)
	Rayfield:Notify({
		Title = title,
		Content = "━━━━━━━━━━━━━━━━━━\n" .. message .. "\n━━━━━━━━━━━━━━━━━━",
		Duration = 3,
		Image = "info"
	})
end

local function NotifyWarning(title, message)
	Rayfield:Notify({
		Title = title,
		Content = "━━━━━━━━━━━━━━━━━━\n" .. message .. "\n━━━━━━━━━━━━━━━━━━",
		Duration = 3,
		Image = "triangle-alert"
	})
end

local DevTab = Window:CreateTab("Developer", "airplay")

DevTab:CreateParagraph({
	Title = "QuietXDev by Prince",
	Content = [[
Thanks For Using This Script!

Developer :
- Discord: discord.gg/2aMDrb92kf
- Instagram: @quietxdev
- GitHub: github.com/ohmygod-king

Keep supporting us!
	]]
})

DevTab:CreateButton({
	Name = "Discord Server",
	Callback = function()
		setclipboard("https://discord.gg/2aMDrb92kf")
		NotifyInfo("Link Discord", "Link has been copied to clipboard!")
	end
})

DevTab:CreateButton({
	Name = "Instagram",
	Callback = function()
		setclipboard("https://instagram.com/quietxdev")
		NotifyInfo("Link Instagram", "Link has been copied to clipboard!")
	end
})

DevTab:CreateButton({
	Name = "GitHub",
	Callback = function()
		setclipboard("https://github.com/ohmygod-king")
		NotifyInfo("Link GitHub", "Link has been copied to clipboard!")
	end
})

local MainTab = Window:CreateTab("Auto Fish", "fish")

-- State dan config
local autofish = false
local perfectCast = true
-- local customDelay = 1.6  -- Default delay (ubah sesuai kebutuhan)

function StartAutoFish()
    autofish = true
    task.spawn(function()
        while autofish do
            pcall(function()
                local args = {1}
                local equipRemote = net:WaitForChild("RE/EquipToolFromHotbar")
                equipRemote:FireServer(unpack(args))
                task.wait(0.1)

                local timestamp = perfectCast and 9999999999 or (tick() + math.random())
                rodRemote:InvokeServer(timestamp)
                task.wait(0.1)

                local x, y = -1.238, 0.969
                if not perfectCast then
                    x = math.random(-1000, 1000) / 1000
                    y = math.random(0, 1000) / 1000
                end
                miniGameRemote:InvokeServer(x, y)
                task.wait(1.3)

                finishRemote:FireServer()
            end)
            task.wait(1.4)
        end
    end)
end

function StopAutoFish()
    autofish = false
end

MainTab:CreateToggle({
    Name = "Enable Auto Fish",
    CurrentValue = false,
    Flag = "AutoFishToggle",
    Callback = function(value)
        if value then
          StartAutoFish()
        else
          StopAutoFish()
        end
    end,
})

MainTab:CreateToggle({
	Name = "Use Perfect Cast",
	CurrentValue = true,
	Flag = "PerfectCast",
	Callback = function(val)
		perfectCast = val
	end,
})

local PlayerTab = Window:CreateTab("Player", "users-round")

PlayerTab:CreateToggle({
	Name = "Infinity Jump",
	CurrentValue = false,
	Flag = "InfinityJump",
	Callback = function(val)
		ijump = val
	end,
})

game:GetService("UserInputService").JumpRequest:Connect(function()
	if ijump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
		LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
	end
end)

PlayerTab:CreateSlider({
	Name = "WalkSpeed",
	Range = {16, 150},
	Increment = 1,
	Suffix = "Speed",
	CurrentValue = 16,
	Flag = "WalkSpeed",
	Callback = function(val)
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = val end
	end,
})

PlayerTab:CreateSlider({
	Name = "Jump Power",
	Range = {50, 500},
	Increment = 10,
	Suffix = "JP",
	CurrentValue = 35,
	Flag = "JumpPower",
	Callback = function(val)
		local char = LocalPlayer.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.UseJumpPower = true
				hum.JumpPower = val
			end
		end
	end,
})

local IslandsTab = Window:CreateTab("Islands", "map")

local islandCoords = {
	["01"] = { name = "Weather Machine", position = Vector3.new(-1471, -3, 1929) },
	["02"] = { name = "Esoteric Depths", position = Vector3.new(3157, -1303, 1439) },
	["03"] = { name = "Tropical Grove", position = Vector3.new(-2038, 3, 3650) },
	["04"] = { name = "Stingray Shores", position = Vector3.new(-32, 4, 2773) },
	["05"] = { name = "Kohana Volcano", position = Vector3.new(-519, 24, 189) },
	["06"] = { name = "Coral Reefs", position = Vector3.new(-3095, 1, 2177) },
	["07"] = { name = "Crater Island", position = Vector3.new(968, 1, 4854) },
	["08"] = { name = "Kohana", position = Vector3.new(-658, 3, 719) },
	["09"] = { name = "Winter Fest", position = Vector3.new(1611, 4, 3280) },
	["10"] = { name = "Isoteric Island", position = Vector3.new(1987, 4, 1400) },
	["11"] = { name = "Treasure Hall", position = Vector3.new(-3600, -267, -1558) },
	["12"] = { name = "Lost Shore", position = Vector3.new(-3663, 38, -989 )}
}

for code, data in pairs(islandCoords) do
	IslandsTab:CreateButton({
		Name = data.name,
		Callback = function()
			local success, err = pcall(function()
				local charFolder = workspace:WaitForChild("Characters", 5)
				local char = charFolder:FindFirstChild(LocalPlayer.Name)
				if not char then error("Character not found") end
				local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 3)
				if not hrp then error("HumanoidRootPart not found") end
				hrp.CFrame = CFrame.new(data.position + Vector3.new(0, 5, 0))
			end)

			if success then
				NotifySuccess("Teleported!", "You are now at " .. data.name)
			else
				NotifyError("Teleport Failed", tostring(err))
			end
		end
	})
end

local SettingsTab = Window:CreateTab("Settings", "cog")

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local function Rejoin()
	local player = Players.LocalPlayer
	if player then
		TeleportService:Teleport(game.PlaceId, player)
	end
end

local function ServerHop()
	local placeId = game.PlaceId
	local servers = {}
	local cursor = ""
	local found = false

	repeat
		local url = "https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"
		if cursor ~= "" then
			url = url .. "&cursor=" .. cursor
		end

		local success, result = pcall(function()
			return HttpService:JSONDecode(game:HttpGet(url))
		end)

		if success and result and result.data then
			for _, server in pairs(result.data) do
				if server.playing < server.maxPlayers and server.id ~= game.JobId then
					table.insert(servers, server.id)
				end
			end
			cursor = result.nextPageCursor or ""
		else
			break
		end
	until not cursor or #servers > 0

	if #servers > 0 then
		local targetServer = servers[math.random(1, #servers)]
		TeleportService:TeleportToPlaceInstance(placeId, targetServer, LocalPlayer)
	else
		NotifyError("Server Hop Failed", "No servers available or all are full!")
	end
end

SettingsTab:CreateButton({
	Name = "Rejoin Server",
	Callback = function()
		Rejoin()
	end,
})

SettingsTab:CreateButton({
	Name = "Server Hop (New Server)",
	Callback = function()
		ServerHop()
	end,
})
