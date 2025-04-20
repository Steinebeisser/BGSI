local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
local isScriptEnabled = true
screenGui.Name = "TaskToggleUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 350)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Parent = screenGui
frame.Active = true
frame.Draggable = true

local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBar.TextColor3 = Color3.new(1, 1, 1)
titleBar.Text = "Task Toggle UI"
titleBar.Font = Enum.Font.SourceSansBold
titleBar.TextSize = 18
titleBar.TextXAlignment = Enum.TextXAlignment.Center
titleBar.Parent = frame

local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, -10, 1, -40)
scrollingFrame.Position = UDim2.new(0, 5, 0, 35)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ScrollBarThickness = 6
scrollingFrame.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.FillDirection = Enum.FillDirection.Vertical
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scrollingFrame

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end)

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(120, 50, 50)
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Text = "X"
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 20
closeButton.BorderSizePixel = 0
closeButton.Parent = frame
closeButton.ZIndex = 2
closeButton.AutoButtonColor = true

local isMinimized = false

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 30, 0, 30)
toggleButton.Position = UDim2.new(1, -70, 0, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 120, 50)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Text = "-"
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 20
toggleButton.BorderSizePixel = 0
toggleButton.Parent = frame
toggleButton.ZIndex = 2
toggleButton.AutoButtonColor = true

toggleButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        scrollingFrame.Visible = false
        toggleButton.Text = "+"
        frame.Size = UDim2.new(0, 300, 0, 30)
    else
        scrollingFrame.Visible = true
        toggleButton.Text = "-"
        frame.Size = UDim2.new(0, 300, 0, 350)
    end
end)



local taskStates = {}
local buttonMap = {}


closeButton.MouseButton1Click:Connect(function()
    print("Exiting...")
    for name, _ in pairs(taskStates) do
        taskStates[name] = false
    end
    screenGui:Destroy()
    isScriptEnabled = false
end)


local function createCheckbox(name, defaultState, loopFunc, displayName)
    displayName = displayName or name
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 30)
    container.BackgroundTransparency = 1
    container.Parent = scrollingFrame

    local checkbox = Instance.new("TextButton")
    checkbox.Size = UDim2.new(0, 24, 0, 24)
    checkbox.Position = UDim2.new(0, 0, 0.5, -12)
    checkbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    checkbox.BorderSizePixel = 0
    checkbox.Text = ""
    checkbox.AutoButtonColor = false
    checkbox.Parent = container

    local checkmark = Instance.new("ImageLabel")
    checkmark.Size = UDim2.new(1, 0, 1, 0)
    checkmark.Position = UDim2.new(0, 0, 0, 0)
    checkmark.BackgroundTransparency = 1
    checkmark.Image = "rbxassetid://6031094678" 
    checkmark.ImageColor3 = Color3.new(1, 1, 1)
    checkmark.Visible = defaultState
    checkmark.Parent = checkbox

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Position = UDim2.new(0, 30, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = displayName
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    taskStates[name] = defaultState

    if defaultState then
        task.spawn(loopFunc)
    end

    checkbox.MouseButton1Click:Connect(function()
        taskStates[name] = not taskStates[name]
        checkmark.Visible = taskStates[name]

        if taskStates[name] then
            print(name .. " enabled")
            task.spawn(function()
                loopFunc()
            end)
        else
            print(name .. " disabled")
        end
    end)

    buttonMap[name] = {
        button = checkbox,
        checkmark = checkmark,
        label = label,
        container = container
    }
end

local function removeCheckbox(name)
    if buttonMap[name] then
        buttonMap[name].container:Destroy()
        buttonMap[name] = nil
        taskStates[name] = nil
    end
end

local remote = game:GetService("ReplicatedStorage"):WaitForChild("Shared", 9e9)
    :WaitForChild("Framework", 9e9)
    :WaitForChild("Network", 9e9)
    :WaitForChild("Remote", 9e9)
    :WaitForChild("Event", 9e9)

function getGemAmount()
    local Players = game:GetService("Players")
    local player = Players:GetPlayers()[1]
    local username = player.Name
    
    local gemValue = player:WaitForChild("PlayerGui")
    :WaitForChild("ScreenGui"):WaitForChild("HUD"):WaitForChild("Left"):WaitForChild("Currency"):WaitForChild("Gems"):WaitForChild("Frame"):WaitForChild("Label").Text
    
    print("Username: ", username)
    print(gemValue)
    
    local gemAmount = tonumber(gemValue:gsub(",", ""))
    return gemAmount
end

function openGifts(amount)
    local args = {
        [1] = "UseGift",
        [2] = "Mystery Box",
        [3] = amount
    }

    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))

    for _, gift in pairs(game:GetService("Workspace"):WaitForChild("Rendered"):WaitForChild("Gifts"):getChildren()) do
        local args = {
            [1] = "ClaimGift",
            [2] = gift.Name
        }

        game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))

        gift:Destroy()
    end
