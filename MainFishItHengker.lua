-------------------------------------------
----- =======[ Load WindUI ]
-------------------------------------------

local Version = "1.6.4"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. Version .. "/main.lua"))()

-------------------------------------------
----- =======[ GLOBAL FUNCTION ]
-------------------------------------------

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

local Player = Players.LocalPlayer
local XPBar = Player:WaitForChild("PlayerGui"):WaitForChild("XP")

LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

task.spawn(function()
    if XPBar then
        XPBar.Enabled = true
    end
end)

local TeleportService = game:GetService("TeleportService")
local PlaceId = game.PlaceId

local function AutoReconnect()
    while task.wait(5) do
        if not Players.LocalPlayer or not Players.LocalPlayer:IsDescendantOf(game) then
            TeleportService:Teleport(PlaceId)
        end
    end
end

Players.LocalPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed then
        TeleportService:Teleport(PlaceId)
    end
end)

task.spawn(AutoReconnect)

local ijump = false

local RodIdle = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations"):WaitForChild("FishingRodReelIdle")

local RodReel = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations"):WaitForChild("EasyFishReelStart")

local RodShake = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations"):WaitForChild("CastFromFullChargePosition1Hand")

local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)

local RodShake = animator:LoadAnimation(RodShake)
local RodIdle = animator:LoadAnimation(RodIdle)
local RodReel = animator:LoadAnimation(RodReel)

-------------------------------------------
----- =======[ NOTIFY FUNCTION ]
-------------------------------------------

local function NotifySuccess(title, message, duration)
    WindUI:Notify({
        Title = title,
        Content = message,
        Duration = duration,
        Icon = "circle-check"
    })
end

local function NotifyError(title, message, duration)
    WindUI:Notify({
        Title = title,
        Content = message,
        Duration = duration,
        Icon = "ban"
    })
end

local function NotifyInfo(title, message, duration)
    WindUI:Notify({
        Title = title,
        Content = message,
        Duration = duration,
        Icon = "info"
    })
end

local function NotifyWarning(title, message, duration)
    WindUI:Notify({
        Title = title,
        Content = message,
        Duration = duration,
        Icon = "triangle-alert"
    })
end


-------------------------------------------
----- =======[ CHECK DATA ]
-------------------------------------------

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local pasteURL = "https://raw.githubusercontent.com/felix672018159/CobaDeployAplikasi/refs/heads/main/expireModFishIt.txt"
local timeAPI = "https://timeapi.io/api/timezone/zone?timeZone=Asia%2FJakarta"
local interval = 30

local notified = false
local kicked = false

local expiryUnix = nil

-- Ambil waktu saat ini dari API
local function getCurrentDateTime()
	local success, response = pcall(function()
		return game:HttpGet(timeAPI)
	end)

	if not success then return nil end

	local ok, data = pcall(function()
		return HttpService:JSONDecode(response)
	end)

	if not ok or not data.currentLocalTime then return nil end

	local year, month, day, hour, minute, second = data.currentLocalTime:match("^(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)")
	if not year then return nil end

	return os.time({
		year = tonumber(year),
		month = tonumber(month),
		day = tonumber(day),
		hour = tonumber(hour),
		min = tonumber(minute),
		sec = tonumber(second)
	})
end

-- Konversi string expired ke unix
local function convertExpiryToUnix(expiryString)
	local d, m, y, h, min, s = expiryString:match("(%d%d)%-(%d%d)%-(%d%d%d%d)%s+(%d%d):(%d%d):(%d%d)")
	if not d then return nil end

	return os.time({
		year = tonumber(y),
		month = tonumber(m),
		day = tonumber(d),
		hour = tonumber(h),
		min = tonumber(min),
		sec = tonumber(s)
	})
end

local function validateInitialLicense()
	local success, data = pcall(function()
		return game:HttpGet(pasteURL)
	end)

	if not success or not data then
		warn("Failed to fetch license data.")
		return false
	end

	for line in data:gmatch("[^\r\n]+") do
		local username, exp = line:match("^(.-)|(%d%d%-%d%d%-%d%d%d%d %d%d:%d%d:%d%d)$")
		if username and exp and username == LocalPlayer.Name then
			expiryUnix = convertExpiryToUnix(exp)
			if not expiryUnix then
				warn("Failed to parse expiry date.")
				return false
			end

			if NotifySuccess then
				NotifySuccess("Lisensi Valid", "User: " .. LocalPlayer.Name)
				NotifySuccess("Expired On", exp)
			end

			notified = true
			return true
		end
	end

	LocalPlayer:Kick("License not found!")
	kicked = true
	return false
end

local initialValid = validateInitialLicense()
if not initialValid then return end

task.spawn(function()
	while not kicked do
		task.wait(interval)

		local currentTime = getCurrentDateTime()
		if not currentTime then
			warn("Gagal mengambil waktu dari internet. Mencoba lagi...")
		elseif expiryUnix and currentTime >= expiryUnix then
			LocalPlayer:Kick("License has expired!")
			kicked = true
			break
		end
	end
end)

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local pasteURL = "https://paste.monster/3nn27BS9Atk6/raw/" --STRING DUMP = LATEST
local interval = 30

local kicked = false
local notified = false

local function checkStatus()
--	local success, result = pcall(function()
--		return game:HttpGet(pasteURL)
--	end)

--	if not success or typeof(result) ~= "string" then
--		return
--	end

--	local response = result:upper():gsub("%s+", "")

--	if response == "UPDATE" then
--		if not kicked then
--			kicked = true
--			LocalPlayer:Kick("QuietXHub Premium Update Available!.")
--		end
--	elseif response == "LATEST" then
--		if not notified then
			notified = true
			warn("[QuietXHub] Status: Latest version")
--		end
--	else
--		warn("[QuietXHub] Status unknown:", response)
--	end
end

--checkStatus()

--task.spawn(function()
--	while not kicked do
--		task.wait(interval)
--		checkStatus()
--	end
--end)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local pasteURL = "https://paste.monster/bnzTAGXXexo3/raw/"
local interval = 1

local kicked = false
local notified = false

--local function checkBlacklist()
--	local success, result = pcall(function()
--		return game:HttpGet(pasteURL)
--	end)

--	if not success or not result then
--		warn("Failed.")
--		return
--	end

--	local blacklist = string.upper(result)
--	local username = string.upper(LocalPlayer.DisplayName)

--	if string.find(blacklist, username) then
--		if not kicked then
--			LocalPlayer:Kick("HAHAHAHA THIS IS TALON, STOP CHEAT!!!")
--			kicked = true
--		end
--	else
--		if not notified then
--			notified = true
--		end
--	end
--end


--checkBlacklist()


--task.spawn(function()
--	while not kicked do
--		task.wait(interval)
--		checkBlacklist()
--	end
--end)


-------------------------------------------
----- =======[ CONFIRM POPUP ]
-------------------------------------------

local confirmed = false
WindUI:Popup({
    Title = "Thanksgiving!",
    Icon = "rbxassetid://129260712070622",
    Content = [[
Thank you for using Premium script!.
]],
    Buttons = {
        { Title = "Close", Variant = "Secondary", Callback = function() end },
        { Title = "Next", Variant = "Primary", Callback = function() confirmed = true end },
    }
})

repeat task.wait() until confirmed


-------------------------------------------
----- =======[ LOAD WINDOW ]
-------------------------------------------

local Window = WindUI:CreateWindow({
    Title = "QuietXHub Premium",
    Icon = "cannabis",
    Author = "by Prince",
    Folder = "QuietXHub",
    Size = UDim2.fromOffset(600, 400),
    Transparent = true,
    Theme = "Dark",
    KeySystem = false,
    ScrollBarEnabled = true,
    HideSearchBar = true,
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
        end,
    }
})

