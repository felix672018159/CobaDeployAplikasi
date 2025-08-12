-------------------------------------------
----- =======[ Load WindUI ]
-------------------------------------------

local Version = "1.6.4"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. Version .. "/main.lua"))()

-------------------------------------------
----- =======[ GLOBAL FUNCTION ]
-------------------------------------------

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Player = Players.LocalPlayer

LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)


local PlaceId = game.PlaceId
local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

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
--NOT YET


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
    Title = "BlockHub Premium",
    Icon = "cannabis",
    Author = "Bwawox",
    Folder = "BlockHub",
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
    Title = "BlockXHub",
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
local myConfig = ConfigManager:CreateConfig("BlockHubXConfig")

WindUI:SetNotificationLower(true)

-------------------------------------------
----- =======[ ALL TAB ]
-------------------------------------------


local DevTab = Window:Tab({
    Title = "Feature Guide!",
    Icon = "airplay"
})

local Player = Window:Tab({
    Title = "Player",
    Icon = "users-round"
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
-------------------------------------------------------------------------------------------------------
-- > Auto Collect Coin :
local monitorCollectorActive = { status = nil }
local function coinCollector()
    while true do
        if monitorCollectorActive.status ~= nil then
            for counterColumns = 1,10 do
                local columns = { counterColumns }
                replicatedStorage:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RE/PlotService/ClaimCoins"):FireServer(unpack(columns))
				task.wait(0.1) --BUG FREEZING GAME
            end
        end
    end
    task.wait(1)
end

Player:Toggle({
	Title = "Coin Collector",
	Callback = function(val)
        if val then
            monitorCollectorActive.status = true
            NotifySuccess("BlockXHub","[Enabled[] Coin Collector", 2)
        else
            monitorCollectorActive.status = nil
            NotifyInfo("BlockXHub","[Disabled] Coin Collector", 2)
        end
	end,
})

task.spawn(coinCollector)

-------------------------------------------
----- =======[ SETTINGS TAB ] ok
-------------------------------------------
local Keybind = SettingsTab:Keybind({
    Title = "Keybind",
    Desc = "Keybind to open UI",
    Value = "G",
    Callback = function(v)
        Window:SetToggleKey(Enum.KeyCode[v])
    end
})

myConfig:Register("Keybind", Keybind)