end

createCheckbox("Blow Bubble", true, function()
    task.spawn(function()
        while taskStates["Blow Bubble"] do
            local args = { [1] = "BlowBubble" }
            remote:FireServer(unpack(args))
            task.wait(0.1)
        end
    end)
end)

local originalSellPos
createCheckbox("Auto Sell", false, function()
    task.spawn(function()
        while taskStates["Auto Sell"] do
            local args = {
                [1] = "SellBubble"
            }
            local autoSellRoot = workspace:WaitForChild("Worlds"):WaitForChild("The Overworld"):WaitForChild("Islands"):WaitForChild("Twilight"):WaitForChild("Island"):WaitForChild("Sell"):WaitForChild("Root")
            if not originalSellPos then
                originalSellPos = autoSellRoot.CFrame
            end


            local player =game.Players.localPlayer
            local name = player.Name

            workspace:WaitForChild(name):WaitForChild("HumanoidRootPart").CFrame = autoSellRoot.CFrame

            game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))

            task.wait(0.1)
        end
    end)
end,
"Auto Sell - Broken")

createCheckbox("Open Island Chest", false, function()
    task.spawn(function()
        while taskStates["Open Island Chest"] do
            local args = {
                [1] = "UnlockRiftChest",
                [2] = "golden-chest",
                [3] = false
            }
            remote:FireServer(unpack(args))
            task.wait(0.1)
        end
    end)
end)

createCheckbox("Open Royal Chest", false, function()
    task.spawn(function()
        while taskStates["Open Royal Chest"] do
            local args = {
                [1] = "UnlockRiftChest",
                [2] = "royal-chest",
                [3] = false
            }
            remote:FireServer(unpack(args))
            task.wait(0.1)
        end
    end)
end)

createCheckbox("Claim Chests", true, function()
    task.spawn(function()
        while taskStates["Claim Chests"] do
            local remote = game:GetService("ReplicatedStorage"):WaitForChild("Shared", 9e9)
                :WaitForChild("Framework", 9e9)
                :WaitForChild("Network", 9e9)
                :WaitForChild("Remote", 9e9)
                :WaitForChild("Event", 9e9)

            remote:FireServer("ClaimChest", "Infinity Chest")

            remote:FireServer("ClaimChest", "Void Chest", true)

            remote:FireServer("ClaimChest", "Giant Chest", true)

            remote:FireServer("ClaimRiftGift", "gift-rift")

            task.wait(10)
        end
    end)
end)

afk_counter = 0

createCheckbox("Anti AFK", true, function()
    task.spawn(function()
        local vu = game:GetService("VirtualUser")
        game:GetService("Players").LocalPlayer.Idled:Connect(function()
            if taskStates["Anti AFK"] then
                vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                print("Anti-AFK triggered VirtualUser input.")
                task.wait(600)
            end
        end)
    end)
end)