Window:EditOpenButton({
    Title = "QuietXHub",
    Icon = "cannabis",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = ColorSequence.new( -- gradient
        Color3.fromHex("9600FF"), 
        Color3.fromHex("AEBAF8")
    ),
    --Enabled = false,
    Draggable = true,
})

local ConfigManager = Window.ConfigManager
local myConfig = ConfigManager:CreateConfig("QuietXConfig")

WindUI:SetNotificationLower(true)

-------------------------------------------
----- =======[ ALL TAB ]
-------------------------------------------


local DevTab = Window:Tab({
    Title = "Feature Guide!",
    Icon = "airplay"
})

local AutoFish = Window:Tab({ 
	Title = "Auto Fish", 
	Icon = "fish"
})

local AutoFarmTab = Window:Tab({
	Title = "Auto Farm",
	Icon = "leaf"
})

local Player = Window:Tab({
    Title = "Player",
    Icon = "users-round"
})

local Utils = Window:Tab({
    Title = "Utility",
    Icon = "earth"
})

local SettingsTab = Window:Tab({ 
	Title = "Settings", 
	Icon = "cog" 
})

-------------------------------------------
----- =======[ DEVELOPER TAB ]
-------------------------------------------

DevTab:Paragraph({
    Title = "Developer",
    Desc = "This is Developer Contact",
    Color = "Green",
    Buttons = {
    	{
    		Title = "Discord Server",
    		Callback = function()
    			setclipboard("https://discord.gg/sudahsayahapushehehehe") --sudah saya hapus hehe
    		end
    	},
      {
      	Title = "Instagram",
      	Callback = function()
      		setclipboard("https://instagram.com/felixvickyl")
        end
      },
      {
      	Title = "Github",
      	Callback = function()
      		setclipboard("https://github.com/felix672018159") --modal ngecrack doang bang (less job of thinking)
        end
      }
    }
})

DevTab:Paragraph({
	Title = "Feature Guide",
	Color = "Grey",
	Desc = [[
====| Auto Enchant Rod |====

For the Enchant Rod feature, please read this first.
Before enchanting, you are required to have an Enchant Stone, then put the Enchant Stones in the 5th slot, then wait until the Enchant is successful. The Enchant Rod feature can be used anywhere.

========================•=========================

====| Rod Modifier |====

For the Rod Modifier feature, you can only change each rod once. If you want to change another rod, then the previous rod will be reset.

And for this feature, it says it can only increase 1.5x from your default rod stats.

Please reset Character after using to work perfectly

========================•=========================

====| Auto Farm |====

Before using it, I will teach you how to set up Auto Farm.

Please select the island you want to visit.Please select the island you want to farm.

Available Island Codes:
01 = Crater Islands
02 = Tropical Grove
03 = Vulcano
04 = Coral Reefs
05 = Winter Fest
06 = Weather Machine
07 = Treasure Room
08 = Deap Sea

Auto Farm Event (Opsional) :
Enable this if you want to farm during events as well, and leave it on if you don't need it!

Fish Threshold :
What is "Fish Threshold"? Detects the number of fish you have caught, if it has reached the number you have determined, it will sell all the fish that have been caught, except above legendary.

========================•=========================
]]
})

-------------------------------------------
----- =======[ AUTO FISH TAB ]
-------------------------------------------


local autofish = false
local autofish2 = false
local perfectCast = true
local customDelay = 1.2

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
                RodShake:Play()
                rodRemote:InvokeServer(timestamp)
                local x, y = -99.238, 99.969
                if not perfectCast then
                    x = math.random(-1000, 1000) / 1000
                    y = math.random(0, 1000) / 1000
                end
                RodIdle:Play()
                miniGameRemote:InvokeServer(x, y)
                task.wait(1)
                finishRemote:FireServer()
                RodReel:Play()
                RodIdle:Stop()
            end)
            task.wait(customDelay)
        end
    end)
end

function StopAutoFish()
    autofish = false
end





local EquipEvent = net:WaitForChild("RE/EquipItem")
local SellRemote = net:WaitForChild("RF/SellItem")

local AutoSellEnabled = false
local AutoSellDelay = 1

local function AutoSell(uuid)
    local success, result = pcall(function()
        return SellRemote:InvokeServer(uuid)
    end)
end


if not HookedAutoSell then
    HookedAutoSell = true

    local OldNamecall
    OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = { ... }
        local method = getnamecallmethod()

        if self == EquipEvent and method == "FireServer" and AutoSellEnabled then
            local uuid = args[1]
            local itemType = args[2]

            print("[AutoSell] Item Equipped:")
            print("  • UUID  :", uuid)
            print("  • Type  :", itemType)

            task.delay(AutoSellDelay, function()
                AutoSell(uuid)
            end)
        end

        return OldNamecall(self, unpack(args))
    end)
end

local DelayFish = AutoFish:Input({
    Title = "Custom Delay (Auto Fish)",
    Desc = "Enter a custom delay in seconds for Auto Fish",
    Value = nil,
    Type = "Input",
    Placeholder = "Example: 1.2",
    Callback = function(text) 
        local value = tonumber(text)
        if value and value > 0 then
			customDelay = value
			NotifySuccess("Custom Delay", "delay is set to " .. customDelay .. " seconds.")
		else
			NotifyWarning("Input Invalid", "Enter a number greater than 0.")
		end
    end
})
myConfig:Register("DelayAFish", DelayFish)

AutoFish:Toggle({
    Title = "Auto Fish",
    Callback = function(value)
        if value then
            StartAutoFish()
        else
            StopAutoFish()
        end
    end
})


local PerfectCast = AutoFish:Toggle({
    Title = "Auto Perfect Cast",
    Value = true,
    Callback = function(value)
        perfectCast = value
    end
})
myConfig:Register("Prefect", PerfectCast)


function sellAllFishes()
	local charFolder = workspace:FindFirstChild("Characters")
	local char = charFolder and charFolder:FindFirstChild(LocalPlayer.Name)
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		NotifyError("Character Not Found", "HRP tidak ditemukan.")
		return
	end

	local originalPos = hrp.CFrame
	local sellerPos = Vector3.new(-32, 5, 2885)
	local sellRemote = net:WaitForChild("RF/SellAllItems")

	task.spawn(function()
		NotifyInfo("Selling...", "I'm going to sell all the fish, please wait...", 3)

		hrp.CFrame = CFrame.new(sellerPos + Vector3.new(0, 3, 0))
		task.wait(1.5)
		local success, err = pcall(function()
			sellRemote:InvokeServer()
		end)

		if success then
			NotifySuccess("Sold!", "All the fish were sold successfully.", 3)
		else
			NotifyError("Sell Failed", tostring(err, 3))
		end

		task.wait(1)
		hrp.CFrame = originalPos
	end)
end

AutoFish:Button({
    Title = "Sell All Fishes",
    Locked = false,
    Callback = function()
        sellAllFishes()
    end
})

