-------------------------------------------
----- =======[ Load WindUI ]
-------------------------------------------

local Version = "1.6.4"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. Version .. "/main.lua"))()

if not WindUI then
    return warn("WindUI failed to load. Please try again.")
end

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

-- TRADER_REMOTES :
local RemoteEventTextNotifications = game:GetService("ReplicatedStorage").Packages._Index:FindFirstChild("sleitnick_net@0.2.0").net:FindFirstChild("RE/TextNotification")
local RemoteArrayUpdateReplions = game:GetService("ReplicatedStorage").Packages._Index["ytrev_replion@2.0.0-rc.3"].replion["Remotes"].ArrayUpdate

-------------------------------------------
----- =======[ CONFIRM POPUP ]
-------------------------------------------

local confirmed = true
repeat task.wait() until confirmed


-------------------------------------------
----- =======[ BEGIN SCRIPTING HERE !!! ]
-------------------------------------------

-----[ LOAD WINDOW ]

local Window = WindUI:CreateWindow({
    Title = "StroxShops Premium",
    Icon = "cannabis",
    Author = "by Ervin Dajiro",
    Folder = "StroxShops",
    Size = UDim2.fromOffset(400, 300),
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
    Title = "StroxXShopsHub",
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
local myConfig = ConfigManager:CreateConfig("StroxXShopsHub")

WindUI:SetNotificationLower(true)

-------------------------------------------
----- =======[ AUTO TRADER ]
local AutoTrade = Window:Tab({
    Title = "Auto Trader",
    Icon = "airplay"
})

local targetUserName = nil
local targetUserId = nil
local tradeActive = false
local blockAutoTrade = false
local autoTradeActive = false
local totalItemToTrade = 0
local itemToTrade = {}


local AutoTradeParagraph = AutoTrade:Paragraph({
	Title = "Trader Informations",
	Color = "Grey",
	Desc = [[
Target Player Name   : 
Target Player UserId :
-----------------------------------
Total Items To Trade     : [0] 
Items Remaining To Trade : [0]
]]
})

function updateTradeInformations() -- playerName, playerUserId, totalItems, itemsRemaining)
    playerName = targetUserName
    playerUserId  = targetUserId
    totalItems = totalItemToTrade
    itemsRemaining = #itemToTrade
    AutoTradeParagraph:SetDesc(
           "\nTarget Player Name   : " .. (playerName or "N/A")
        .. "\nTarget Player UserId : " .. (playerUserId or "N/A")
        .. "\n------------------------------------------"
        .. "\nTotal Items To Trade     : [" .. totalItemToTrade .. "]"
        .. "\nItems Remaining To Trade : [" .. #itemToTrade .. "]"
    )
    --AutoTradeParagraph:SetDesc( "\nTarget Player Name   : " .. (playerName or "N/A") .. "\nTarget Player UserId : " .. (playerUserId or "N/A") .. "\n------------------------------------------" .. "\nTotal Items To Trade     : [" .. totalItemToTrade .. "]" .. "\nItems Remaining To Trade : [" .. #itemToTrade .. "]")
end

AutoTrade:Input({
   Title = "Trade",
   Desc = "Trade With Someone Here",
   Placeholder = "Enter Display Name",
   Callback = function(displayName)
      for _, player in ipairs(Players:GetPlayers()) do
         if player.DisplayName == displayName or player.Name == displayName then
            targetUserName = player.DisplayName
            targetUserId = player.UserId
            updateTradeInformations()
            NotifySuccess("Trade Target", "Trade target found: " .. player.Name)
            return
         end
      end
      NotifyError("Trade Target", "Player not found", 3)
   end,
})

AutoTrade:Toggle({
   Title = "Enable Item Add To Trade",
   Value = false,
   Callback = function(val)
      tradeActive = val
      if val then
         NotifySuccess("Add Item Trade Mode", "Add Item Mode is active. Click an item to add to list trade..")
      else
         totalItemToTrade = 0
         itemToTrade = {}
         NotifySuccess("Add Item Trade Mode", "Add Item Mode Disabled.")
         updateTradeInformations()
      end
   end,
})

AutoTrade:Toggle({
   Title = "Start Auto Trade",
   Value = false,
   Callback = function(val)
      if val then
         StartAutoTrade()
         NotifySuccess("Auto Trade Mode", "Trade Mode is active. Start Auto trading..")
      else
		 blockAutoTrade = false
         StopAutoTrade()
         NotifySuccess("Auto Trade Mode", "Trade Mode Disabled.")
      end
   end,
})


local RFAwaitTradeResponse = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/AwaitTradeResponse"]

local autoAcceptTrade = false

RFAwaitTradeResponse.OnClientInvoke = function(fromPlayer, timeNow)
    if autoAcceptTrade then
        return true
    else
        return nil
    end
end

AutoTrade:Toggle({
    Title = "Auto Accept Trade",
    Desc = "Skip Time Trade",
    Value = false,
    Callback = function(state)
        autoAcceptTrade = state
        if autoAcceptTrade then
            autoAcceptTrade = true
            NotifySuccess("Trade", "Auto Accept Trade Enabled")
        else
            autoAcceptTrade = false
            NotifyWarning("Trade", "Auto Accept Trade Disabled")
        end
    end
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
         if table.find(itemToTrade, uuid) then
            updateTradeInformations()
            NotifyError("Item Already Added", "Count :" .. #itemToTrade, 1)
            return nil
         else
            if autoTradeActive then
            else
                table.insert(itemToTrade, uuid)
                totalItemToTrade = totalItemToTrade + 1
                NotifySuccess("Item Trade Added", "Count :" .. #itemToTrade, 1)
                updateTradeInformations()
                print("ADDED ITEM : " .. uuid .. " | Total Items : " .. #itemToTrade)
                --NotifySuccess("Item Added", "Item added to trade list. Total items: " .. #itemToTrade)
            end
         end
         --local initiateTrade = net:WaitForChild("RF/InitiateTrade")
         --initiateTrade:InvokeServer(targetUserId, uuid)
         --NotifySuccess("Trade Sent", "Trade sent to " .. targetUserId)
      else
         --NotifyError("Failed to Send Trade", "Make sure Display Name is filled in and the item is valid.")
      end
      return nil
   end

   return oldNamecall(self, unpack(args))
end)
setreadonly(mt, true)

-- MONITOR TEXT EVENTS :
RemoteEventTextNotifications.OnClientEvent:Connect(function(args1, args2, args3, args4)
	if type(args1) == "table" then
		if args1.Text ~= nil then
            if string.find(args1.Text, "Send trade request!") then
                -- print("")
            elseif string.find(args1.Text, "Trade was declined!") or string.find(args1.Text, "Trade was decline") or string.find(args1.Text, "You are too far away!") or string.find(args1.Text, "One or more people are already in a trade!") or string.find(args1.Text, "Sending trades too fast")  then
                task.wait(4.6)
                blockAutoTrade = false
                updateTradeInformations()
                -- print("")
            elseif string.find(args1.Text, "Trade completed!") then
                table.remove(itemToTrade, 1)
                task.wait(4.6)
                blockAutoTrade = false
                updateTradeInformations()
            else
                -- print("")
            end
		end
	end
end)

-- MONITOR ADDED ITEMS TO TRADE [UNUSED !!]
RemoteArrayUpdateReplions.OnClientEvent:Connect(function(args1, args2, args3, args4)
	if type(args1) == "string" and type(args2) == "string" and type(args3) == "string" and type(args4) == "string" then
		if args2 == "i" and args3 == "EquippedItems" then
			-- print(typeof(args1), args1)
			-- print(typeof(args2), args2)
			-- print(typeof(args3), args3)
			--print(typeof(args4), args4) -- UUID OF ITEMS <3
		end
	end
end)

-- FUNCTIONS START AUTO TRADE
function StartAutoTrade() --NEW FUNCTIONS V3...
    print("USING AUTOTRADE V1")
    autoTradeActive = true
    task.spawn(function()
        while autoTradeActive do
            if #itemToTrade == 0 then
                NotifyInfo("Auto Trade Completed", "Auto Trade Complated total [" .. #itemToTrade .. " / " .. totalItemToTrade ..  "]", 3600)
                autoTradeActive = false
                blockAutoTrade = false
                break
            end
            pcall(function()
                ---FILL AUTO TRADE SCRIPT HERE
                if blockAutoTrade == false then
                    local initiateTrade = net:WaitForChild("RF/InitiateTrade")
                    local uuid = itemToTrade[1]
                    initiateTrade:InvokeServer(targetUserId, uuid)
                    NotifySuccess("Trade Sent", "Trade sent to " .. targetUserId .. "[" .. #itemToTrade .. " / " .. totalItemToTrade ..  "]")
                    blockAutoTrade = true
                end
                ---END FILLED
		        task.wait(0.1)
            end)
            task.wait(0.5)
        end
    end)
end

-- FUNCTIONS STOP AUTOTRADE
function StopAutoTrade()
    autoTradeActive = false
end