createCheckbox("Auto Craft Potions", false, function() 
    potionTypes = {"Lucky", "Speed", "Mythic", "Coins"}

    for _, potion in potionTypes do
        for i = 1, 5 do
            local args = {
                [1] = "CraftPotion";
                [2] = potion;
                [3] = i;
                [4] = true;
            }

            game:GetService("ReplicatedStorage"):WaitForChild("Shared", 9e9):WaitForChild("Framework", 9e9):WaitForChild("Network", 9e9):WaitForChild("Remote", 9e9):WaitForChild("Event", 9e9):FireServer(unpack(args))
        end
    end

    taskStates["Auto Craft Potions"] = false
    local ref = buttonMap["Auto Craft Potions"]
    if ref then
        ref.checkmark.Visible = false
    end
end)

createCheckbox("Buy Alien Shop", true, function()
    task.spawn(function()
        while taskStates["Buy Alien Shop"] do
            for i = 1, 3 do
                local args = {
                    [1] = "BuyShopItem";
                    [2] = "alien-shop";
                    [3] = i;
                }

                game:GetService("ReplicatedStorage"):WaitForChild("Shared", 9e9):WaitForChild("Framework", 9e9):WaitForChild("Network", 9e9):WaitForChild("Remote", 9e9):WaitForChild("Event", 9e9):FireServer(unpack(args))
            end

            task.wait(0.1)
        end
    end)
end)

createCheckbox("Buy Blackmarket Shop", true, function()
    task.spawn(function()
        while taskStates["Buy Blackmarket Shop"] do
            for i = 1, 3 do
                local args = {
                    [1] = "BuyShopItem",
                    [2] = "shard-shop",
                    [3] = i
                }
                
                game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
            end

            task.wait(0.1)
        end
    end)
end)

createCheckbox("Claim Playtime Rewards", true, function()
    task.spawn(function()
        while taskStates["Claim Playtime Rewards"] do
            for i=1, 9 do 
                local args = {
                    [1] = "ClaimPlaytime";
                    [2] = i;
                }
                
                game:GetService("ReplicatedStorage"):WaitForChild("Shared", 9e9):WaitForChild("Framework", 9e9):WaitForChild("Network", 9e9):WaitForChild("Remote", 9e9):WaitForChild("Function", 9e9):InvokeServer(unpack(args))
            end

        task.wait(10)
        end
    end)
end)

createCheckbox("Claim Spinwheels", true, function()
    task.spawn(function()
        while taskStates["Claim Spinwheels"] do
            local args = {
                [1] = "ClaimFreeWheelSpin";
            }
            
            game:GetService("ReplicatedStorage"):WaitForChild("Shared", 9e9):WaitForChild("Framework", 9e9):WaitForChild("Network", 9e9):WaitForChild("Remote", 9e9):WaitForChild("Event", 9e9):FireServer(unpack(args))

            task.wait(10)
        end
    end)
end)

createCheckbox("Auto Doggy Jump", true, function()
    task.spawn(function()
        while taskStates["Auto Doggy Jump"] do
            for i = 1, 3 do
                local args = {
                    [1] = "DoggyJumpWin",
                    [2] = i
                }
            
                game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
            end
            task.wait(10)
        end
    end)
end)

local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local HttpService = game:GetService("HttpService")

local avatarCache = {}

function sendWebHook(webhook, message, embed)
    if not httprequest or not webhook then return end
    local player = game:GetService("Players").LocalPlayer

    local userId = player.UserId
    local username = player.Name .. " | " .. tostring(userId)
    
    local avatarUrl = avatarCache[userId]
    if not avatarUrl then
        local success, result = pcall(function()
            local response = httprequest({
                Url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. userId .. "&size=420x420&format=Png&isCircular=false",
                Method = "GET"
            })
            local data = HttpService:JSONDecode(response.Body).data
            if data and data[1] and data[1].state == "Completed" then
                avatarUrl = data[1].imageUrl
                avatarCache[userId] = avatarUrl
            end
        end)
        if not success then
            avatarUrl = "https://tr.rbxcdn.com/6c881fc4fc79802c012cb82a689e84e0/420/420/AvatarHeadshot/Png"
        end
    end

    local data = {
        username = username,
        avatar_url = avatarUrl,
        embeds = { embed },
        allowed_mentions = { parse = {} }
    }

    httprequest({
        Url = webhook,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = HttpService:JSONEncode(data)
    })