AutoFish:Button({
    Title = "Auto Enchant Rod",
    Callback = function()
        local ENCHANT_POSITION = Vector3.new(3231, -1303, 1402)
		local char = workspace:WaitForChild("Characters"):FindFirstChild(LocalPlayer.Name)
		local hrp = char and char:FindFirstChild("HumanoidRootPart")

		if not hrp then
			NotifyError("Auto Enchant Rod", "Failed to get character HRP.")
			return
		end

		NotifyInfo("Preparing Enchant...", "Please manually place Enchant Stone into slot 5 before we begin...", 5)

		task.wait(3)

		local Player = game:GetService("Players").LocalPlayer
		local slot5 = Player.PlayerGui.Backpack.Display:GetChildren()[10]

		local itemName = slot5 and slot5:FindFirstChild("Inner") and slot5.Inner:FindFirstChild("Tags") and slot5.Inner.Tags:FindFirstChild("ItemName")

		if not itemName or not itemName.Text:lower():find("enchant") then
			NotifyError("Auto Enchant Rod", "Slot 5 does not contain an Enchant Stone.")
			return
		end

		NotifyInfo("Enchanting...", "It is in the process of Enchanting, please wait until the Enchantment is complete", 7)

		local originalPosition = hrp.Position
		task.wait(1)
		hrp.CFrame = CFrame.new(ENCHANT_POSITION + Vector3.new(0, 5, 0))
		task.wait(1.2)

		local equipRod = net:WaitForChild("RE/EquipToolFromHotbar")
		local activateEnchant = net:WaitForChild("RE/ActivateEnchantingAltar")

		pcall(function()
			equipRod:FireServer(5)
			task.wait(0.5)
			activateEnchant:FireServer()
			task.wait(7)
			NotifySuccess("Enchant", "Successfully Enchanted!", 3)
		end)

		task.wait(0.9)
		hrp.CFrame = CFrame.new(originalPosition + Vector3.new(0, 3, 0))
    end
})


-------------------------------------------
----- =======[ AUTO FARM TAB ]
-------------------------------------------


local floatPlatform = nil

local function floatingPlat(enabled)
	if enabled then
			local charFolder = workspace:WaitForChild("Characters", 5)
			local char = charFolder:FindFirstChild(LocalPlayer.Name)
			if not char then return end

			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hrp then return end

			floatPlatform = Instance.new("Part")
			floatPlatform.Anchored = true
			floatPlatform.Size = Vector3.new(10, 1, 10)
			floatPlatform.Transparency = 1
			floatPlatform.CanCollide = true
			floatPlatform.Name = "FloatPlatform"
			floatPlatform.Parent = workspace

			task.spawn(function()
				while floatPlatform and floatPlatform.Parent do
					pcall(function()
						floatPlatform.Position = hrp.Position - Vector3.new(0, 3.5, 0)
					end)
					task.wait(0.1)
				end
			end)

			NotifySuccess("Float Enabled", "This feature has been successfully activated!")
		else
			if floatPlatform then
				floatPlatform:Destroy()
				floatPlatform = nil
			end
			NotifyWarning("Float Disabled", "Feature disabled")
		end
end

  
local LocalPlayer = Players.LocalPlayer  
local workspace = game:GetService("Workspace")  
  
local knownEvents = {}

-- Mapping kode → nama event
local eventCodes = {
	["1"] = "Ghost Shark Hunt",
	["2"] = "Shark Hunt",
	["3"] = "Worm Hunt"
}

local function teleportTo(position)
	local char = workspace:FindFirstChild("Characters"):FindFirstChild(LocalPlayer.Name)
	if char then
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = CFrame.new(position + Vector3.new(0, 10, 0))
		end
	end
end

local function updateKnownEvents()
	knownEvents = {}

	local props = workspace:FindFirstChild("Props")
	if props then
		for _, child in ipairs(props:GetChildren()) do
			if child:IsA("Model") and child.PrimaryPart then
				knownEvents[child.Name:lower()] = child
			end
		end
	end
end

local function monitorEvents()
	local props = workspace:FindFirstChild("Props")
	if not props then
		workspace.ChildAdded:Connect(function(child)
			if child.Name == "Props" then
				task.wait(0.3)
				monitorEvents()
			end
		end)
		return
	end

	props.ChildAdded:Connect(function()
		task.wait(0.3)
		updateKnownEvents()
	end)

	props.ChildRemoved:Connect(function()
		task.wait(0.3)
		updateKnownEvents()
	end)

	updateKnownEvents()
end

monitorEvents()

local autoTPEvent = false
local savedCFrame = nil
local monitoringTP = false
local alreadyTeleported = false
local teleportTime = nil

local function saveOriginalPosition()
	local char = workspace:FindFirstChild("Characters"):FindFirstChild(LocalPlayer.Name)
	if char and char:FindFirstChild("HumanoidRootPart") then
		savedCFrame = char.HumanoidRootPart.CFrame
	end
end

local function returnToOriginalPosition()
	if savedCFrame then
		local char = workspace:FindFirstChild("Characters"):FindFirstChild(LocalPlayer.Name)
		if char and char:FindFirstChild("HumanoidRootPart") then
			char.HumanoidRootPart.CFrame = savedCFrame
		end
	end
end

local function monitorAutoTP()
	if monitoringTP then return end
	monitoringTP = true

	while autoTPEvent do
		if next(knownEvents) ~= nil then
			for _, eventModel in pairs(knownEvents) do
				if not alreadyTeleported then
					saveOriginalPosition()
					teleportTo(eventModel:GetPivot().Position)
					if typeof(floatingPlat) == "function" then
						floatingPlat(true)
					end
					alreadyTeleported = true
					teleportTime = tick()
					NotifyError("Event Farm", "Teleported to: " .. eventModel.Name)
				end
				break
			end
		end

		if alreadyTeleported and teleportTime and (tick() - teleportTime >= 900) then
			returnToOriginalPosition()
			if typeof(floatingPlat) == "function" then
				floatingPlat(false)
			end
			alreadyTeleported = false
			teleportTime = nil
			NotifyInfo("Event Timeout", "Returned after 15 minutes.")
		end

		task.wait(1)
	end

	monitoringTP = false
end


local selectedIsland = "01"
local isAutoFarmRunning = false

local islandCodes = {
    ["01"] = "Crater Islands",
    ["02"] = "Tropical Grove",
    ["03"] = "Vulcano",
    ["04"] = "Coral Reefs",
    ["05"] = "Winter",
    ["06"] = "Machine",
    ["07"] = "Treasure Room",
    ["08"] = "Sisyphus Statue"
}

