task.wait(1)
-------------------------------------------
----- =======[ Load WindUI ]
-------------------------------------------

local Version = "1.6.4"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" ..
    Version .. "/main.lua"))()

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
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

for i, v in next, getconnections(game:GetService("Players").LocalPlayer.Idled) do
    v:Disable()
end

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

local RodShake = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations"):WaitForChild(
    "CastFromFullChargePosition1Hand")

local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")


local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)

local RodShake = animator:LoadAnimation(RodShake)
local RodIdle = animator:LoadAnimation(RodIdle)
local RodReel = animator:LoadAnimation(RodReel)

local blockNotif = false

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")


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
----- =======[ LOAD WINDOW ]
-------------------------------------------

WindUI.TransparencyValue = 0.3

local Window = WindUI:CreateWindow({
    Title = "Fish It Armagedons",
    Icon = "hop",
    Author = "by BlackSlasher",
    Folder = "DarkByte",
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
    Title = "Voldemort",
    Icon = "hop",
    CornerRadius = UDim.new(0,19),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("9600FF"), 
        Color3.fromHex("AEBAF8")
    ),
    Draggable = true,
})

Window:Tag({
    Title = "CURSED",
    Color = Color3.fromHex("#ff0000") --#30ff6a
})



local ConfigManager = Window.ConfigManager
local myConfig = ConfigManager:CreateConfig("DarkByte")

WindUI:SetNotificationLower(true)

-------------------------------------------
----- =======[ ALL TAB ]
-------------------------------------------

local Home = Window:Tab({
	Title = "Developer Info",
	Icon = "hard-drive"
})

local AllMenu = Window:Section({
	Title = "All Menu Here",
	Icon = "tally-3",
	Opened = true,
})

local AutoFish = AllMenu:Tab({ 
	Title = "Auto Fish", 
	Icon = "fish"
})

local AutoFarmTab = AllMenu:Tab({
	Title = "Auto Farm",
	Icon = "leaf"
})

local Trade = AllMenu:Tab({
	Title = "Trade",
	Icon = "handshake"
})

local Player = AllMenu:Tab({
    Title = "Player",
    Icon = "users-round"
})

local Utils = AllMenu:Tab({
    Title = "Utility",
    Icon = "earth"
})

local FishNotif = AllMenu:Tab({
	Title = "Fish Notification",
	Icon = "bell-ring"
})

local SettingsTab = AllMenu:Tab({ 
	Title = "Settings", 
	Icon = "cog" 
})

-------------------------------------------
----- =======[ AUTO FISH TAB ]
-------------------------------------------

local REReplicateTextEffect = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/ReplicateTextEffect"]

local autofish = false
local perfectCast = true
local customDelay = 1
local fishingActive = false
local delayInitialized = false


local fastRods = {
	["Ares Rod"] = true,
	["Angler Rod"] = true,
	["Ghostfinn Rod"] = true 
}

local mediumRods = {
	["Astral Rod"] = true,
	["Chrome Rod"] = true,
	["Steampunk Rod"] = true
}

local veryLowRods = {
	["Lucky Rod"] = true,
	["Midnight Rod"] = true,
	["Demascus Rod"] = true,
	["Grass Rod"] = true,
	["Luck Rod"] = true,
	["Carbon Rod"] = true,
	["Lava Rod"] = true,
	["Starter Rod"] = true
}


local function getValidRodName()
local player = Players.LocalPlayer
local display = player.PlayerGui:WaitForChild("Backpack"):WaitForChild("Display")

for _, tile in ipairs(display:GetChildren()) do      
    local success, itemNamePath = pcall(function()      
        return tile.Inner.Tags.ItemName      
    end)      
    if success and itemNamePath and itemNamePath:IsA("TextLabel") then      
        local name = itemNamePath.Text      
        if veryLowRods[name] or fastRods[name] or mediumRods[name] then      
            return name      
        end      
    end      
end      
return nil

end

local function updateDelayBasedOnRod(showNotify)
if delayInitialized then return end

local rodName = getValidRodName()      
if rodName then
    if fastRods[rodName] then      
        customDelay = math.random(100, 120) / 100
    elseif mediumRods[rodName] then
    	  customDelay = math.random(140, 200) / 100
    elseif veryLowRods[rodName] then
    	  customDelay = math.random(300, 500) / 100
    else      
        customDelay = 10      
    end      
    delayInitialized = true      
    if showNotify and autofish then      
        NotifySuccess("Rod Detected", string.format("Detected Rod: %s | Delay: %.2fs", rodName, customDelay))      
    end      