end

function createPetHatchEmbed(petName, hatchRarity, imageUrl, bubbleCount, eggCount, hexColor)
    local descriptionText = ""
    local raw = hatchRarity:gsub("%%", "")
    local numberRarity = tonumber(raw)
    local oddsText = ""
    if numberRarity and numberRarity > 0 then
        local odds = math.floor(100 / numberRarity + 0.5)
        oddsText = string.format("(~1 in %s)", string.format("%0.f", odds):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
    end
    local hatchRarityText =  hatchRarity .. "`" .. oddsText .. "`" .."\n"

    local bubbleText = ""
    if bubbleCount then
        bubbleText = string.format("`%s` bubbles", bubbleCount) .. "\n"
    end

    local eggText = ""
    if eggCount then
        eggText = string.format("`%s` eggs", eggCount) .. "\n"
    end

    local herbPing = "<@1156652504185053294>"

    print("Egg Count:", eggCount)
    print("Bubble Count:", bubbleCount)
    print("Bubble Text:", bubbleText)
    print("Egg Text:", eggText)
    print("Hatch Rarity Text:", hatchRarityText)

    descriptionText = descriptionText .. hatchRarityText .. bubbleText .. eggText .. herbPing
    local embed = {
        title = petName,
        description = descriptionText,
        color = hexColor,
        thumbnail = imageUrl and { url = imageUrl } or nil,
        footer = {
            text = "Praise to Steinebeisser"
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    return embed
end

function getAssetUrl(assetId)
    local url = "https://thumbnails.roblox.com/v1/assets?assetIds=" .. assetId .. "&size=420x420&format=Png&isCircular=false"
    local response = httprequest({
        Url = url,
        Method = "GET"
    })

    print("RESPONSE:", response.Body)

    local data = HttpService:JSONDecode(response.Body)
    
    if data and data.data and data.data[1] and data.data[1].imageUrl then
        return data.data[1].imageUrl
    end

    return nil
end

local function logChildren(parent, indent)
    indent = indent or ""  
    for _, child in pairs(parent:GetChildren()) do
        print(indent .. child.Name .. " (Type: " .. child.ClassName .. ")")
        if #child:GetChildren() > 0 then
            logChildren(child, indent .. "  ")  
        end
    end
end

function getEggCount()
    local player = game:GetService("Players").LocalPlayer
    local eggCount = player:WaitForChild("leaderstats"):WaitForChild("🥚 Hatches").Value
    return tonumber(eggCount)
end

function getBubbleCount()
    local player = game:GetService("Players").LocalPlayer
    local bubbleCount = player:WaitForChild("leaderstats"):WaitForChild("🟣 Bubbles").Value
    return tonumber(bubbleCount)
end

createCheckbox("Hatch Webhook", false, function()
    task.spawn(function()
        local player = game:GetService("Players").LocalPlayer
        local lastHatching = player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("Hatching"):WaitForChild("Last")
        local newHatch = true;
        
        local function trackSlot(slot)
            local function markAsNew()
                newHatch = true
            end
        
            slot:GetPropertyChangedSignal("Name"):Connect(markAsNew)
        
            local chance = slot:FindFirstChild("Chance")
            if chance and chance:IsA("TextLabel") then
                chance:GetPropertyChangedSignal("ContentText"):Connect(markAsNew)
            end
        end

        for _, child in ipairs(lastHatching:GetChildren()) do
            if child:IsA("GuiObject") then
                trackSlot(child)
            end
        end
        
        lastHatching.ChildAdded:Connect(function(child)
            if child:IsA("GuiObject") then
                trackSlot(child)
                newHatch = true
            end
        end)
        
        local rarityThreshold = 5 --0.001
        local webhook = "https://discord.com/api/webhooks/1362564811380228306/WrVSHzYpAvk0ufBaaMak0SLRuhuojXehNBuGJMRYAQFav6ksx6CJQwU6urHI2zbTuxRn"

        while taskStates["Hatch Webhook"] do
            if newHatch then
                for _, hatch in pairs(lastHatching:GetChildren()) do
                    if hatch:IsA("GuiObject") and hatch.Name ~= "Title" then
                        local hatchRarity = hatch:FindFirstChild("Chance").ContentText
                        local raw = hatchRarity:gsub("%%", "")
                        local numberRarity = tonumber(raw)
                        if numberRarity <= rarityThreshold then
                            print("Number Rarity:", numberRarity)
                            print("Rare Pet Dropped: " .. hatch.Name .. " (" .. hatchRarity .. ")")
                            local assetID = hatch:FindFirstChild("Icon"):FindFirstChild("Label").Image:split("rbxassetid://")[2]

                            local eggCount = getEggCount()
                            local bubbleCount = getBubbleCount()
                            local textColor = hatch:FindFirstChild("Label").TextColor3
                            local r = math.floor(textColor.R * 255)
                            local g = math.floor(textColor.G * 255)
                            local b = math.floor(textColor.B * 255)
                            local hexColor = r * 256^2 + g * 256 + b
                        
                            sendWebHook(webhook, nil, createPetHatchEmbed(hatch.Name, hatchRarity, getAssetUrl(assetID), bubbleCount, eggCount, hexColor))
                        end
                    end
                end
                newHatch = false
            end
            task.wait(0.1)
        end
    end)
end) 

createCheckbox("Use Tickets", false, function()
    task.spawn(function()
        while taskStates["Use Tickets"] do

            local args = {
                [1] = "WheelSpin";
            }

            game:GetService("ReplicatedStorage"):WaitForChild("Shared", 9e9):WaitForChild("Framework", 9e9):WaitForChild("Network", 9e9):WaitForChild("Remote", 9e9):WaitForChild("Function", 9e9):InvokeServer(unpack(args))

            local args = {
                [1] = "ClaimWheelSpinQueue";
            }

            game:GetService("ReplicatedStorage"):WaitForChild("Shared", 9e9):WaitForChild("Framework", 9e9):WaitForChild("Network", 9e9):WaitForChild("Remote", 9e9):WaitForChild("Event", 9e9):FireServer(unpack(args))
            
            task.wait(0.1)
        end
    end)
    end,
    "Use Tickets <Only Enable if in zone and disable afterwards otherwise bugs out>"
)

createCheckbox("Myster Gift", false, function()
    task.spawn(function()
        while taskStates["Myster Gift"] do
            openGifts(10)

            task.wait(0.1)
        end
    end)
end, "Mystery Gift x10")

createCheckbox("Auto Collect Coints", false, function()
    task.spawn(function()
        while taskStates["Auto Collect Coints"] do
            local renderedStorage = Workspace:WaitForChild("Rendered")

            for _, folder in pairs(renderedStorage:getChildren()) do
                if folder.Name == "Chunker" then
                    for _, chunker in pairs(folder:getChildren()) do
                        if (chunker:IsA("Model")) and chunker.Name:match("%x%-") then
                            local args = {
                                [1] = chunker.Name
                            }
                        
                            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Pickups"):WaitForChild("CollectPickup"):FireServer(unpack(args))
                            chunker:Destroy()
                        end
                    end
                end
            end

            task.wait(0.1)
        end
    end)
end)

local genieOldPos
local isOpenGenie = false
createCheckbox("Open Genie Menu", false, function()
    taskStates["Open Genie Menu"] = false
    local genieRoot = workspace:WaitForChild("Worlds"):WaitForChild("The Overworld"):WaitForChild("Islands"):WaitForChild("Zen"):WaitForChild("Island"):WaitForChild("GemGenie"):WaitForChild("Root")

    if isOpenGenie then
        genieRoot.CFrame = genieOldPos
        isOpenGenie = false
        local ref = buttonMap["Open Genie Menu"]
        if ref then
            ref.checkmark.Visible = false
        end
        return
    end

    local player =game.Players.localPlayer
    local name = player.Name

    local cframePos = workspace:WaitForChild(name):WaitForChild("HumanoidRootPart").CFrame

    genieOldPos = genieRoot.CFrame

    genieRoot.CFrame = cframePos
    isOpenGenie = true
end)


local enchanterOldPos
local isOpenEnchanter = false
createCheckbox("Open enchanter", false, function()
    taskStates["Open enchanter"] = false
    local enchanterRoot = workspace:WaitForChild("Worlds"):WaitForChild("The Overworld"):WaitForChild("Islands"):WaitForChild("The Void"):WaitForChild("Island"):WaitForChild("EnchanterActivation"):WaitForChild("Root")

    if isOpenEnchanter then
        enchanterRoot.CFrame = enchanterOldPos
        isOpenEnchanter = false
        local ref = buttonMap["Open enchanter"]
        if ref then
            ref.checkmark.Visible = false
        end
        return
    end 

    local player =game.Players.localPlayer
    local name = player.Name

    local cframePos = workspace:WaitForChild(name):WaitForChild("HumanoidRootPart").CFrame

    enchanterOldPos = enchanterRoot.CFrame

    enchanterRoot.CFrame = cframePos
    isOpenEnchanter = true
end)

local blackmarkedOldPos
local isOpenBlack = false
createCheckbox("Open Blackmarked", false, function()
    taskStates["Open Blackmarked"] = false
    local blackmarkedRoot = workspace:WaitForChild("Worlds"):WaitForChild("The Overworld"):WaitForChild("Islands"):WaitForChild("The Void"):WaitForChild("Island"):WaitForChild("Vendor"):WaitForChild("Activation"):WaitForChild("Root")

    if isOpenBlack then
        blackmarkedRoot.CFrame = blackmarkedOldPos
        isOpenBlack = false
        local ref = buttonMap["Open Blackmarked"]
        if ref then
            ref.checkmark.Visible = false
        end
        return
    end 
    
    local player =game.Players.localPlayer
    local name = player.Name

    local cframePos = workspace:WaitForChild(name):WaitForChild("HumanoidRootPart").CFrame

    blackmarkedOldPos = blackmarkedRoot.CFrame

    blackmarkedRoot.CFrame = cframePos
    isOpenBlack = true
end)



-- Rift UI Section
local riftSectionLabel = Instance.new("TextLabel")
riftSectionLabel.Size = UDim2.new(1, -10, 0, 25)
riftSectionLabel.Text = "Rifts:"
riftSectionLabel.TextColor3 = Color3.new(1, 1, 1)
riftSectionLabel.Font = Enum.Font.SourceSansBold
riftSectionLabel.TextSize = 20
riftSectionLabel.BackgroundTransparency = 1
riftSectionLabel.Parent = scrollingFrame


createCheckbox("Auto Hatch Rifts", true, function()
end)

local riftsFolder = workspace.Rendered:WaitForChild("Rifts")


local function getLuckMultiplier(rift)

    
    local display = rift:FindFirstChild("Display")
    if not display then return nil end

    local surfaceGui = display:FindFirstChild("SurfaceGui")
    if not surfaceGui then return nil end

    local icon = surfaceGui:FindFirstChild("Icon")
    if not icon then return nil end

    local luck = icon:FindFirstChild("Luck")
    if luck and luck:IsA("TextLabel") then
        return luck.Text
    end

    return nil
end

local function getNearestIsland(position)
    local islandsFolder = workspace:WaitForChild("Worlds"):WaitForChild("The Overworld"):WaitForChild("Islands")
    local nearestIsland

    for _, island in pairs(islandsFolder:GetChildren()) do
        local islandStats = island:WaitForChild("Island")
        local islandPivot = islandStats:GetPivot()
        local islandPosition = islandPivot.Position
        local distance = (position - islandPosition).Magnitude

        if not nearestIsland or distance < (position - nearestIsland:WaitForChild("Island"):GetPivot().Position).Magnitude then
            nearestIsland = island
        end

        print("Island:", island.Name, "Distance:", distance, "Valid:", position.Y > islandPosition.Y)
    end

    return nearestIsland
end

local function teleportToIsland(island)
    local args = {
        [1] = "Teleport";
        [2] = "Workspace.Worlds.The Overworld.Islands." .. island.Name .. ".Island.Portal.Spawn";
    }

    game:GetService("ReplicatedStorage"):WaitForChild("Shared", 9e9):WaitForChild("Framework", 9e9):WaitForChild("Network", 9e9):WaitForChild("Remote", 9e9):WaitForChild("Event", 9e9):FireServer(unpack(args))
end

local function setJumpPower(power)
    local player = game.Players.LocalPlayer
    local humanoid = workspace:WaitForChild(player.Name).Humanoid
    humanoid.JumpPower = power
    humanoid.JumpHeight = power
end

function getNearestEggName(position) 
    local renderedStorage = Workspace:WaitForChild("Rendered")
    local nearestEgg

    for _, folder in pairs(renderedStorage:getChildren()) do
        if folder.Name == "Chunker" then
            for _, chunker in pairs(folder:getChildren()) do
                if (chunker:IsA("Model")) then
                    local chunkerPos = chunker:GetPivot().Position
                    local distance = (position - chunkerPos).Magnitude
                    if not nearestEgg or distance < (position - nearestEgg:GetPivot().Position).Magnitude then
                        nearestEgg = chunker
                    end
                end
            end
        end
    end

    return nearestEgg.Name
end

function hatchEgg(rift)
    task.spawn(function()
        while taskStates["Auto Hatch Rifts"] and taskStates["Rift: " .. rift:GetPivot().Position.Y] do
            local nearestEgg = getNearestEggName(rift:GetPivot().Position)
            print("Hatching Egg:", nearestEgg)
            local args = {
                [1] = "HatchEgg";
                [2] = nearestEgg;
                [3] = 6;
            }

            game:GetService("ReplicatedStorage"):WaitForChild("Shared", 9e9):WaitForChild("Framework", 9e9):WaitForChild("Network", 9e9):WaitForChild("Remote", 9e9):WaitForChild("Event", 9e9):FireServer(unpack(args))

            task.wait(0.3)
        end
    end)
end


function moveToPos(rift)
    local targetPos = rift:GetPivot().Position + Vector3.new(0, 10, 0)
    local root = game.Players.LocalPlayer.Character.HumanoidRootPart
    local playerPos = root.Position
    
    local models = workspace:WaitForChild("Stages"):FindFirstChild("Model")
    if not models then
        print("Model not found")
        return
    end

    local part = models:FindFirstChild("Part")
    if not part then
        print("Part not found")
        return
    end

    part.Position = root.Position - Vector3.new(0, 3, 0)
    local moveSpeedPoggers = 6
    local updateTime = 1
    local moveSpeed = moveSpeedPoggers
    local finishedMove = false
    local riftHeight = rift:GetPivot().Position.Y
    local toTarget1 = targetPos - part.Position
    local distance1 = toTarget1.Magnitude
    if (distance1 < 1500) then
        moveSpeed = moveSpeedPoggers / 1.5
    end
    if (distance1 < 1000) then
        moveSpeed = moveSpeedPoggers / 2
    end
    if (distance1 < 500) then
        moveSpeed = moveSpeedPoggers / 3
    end
    if (distance1 < 100) then
        moveSpeed = moveSpeedPoggers / 5
    end
    task.spawn(function()
        local slowedDown = false
        print("Moving to Rift:", rift.Name .. " at height:", riftHeight)
        while taskStates["Rift: " .. riftHeight] do
            local toTarget = targetPos - part.Position
            local distance = toTarget.Magnitude

            if distance < 300 and not slowedDown then
                slowedDown = true
                moveSpeed = 2
            end
            if distance - moveSpeed <= 0 then
                finishedMove = true
            end

            local direction = toTarget.Unit
            local moveDelta = moveSpeed * direction

            print("Moving up, distance remaining:", distance)
            part.Position = part.Position + moveDelta * updateTime
            root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
            task.wait(0.01)
            if finishedMove then
                print("Finished moving to Rift:", rift.Name)
                moveSpeed = moveSpeedPoggers
                task.wait(3)
                part.Position = Vector3.new(0, 0, 0)
                if taskStates["Auto Hatch Rifts"] then
                    hatchEgg(rift)
                    print("Hatching Rift:", rift.Name)
                end
                break
            end
        end
    end)
end

local function moveToRift(rift)
    local pivot = rift:GetPivot()
    local player = game.Players.LocalPlayer.Character.HumanoidRootPart
    
    print("Moving to Rift:", rift.Name, "Position:", pivot.Position)
    local nearestIsland = getNearestIsland(pivot.Position)
    teleportToIsland(nearestIsland)
    task.wait(2)
    moveToPos(rift)

end

function getRiftTimer(rift)
    local timer = rift:WaitForChild("Display"):WaitForChild("SurfaceGui"):WaitForChild("Timer").ContentText
    return timer
end

function riftTimer(rift) 
    local height = rift:GetPivot().Position.Y
    local multiplier = getLuckMultiplier(rift)
    task.spawn(function()
        local baseName = "Rift: " .. rift.Name
        if multiplier then
            baseName = baseName .. " " .. multiplier
        end
        print("Starting timer for", baseName)
        while buttonMap["Rift: " .. height] do
            local timer = getRiftTimer(rift)
            buttonMap["Rift: " .. height].label.Text = baseName .. "    -   [" .. timer .. "]" 
            task.wait(1)
        end
    end)
end

if (isScriptEnabled) then
    for _, rift in pairs(riftsFolder:GetChildren()) do
        if rift:IsA("Model") then
            local height = rift:GetPivot().Position.Y

            local multiplier = getLuckMultiplier(rift)
            local displayName = "Rift: " .. rift.Name
            if multiplier then
                displayName = displayName .. " " .. multiplier
            end
            createCheckbox("Rift: " .. height, false, function()
                moveToRift(rift)
            end, displayName)
            riftTimer(rift)
            if multiplier then
                print("Rift:", rift.Name, "Luck Multiplier:", multiplier, "Height", height)
            else
                print("Rift:", rift.Name, "has no luck multiplier.", "Height", height)
            end
        end
    end

    riftsFolder.ChildAdded:Connect(function(child)
        if child:IsA("Model") then

            local rift = child
            local height = rift:GetPivot().Position.Y

            local multiplier = getLuckMultiplier(rift)
            local displayName = "Rift: " .. rift.Name
            if multiplier then
                displayName = displayName .. " " .. multiplier
            end
            createCheckbox("Rift: " .. height, false, function()
                moveToRift(rift)
            end, displayName) 
            riftTimer(rift)
            if multiplier then
                print("NEW: Rift:", rift.Name, "Luck Multiplier:", multiplier)
            else
                print("NEW: Rift:", rift.Name, "has no luck multiplier.")
            end
        end
    end)

    riftsFolder.ChildRemoved:Connect(function(child)
        if child:IsA("Model") then
            local rift = child
            local height = rift:GetPivot().Position.Y
            removeCheckbox("Rift: " .. height)
            print("Rift removed: " .. rift.Name)
        end
    end)
end