local farmLocations = {
    ["Crater Islands"] = {
    	CFrame.new(1066.1864, 57.2025681, 5045.5542, -0.682534158, 1.00865822e-08, 0.730853677, -5.8900711e-09, 1, -1.93017531e-08, -0.730853677, -1.74788859e-08, -0.682534158),
    	CFrame.new(1057.28992, 33.0884132, 5133.79883, 0.833871782, 5.44149223e-08, 0.551958203, -6.58184218e-09, 1, -8.86416984e-08, -0.551958203, 7.02829084e-08, 0.833871782),
    	CFrame.new(988.954712, 42.8254471, 5088.71289, -0.849417388, -9.89310394e-08, 0.527721584, -5.96115086e-08, 1, 9.15179328e-08, -0.527721584, 4.62786431e-08, -0.849417388),
    	CFrame.new(1006.70685, 17.2302666, 5092.14844, -0.989664078, 5.6538525e-09, -0.143405005, 9.14879283e-09, 1, -2.3711717e-08, 0.143405005, -2.47786183e-08, -0.989664078),
    	CFrame.new(1025.02356, 2.77259707, 5011.47021, -0.974474192, -6.87871804e-08, 0.224499553, -4.47472104e-08, 1, 1.12170284e-07, -0.224499553, 9.92613209e-08, -0.974474192),
    	CFrame.new(1071.14551, 3.528404, 5038.00293, -0.532300115, 3.38677708e-08, 0.84655571, 6.69992914e-08, 1, 2.12149165e-09, -0.84655571, 5.7847906e-08, -0.532300115),
    	CFrame.new(1022.55457, 16.6277809, 5066.28223, 0.721996129, 0, -0.691897094, 0, 1, 0, 0.691897094, 0, 0.721996129),
    },
    ["Tropical Grove"] = {
    	CFrame.new(-2165.05469, 2.77070165, 3639.87451, -0.589090407, -3.61497356e-08, -0.808067143, -3.20645626e-08, 1, -2.13606164e-08, 0.808067143, 1.3326984e-08, -0.589090407)
    },
    ["Vulcano"] = {
    	CFrame.new(-701.447937, 48.1446075, 93.1546631, -0.0770962164, 1.34335654e-08, -0.997023642, 9.84464776e-09, 1, 1.27124169e-08, 0.997023642, -8.83526763e-09, -0.0770962164),
    	CFrame.new(-654.994934, 57.2567711, 75.098526, -0.540957272, 2.58946509e-09, -0.841050088, -7.58775585e-08, 1, 5.18827363e-08, 0.841050088, 9.1883166e-08, -0.540957272),
    },
    ["Coral Reefs"] = {
    	CFrame.new(-3118.39624, 2.42531538, 2135.26392, 0.92336154, -1.0069185e-07, -0.383931547, 8.0607947e-08, 1, -6.84016968e-08, 0.383931547, 3.22115596e-08, 0.92336154),
    },
    ["Winter"] = {
    	CFrame.new(2036.15308, 6.54998732, 3381.88916, 0.943401575, 4.71338666e-08, -0.331652641, -3.28136842e-08, 1, 4.87781051e-08, 0.331652641, -3.51345975e-08, 0.943401575),
    },
    ["Machine"] = {
    	CFrame.new(-1459.3772, 14.7103214, 1831.5188, 0.777951121, 2.52131862e-08, -0.628324807, -5.24126378e-08, 1, -2.47663063e-08, 0.628324807, 5.21991339e-08, 0.777951121)
    },
    ["Treasure Room"] = {
    	CFrame.new(-3625.0708, -279.074219, -1594.57605, 0.918176472, -3.97606392e-09, -0.396171629, -1.12946204e-08, 1, -3.62128851e-08, 0.396171629, 3.77244298e-08, 0.918176472),
    	CFrame.new(-3600.72632, -276.06427, -1640.79663, -0.696130812, -6.0491181e-09, 0.717914939, -1.09490363e-08, 1, -2.19084972e-09, -0.717914939, -9.38559541e-09, -0.696130812),
    	CFrame.new(-3548.52222, -269.309845, -1659.26685, 0.0472991578, -4.08685423e-08, 0.998880744, -7.68598838e-08, 1, 4.45538149e-08, -0.998880744, -7.88812216e-08, 0.0472991578),
    	CFrame.new(-3581.84155, -279.09021, -1696.15637, -0.999634147, -0.000535600528, -0.0270430837, -0.000448358158, 0.999994695, -0.00323198596, 0.0270446707, -0.00321867829, -0.99962908),
    	CFrame.new(-3601.34302, -282.790955, -1629.37036, -0.526346684, 0.00143659476, 0.850268841, -0.000266355521, 0.999998271, -0.00185445137, -0.850269973, -0.00120255165, -0.526345372)
    },
    ["Sisyphus Statue"] = {
    	CFrame.new(-3722.92139, -101.130035, -955.649902, 0.777723014, -1.41385739e-08, 0.628607094, -2.57670365e-08, 1, 5.43713092e-08, -0.628607094, -5.84831632e-08, 0.777723014),
    	CFrame.new(-3708.47119, -97.2460022, -954.105835, 0.123319283, -4.95575279e-08, -0.992367029, 1.97065848e-08, 1, -4.7489813e-08, 0.992367029, -1.36997551e-08, 0.123319283),
    	CFrame.new(-3731.65234, -98.469101, -944.594482, -0.694187641, 2.44169023e-08, 0.719794095, -6.91526525e-09, 1, -4.05913241e-08, -0.719794095, -3.31555619e-08, -0.694187641)
    }
}


local function parseNumberWithDot(str)
    if typeof(str) ~= "string" or str == "" then return nil end
    local clean = str:gsub("%.", "")
    if clean == "" then return nil end
    return tonumber(clean)
end
      
local obtainedFishUUIDs = {}
local obtainedLimit = 30

local Remote = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RE/ObtainedNewFishNotification"]
Remote.OnClientEvent:Connect(function(_, _, data)
    if data and data.InventoryItem and data.InventoryItem.UUID then
        table.insert(obtainedFishUUIDs, data.InventoryItem.UUID)
    end
end)

local function sellItems()
    if #obtainedFishUUIDs > 0 then
        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index")
            :WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/SellAllItems"):InvokeServer()
    end

    obtainedFishUUIDs = {}
end