else      
    customDelay = 10      
    delayInitialized = true       
    if showNotify and autofish then      
        NotifyWarning("Rod Detection Failed", "No valid rod found in list. Default delay 10s applied.")      
    end      
end

end

local function setupRodWatcher()
    local player = Players.LocalPlayer
    local display = player.PlayerGui:WaitForChild("Backpack"):WaitForChild("Display")
    display.ChildAdded:Connect(function()
        task.wait(0.05)
        if not delayInitialized then
            updateDelayBasedOnRod(true)
        end
    end)
end
setupRodWatcher()

-- FISH THRESHOLD V2
local obtainedFishUUIDs = {}
local obtainedLimit = 30

local RemoteV2 = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RE/ObtainedNewFishNotification"]
RemoteV2.OnClientEvent:Connect(function(_, _, data)
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

local function monitorFishThreshold()
    task.spawn(function()
        while autofish do
            if #obtainedFishUUIDs >= obtainedLimit then
                NotifyInfo("Fish Threshold Reached", "Selling all fishes...")
                sellItems()
                obtainedFishUUIDs = {}
                task.wait(0.5)
            end
            task.wait(0.3)
        end
    end)
end

-- REReplicateTextEffect.OnClientEvent:Connect(function(data)
--     if autofish and fishingActive
--     and data
--     and data.TextData
--     and data.TextData.EffectType == "Exclaim" then

--         local myHead = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Head")      
--         if myHead and data.Container == myHead then      
--             task.spawn(function()      
--                 for i = 1, 3 do
--                     task.wait(BypassDelay)
--                     finishRemote:FireServer()      
--                     --rconsoleclear()      
--                 end      
--             end)      
--         end      
--     end
-- end)

function StartAutoFish()
autofish = true
updateDelayBasedOnRod(true)
monitorFishThreshold()
task.spawn(function()      
    while autofish do      
        pcall(function()      
            fishingActive = true      
  
            local equipRemote = net:WaitForChild("RE/EquipToolFromHotbar")      
            equipRemote:FireServer(1)      
            task.wait(0.1)      
  
            local chargeRemote = ReplicatedStorage      
                .Packages._Index["sleitnick_net@0.2.0"].net["RF/ChargeFishingRod"]      
            chargeRemote:InvokeServer(workspace:GetServerTimeNow())      
                  
            task.wait(0.5)      
  
            local timestamp = workspace:GetServerTimeNow()      
            RodShake:Play()      
            rodRemote:InvokeServer(timestamp)      
  
            local baseX, baseY = -0.7499996423721313, 0.991067629351885      
            local x, y      
            if perfectCast then      
                x = baseX + (math.random(-500, 500) / 10000000)      
                y = baseY + (math.random(-500, 500) / 10000000)      
            else      
                x = math.random(-1000, 1000) / 1000      
                y = math.random(0, 1000) / 1000      
            end      
  
            RodIdle:Play()      
            miniGameRemote:InvokeServer(x, y)      
  
            task.wait(customDelay)      
  
            fishingActive = false      
        end)      
    end      
end)

end

function StopAutoFish()
autofish = false
fishingActive = false
delayInitialized = false
end

local REReplicateTextEffectV2 = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/ReplicateTextEffect"]

local autofishV2 = false
local perfectCastV2 = true
local fishingActiveV2 = false
local delayInitializedV2 = false

local RodDelaysV2 = {
    ["Ares Rod"] = {custom = 1.12, bypass = 1.45},
    ["Angler Rod"] = {custom = 1.12, bypass = 1.45},
    ["Ghostfinn Rod"] = {custom = 1.12, bypass = 1.45},

    ["Astral Rod"] = {custom = 2.9, bypass = 2.45},
    ["Chrome Rod"] = {custom = 2.3, bypass = 2},
    ["Steampunk Rod"] = {custom = 2.5, bypass = 2.3},

    ["Lucky Rod"] = {custom = 3.5, bypass = 3.6},
    ["Midnight Rod"] = {custom = 3.3, bypass = 3.4},
    ["Demascus Rod"] = {custom = 3.9, bypass = 3.8},
    ["Grass Rod"] = {custom = 3.8, bypass = 3.9},
    ["Luck Rod"] = {custom = 4.2, bypass = 4.1},
    ["Carbon Rod"] = {custom = 4, bypass = 3.8},
    ["Lava Rod"] = {custom = 4.2, bypass = 4.1},
    ["Starter Rod"] = {custom = 4.3, bypass = 4.2},
}

local customDelayV2 = 1
local BypassDelayV2 = 0.5

local function getValidRodNameV2()
    local player = Players.LocalPlayer
    local display = player.PlayerGui:WaitForChild("Backpack"):WaitForChild("Display")
    for _, tile in ipairs(display:GetChildren()) do
        local success, itemNamePath = pcall(function()
            return tile.Inner.Tags.ItemName
        end)
        if success and itemNamePath and itemNamePath:IsA("TextLabel") then
            local name = itemNamePath.Text
            if RodDelaysV2[name] then
                return name
            end
        end
    end
    return nil
end

local function updateDelayBasedOnRodV2(showNotify)
    if delayInitializedV2 then return end
    local rodName = getValidRodNameV2()
    if rodName and RodDelaysV2[rodName] then
        customDelayV2 = RodDelaysV2[rodName].custom
        BypassDelayV2 = RodDelaysV2[rodName].bypass
        delayInitializedV2 = true
        if showNotify and autofishV2 then
            NotifySuccess("Rod Detected (V2)", string.format("Detected Rod: %s | Delay: %.2fs | Bypass: %.2fs", rodName, customDelayV2, BypassDelayV2))
        end
    else
        customDelayV2 = 10
        BypassDelayV2 = 1
        delayInitializedV2 = true
        if showNotify and autofishV2 then
            NotifyWarning("Rod Detection Failed (V2)", "No valid rod found. Default delay applied.")
        end
    end
end

-- FISH THRESHOLD V2
local obtainedFishUUIDsV2 = {}
local obtainedLimitV2 = 30

local RemoteV2 = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RE/ObtainedNewFishNotification"]
RemoteV2.OnClientEvent:Connect(function(_, _, data)
    if data and data.InventoryItem and data.InventoryItem.UUID then
        table.insert(obtainedFishUUIDsV2, data.InventoryItem.UUID)
    end
end)

local function sellItemsV2()
    if #obtainedFishUUIDsV2 > 0 then
        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index")
            :WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/SellAllItems"):InvokeServer()
    end
    obtainedFishUUIDsV2 = {}
end

local function monitorFishThresholdV2()
    task.spawn(function()
        while autofishV2 do
            if #obtainedFishUUIDsV2 >= obtainedLimitV2 then
                NotifyInfo("Fish Threshold Reached (V2)", "Selling all fishes...")
                sellItemsV2()
                obtainedFishUUIDsV2 = {}
                task.wait(0.5)
            end
            task.wait(0.3)
        end
    end)
end


-- REReplicateTextEffectV2.OnClientEvent:Connect(function(data)
--     if autofishV2 and fishingActiveV2
--     and data
--     and data.TextData
--     and data.TextData.EffectType == "Exclaim" then

--         local myHead = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Head")
--         if myHead and data.Container == myHead then
--             task.spawn(function()
--                 for i = 1, 3 do
--                     task.wait(BypassDelayV2)
--                     finishRemote:FireServer()
--                     --rconsoleclear()
--                 end
--             end)
--         end
--     end
-- end)

function printTable(tbl, indent)
	indent = indent or ""
	for key, value in pairs(tbl) do
		if typeof(value) == "table" then
			print(indent .. tostring(key) .. ":")
			printTable(value, indent .. "  ")
		else
			print(indent .. tostring(key) .. ": " .. tostring(value))
		end
	end
end
local isCaughtFishWhenStartedAutoFish = false
local RemoteCaughtFish = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RE/FishCaught"]
RemoteCaughtFish.OnClientEvent:Connect(function(idFish, data)
    isCaughtFishWhenStartedAutoFish = true
end)

function StopAutoFishV2()
    autofishV2 = false
    fishingActiveV2 = false
    delayInitializedV2 = false
    RodIdle:Stop()
    RodShake:Stop()
    RodReel:Stop()
end

function StartAutoFishV2()
    autofishV2 = true
    updateDelayBasedOnRodV2(true)
    monitorFishThresholdV2()
    task.spawn(function()
        while autofishV2 do
            local targetTime = 0
            local forceCloseTime = false
            pcall(function()
                fishingActiveV2 = true

                local equipRemote = net:WaitForChild("RE/EquipToolFromHotbar")
                equipRemote:FireServer(1)
                task.wait(0.1)

                local chargeRemote = ReplicatedStorage
                    .Packages._Index["sleitnick_net@0.2.0"].net["RF/ChargeFishingRod"]
                chargeRemote:InvokeServer(workspace:GetServerTimeNow())
                task.wait(0.5)

                local timestamp = workspace:GetServerTimeNow()
                RodShake:Play()
                rodRemote:InvokeServer(timestamp)

                local baseX, baseY = -0.7499996423721313, 1
                local x, y
                if perfectCastV2 then
                    x = baseX + (math.random(-500, 500) / 10000000)
                    y = baseY + (math.random(-500, 500) / 10000000)
                else
                    x = math.random(-1000, 1000) / 1000
                    y = math.random(0, 1000) / 1000
                end

                RodIdle:Play()
                local mGRresult1, mGRresult2 = miniGameRemote:InvokeServer(x, y)
        
                task.wait(0.2)
                targetTime = workspace:GetServerTimeNow() + 10
                repeat
                  task.wait(0.4)
                  finishRemote:FireServer()
                  if targetTime < workspace:GetServerTimeNow() then
                    fishingActiveV2 = false
                    delayInitializedV2 = false
                    RodIdle:Stop()
                    RodShake:Stop()
                    RodReel:Stop()
                    forceCloseTime = true
                    isCaughtFishWhenStartedAutoFish = false
					task.wait(5)
                    break
                  end
                until isCaughtFishWhenStartedAutoFish == true
                isCaughtFishWhenStartedAutoFish = false

                if mGRresult2.SelectedRarity <= 0.00003 then
					print("[GOCHA]>>>>>> DAMN IT'S INSANE YOU GOT RAREST ONE BROH")
					printTable(mGRresult2)
					task.wait(10)
				end

                task.wait(0.1)
                fishingActiveV2 = false
            end)
            if forceCloseTime then
                fishingActiveV2 = true
                delayInitializedV2 = true
            end
        end
    end)
end

AutoFish:Input({
	Title = "Bypass Delay",
	Desc = "Use 1 for rod above a Ares",
	Placeholder = "Example: 1",
	Value = nil,
	Callback = function(value)
		local number = tonumber(value)
		if number then
		  BypassDelay = number
			NotifySuccess("Bypass Delay", "Bypass Delay set to " .. number)
		else
		  NotifyError("Invalid Input", "Failed to convert input to number.")
		end
	end,
})

local FishThres = AutoFish:Input({
	Title = "Fish Threshold",
	Placeholder = "Example: 1500",
	Value = nil,
	Callback = function(value)
		local number = tonumber(value)
		if number then
		  obtainedLimit = number
		  obtainedLimitV2 = number
			NotifySuccess("Threshold Set", "Fish threshold set to " .. number)
		else
		  NotifyError("Invalid Input", "Failed to convert input to number.")
		end
	end,
})

myConfig:Register("FishThreshold", FishThres)

AutoFish:Toggle({
	Title = "Auto Fish V2",
	Callback = function(value)
		if value then
			StartAutoFishV2()
		else
			StopAutoFishV2()
		end
	end
})

AutoFish:Toggle({
    Title = "Auto Fish (Custom Delay)",
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

local REEquipItem = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipItem"]
local RFSellItem = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/SellItem"]

local autoSellMythic = false

function ToggleAutoSellMythic(state)
	autoSellMythic = state
	if autoSellMythic then
		NotifySuccess("AutoSellMythic", "Status: ON")
	else
		NotifyWarning("AutoSellMythic", "Status: OFF")
	end
end

-- local oldFireServer
-- oldFireServer = hookmetamethod(game, "__namecall", function(self, ...)
-- 	local args = {...}
-- 	local method = getnamecallmethod()

-- 	if autoSellMythic
-- 		and method == "FireServer"
-- 		and self == REEquipItem
-- 		and typeof(args[1]) == "string"
-- 		and args[2] == "Fishes" then

-- 		local uuid = args[1]

-- 		task.delay(1, function()
-- 			pcall(function()
-- 				local result = RFSellItem:InvokeServer(uuid)
-- 				if result then
-- 					NotifySuccess("AutoSellMythic", "Items Sold!!")
-- 				else
-- 					NotifyError("AutoSellMythic", "Failed to sell item!!")
-- 				end
-- 			end)
-- 		end)
-- 	end

-- 	return oldFireServer(self, ...)
-- end)

-- AutoFish:Toggle({
-- 	Title = "Auto Sell Mythic",
-- 	Desc = "Automatically sells clicked fish",
-- 	Default = false,
-- 	Callback = function(state)
-- 		ToggleAutoSellMythic(state)
-- 	end
-- })


function sellAllFishes()
	local charFolder = workspace:FindFirstChild("Characters")
	local char = charFolder and charFolder:FindFirstChild(LocalPlayer.Name)
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		NotifyError("Character Not Found", "HRP tidak ditemukan.")
		return
	end

	local originalPos = hrp.CFrame
	local sellRemote = net:WaitForChild("RF/SellAllItems")

	task.spawn(function()
		NotifyInfo("Selling...", "I'm going to sell all the fish, please wait...", 3)

		task.wait(1)
		local success, err = pcall(function()
			sellRemote:InvokeServer()
		end)

		if success then
			NotifySuccess("Sold!", "All the fish were sold successfully.", 3)
		else
			NotifyError("Sell Failed", tostring(err, 3))
		end

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

  
  
local workspace = game:GetService("Workspace")  
  
local knownEvents = {}

local eventCodes = {
	["1"] = "Ghost Shark Hunt",
	["2"] = "Shark Hunt",
	["3"] = "Worm Hunt",
	["4"] = "Black Hole",
	["5"] = "Meteor Rain",
	["6"] = "Ghost Worm",
	["7"] = "Shocked"
}

local function teleportTo(position)
	local char = workspace:FindFirstChild("Characters"):FindFirstChild(LocalPlayer.Name)
	if char then
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = CFrame.new(position + Vector3.new(0, 20, 0))
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
local eventTarget = nil

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

local function isEventStillActive(name)
	updateKnownEvents()
	return knownEvents[name:lower()] ~= nil
end

local function monitorAutoTP()
	if monitoringTP then return end
	monitoringTP = true

	while true do
		if autoTPEvent then
			if not alreadyTeleported then
				updateKnownEvents()
				for _, eventModel in pairs(knownEvents) do
					saveOriginalPosition()
					teleportTo(eventModel:GetPivot().Position)
					if typeof(floatingPlat) == "function" then
						floatingPlat(true)
					end
					alreadyTeleported = true
					teleportTime = tick()
					eventTarget = eventModel.Name
					NotifyError("Event Farm", "Teleported to: " .. eventTarget)
					break
				end
			else
				if teleportTime and (tick() - teleportTime >= 900) then
					returnToOriginalPosition()
					if typeof(floatingPlat) == "function" then
						floatingPlat(false)
					end
					alreadyTeleported = false
					teleportTime = nil
					eventTarget = nil
					NotifyInfo("Event Timeout", "Returned after 15 minutes.")
				elseif eventTarget and not isEventStillActive(eventTarget) then
					returnToOriginalPosition()
					if typeof(floatingPlat) == "function" then
						floatingPlat(false)
					end
					alreadyTeleported = false
					teleportTime = nil
					NotifyInfo("Event Ended", "Returned to start position.")
				end
			end
		else
			if alreadyTeleported then
				returnToOriginalPosition()
				if typeof(floatingPlat) == "function" then
					floatingPlat(false)
				end
				alreadyTeleported = false
				teleportTime = nil
				eventTarget = nil
			end
		end

		task.wait(1)
	end
end

task.spawn(monitorAutoTP)

local selectedIsland = "09"
local isAutoFarmRunning = false

local islandCodes = {
    ["01"] = "Crater Islands",
    ["02"] = "Tropical Grove",
    ["03"] = "Vulcano",
    ["04"] = "Coral Reefs",
    ["05"] = "Winter",
    ["06"] = "Machine",
    ["07"] = "Treasure Room",
    ["08"] = "Sisyphus Statue",
    ["09"] = "Fisherman Island"
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
    	CFrame.new(-3777.43433, -135.074417, -975.198975, -0.284491211, -1.02338751e-08, -0.958678663, 6.38407585e-08, 1, -2.96199456e-08, 0.958678663, -6.96293867e-08, -0.284491211),
    	CFrame.new(-3697.77124, -135.074417, -886.946411, 0.979794085, -9.24526766e-09, 0.200008959, 1.35701708e-08, 1, -2.02526174e-08, -0.200008959, 2.25575487e-08, 0.979794085),
    	CFrame.new(-3764.021, -135.074417, -903.742493, 0.785813689, -3.05788426e-08, -0.618463278, -4.87374336e-08, 1, -1.11368585e-07, 0.618463278, 1.17657272e-07, 0.785813689)
    },
    ["Fisherman Island"] = {
    	CFrame.new(-75.2439423, 3.24433279, 3103.45093, -0.996514142, -3.14880424e-08, -0.0834242329, -3.84156422e-08, 1, 8.14354024e-08, 0.0834242329, 8.43563228e-08, -0.996514142),
    	CFrame.new(-162.285294, 3.26205397, 2954.47412, -0.74356699, -1.93168272e-08, -0.668661416, 1.03873425e-08, 1, -4.04397653e-08, 0.668661416, -3.70152904e-08, -0.74356699),
    	CFrame.new(-69.8645096, 3.2620542, 2866.48096, 0.342575252, 8.79649331e-09, 0.939490378, 4.78986739e-10, 1, -9.53770485e-09, -0.939490378, 3.71738529e-09, 0.342575252),
    	CFrame.new(247.130951, 2.47001815, 3001.72412, -0.724809051, -8.27166033e-08, -0.688949764, -8.16509669e-08, 1, -3.41610367e-08, 0.688949764, 3.14931867e-08, -0.724809051)
    }
}

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
        task.wait(5.5)  

        --StartAutoFish()
        StartAutoFishV2()
        
        while isAutoFarmRunning do
            if not isAutoFarmRunning then  
                StopAutoFishV2()  
                NotifyWarning("Auto Farm Stopped", "Auto Farm manually disabled. Auto Fish stopped.")  
                break  
            end  
            task.wait(0.5)
        end
    end
end      

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
    Value = nameList[9],
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

local AutoFarm = AutoFarmTab:Toggle({
	Title = "Start Auto Farm",
	Callback = function(state)
		isAutoFarmRunning = state
		if state then
			startAutoFarmLoop()
		else
			StopAutoFishV2()
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
----- =======[ UTILITY TAB ]
-------------------------------------------

local weatherActive = {}
local weatherData = {
    ["Storm"] = { duration = 900 },
    ["Cloudy"] = { duration = 900 },
    ["Snow"] = { duration = 900 },
    ["Wind"] = { duration = 900 },
    ["Radiant"] = { duration = 900 }
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
    Values = { "Storm", "Cloudy", "Snow", "Wind", "Radiant" },
    Value = {},
    Multi = true,
    AllowNone = true,
    Callback = function(selected)
    	  if not blockNotif then
    	  	blockNotif = true
    	  	return
    	  end
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

local TweenService = game:GetService("TweenService")

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
	frame.BackgroundTransparency = 0.1

	local tweenIn = TweenService:Create(frame, TweenInfo.new(0.2), { BackgroundTransparency = 0.1 })
	tweenIn:Play()
	tweenIn.Completed:Wait()

	wait(duration)

	local tweenOut = TweenService:Create(frame, TweenInfo.new(0.3), { BackgroundTransparency = 0.1 })
	tweenOut:Play()
	tweenOut.Completed:Wait()
	gui:Destroy()
end

local function SafePurchase(callback)
	local originalCFrame = HRP.CFrame
	HRP.CFrame = npcCFrame
	FadeScreen(0.2)
	pcall(callback)
	wait(0.1)
	HRP.CFrame = originalCFrame
end

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

-------------------------------------------
----- =======[ UTILITY TAB ]
-------------------------------------------


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



--|------------------------------------|
--|--------- OH NOOOOHHHHHHH ----------|
--|------------------------------------|
task.wait(2)
--selectedIsland = "Crater Islands"
selectedIsland = "Tropical Grove"
--selectedIsland = "Vulcano"
--selectedIsland = "Coral Reefs"
--selectedIsland = "Winter Fest"
--selectedIsland = "Weather Machine"
--selectedIsland = "Treasure Room"
--selectedIsland = "Deap Sea"

-- Tropical Grove
--AUTO SHADER
task.wait(1)
AutoFarm:Set(true)
Window:SelectTab(3)