local function startAutoFarmLoop()
    NotifySuccess("Auto Farm Enabled", "Fishing started on island: " .. selectedIsland)

    while isAutoFarmRunning do
        local islandSpots = farmLocations[selectedIsland]
        if type(islandSpots) == "table" and #islandSpots > 0 then
            location = islandSpots[math.random(1, #islandSpots)]
        else
            location = islandSpots
        end

        if not location then
            NotifyError("Invalid Island", "Selected island name not found.")
            return
        end

        local char = workspace:FindFirstChild("Characters"):FindFirstChild(LocalPlayer.Name)
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            NotifyError("Teleport Failed", "HumanoidRootPart not found.")
            return
        end

        hrp.CFrame = location
        task.wait(1.5)

        StartAutoFish()

        repeat
            if not isAutoFarmRunning then break end
            task.wait(0.3)
        until #obtainedFishUUIDs >= obtainedLimit

        if not isAutoFarmRunning then
            StopAutoFish()
            NotifyWarning("Auto Farm Stopped", "Auto Farm manually disabled. Auto Fish stopped.")
            break
        end

        StopAutoFish()
        NotifyInfo("Fish Threshold Reached", "Selling all fishes...")
        task.wait(1.5)

        local npcSellLocation = CFrame.new(-32, 5, 2885)
        if npcSellLocation then
            hrp.CFrame = npcSellLocation
            task.wait(1.25)
        end

        sellItems()
        task.wait(1.5)
    end
end      


local islandCodes = {
    ["01"] = "Crater Islands",
    ["02"] = "Tropical Grove",
    ["03"] = "Vulcano",
    ["04"] = "Coral Reefs",
    ["05"] = "Winter",
    ["06"] = "Machine",
    ["07"] = "Treasure Room",
    ["08"] = "Sisyphus Statue"
}

local nameList = {}
local islandNamesToCode = {}

for code, name in pairs(islandCodes) do
    table.insert(nameList, name)
    islandNamesToCode[name] = code
end

table.sort(nameList)

local CodeIsland = AutoFarmTab:Dropdown({
    Title = "Farm Island",
    Values = nameList,
    Value = nameList[1],
    Callback = function(selectedName)
        local code = islandNamesToCode[selectedName]
        local islandName = islandCodes[code]
        if islandName and farmLocations[islandName] then
            selectedIsland = islandName
            NotifySuccess("Island Selected", "Farming location set to " .. islandName)
        else
            NotifyError("Invalid Selection", "The island name is not recognized.")
        end
    end
})

myConfig:Register("IslCode", CodeIsland)

local FishThres = AutoFarmTab:Input({
	Title = "Fish Threshold",
	Placeholder = "Example: 1500",
	Value = nil,
	Callback = function(value)
		local number = tonumber(value)
		if number then
		  obtainedLimit = number
			NotifySuccess("Threshold Set", "Fish threshold set to " .. number)
		else
		  NotifyError("Invalid Input", "Failed to convert input to number.")
		end
	end,
})

myConfig:Register("FishThreshold", FishThres)

local AutoFarm = AutoFarmTab:Toggle({
	Title = "Start Auto Farm",
	Callback = function(state)
		isAutoFarmRunning = state
		if state then
			startAutoFarmLoop()
		else
			StopAutoFish()
		end
	end
})

myConfig:Register("AutoFarmStart", AutoFarm)

AutoFarmTab:Toggle({
	Title = "Auto Farm Event",
	Desc = "!! DO WITH YOUR OWN RISK !!",
	Value = false,
	Callback = function(state)
		autoTPEvent = state
		if autoTPEvent then
			monitorAutoTP()
		else
			if alreadyTeleported then
				returnToOriginalPosition()
				if typeof(floatingPlat) == "function" then
					floatingPlat(false)
				end
				alreadyTeleported = false
			end
		end
	end
})


-------------------------------------------
----- =======[ PLAYER TAB ]
-------------------------------------------

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local currentDropdown = nil

-- Fungsi untuk ambil daftar player
local function getPlayerList()
local list = {}
for _, p in ipairs(Players:GetPlayers()) do
if p ~= LocalPlayer then
table.insert(list, p.DisplayName)
end
end
return list
end

-- Fungsi teleport (tidak diubah)
local function teleportToPlayerExact(target)
local characters = workspace:FindFirstChild("Characters")
if not characters then return end

local targetChar = characters:FindFirstChild(target)  
local myChar = characters:FindFirstChild(LocalPlayer.Name)  

if targetChar and myChar then  
	local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")  
	local myHRP = myChar:FindFirstChild("HumanoidRootPart")  
	if targetHRP and myHRP then  
		myHRP.CFrame = targetHRP.CFrame + Vector3.new(2, 0, 0)  
	end  
end

end

-- Fungsi untuk buat ulang dropdown
local function updateDropdown()
-- Hancurkan dropdown lama jika ada
if currentDropdown and currentDropdown.Destroy then
currentDropdown:Destroy()
end

-- Buat ulang dengan data terbaru  
currentDropdown = Player:Dropdown({  
	Title = "Teleport to Player",  
	Desc = "Select player to teleport",  
	Values = getPlayerList(),  
	Callback = function(selectedDisplayName)  
		for _, p in pairs(Players:GetPlayers()) do  
			if p.DisplayName == selectedDisplayName then  
				teleportToPlayerExact(p.Name)  
				NotifySuccess("Teleport Successfully", "Successfully Teleported to " .. p.DisplayName .. "!", 3)  
				break  
			end  
		end  
	end  
})

end

-- Update dropdown saat player join/leave
Players.PlayerAdded:Connect(function()
task.delay(0.1, updateDropdown) -- kasih delay kecil biar data sempat update
end)

Players.PlayerRemoving:Connect(function()
task.delay(0.1, updateDropdown)
end)

-- Inisialisasi awal
updateDropdown()


local defaultMinZoom = LocalPlayer.CameraMinZoomDistance
local defaultMaxZoom = LocalPlayer.CameraMaxZoomDistance

Player:Toggle({
    Title = "Unlimited Zoom",
    Desc = "Unlimited Camera Zoom for take a Picture",
    Value = false,
    Callback = function(state)
        if state then
            LocalPlayer.CameraMinZoomDistance = 0.5
            LocalPlayer.CameraMaxZoomDistance = 9999
        else
            LocalPlayer.CameraMinZoomDistance = defaultMinZoom
            LocalPlayer.CameraMaxZoomDistance = defaultMaxZoom
        end
    end
})


local function accessAllBoats()
    local vehicles = workspace:FindFirstChild("Vehicles")
    if not vehicles then
        NotifyError("Not Found", "Vehicles container not found.")
        return
    end

    local count = 0

    for _, boat in ipairs(vehicles:GetChildren()) do
        if boat:IsA("Model") and boat:GetAttribute("OwnerId") then
            local currentOwner = boat:GetAttribute("OwnerId")
            if currentOwner ~= LocalPlayer.UserId then
                boat:SetAttribute("OwnerId", LocalPlayer.UserId)
                count += 1
            end
        end
    end

    NotifySuccess("Access Granted", "You now own " .. count .. " boat(s).", 3)
end

Player:Button({
    Title = "Access All Boats",
    Callback = accessAllBoats
})

Player:Toggle({
	Title = "Infinity Jump",
	Callback = function(val)
		ijump = val
	end,
})

game:GetService("UserInputService").JumpRequest:Connect(function()
	if ijump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
		LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
	end
end)

local EnableFloat = Player:Toggle({
	Title = "Enable Float",
	Value = nil,
	Callback = function(enabled)
			floatingPlat(enabled)
	end,
})

myConfig:Register("ActiveFloat", EnableFloat)

local universalNoclip = false
local originalCollisionState = {}


local NoClip = Player:Toggle({
	Title = "Universal No Clip",
	Value = nil,
	Callback = function(val)
		universalNoclip = val

		if val then
			NotifySuccess("Universal Noclip Active", "You & your vehicle can penetrate all objects.", 3)
		else

			for part, state in pairs(originalCollisionState) do
				if part and part:IsA("BasePart") then
					part.CanCollide = state
				end
			end
			originalCollisionState = {}
			NotifyWarning("Universal Noclip Disabled", "All collisions are returned to their original state.", 3)
		end
	end,
})

game:GetService("RunService").Stepped:Connect(function()
	if not universalNoclip then return end

	local char = LocalPlayer.Character
	if char then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") and part.CanCollide == true then
				originalCollisionState[part] = true
				part.CanCollide = false
			end
		end
	end

	for _, model in ipairs(workspace:GetChildren()) do
		if model:IsA("Model") and model:FindFirstChildWhichIsA("VehicleSeat", true) then
			for _, part in ipairs(model:GetDescendants()) do
				if part:IsA("BasePart") and part.CanCollide == true then
					originalCollisionState[part] = true
					part.CanCollide = false
				end
			end
		end
	end
end)

myConfig:Register("NoClip", NoClip)

local AntiDrown_Enabled = false
local rawmt = getrawmetatable(game)
setreadonly(rawmt, false)
local oldNamecall = rawmt.__namecall

rawmt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if tostring(self) == "URE/UpdateOxygen" and method == "FireServer" and AntiDrown_Enabled then
        return nil
    end

    return oldNamecall(self, ...)
end)


local ADrown = Player:Toggle({
	Title = "Anti Drown (Oxygen Bypass)",
	Callback = function(state)
		AntiDrown_Enabled = state
		if state then
			NotifySuccess("Anti Drown Active", "Oxygen loss has been blocked.", 3)
		else
			NotifyWarning("Anti Drown Disabled", "You're vulnerable to drowning again.", 3)
		end
	end,
})

myConfig:Register("AntiDrown", ADrown)

local Speed = Player:Slider({
	Title = "WalkSpeed",
	Value = {
	    Min = 16,
	    Max = 200,
	    Default = 20
	},
	Step = 1,
	Callback = function(val)
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = val end
	end,
})

myConfig:Register("PlayerSpeed", Speed)

local Jp = Player:Slider({
	Title = "Jump Power",
	Value = {
	    Min = 50, 
	    Max = 500,
	    Default = 35
	},
	Step = 10,
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

myConfig:Register("JumpPower", Jp)


-------------------------------------------
----- =======[ UTILITY TAB ]
-------------------------------------------

local targetUserId = nil
local tradeActive = false

Utils:Input({
   Title = "Trade",
   Desc = "Trade With Someone Here",
   Placeholder = "Enter Display Name",
   Callback = function(displayName)
      for _, player in ipairs(Players:GetPlayers()) do
         if player.DisplayName == displayName or player.Name == displayName then
            targetUserId = player.UserId
            NotifySuccess("Trade Target", "Trade target found: " .. player.Name)
            return
         end
      end
      NotifyError("Trade Target", "Player not found", 3)
   end,
})

Utils:Toggle({
   Title = "Enable Trade",
   Value = false,
   Callback = function(val)
      tradeActive = val
      if val then
         NotifySuccess("Trade Mode", "Trade Mode is active. Click an item to send a trade..")
      else
         NotifySuccess("Trade Mode", "Trade Mode Disabled.")
      end
   end,
})

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
   local args = {...}
   local method = getnamecallmethod()

   if tradeActive and tostring(self) == "RE/EquipItem" and method == "FireServer" then
      local uuid = args[1]
      if uuid and targetUserId then
         local initiateTrade = net:WaitForChild("RF/InitiateTrade")
         initiateTrade:InvokeServer(targetUserId, uuid)
         NotifySuccess("Trade Sent", "Trade sent to " .. targetUserId)
      else
         NotifyError("Failed to Send Trade", "Make sure Display Name is filled in and the item is valid.")
      end
      return nil
   end

   return oldNamecall(self, unpack(args))
end)

setreadonly(mt, true)

local weatherActive = {}
local weatherData = {
    ["Storm"] = { duration = 600 },
    ["Cloudy"] = { duration = 600 },
    ["Snow"] = { duration = 600 },
    ["Wind"] = { duration = 600 }
}

local function randomDelay(min, max)
    return math.random(min * 100, max * 100) / 100
end

local function autoBuyWeather(weatherType)
    local purchaseRemote = ReplicatedStorage:WaitForChild("Packages")
        :WaitForChild("_Index")
        :WaitForChild("sleitnick_net@0.2.0")
        :WaitForChild("net")
        :WaitForChild("RF/PurchaseWeatherEvent")

    task.spawn(function()
        while weatherActive[weatherType] do
            pcall(function()
                purchaseRemote:InvokeServer(weatherType)
                NotifySuccess("Weather Purchased", "Successfully activated " .. weatherType)

                task.wait(weatherData[weatherType].duration)

                local randomWait = randomDelay(1, 5)
                NotifyInfo("Waiting...", "Delay before next purchase: " .. tostring(randomWait) .. "s")
                task.wait(randomWait)
            end)
        end
    end)
end


local WeatherDropdown = Utils:Dropdown({
    Title = "Auto Buy Weather",
    Values = { "Storm", "Cloudy", "Snow", "Wind" },
    Value = {},
    Multi = true,
    AllowNone = true,
    Callback = function(selected)
        for weatherType, active in pairs(weatherActive) do
            if active and not table.find(selected, weatherType) then
                weatherActive[weatherType] = false
                NotifyWarning("Auto Weather", "Auto buying " .. weatherType .. " has been stopped.")
            end
        end
        for _, weatherType in pairs(selected) do
            if not weatherActive[weatherType] then
                weatherActive[weatherType] = true
                NotifyInfo("Auto Weather", "Auto buying " .. weatherType .. " has started!")
                autoBuyWeather(weatherType)
            end
        end
    end
})

myConfig:Register("WeatherDropdown", WeatherDropdown)


local RodItemsPath = game:GetService("ReplicatedStorage"):WaitForChild("Items")

local BaitsPath = ReplicatedStorage:WaitForChild("Baits")

local lastModifiedRod = nil
local originalRodData = {}

local lastModifiedBait = nil
local originalBaitData = {}

local function deepCopyTable(tbl)
	local copy = {}
	for k, v in pairs(tbl) do
		copy[k] = typeof(v) == "table" and deepCopyTable(v) or v
	end
	return copy
end

local function resetPreviousRod()
	if lastModifiedRod and originalRodData[lastModifiedRod] then
		local rodModule = RodItemsPath:FindFirstChild(lastModifiedRod)
		if rodModule and rodModule:IsA("ModuleScript") then
			local rodData = require(rodModule)
			local originalData = originalRodData[lastModifiedRod]

			for key, value in pairs(originalData) do
				rodData[key] = value
			end
			NotifyWarning("Rod Reset", "Rod '" .. lastModifiedRod .. "' has been reset.", 3)
		end
	end
end

local function modifyRodData(rodNameInput)
	local targetModule = RodItemsPath:FindFirstChild(rodNameInput)
	if not targetModule then
		NotifyError("Rod Not Found", "No rod matched: " .. rodNameInput, 3)
		return
	end

	resetPreviousRod()

	local rodData = require(targetModule)
	if rodData.Data and rodData.Data.Type == "Fishing Rods" then
		originalRodData[rodNameInput] = deepCopyTable(rodData)
		lastModifiedRod = rodNameInput

		if rodData.RollData and rodData.RollData.BaseLuck then
			rodData.RollData.BaseLuck *= 1.35
		end
		if rodData.ClickPower then
			rodData.ClickPower *= 1.25
		end
		if rodData.Resilience then
			rodData.Resilience *= 1.25
		end
		if typeof(rodData.Windup) == "NumberRange" then
			local newMin = rodData.Windup.Min * 0.50
			local newMax = rodData.Windup.Max * 0.50
			rodData.Windup = NumberRange.new(newMin, newMax)
		end
		if rodData.MaxWeight then
			rodData.MaxWeight *= 1.25
		end

		NotifySuccess("Rod Modified", "Rod '" .. rodData.Data.Name .. "' successfully boosted.", 3)
	else
		NotifyError("Invalid Rod", "The selected module is not a valid rod.", 3)
	end
end

local function resetPreviousBait()
	if lastModifiedBait and originalBaitData[lastModifiedBait] then
		local bait = BaitsPath:FindFirstChild(lastModifiedBait)
		if bait and bait:IsA("ModuleScript") then
			local baitData = require(bait)
			local originalData = originalBaitData[lastModifiedBait]

			for key, value in pairs(originalData) do
				baitData[key] = value
			end

			NotifyWarning("Bait Reset", "Bait '" .. lastModifiedBait .. "' has been reset.", 3)
		end
	end
end

local function modifyBaitData(baitName)
	local baitModule = BaitsPath:FindFirstChild(baitName)
	if not baitModule then
		NotifyError("Bait Not Found", "No bait matched: " .. baitName, 3)
		return
	end

	resetPreviousBait()

	local baitData = require(baitModule)
	originalBaitData[baitName] = deepCopyTable(baitData)
	lastModifiedBait = baitName

	if baitData.Modifiers and baitData.Modifiers.BaseLuck then
		baitData.Modifiers.BaseLuck *= 1.4
	end

	NotifySuccess("Bait Modified", "Bait '" .. baitName .. "' successfully boosted.", 3)
end

local rodOptions = {}
local rodNameMap = {}

for _, item in pairs(RodItemsPath:GetChildren()) do
	if item:IsA("ModuleScript") and item.Name:sub(1,3) == "!!!" then
		local displayName = item.Name:gsub("^!!!", "")
		table.insert(rodOptions, displayName)
		rodNameMap[displayName] = item.Name
	end
end

Utils:Dropdown({
	Title = "Rod Modifiers",
	Values = rodOptions,
	Multi = false,
	Callback = function(displayedRodName)
		local actualRodName = rodNameMap[displayedRodName]
		if actualRodName then
			modifyRodData(actualRodName)
		end
	end
})


local baitOptions = {}
for _, bait in pairs(BaitsPath:GetChildren()) do
	if bait:IsA("ModuleScript") then
		table.insert(baitOptions, bait.Name)
	end
end

Utils:Dropdown({
	Title = "Bait Modifier",
	Values = baitOptions,
	Multi = false,
	Callback = function(option)
		modifyBaitData(option)
	end
})

Utils:Button({
	Title = "Reset Last Modified Bait",
	Callback = function()
		if lastModifiedBait then
			resetPreviousBait()
			lastModifiedBait = nil
		else
			NotifyWarning("No Bait", "No bait has been modified yet.", 3)
		end
	end
})

Utils:Button({
	Title = "Reset Last Modified Rod",
	Callback = function()
		if lastModifiedRod then
			resetPreviousRod()
			lastModifiedRod = nil
		else
			NotifyWarning("No Rod", "No rod has been modified yet.", 3)
		end
	end
})

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

local islandNames = {}
for _, data in pairs(islandCoords) do
    table.insert(islandNames, data.name)
end

Utils:Dropdown({
    Title = "Island Selector",
    Desc = "Select island to teleport",
    Values = islandNames,
    Value = islandNames[1],
    Callback = function(selectedName)
        for code, data in pairs(islandCoords) do
            if data.name == selectedName then
                local success, err = pcall(function()
                    local charFolder = workspace:WaitForChild("Characters", 5)
                    local char = charFolder:FindFirstChild(LocalPlayer.Name)
                    if not char then error("Character not found") end
                    local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 3)
                    if not hrp then error("HumanoidRootPart not found") end
                    hrp.CFrame = CFrame.new(data.position + Vector3.new(0, 5, 0))
                end)

                if success then
                    NotifySuccess("Teleported!", "You are now at " .. selectedName)
                else
                    NotifyError("Teleport Failed", tostring(err))
                end
                break
            end
        end
    end
})

local eventsList = { "Shark Hunt", "Ghost Shark Hunt", "Worm Hunt" }

Utils:Dropdown({
    Title = "Teleport Event",
    Values = eventsList,
    Value = "Shark Hunt",
    Callback = function(option)
        local props = workspace:FindFirstChild("Props")
        if props and props:FindFirstChild(option) and props[option]:FindFirstChild("Fishing Boat") then
            local fishingBoat = props[option]["Fishing Boat"]
            local boatCFrame = fishingBoat:GetPivot()
            local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = boatCFrame + Vector3.new(0, 15, 0)
                WindUI:Notify({
                	Title = "Event Available!",
                	Content = "Teleported To " .. option,
                	Icon = "circle-check",
                	Duration = 3
                })
            end
        else
            WindUI:Notify({
                Title = "Event Not Found",
                Text = option .. " Not Found!",
                Icon = "ban",
                Duration = 3
            })
        end
    end
})

local Boats = {
    { Name = "Small Boat", Id = 1 },
    { Name = "Kayak", Id = 2 },
    { Name = "Jetsky", Id = 3 },
    { Name = "Highfield Boat", Id = 4 },
    { Name = "Speed Boat", Id = 5 },
    { Name = "Fishing Boat", Id = 6 },
    { Name = "Hyper Boat", Id = 7 },
    { Name = "Alpha Floaty", Id = 8 },
    { Name = "Devil Duck 9000", Id = 9 },
    { Name = "Festive Duck", Id = 10 },
    { Name = "Frozen Boat", Id = 11 },
    { Name = "Santa Sleigh", Id = 12 },
    { Name = "Cruiser Boat", Id = 13 },
    { Name = "Mini Yacth", Id = 14 },
}

local function despawnBoat()
	local success, err = pcall(function()
		net:WaitForChild("RF/DespawnBoat"):InvokeServer()
	end)
	if not success then
		NotifyError("Despawn Failed", tostring(err))
	end
end

local function spawnBoat(id, name)
	despawnBoat()
	task.wait(1.3)
	local success, err = pcall(function()
		net:WaitForChild("RF/SpawnBoat"):InvokeServer(id)
	end)

	if success then
		NotifySuccess("Boat Spawned", "Successfully spawned " .. name)
	else
		NotifyError("Spawn Failed", tostring(err))
	end
end

local boatNames = {}
for _, boat in ipairs(Boats) do
	table.insert(boatNames, boat.Name)
end

Utils:Dropdown({
    Title = "Spawn Boat",
    Desc = "Select a boat to spawn",
    Values = boatNames,
    Value = boatNames[1],
    Callback = function(selectedName)
        for _, boat in ipairs(Boats) do
            if boat.Name == selectedName then
                spawnBoat(boat.Id, boat.Name)
                break
            end
        end
    end
})



local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local HRP = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

local Items = ReplicatedStorage:WaitForChild("Items")
local Baits = ReplicatedStorage:WaitForChild("Baits")
local net = ReplicatedStorage:WaitForChild("Packages")
	:WaitForChild("_Index")
	:WaitForChild("sleitnick_net@0.2.0")
	:WaitForChild("net")


local npcCFrame = CFrame.new(
	66.866745, 4.62500143, 2858.98535,
	-0.981261611, 5.77215005e-08, -0.192680314,
	6.94250204e-08, 1, -5.39889484e-08,
	0.192680314, -6.63541186e-08, -0.981261611
)


local function FadeScreen(duration)
	local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false

	local frame = Instance.new("Frame", gui)
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1

	local tweenIn = TweenService:Create(frame, TweenInfo.new(0.2), { BackgroundTransparency = 0.9 })
	tweenIn:Play()
	tweenIn.Completed:Wait()

	wait(duration)

	local tweenOut = TweenService:Create(frame, TweenInfo.new(0.3), { BackgroundTransparency = 1 })
	tweenOut:Play()
	tweenOut.Completed:Wait()
	gui:Destroy()
end

local function SafePurchase(callback)
	local originalCFrame = HRP.CFrame
	HRP.CFrame = npcCFrame
	FadeScreen(0.9)
	pcall(callback)
	wait(1)
	HRP.CFrame = originalCFrame
end

-- RODS DROPDOWN
local rodOptions = {}
local rodData = {}

for _, rod in ipairs(Items:GetChildren()) do
	if rod:IsA("ModuleScript") and rod.Name:find("!!!") then
		local success, module = pcall(require, rod)
		if success and module and module.Data then
			local id = module.Data.Id
			local name = module.Data.Name or rod.Name
			local price = module.Price or module.Data.Price

			if price then
				table.insert(rodOptions, name .. " | Price: " .. tostring(price))
				rodData[name] = id
			end
		end
	end
end

Utils:Dropdown({
	Title = "Rod Shop",
	Desc = "Select Rod to Buy",
	Values = rodOptions,
	Value = nil,
	Callback = function(option)
		local selectedName = option:split(" |")[1]
		local id = rodData[selectedName]

		SafePurchase(function()
			net:WaitForChild("RF/PurchaseFishingRod"):InvokeServer(id)
			NotifySuccess("Rod Purchased", selectedName .. " has been successfully purchased!")
		end)
	end,
})


local baitOptions = {}
local baitData = {}

for _, bait in ipairs(Baits:GetChildren()) do
	if bait:IsA("ModuleScript") then
		local success, module = pcall(require, bait)
		if success and module and module.Data then
			local id = module.Data.Id
			local name = module.Data.Name or bait.Name
			local price = module.Price or module.Data.Price

			if price then
				table.insert(baitOptions, name .. " | Price: " .. tostring(price))
				baitData[name] = id
			end
		end
	end
end

Utils:Dropdown({
	Title = "Baits Shop",
	Desc = "Select Baits to Buy",
	Values = baitOptions,
	Value = nil,
	Callback = function(option)
		local selectedName = option:split(" |")[1]
		local id = baitData[selectedName]

		SafePurchase(function()
			net:WaitForChild("RF/PurchaseBait"):InvokeServer(id)
			NotifySuccess("Bait Purchased", selectedName .. " has been successfully purchased!")
		end)
	end,
})

local npcFolder = game:GetService("ReplicatedStorage"):WaitForChild("NPC")

local npcList = {}
for _, npc in pairs(npcFolder:GetChildren()) do
	if npc:IsA("Model") then
		local hrp = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
		if hrp then
			table.insert(npcList, npc.Name)
		end
	end
end


Utils:Dropdown({
	Title = "NPC",
	Desc = "Select NPC to Teleport",
	Values = npcList,
	Value = nil,
	Callback = function(selectedName)
		local npc = npcFolder:FindFirstChild(selectedName)
		if npc and npc:IsA("Model") then
			local hrp = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
			if hrp then
				local charFolder = workspace:FindFirstChild("Characters", 5)
				local char = charFolder and charFolder:FindFirstChild(LocalPlayer.Name)
				if not char then return end
				local myHRP = char:FindFirstChild("HumanoidRootPart")
				if myHRP then
					myHRP.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
					NotifySuccess("Teleported!", "You are now near: " .. selectedName)
				end
			end
		end
	end
})


-------------------------------------------
----- =======[ SETTINGS TAB ]
-------------------------------------------


local AntiAFKEnabled = true
local AFKConnection = nil

SettingsTab:Toggle({
	Title = "Anti-AFK",
	Value = true,
	Callback = function(Value)
		AntiAFKEnabled = Value

		if AntiAFKEnabled then
			if AFKConnection then
				AFKConnection:Disconnect()
			end

			
			local LocalPlayer = Players.LocalPlayer
			local VirtualUser = game:GetService("VirtualUser")

			AFKConnection = LocalPlayer.Idled:Connect(function()
				pcall(function()
					VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
					task.wait(1)
					VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
				end)
			end)

			if NotifySuccess then
				NotifySuccess("Anti-AFK Activated", "You will now avoid being kicked.")
			end

		else
			if AFKConnection then
				AFKConnection:Disconnect()
				AFKConnection = nil
			end

			if NotifySuccess then
				NotifySuccess("Anti-AFK Deactivated", "You can now go idle again.")
			end
		end
	end,
})

SettingsTab:Button({
	Title = "Boost FPS (Maximize Performance)",
	Callback = function()
		for _, v in pairs(game:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Material = Enum.Material.SmoothPlastic
				v.Reflectance = 0
			elseif v:IsA("Decal") or v:IsA("Texture") then
				v.Transparency = 1
			end
		end

		local Lighting = game:GetService("Lighting")
		for _, effect in pairs(Lighting:GetChildren()) do
			if effect:IsA("PostEffect") then
				effect.Enabled = false
			end
		end

		Lighting.GlobalShadows = false
		Lighting.FogEnd = 1e10

		settings().Rendering.QualityLevel = "Level01"
	end
})

SettingsTab:Button({
	Title = "HDR Shader",
	Callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/felix672018159/CobaDeployAplikasi/refs/heads/main/hdrModFishIt.lua"))()
	end,
})

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

local Keybind = SettingsTab:Keybind({
    Title = "Keybind",
    Desc = "Keybind to open UI",
    Value = "G",
    Callback = function(v)
        Window:SetToggleKey(Enum.KeyCode[v])
    end
})

myConfig:Register("Keybind", Keybind)

SettingsTab:Button({
	Title = "Rejoin Server",
	Callback = function()
		Rejoin()
	end,
})

SettingsTab:Button({
	Title = "Server Hop (New Server)",
	Callback = function()
		ServerHop()
	end,
})


local WebhookURL = "https://discord.com/api/webhooks/diohok-ohok" -- "https://discord.com/api/webhooks/1398155779059744931/dMJWFs3LhU9XetoQr49i4LCiFMXHG5qZsIterXxX-zCqFLy_pgiT5crDPkqZxGfJNdQu"      
local TargetKeywords = {      
    "shark",      
    "turtle",      
    "whale",      
    "worm",
    "robot kraken",
    "giant squid",
    "blob fish",
    "seahorse",
    "ray",
    "dotted stingray",
    "lined cardinal fish"
       
}      

-- ✅ VARIABEL TOGGLE
local WebhookEnabled = true

-- ✅ UI TOGGLE
SettingsTab:Toggle({
    Title = "Fish Webhook",
    Value = true,
    Callback = function(value)
        WebhookEnabled = value
        if WebhookEnabled then
            NotifySuccess("Webhook ON", "Webhook Enabled.")
        else
            NotifyWarning("Webhook OFF", "Webhook Disabled")
        end
    end
})

-- ✅ CEK KATA KUNCI IKAN
local function isTargetFish(fishName)
	for _, keyword in pairs(TargetKeywords) do
		if string.find(string.lower(fishName), string.lower(keyword)) then
			return true
		end
	end
	return false
end

-- ✅ CARI GAMBAR DARI ASSET ID
local function GetRobloxImage(assetId)
	local url = "https://thumbnails.roblox.com/v1/assets?assetIds=" .. assetId .. "&size=420x420&format=Png&isCircular=false"
	local success, response = pcall(game.HttpGet, game, url)
	if success then
		local HttpService = game:GetService("HttpService")
		local data = HttpService:JSONDecode(response)
		if data and data.data and data.data[1] and data.data[1].imageUrl then
			return data.data[1].imageUrl
		end
	end
	return nil
end

-- ✅ KIRIM WEBHOOK
local function sendFishWebhook(fishName, rarityText, assetId)
	if not WebhookEnabled then return end -- ⛔ Cegah jika toggle off

	local HttpService = game:GetService("HttpService")
	local username = game:GetService("Players").LocalPlayer.DisplayName
	local imageUrl = GetRobloxImage(assetId)

	if not imageUrl then
		warn("❌ Gagal mendapatkan image URL untuk assetId:", assetId)
		return
	end

	local embedDesc = string.format([[
Hei **%s**! 🎣      
You have successfully caught a fish.

======| FISH DATA |======    
🧾 Name : **%s**      
🌟 Rarity : **%s**
]], username, fishName, rarityText)

	local data = {
		["username"] = "QuietXHub",
		["embeds"] = {{
			["title"] = "Fish Caught!",
			["description"] = embedDesc,
			["color"] = tonumber("0x00bfff"),
			["image"] = {
				["url"] = imageUrl
			},
			["footer"] = {
				["text"] = "Fish It Notifier • " .. os.date("%d %B %Y, %H:%M:%S")
			}
		}}
	}

	local requestFunc = syn and syn.request or http and http.request or http_request or request or fluxus and fluxus.request
	if requestFunc then
		requestFunc({
			Url = WebhookURL,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json"
			},
			Body = HttpService:JSONEncode(data)
		})
	else
		warn("❌ HttpRequest tidak tersedia di executor ini.")
	end
end

-- ✅ MONITOR IKAN YANG DIDAPAT
local function startFishDetection()
	local plr = game:GetService("Players").LocalPlayer
	local guiNotif = plr.PlayerGui:WaitForChild("Small Notification"):WaitForChild("Display"):WaitForChild("Container")

	local fishText = guiNotif:WaitForChild("ItemName")
	local rarityText = guiNotif:WaitForChild("Rarity")
	local imageFrame = plr.PlayerGui["Small Notification"]:WaitForChild("Display"):WaitForChild("VectorFrame"):WaitForChild("Vector")

	fishText:GetPropertyChangedSignal("Text"):Connect(function()
		local fishName = fishText.Text
		if isTargetFish(fishName) then
			local rarity = rarityText.Text
			local assetId = string.match(imageFrame.Image, "%d+")
			if assetId then
				sendFishWebhook(fishName, rarity, assetId)
			end
		end
	end)
end

-- ✅ EKSEKUSI
startFishDetection()

SettingsTab:Button({
    Title = "Save",
    Desc = "Save Settings to config",
    Callback = function()
        myConfig:Save()
        NotifySuccess("Config Saved", "Config has been saved!")
    end
})

SettingsTab:Button({
    Title = "Load",
    Desc = "Loads Settings from config",
    Callback = function()
        myConfig:Load()
        NotifySuccess("Config Loaded", "Config has beed loaded!")
    end
})
